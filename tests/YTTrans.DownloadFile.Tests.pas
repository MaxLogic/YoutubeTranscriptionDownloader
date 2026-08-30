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
    [Test] procedure RemovingVideosDoesNotAlterSiblingChannels;
    [Test] procedure CheckpointPreservesSiblingChannelsWhenUpdatingState;
    [Test] procedure AppliesFreshFailedAndAllEligibility;
    [Test] procedure AppliesThrottledEligibilityAndPacingInheritance;
    [Test] procedure DetectsThrottlingAndDegradesWorkers;
    [Test] procedure DistinguishesChannelAndVideoSeedUrls;
    [Test] procedure CheckpointCreatesBackupAndReleasesLock;
    [Test] procedure CheckpointRejectsExternalEdits;
  end;

implementation

uses
  System.DateUtils,
  System.IOUtils,
  System.SysUtils,
  YTTrans.DownloadFile,
  YTTrans.Throttle,
  YTTransApp,
  VSoft.YAML;

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

procedure TDownloadFileTests.AppliesThrottledEligibilityAndPacingInheritance;
const
  CYaml =
    'schema: 1' + sLineBreak +
    'mode: throttled' + sLineBreak +
    'defaults:' + sLineBreak +
    '  request_interval_ms: 3000' + sLineBreak +
    '  sleep_requests_seconds: 1' + sLineBreak +
    '  sleep_subtitles_seconds: 3' + sLineBreak +
    '  socket_timeout_seconds: 60' + sLineBreak +
    'groups:' + sLineBreak +
    '  - request_interval_ms: 4000' + sLineBreak +
    '    videos:' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=throttled01' + sLineBreak +
    '        request_interval_ms: 5000' + sLineBreak +
    '        state:' + sLineBreak +
    '          status: throttled' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=failed00001' + sLineBreak +
    '        state:' + sLineBreak +
    '          status: failed' + sLineBreak +
    'state:' + sLineBreak +
    '  status: throttled' + sLineBreak +
    '  throttle_retry_after_utc: 2030-01-01T12:00:00.000Z' + sLineBreak;
var
  Job: TDownloadFile;
  Entries: TArray<TDownloadEntry>;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    Assert.AreEqual(dmThrottled, Job.Mode);
    Assert.AreEqual('throttled', DownloadModeToString(Job.Mode));
    Entries := Job.Entries;
    Assert.AreEqual(2, Length(Entries));
    Assert.AreEqual(5000, Entries[0].Options.RequestIntervalMs);
    Assert.AreEqual(1, Entries[0].Options.SleepRequestsSeconds);
    Assert.AreEqual(3, Entries[0].Options.SleepSubtitlesSeconds);
    Assert.AreEqual(60, Entries[0].Options.SocketTimeoutSeconds);
    Assert.AreEqual(Int64(60000), Job.ThrottleCooldownRemainingMs(
      EncodeDateTime(2030, 1, 1, 11, 59, 0, 0)));
    Assert.AreEqual(Int64(0), Job.ThrottleCooldownRemainingMs(
      EncodeDateTime(2030, 1, 1, 12, 1, 0, 0)));
    Assert.IsTrue(Job.IsEligible(Entries[0]));
    Assert.IsFalse(Job.IsEligible(Entries[1]));
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

procedure TDownloadFileTests.RemovingVideosDoesNotAlterSiblingChannels;
const
  CYaml =
    'schema: 1' + sLineBreak +
    'mode: fresh' + sLineBreak +
    'groups:' + sLineBreak +
    '  - channels:' + sLineBreak +
    '      - name: channel one' + sLineBreak +
    '        url: https://www.youtube.com/watch?v=video000001' + sLineBreak +
    '      - name: channel two' + sLineBreak +
    '        url: https://www.youtube.com/watch?v=video000002' + sLineBreak +
    '      - name: channel three' + sLineBreak +
    '        url: https://www.youtube.com/watch?v=video000003' + sLineBreak +
    '    videos:' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=video000001' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=video000002' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=video000003' + sLineBreak;
