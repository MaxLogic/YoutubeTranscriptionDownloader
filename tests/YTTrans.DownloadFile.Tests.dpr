program YTTransDownloadFileTests;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListModules,
  madListProcesses,
  System.SysUtils,
  DUnitX.Loggers.Console,
  DUnitX.TestFramework,
  MaxLogic.MadExcept.AiRunner in '..\..\MaxLogicFoundation\MaxLogic.MadExcept.AiRunner.pas',
  YTTrans.MadExcept.Tests in 'YTTrans.MadExcept.Tests.pas',
  YTTrans.ProcessRunner.Tests in 'YTTrans.ProcessRunner.Tests.pas',
  YTTrans.Gui.Downloads.Tests in 'YTTrans.Gui.Downloads.Tests.pas',
  YTTrans.DownloadFile.Tests in 'YTTrans.DownloadFile.Tests.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
begin
  MaxLogic.MadExcept.AiRunner.ConfigureMadExceptForAiRunner;
  if (ParamCount = 1) and SameText(ParamStr(1),
    '--madexcept-crash-fixture') then
    raise EAccessViolation.Create('YTTrans madExcept crash fixture');
  try
    TDUnitX.CheckCommandLine;
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;
    Runner.FailsOnNoAsserts := True;
    Runner.AddLogger(TDUnitXConsoleLogger.Create(True));
    Results := Runner.Execute;
    if not Results.AllPassed then
      ExitCode := 1;
  except
    on E: Exception do
    begin
      Writeln(E.ClassName, ': ', E.Message);
      ExitCode := 2;
    end;
  end;
end.
