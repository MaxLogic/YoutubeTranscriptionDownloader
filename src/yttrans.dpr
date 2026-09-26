program YouTrans;

{$APPTYPE CONSOLE}
{$STRONGLINKTYPES ON}

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListModules,
  madListProcesses,
  System.SysUtils,
  {$IF DEFINED(madExcept) AND DEFINED(DEBUG)}
  MaxLogic.MadExcept.AiRunner in '..\..\MaxLogicFoundation\MaxLogic.MadExcept.AiRunner.pas',
  {$IFEND}
  maxLogic.MadExcept in '..\..\MaxLogicFoundation\maxLogic.MadExcept.pas',
  YTTrans.MadExcept in 'YTTrans.MadExcept.pas',
  YTTransApp in 'YTTransApp.pas';


begin
  YTTrans.MadExcept.ConfigureMadExceptForApplication;
  {$IF DEFINED(madExcept) AND DEFINED(DEBUG)}
  MaxLogic.MadExcept.AiRunner.ConfigureFromEnvironment;
  {$IFEND}
  ExitCode := YTTransApp.Run;
end.
