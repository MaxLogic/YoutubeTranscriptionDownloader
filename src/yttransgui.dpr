program yttransgui;

{$R *.res}

uses
  Vcl.Forms,
  YTTrans.FrontMatter in 'YTTrans.FrontMatter.pas',
  YTTrans.ProcessRunner in 'YTTrans.ProcessRunner.pas',
  YTTrans.Gui.Downloads in 'YTTrans.Gui.Downloads.pas',
  YTTrans.Gui.MainForm in 'YTTrans.Gui.MainForm.pas' {MainForm};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'yttrans GUI';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
