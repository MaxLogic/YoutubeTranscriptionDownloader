unit YTTrans.ProcessRunner.Tests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TYTTransProcessRunnerTests = class
  public
    // T-028
    [Test] procedure RunsExecutableFromPathWithSpaces;
    // T-028
    [Test] procedure FailedStartReleasesPipeHandles;
    // T-029
    [Test] procedure CapturesLargeStdoutAndTrailingStderr200Times;
    // a grandchild that outlives the child keeps the pipe write end open
    [Test] procedure ReturnsWhenGrandchildHoldsPipeAfterExit;
  end;

implementation

uses
  Winapi.Windows, System.SysUtils, System.IOUtils, System.Classes,
  System.Diagnostics,
  YTTrans.ProcessRunner;

function GetProcessHandleCount(hProcess: THandle;
  var pdwHandleCount: DWORD): BOOL; stdcall; external kernel32;

function SystemCmdExe: string;
var
  lDir: array[0..MAX_PATH] of Char;
begin
  GetSystemDirectory(lDir, MAX_PATH);
  Result := IncludeTrailingPathDelimiter(lDir) + 'cmd.exe';
end;

function CurrentHandleCount: Cardinal;
begin
  Result := 0;
  if not GetProcessHandleCount(GetCurrentProcess, Result) then
    RaiseLastOSError;
end;

procedure TYTTransProcessRunnerTests.RunsExecutableFromPathWithSpaces;
var
  lDir, lExe, lOut, lErr: string;
  lExitCode: Integer;
begin
  lDir := TPath.Combine(TPath.GetTempPath,
    'yttrans runner space ' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(lDir);
  try
    lExe := TPath.Combine(lDir, 'cmd.exe');
    TFile.Copy(SystemCmdExe, lExe);
    // %CMDCMDLINE% echoes the raw command line, so argv[0] must be quoted
    lExitCode := RunConsoleProcess(lExe, '/d /c echo %CMDCMDLINE%', lOut, lErr);
    Assert.AreEqual(0, lExitCode, 'exit code; stderr=' + lErr);
    Assert.AreEqual('"' + lExe + '" /d /c echo %CMDCMDLINE%', Trim(lOut));
  finally
    TDirectory.Delete(lDir, True);
  end;
end;

procedure TYTTransProcessRunnerTests.FailedStartReleasesPipeHandles;
const
  CRuns = 50;
var
  lMissing, lOut, lErr: string;
  lBefore, lAfter: Cardinal;
  lRaised, i: Integer;
begin
  lMissing := TPath.Combine(TPath.GetTempPath,
    'yttrans-missing-' + TGUID.NewGuid.ToString + '.exe');
  // warm-up: the first exception may allocate lazy, process-lifetime handles
  try
    RunConsoleProcess(lMissing, '--version', lOut, lErr);
  except
    on E: EOSError do
      ;
  end;
  lRaised := 0;
  lBefore := CurrentHandleCount;
  for i := 1 to CRuns do
    try
      RunConsoleProcess(lMissing, '--version', lOut, lErr);
    except
      on E: EOSError do
        Inc(lRaised);
    end;
  lAfter := CurrentHandleCount;
  Assert.AreEqual(CRuns, lRaised, 'every start must fail with EOSError');
  Assert.IsTrue(lAfter < lBefore + 10, Format(
    'handle count grew from %d to %d over %d failed starts',
    [lBefore, lAfter, CRuns]));
end;

procedure TYTTransProcessRunnerTests.CapturesLargeStdoutAndTrailingStderr200Times;
const
  CRuns = 200;
var
  lFile, lExpected, lOut, lErr, lFirstFailure: string;
  lBuilder: TStringBuilder;
  lExitCode, lFailures, i: Integer;
begin
  lBuilder := TStringBuilder.Create;
  try
    i := 0;
    while lBuilder.Length < 1200 * 1024 do
    begin
      lBuilder.AppendFormat('%.7d yttrans runner payload line abcdefghijklmnop'#13#10, [i]);
      Inc(i);
    end;
    lExpected := lBuilder.ToString;
  finally
    lBuilder.Free;
  end;

  lFile := TPath.Combine(TPath.GetTempPath,
    'yttrans-runner-payload-' + TGUID.NewGuid.ToString + '.txt');
  TFile.WriteAllText(lFile, lExpected, TEncoding.ASCII);
  try
    lFailures := 0;
    lFirstFailure := '';
    for i := 1 to CRuns do
    begin
      lExitCode := RunConsoleProcess(SystemCmdExe,
        Format('/d /s /c "type "%s" & 1>&2 echo END-OF-STDERR"', [lFile]),
        lOut, lErr);
      if (lExitCode <> 0) or (lOut <> lExpected) or
        (Trim(lErr) <> 'END-OF-STDERR') then
      begin
        Inc(lFailures);
        if lFirstFailure = '' then
          lFirstFailure := Format(
            'run %d: exit=%d stdout=%d/%d chars stderr="%s"',
            [i, lExitCode, Length(lOut), Length(lExpected), Trim(lErr)]);
      end;
    end;
    Assert.AreEqual(0, lFailures, Format('%d of %d runs lost output; first: %s',
      [lFailures, CRuns, lFirstFailure]));
  finally
    TFile.Delete(lFile);
  end;
end;

procedure TYTTransProcessRunnerTests.ReturnsWhenGrandchildHoldsPipeAfterExit;
var
  lOut, lErr: string;
  lExitCode: Integer;
  lWatch: TStopwatch;
  lSecurity: TSecurityAttributes;
  lCallerRead, lCallerWrite: THandle;
  lAvailable: DWORD;
  lWriterAlive: Boolean;
begin
  // An inheritable handle of the caller (like the monitoring log pipe of
  // yttrans itself) must not reach the child, or the lingering ping holds it.
  lSecurity := Default(TSecurityAttributes);
  lSecurity.nLength := SizeOf(lSecurity);
  lSecurity.bInheritHandle := True;
  if not CreatePipe(lCallerRead, lCallerWrite, @lSecurity, 0) then
    RaiseLastOSError;
  try
    // ping inherits the stderr pipe and runs ~14 s after cmd has exited
    lWatch := TStopwatch.StartNew;
    lExitCode := RunConsoleProcess(SystemCmdExe,
      '/d /s /c "start /b ping -n 15 127.0.0.1 >nul & echo done"', lOut, lErr);
    lWatch.Stop;
    CloseHandle(lCallerWrite);
    lCallerWrite := 0;
    // succeeds while any other process still holds the write end
    lWriterAlive := PeekNamedPipe(lCallerRead, nil, 0, nil, @lAvailable, nil);

    Assert.IsTrue(lWatch.ElapsedMilliseconds < 10000, Format(
      'returned after %d ms', [lWatch.ElapsedMilliseconds]));
    Assert.AreEqual(0, lExitCode);
    Assert.AreEqual('done', Trim(lOut));
    Assert.Contains(lErr, '[yttrans] output pipe still held by a child process');
    Assert.IsFalse(lWriterAlive,
      'the grandchild inherited an unrelated handle of the caller');
  finally
    if lCallerWrite <> 0 then
      CloseHandle(lCallerWrite);
    CloseHandle(lCallerRead);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TYTTransProcessRunnerTests);

end.
