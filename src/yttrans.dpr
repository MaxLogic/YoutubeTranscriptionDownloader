program YouTrans;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  YTTransApp in 'YTTransApp.pas';


begin
  ExitCode := YTTransApp.Run;
end.