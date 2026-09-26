unit YTTrans.ProcessRunner;

// Local console launcher for yt-dlp. MaxLogic.ioutils.ExecuteFile splits the
// command at the first space (breaks install paths with spaces, T-028) and
// its runner closes the read pipes before the readers drain them (T-029).

interface

const
  // After the process exits, readers get this long to reach end of pipe.
  CPipeGraceMs = 5000;
  CPipeHeldNote =
    '[yttrans] output pipe still held by a child process after exit; stopped reading';

// Runs aExePath with aArguments (already quoted), hidden, in the exe's folder,
// and waits for it. Returns the exit code and the stdout/stderr text, read until
// the child closes both pipes and decoded with the ANSI code page. When a
// grandchild still holds a pipe CPipeGraceMs after the exit, reading stops and
// CPipeHeldNote is appended to aStdErr.
// Raises EOSError when the process cannot be started; no handles leak.
function RunConsoleProcess(const aExePath, aArguments: string;
  out aStdOut, aStdErr: string): Integer;

implementation

uses
  Winapi.Windows, System.SysUtils, System.Classes;

const
  // not declared in Winapi.Windows (Delphi 12)
  PROC_THREAD_ATTRIBUTE_HANDLE_LIST = $00020002;

type
  TStartupInfoExW = record
    StartupInfo: TStartupInfoW;
    lpAttributeList: PProcThreadAttributeList;
  end;

  // Owns the pipe read end and closes it when reading ends, so a failed
  // reader turns into a broken pipe for the child instead of a full pipe.
  TPipeReader = class(TThread)
  private
    FHandle: THandle;
    FData: TBytesStream;
  protected
    procedure Execute; override;
  public
    constructor Create(const aReadHandle: THandle);
    destructor Destroy; override;
    // Stops reading and waits for the thread; cancels a blocked ReadFile.
    procedure StopReading;
    procedure RaiseIfFailed(const aStreamName: string);
    function Text: string;
  end;

constructor TPipeReader.Create(const aReadHandle: THandle);
begin
  FHandle := aReadHandle;
  FData := TBytesStream.Create;
  inherited Create(True);
  FreeOnTerminate := False;
end;

destructor TPipeReader.Destroy;
begin
  inherited; // terminates and waits; a never-started reader exits at once
  if FHandle <> 0 then
    CloseHandle(FHandle);
  FData.Free;
end;

procedure TPipeReader.Execute;
var
  lBuffer: array[0..65535] of Byte;
  lRead: DWORD;
begin
  try
    // ends at ERROR_BROKEN_PIPE (all write ends closed) or on cancellation
    while (not Terminated) and
      ReadFile(FHandle, lBuffer, SizeOf(lBuffer), lRead, nil) do
      if lRead > 0 then
        FData.WriteBuffer(lBuffer, lRead);
  finally
    CloseHandle(FHandle);
    FHandle := 0;
  end;
end;

procedure TPipeReader.StopReading;
begin
  Terminate;
  while WaitForSingleObject(Handle, 50) = WAIT_TIMEOUT do
    CancelSynchronousIo(Handle);
end;

procedure TPipeReader.RaiseIfFailed(const aStreamName: string);
begin
  if FatalException is Exception then
    raise Exception.CreateFmt('Reading the child %s failed: %s',
      [aStreamName, Exception(FatalException).Message])
  else if Assigned(FatalException) then
    raise Exception.CreateFmt('Reading the child %s failed', [aStreamName]);
end;

function TPipeReader.Text: string;
begin
  Result := TEncoding.ANSI.GetString(FData.Bytes, 0, FData.Size);
end;

procedure CloseAndZero(var aHandle: THandle);
begin
  if aHandle <> 0 then
  begin
    CloseHandle(aHandle);
    aHandle := 0;
  end;
end;

procedure CreateChildPipe(const aSecurity: TSecurityAttributes;
  out aRead, aWrite: THandle);
begin
  aRead := 0;
  aWrite := 0;
  if not CreatePipe(aRead, aWrite, @aSecurity, 0) then
    RaiseLastOSError;
  // only the child's write end may be inherited
  if not SetHandleInformation(aRead, HANDLE_FLAG_INHERIT, 0) then
    RaiseLastOSError;
end;

function RunConsoleProcess(const aExePath, aArguments: string;
  out aStdOut, aStdErr: string): Integer;
var
  lSecurity: TSecurityAttributes;
  lOutRead, lOutWrite, lErrRead, lErrWrite, lNul, lProcess: THandle;
  lStartup: TStartupInfoExW;
  lInheritList: array[0..2] of THandle;
  lAttributes: PProcThreadAttributeList;
  lAttributesSize: NativeUInt;
  lInfo: TProcessInformation;
  lCmd, lWorkDir: string;
  lOutReader, lErrReader: TPipeReader;
  lReaders: array[0..1] of THandle;
  lPipeHeld: Boolean;
  lExitCode: DWORD;
