unit YTTrans.Gui.Downloads;

// Non-visual part of yttransgui (YTD-039): download items, pure helpers and
// the worker thread that runs one yttrans.exe child per item. No VCL here.

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections;

const
  CSessionFolderPrefix = 'yttransgui-';

type
  TDownloadStatus = (dsQueued, dsDownloading, dsDone, dsFailed);

  TDownloadItem = class
  public
    Url, TranscriptPath, Title, Output: string; // Output: yttrans text of a failed attempt
    Status: TDownloadStatus;
  end;

  // Runs one yttrans.exe child. Fields are set before Start; results are read
  // in OnTerminate (main thread). Item is only touched by the main thread.
  TDownloadThread = class(TThread)
  protected
    procedure Execute; override;
  public
    ExePath, Arguments: string;
    Job: THandle;
    Item: TDownloadItem;
    ExitCode: Integer;
    StdOut, StdErr, StartError: string;
    constructor Create;
  end;

// Trim, strip one surrounding pair of double quotes, Trim.
function NormalizeUrlInput(const aText: string): string;
// "<url>" -o "<file>" -meta; a double quote inside the URL becomes %22.
function BuildYtTransArguments(const aUrl, aOutputFile: string): string;
function DownloadDisplayText(const aItem: TDownloadItem): string;
// Trimmed stdout and stderr on separate lines, empty parts skipped.
function FailureOutput(aExitCode: Integer; const aStdOut, aStdErr: string): string;
// Case-sensitive: YouTube video IDs are case-sensitive.
function IndexOfUrl(const aItems: TObjectList<TDownloadItem>; const aUrl: string): Integer;
// A job whose processes are killed when its last handle closes; 0 on failure.
function CreateKillOnCloseJob: THandle;
// True when aDir is a direct child of aTempPath named yttransgui-*.
function IsSessionFolder(const aDir, aTempPath: string): Boolean;
// Deletes aDir only when IsSessionFolder holds for the user temp path and aDir
// is not a reparse point; deletes its plain top-level files only and never
// follows links. One retry after 200 ms; errors are ignored.
procedure DeleteSessionFolder(const aDir: string);

implementation

uses
  Winapi.Windows, System.IOUtils, System.StrUtils, YTTrans.ProcessRunner;

function NormalizeUrlInput(const aText: string): string;
begin
  Result := Trim(aText);
  if (Length(Result) >= 2) and (Result[1] = '"') and
    (Result[Length(Result)] = '"') then
    Result := Trim(Copy(Result, 2, Length(Result) - 2));
end;

function BuildYtTransArguments(const aUrl, aOutputFile: string): string;
begin
  Result := '"' + StringReplace(aUrl, '"', '%22', [rfReplaceAll]) + '" -o "' +
    aOutputFile + '" -meta';
end;

function DownloadDisplayText(const aItem: TDownloadItem): string;
begin
  case aItem.Status of
    dsQueued: Result := '[queued] ' + aItem.Url;
    dsDownloading: Result := '[downloading] ' + aItem.Url;
    dsDone:
      if aItem.Title <> '' then
        Result := '[done] ' + aItem.Title
      else
        Result := '[done] ' + aItem.Url;
  else
    Result := '[failed] ' + aItem.Url;
  end;
end;

function FailureOutput(aExitCode: Integer; const aStdOut, aStdErr: string): string;
var
  lOut, lErr: string;
begin
  lOut := Trim(aStdOut);
  lErr := Trim(aStdErr);
  if (lOut <> '') and (lErr <> '') then
    Result := lOut + sLineBreak + lErr
  else if lOut <> '' then
    Result := lOut
  else if lErr <> '' then
    Result := lErr
  else
    Result := Format('yttrans exited with code %d without output.', [aExitCode]);
end;

function IndexOfUrl(const aItems: TObjectList<TDownloadItem>; const aUrl: string): Integer;
begin
  for Result := 0 to aItems.Count - 1 do
    if SameStr(aItems[Result].Url, aUrl) then
      Exit;
  Result := -1;
end;

function CreateKillOnCloseJob: THandle;
var
  lInfo: TJobObjectExtendedLimitInformation;
begin
  Result := CreateJobObject(nil, nil);
  if Result = 0 then
    Exit;
  lInfo := Default(TJobObjectExtendedLimitInformation);
  lInfo.BasicLimitInformation.LimitFlags := JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
  if not SetInformationJobObject(Result, JobObjectExtendedLimitInformation,
    @lInfo, SizeOf(lInfo)) then
  begin
    CloseHandle(Result);
    Result := 0;
  end;
end;

function IsSessionFolder(const aDir, aTempPath: string): Boolean;
var
  lDir: string;
begin
  lDir := ExcludeTrailingPathDelimiter(aDir);
  Result := (aTempPath <> '') and
    StartsText(CSessionFolderPrefix, ExtractFileName(lDir)) and
    (Length(ExtractFileName(lDir)) > Length(CSessionFolderPrefix)) and
    SameText(ExtractFileDir(lDir), ExcludeTrailingPathDelimiter(aTempPath));
end;

// Deletes the plain top-level files of aDir, then aDir itself. Never follows
// a reparse point: a linked aDir is refused, linked or nested entries are
// left, so RemoveDir then fails and the folder stays.
function TryDeleteFlatFolder(const aDir: string): Boolean;
var
  lAttr: DWORD;
  lFind: TWin32FindData;
  lHandle: THandle;
  lName: string;
begin
  lAttr := GetFileAttributes(PChar(aDir));
  if (lAttr = INVALID_FILE_ATTRIBUTES) or
    (lAttr and FILE_ATTRIBUTE_DIRECTORY = 0) or
    (lAttr and FILE_ATTRIBUTE_REPARSE_POINT <> 0) then
    Exit(False);
  lHandle := FindFirstFile(PChar(TPath.Combine(aDir, '*')), lFind);
  if lHandle <> INVALID_HANDLE_VALUE then
    try
      repeat
        lName := lFind.cFileName;
        if (lFind.dwFileAttributes and (FILE_ATTRIBUTE_DIRECTORY or
          FILE_ATTRIBUTE_REPARSE_POINT)) = 0 then
          Winapi.Windows.DeleteFile(PChar(TPath.Combine(aDir, lName)));
      until not FindNextFile(lHandle, lFind);
    finally
      Winapi.Windows.FindClose(lHandle);
    end;
  Result := RemoveDirectory(PChar(aDir));
end;

procedure DeleteSessionFolder(const aDir: string);
begin
  if not IsSessionFolder(aDir, TPath.GetTempPath) then
    Exit;
  if not TryDeleteFlatFolder(aDir) then
  begin
    Sleep(200);
    TryDeleteFlatFolder(aDir); // a child that could not be killed may hold a file
  end;
end;

{ TDownloadThread }

constructor TDownloadThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
end;

procedure TDownloadThread.Execute;
begin
  try
    if not FileExists(ExePath) then
      StartError := 'yttrans.exe not found: ' + ExePath
    else
      ExitCode := RunConsoleProcess(ExePath, Arguments, StdOut, StdErr, Job);
  except
    on E: Exception do
      StartError := E.Message;
  end;
end;

end.
