unit YTTrans.MadExcept;

interface

procedure ConfigureMadExceptForApplication;

implementation

uses
  System.SysUtils,
  madExcept,
  maxLogic.MadExcept;

const
  cBugReportEndpoint = 'https://maxlogic.eu/bugreport_mailer/bugreport_mailer.php';
  cBugReportCustomer = 'maxlogic';

var
  glSettings: IMEModuleSettings;

procedure ConfigureMadExceptForApplication;
begin
  glSettings := MESettings(0);
  maxLogic.MadExcept.AdjustMadExcept(
    IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))));
  maxLogic.MadExcept.SetUpWebUpload(cBugReportEndpoint, cBugReportCustomer);

  glSettings.GeneralShowSetting := ssNothing;
  glSettings.Filter1ShowSetting := ssNothing;
  glSettings.Filter2ShowSetting := ssNothing;
  glSettings.ShowPleaseWaitBox := False;
  glSettings.AutoClipboard := False;
  glSettings.MailViaMapi := False;
  glSettings.MailViaMailto := False;
  glSettings.MailAsSmtpServer := False;
  glSettings.MailAsSmtpClient := False;
  glSettings.UploadToCustomScript := True;
  glSettings.HttpServer := cBugReportEndpoint;
  glSettings.HttpSsl := True;
  glSettings.HttpPort := 0;
  glSettings.AdditionalFields['BugReportField'] := 'bugreport';
  glSettings.AdditionalFields['customerIdentifier'] := cBugReportCustomer;
  glSettings.SendInBackground := True;
  glSettings.AutoSend := True;
end;

end.