begin
  aStdOut := '';
  aStdErr := '';
  lOutRead := 0;
  lOutWrite := 0;
  lErrRead := 0;
  lErrWrite := 0;
  lNul := 0;
  lProcess := 0;
  lOutReader := nil;
  lErrReader := nil;
  lSecurity := Default(TSecurityAttributes);
  lSecurity.nLength := SizeOf(lSecurity);
  lSecurity.bInheritHandle := True;
  try
    CreateChildPipe(lSecurity, lOutRead, lOutWrite);
    CreateChildPipe(lSecurity, lErrRead, lErrWrite);
    lNul := CreateFile('NUL', GENERIC_READ, FILE_SHARE_READ or FILE_SHARE_WRITE,
      @lSecurity, OPEN_EXISTING, 0, 0);
    if lNul = INVALID_HANDLE_VALUE then
    begin
      lNul := 0;
      RaiseLastOSError;
    end;

    lStartup := Default(TStartupInfoExW);
    lStartup.StartupInfo.cb := SizeOf(lStartup);
    lStartup.StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    lStartup.StartupInfo.wShowWindow := SW_HIDE;
    lStartup.StartupInfo.hStdInput := lNul;
    lStartup.StartupInfo.hStdOutput := lOutWrite;
    lStartup.StartupInfo.hStdError := lErrWrite;

    lCmd := '"' + aExePath + '"';
    if aArguments <> '' then
      lCmd := lCmd + ' ' + aArguments;
    UniqueString(lCmd);
    lWorkDir := ExtractFileDir(aExePath);
    lInfo := Default(TProcessInformation);

    // Inherit only the three std handles, never other inheritable handles of
    // yttrans (e.g. the stdout/stderr pipe of a monitoring script), which a
    // lingering grandchild would otherwise keep open.
    lInheritList[0] := lNul;
    lInheritList[1] := lOutWrite;
    lInheritList[2] := lErrWrite;
    lAttributesSize := 0;
    InitializeProcThreadAttributeList(nil, 1, 0, lAttributesSize);
    GetMem(lAttributes, lAttributesSize);
    try
      if not InitializeProcThreadAttributeList(lAttributes, 1, 0,
        lAttributesSize) then
        RaiseLastOSError;
      try
        if not UpdateProcThreadAttribute(lAttributes, 0,
          PROC_THREAD_ATTRIBUTE_HANDLE_LIST, @lInheritList, SizeOf(lInheritList),
          nil, PNativeUInt(nil)^) then // lpReturnSize is reserved: NULL
          RaiseLastOSError;
        lStartup.lpAttributeList := lAttributes;
        if not CreateProcess(PChar(aExePath), PChar(lCmd), nil, nil, True,
          NORMAL_PRIORITY_CLASS or EXTENDED_STARTUPINFO_PRESENT, nil,
          Pointer(lWorkDir), lStartup.StartupInfo, lInfo) then
          RaiseLastOSError;
      finally
        DeleteProcThreadAttributeList(lAttributes);
      end;
    finally
      FreeMem(lAttributes);
    end;
    lProcess := lInfo.hProcess;
    CloseHandle(lInfo.hThread);

    // the child owns its copies now; ours would keep the pipes open forever
    CloseAndZero(lOutWrite);
    CloseAndZero(lErrWrite);
    CloseAndZero(lNul);

    lOutReader := TPipeReader.Create(lOutRead);
    lOutRead := 0;
    lErrReader := TPipeReader.Create(lErrRead);
    lErrRead := 0;
    lOutReader.Start;
    lErrReader.Start;
    try
      WaitForSingleObject(lProcess, INFINITE);
      // a grandchild (e.g. a JS runtime) may still hold the write ends
      lReaders[0] := lOutReader.Handle;
      lReaders[1] := lErrReader.Handle;
      lPipeHeld := WaitForMultipleObjects(Length(lReaders), @lReaders, True,
        CPipeGraceMs) = WAIT_TIMEOUT;
    finally
      lOutReader.StopReading;
      lErrReader.StopReading;
    end;
    lOutReader.RaiseIfFailed('stdout');
    lErrReader.RaiseIfFailed('stderr');

    if GetExitCodeProcess(lProcess, lExitCode) then
      Result := Integer(lExitCode)
    else
      Result := -1;
    aStdOut := lOutReader.Text;
    aStdErr := lErrReader.Text;
    if lPipeHeld then
      aStdErr := aStdErr + CPipeHeldNote + sLineBreak;
  finally
    lErrReader.Free;
    lOutReader.Free;
    CloseAndZero(lProcess);
    CloseAndZero(lNul);
    CloseAndZero(lErrWrite);
    CloseAndZero(lErrRead);
    CloseAndZero(lOutWrite);
    CloseAndZero(lOutRead);
  end;
end;

end.
