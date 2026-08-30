unit YTTrans.DownloadFile.Tests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TDownloadFileTests = class
  public
    [Test] procedure LoadsGroupedQueueAndResolvesInheritance;
    [Test] procedure RejectsUnknownFieldsWithYamlPath;
    [Test] procedure RejectsAliasesAndMultipleDocuments;
    [Test] procedure PreservesCommentsWhenRemovingSuccessfulVideo;
    [Test] procedure AppliesFreshFailedAndAllEligibility;
    [Test] procedure DetectsThrottlingAndDegradesWorkers;
    [Test] procedure DistinguishesChannelAndVideoSeedUrls;
    [Test] procedure CheckpointCreatesBackupAndReleasesLock;
    [Test] procedure CheckpointRejectsExternalEdits;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  YTTrans.DownloadFile,
  YTTrans.Throttle,
  YTTransApp;

procedure TDownloadFileTests.LoadsGroupedQueueAndResolvesInheritance;
const
  CYaml =
    'schema: 1' + sLineBreak +
    'mode: fresh' + sLineBreak +
    'defaults:' + sLineBreak +
    '  output_dir: output' + sLineBreak +
    '  jobs: 1' + sLineBreak +
    'groups:' + sLineBreak +
    '  - name: examples' + sLineBreak +
    '    subfolder: Writing' + sLineBreak +
    '    channels:' + sLineBreak +
    '      - url: https://www.youtube.com/@MaxLogicPawel' + sLineBreak +
    '    videos:' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=lRQae-tRw-k';
var
  Job: TDownloadFile;
  Entries: TArray<TDownloadEntry>;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    Entries := Job.Entries;
    Assert.AreEqual(2, Length(Entries));
    Assert.AreEqual('Writing', Entries[0].Options.Subfolder);
    Assert.AreEqual(1, Entries[1].Options.Jobs);
    Assert.AreEqual('F:\queue\output', Job.OutputRoot);
  finally
    Job.Free;
  end;
end;

procedure TDownloadFileTests.RejectsUnknownFieldsWithYamlPath;
begin
  Assert.WillRaiseWithMessage(
    procedure
    var
      Job: TDownloadFile;
    begin
      Job := TDownloadFile.LoadForTest(
        'schema: 1' + sLineBreak +
        'mode: fresh' + sLineBreak +
        'groups:' + sLineBreak +
        '  - videos:' + sLineBreak +
        '      - url: https://www.youtube.com/watch?v=lRQae-tRw-k' + sLineBreak +
        '        mystery: true',
        'F:\queue\download.yaml');
      Job.Free;
    end,
    EDownloadFileError,
    'Unknown field at groups[0].videos[0].mystery');
end;

procedure TDownloadFileTests.RejectsAliasesAndMultipleDocuments;
begin
  Assert.WillRaise(
    procedure
    var Job: TDownloadFile;
    begin
      Job := TDownloadFile.LoadForTest(
        'schema: 1' + sLineBreak + 'mode: fresh' + sLineBreak +
        'groups: &queue []' + sLineBreak,
        'F:\queue\download.yaml');
      Job.Free;
    end,
    EDownloadFileError);
  Assert.WillRaise(
    procedure
    var Job: TDownloadFile;
    begin
      Job := TDownloadFile.LoadForTest(
        'schema: 1' + sLineBreak + 'mode: fresh' + sLineBreak + 'groups: []' + sLineBreak +
        '---' + sLineBreak + 'schema: 1' + sLineBreak + 'mode: fresh' + sLineBreak + 'groups: []',
        'F:\queue\download.yaml');
      Job.Free;
    end,
    EDownloadFileError);
end;

procedure TDownloadFileTests.PreservesCommentsWhenRemovingSuccessfulVideo;
const
  CYaml =
    '# queue comment' + sLineBreak +
    'schema: 1' + sLineBreak +
    'mode: fresh # edit this mode' + sLineBreak +
    'groups:' + sLineBreak +
    '  - name: examples' + sLineBreak +
    '    videos:' + sLineBreak +
    '      # keep the second item' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=first000001' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=second00001';
