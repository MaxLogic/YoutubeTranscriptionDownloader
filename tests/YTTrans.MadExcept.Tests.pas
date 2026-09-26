unit YTTrans.MadExcept.Tests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TYTTransMadExceptTests = class
  public
    [Test] procedure ApplicationUsesQueuedHttpsBugReportUpload;
  end;

implementation

uses
  System.SysUtils,
  madExcept,
  MaxLogic.MadExcept.AiRunner,
  YTTrans.MadExcept;

procedure TYTTransMadExceptTests.ApplicationUsesQueuedHttpsBugReportUpload;
var
  lSettings: IMEModuleSettings;
begin
  try
    ConfigureMadExceptForApplication;
    lSettings := MESettings(0);

    Assert.IsTrue(lSettings.IsValid, 'MESettings.IsValid');
    Assert.IsTrue(lSettings.AutoSave, 'AutoSave');
    Assert.AreEqual(Integer(ssNothing),
      Integer(lSettings.GeneralShowSetting), 'GeneralShowSetting');
    Assert.AreEqual(Integer(ssNothing),
      Integer(lSettings.Filter1ShowSetting), 'Filter1ShowSetting');
    Assert.AreEqual(Integer(ssNothing),
      Integer(lSettings.Filter2ShowSetting), 'Filter2ShowSetting');
    Assert.IsFalse(lSettings.ShowPleaseWaitBox, 'ShowPleaseWaitBox');
    Assert.IsFalse(lSettings.AutoClipboard, 'AutoClipboard');
    Assert.IsTrue(lSettings.UploadToCustomScript, 'UploadToCustomScript');
    Assert.IsTrue(lSettings.HttpSsl, 'HttpSsl');
    Assert.AreEqual(0, Integer(lSettings.HttpPort), 'HttpPort');
    Assert.AreEqual('https://maxlogic.eu/bugreport_mailer/bugreport_mailer.php',
      string(lSettings.HttpServer), 'HttpServer');
    Assert.AreEqual('maxlogic',
      string(lSettings.AdditionalFields['customerIdentifier']),
      'customerIdentifier');
    Assert.AreEqual('bugreport',
      string(lSettings.AdditionalFields['BugReportField']), 'BugReportField');
    Assert.IsFalse(lSettings.MailViaMapi, 'MailViaMapi');
    Assert.IsFalse(lSettings.MailViaMailto, 'MailViaMailto');
    Assert.IsFalse(lSettings.MailAsSmtpServer, 'MailAsSmtpServer');
    Assert.IsFalse(lSettings.MailAsSmtpClient, 'MailAsSmtpClient');
    Assert.IsTrue(lSettings.SendInBackground, 'SendInBackground');
    Assert.IsNotEmpty(string(lSettings.MailSubject), 'MailSubject');
    Assert.IsNotEmpty(string(lSettings.MailBody), 'MailBody');
    Assert.IsTrue(lSettings.AutoSend, 'AutoSend');
  finally
    MaxLogic.MadExcept.AiRunner.ConfigureMadExceptForAiRunner;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TYTTransMadExceptTests);

end.