var
  Job: TDownloadFile;
  Entries: TArray<TDownloadEntry>;
  Snapshot: TArray<TDownloadEntry>;
  State: IYAMLMapping;
  Text: string;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    Snapshot := Job.Entries;
    Assert.AreEqual(6, Length(Snapshot));
    State := Snapshot[0].Node.AddOrSetMapping('state');
    State.AddOrSetValue('status', 'completed_with_errors');
    State.AddOrSetValue('downloaded', 1);
    Job.ToYaml;
    Job.RemoveStandaloneVideoByUrl(0,
      'https://www.youtube.com/watch?v=video000001');
    Job.ToYaml;
    Job.RemoveStandaloneVideoByUrl(0,
      'https://www.youtube.com/watch?v=video000002');
    Entries := Job.Entries;
    Text := Job.ToYaml;
    Assert.AreEqual(4, Length(Entries));
    Assert.AreEqual('channel one', Entries[0].Name);
    Assert.AreEqual('channel two', Entries[1].Name);
    Assert.AreEqual('channel three', Entries[2].Name);
    Assert.Contains(Text, 'https://www.youtube.com/watch?v=video000003');
  finally
    Job.Free;
  end;
end;

procedure TDownloadFileTests.CheckpointPreservesSiblingChannelsWhenUpdatingState;
const
  CYaml =
    'schema: 1' + sLineBreak +
    'mode: fresh' + sLineBreak +
    'groups:' + sLineBreak +
    '  - channels:' + sLineBreak +
    '      - name: channel one' + sLineBreak +
    '        url: https://www.youtube.com/watch?v=video000001' + sLineBreak +
    '        state:' + sLineBreak +
    '          status: completed' + sLineBreak +
    '          error_kind:' + sLineBreak +
    '          error:' + sLineBreak +
    '      - name: channel two' + sLineBreak +
    '        url: https://www.youtube.com/watch?v=video000002' + sLineBreak +
    '      - name: channel three' + sLineBreak +
    '        url: https://www.youtube.com/watch?v=video000003' + sLineBreak +
    '    videos:' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=video000001' + sLineBreak;
var
  Dir, FileName: string;
  Job, Reloaded: TDownloadFile;
  Snapshot, Entries: TArray<TDownloadEntry>;
  State: IYAMLMapping;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    FileName := TPath.Combine(Dir, 'download.yaml');
    TFile.WriteAllText(FileName, CYaml, TEncoding.UTF8);
    Job := TDownloadFile.Open(FileName);
    try
      Snapshot := Job.Entries;
      Assert.AreEqual(4, Length(Snapshot));
      State := Snapshot[0].Node['state'].AsMapping;
      State.AddOrSetValue('status', 'completed_with_errors');
      State.AddOrSetValue('attempt_count', 2);
      Job.Checkpoint;
    finally
      Job.Free;
    end;
    Reloaded := TDownloadFile.Open(FileName);
    try
      Entries := Reloaded.Entries;
      Assert.AreEqual(4, Length(Entries));
      Assert.AreEqual('channel one', Entries[0].Name);
      Assert.AreEqual('channel two', Entries[1].Name);
      Assert.AreEqual('channel three', Entries[2].Name);
    finally
      Reloaded.Free;
    end;
  finally
    TDirectory.Delete(Dir, True);
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
  Assert.IsTrue(TThrottleController.IsThrottleMessage('YouTube throttling persisted; channel processing was deferred'));
  Assert.IsFalse(TThrottleController.IsThrottleMessage('video unavailable'));
  Controller := TThrottleController.Create(8);
  try
    Assert.AreEqual(8, Controller.EffectiveWorkers);
    Controller.ReportResult(0, 'HTTP Error 429: Too Many Requests');
    Assert.AreEqual(1, Controller.EffectiveWorkers,
      'Throttle output must be honored even when yt-dlp returns exit code 0');
    Assert.AreEqual(1, Controller.ThrottleAttempt);
    Assert.IsTrue(Controller.CooldownRemainingMs > 0);
    Controller.ReportResult(0, 'ok');
    Controller.ReportResult(1, 'Sign in to confirm you are not a bot');
    Assert.AreEqual(1, Controller.EffectiveWorkers);
    Controller.ReportResult(1, 'HTTP Error 429');
    Controller.ReportResult(1, 'rate limit');
    Assert.IsTrue(Controller.IsTerminal);
    Controller.ReportResult(0, 'ok');
    Assert.IsFalse(Controller.IsTerminal,
      'A successful request must clear terminal throttle state');
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