var
  Job: TDownloadFile;
  Text: string;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    Job.RemoveStandaloneVideo(0, 0);
    Text := Job.ToYaml;
    Assert.IsTrue(Text.Contains('# queue comment'));
    Assert.IsTrue(Text.Contains('# edit this mode'));
    Assert.IsTrue(Text.Contains('# keep the second item'));
    Assert.IsFalse(Text.Contains('first000001'));
    Assert.IsTrue(Text.Contains('second00001'));
  finally
    Job.Free;
  end;
end;

procedure TDownloadFileTests.AppliesFreshFailedAndAllEligibility;
const
  CYaml =
    'schema: 1' + sLineBreak +
    'mode: fresh' + sLineBreak +
    'groups:' + sLineBreak +
    '  - videos:' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=new00000001' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=fail0000001' + sLineBreak +
    '        state:' + sLineBreak +
    '          status: failed';
var
  Job: TDownloadFile;
  Entries: TArray<TDownloadEntry>;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    Entries := Job.Entries;
    Assert.IsTrue(Job.IsEligible(Entries[0]));
    Assert.IsFalse(Job.IsEligible(Entries[1]));
    Job.Mode := dmFailed;
    Assert.IsFalse(Job.IsEligible(Entries[0]));
    Assert.IsTrue(Job.IsEligible(Entries[1]));
    Job.Mode := dmAll;
    Assert.IsTrue(Job.IsEligible(Entries[0]));
    Assert.IsTrue(Job.IsEligible(Entries[1]));
  finally
    Job.Free;
  end;
end;

procedure TDownloadFileTests.DetectsThrottlingAndDegradesWorkers;
var
  Controller: TThrottleController;
begin
  Assert.IsTrue(TThrottleController.IsThrottleMessage('HTTP Error 429: Too Many Requests'));
  Assert.IsFalse(TThrottleController.IsThrottleMessage('video unavailable'));
  Controller := TThrottleController.Create(8);
  try
    Assert.AreEqual(8, Controller.EffectiveWorkers);
    Controller.ReportResult(1, 'Sign in to confirm you are not a bot');
    Assert.AreEqual(1, Controller.EffectiveWorkers);
    Controller.ReportResult(1, 'HTTP Error 429');
    Controller.ReportResult(1, 'rate limit');
    Assert.IsTrue(Controller.IsTerminal);
    Controller.ReportResult(0, 'ok');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.DistinguishesChannelAndVideoSeedUrls;
begin
  Assert.IsTrue(IsYouTubeVideoUrl('https://www.youtube.com/watch?v=lRQae-tRw-k'));
  Assert.IsTrue(IsYouTubeVideoUrl('https://youtu.be/lRQae-tRw-k'));
  Assert.IsFalse(IsYouTubeVideoUrl('https://www.youtube.com/@MaxLogicPawel'));
  Assert.IsFalse(IsYouTubeVideoUrl('https://www.youtube.com/channel/UC123'));
end;

procedure TDownloadFileTests.CheckpointCreatesBackupAndReleasesLock;
var
  Dir, FileName: string;
  Job: TDownloadFile;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    FileName := TPath.Combine(Dir, 'download.yaml');
    TFile.WriteAllText(FileName,
      'schema: 1' + sLineBreak + 'mode: fresh' + sLineBreak + 'groups: []',
      TEncoding.UTF8);
    Job := TDownloadFile.Open(FileName);
    try
      Assert.IsTrue(TFile.Exists(FileName + '.lock'));
      Job.Checkpoint;
      Assert.IsTrue(TFile.Exists(FileName + '.bak'));
    finally
      Job.Free;
    end;
    Assert.IsFalse(TFile.Exists(FileName + '.lock'));
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.CheckpointRejectsExternalEdits;
var
  Dir, FileName: string;
  Job: TDownloadFile;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    FileName := TPath.Combine(Dir, 'download.yaml');
    TFile.WriteAllText(FileName,
      'schema: 1' + sLineBreak + 'mode: fresh' + sLineBreak + 'groups: []',
      TEncoding.UTF8);
    Job := TDownloadFile.Open(FileName);
    try
      TFile.WriteAllText(FileName,
        'schema: 1' + sLineBreak + 'mode: all' + sLineBreak + 'groups: []',
        TEncoding.UTF8);
      Assert.WillRaise(
        procedure
        begin
          Job.Checkpoint;
        end,
        EDownloadFileError);
    finally
      Job.Free;
    end;
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDownloadFileTests);

end.
