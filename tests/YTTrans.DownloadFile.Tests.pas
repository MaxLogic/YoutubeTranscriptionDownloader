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
    [Test] procedure ThrottleLevelDropsAfterFiveSuccessfulVideos;
    [Test] procedure ThrottleWaitsFollowLevelScheduleWithJitter;
    [Test] procedure ThrottleLevelNineParksAndResumesAtLevelEight;
    [Test] procedure RequestPacingUsesConfiguredRandomRange;
    [Test] procedure RequestPacingIncreasesWithThrottleLevel;
    [Test] procedure InternalYtDlpSleepsScaleWithThrottleLevel;
    [Test] procedure RestoresAdaptiveThrottleStateAndCooldown;
    [Test] procedure ReadsPersistedAdaptiveThrottleState;
    [Test] procedure ResumesInterruptedThrottleEntry;
    [Test] procedure OrdersChannelVideosNewestFirst;
    [Test] procedure DistinguishesChannelAndVideoSeedUrls;
    [Test] procedure CheckpointCreatesBackupAndReleasesLock;
    [Test] procedure CheckpointRejectsExternalEdits;
    [Test] procedure ChannelIndexRoundTripsAndDeduplicates;
    [Test] procedure ChannelIndexRetainsLastGoodCopy;
    [Test] procedure FreshDiscoveryUsesRssAndPreservesHistory;
    [Test] procedure RssThrottleUsesSharedController;
    [Test] procedure RecoveryModesAvoidFreshDiscovery;
    [Test] procedure AllModeForcesSafeFullReconciliation;
  end;

implementation

uses
  System.Classes,
  System.DateUtils,
  System.IOUtils,
  System.SysUtils,
  YTTrans.ChannelIndex,
  YTTrans.DownloadFile,
  YTTrans.Throttle,
  YTTransApp,
  VSoft.YAML;

function LoadFixture(const aName: string): string;
var
  lFileName: string;
begin
  lFileName := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\tests\fixtures\' + aName));
  Result := TFile.ReadAllText(lFileName, TEncoding.UTF8);
end;

function SampleChannelIndex: TChannelIndexData;
begin
  Result := Default(TChannelIndexData);
  Result.SourceUrl := 'https://www.youtube.com/@Example';
  Result.ChannelId := 'UC1234567890example';
  Result.ChannelName := 'Example';
  Result.LastFullScanUtc := EncodeDateTime(2030, 1, 1, 0, 0, 0, 0);
  SetLength(Result.Videos, 1);
  Result.Videos[0].VideoId := 'abcDEF12345';
  Result.Videos[0].Url :=
    'https://www.youtube.com/watch?v=abcDEF12345';
  Result.Videos[0].PublishedAt := '2029-12-31T12:00:00.000Z';
  Result.Videos[0].PublishedUnix := 1893412800;
end;

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
  SuccessIndex: Integer;
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
    Assert.AreEqual(1, Controller.ThrottleLevel);
    Assert.IsTrue(Controller.CooldownRemainingMs > 0);
    Controller.ReportResult(0, 'ok');
    Controller.ReportResult(1, 'Sign in to confirm you are not a bot');
    Assert.AreEqual(1, Controller.EffectiveWorkers);
    Controller.ReportResult(1, 'HTTP Error 429');
    Controller.ReportResult(1, 'rate limit');
    Assert.AreEqual(4, Controller.ThrottleLevel);
    Assert.IsFalse(Controller.IsParked);
    for SuccessIndex := 1 to 5 do
      Controller.ReportVideoSuccess;
    Assert.AreEqual(3, Controller.ThrottleLevel,
      'Five successfully downloaded videos must lower the throttle level once');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ThrottleLevelDropsAfterFiveSuccessfulVideos;
var
  Controller: TThrottleController;
  SuccessIndex: Integer;
begin
  Controller := TThrottleController.Create(1);
  try
    Controller.ReportResult(1, 'HTTP Error 429');
    Assert.AreEqual(1, Controller.ThrottleLevel);
    for SuccessIndex := 1 to 4 do
      Controller.ReportVideoSuccess;
    Assert.AreEqual(1, Controller.ThrottleLevel);
    Assert.AreEqual(4, Controller.SuccessfulVideosSinceThrottle);

    Controller.ReportVideoSuccess;
    Assert.AreEqual(0, Controller.ThrottleLevel);
    Assert.AreEqual(0, Controller.SuccessfulVideosSinceThrottle);

    Controller.ReportResult(1, 'HTTP Error 429');
    Controller.ReportVideoSuccess;
    Controller.ReportResult(1, 'HTTP Error 429');
    Assert.AreEqual(2, Controller.ThrottleLevel);
    Assert.AreEqual(0, Controller.SuccessfulVideosSinceThrottle,
      'A new throttle response must restart the five-video recovery count');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ThrottleLevelNineParksAndResumesAtLevelEight;
var
  Controller: TThrottleController;
  Level: Integer;
  SuccessIndex: Integer;
begin
  Controller := TThrottleController.Create(1);
  try
    for Level := 1 to 8 do
    begin
      Controller.ReportResult(1, 'HTTP Error 429');
      Assert.AreEqual(Level, Controller.ThrottleLevel);
      Assert.IsFalse(Controller.IsParked);
    end;
    Controller.ReportResult(1, 'HTTP Error 429');
    Assert.AreEqual(9, Controller.ThrottleLevel);
    Assert.IsTrue(Controller.IsParked);
    Assert.IsTrue(Controller.CooldownRemainingMs >= 81 * 60 * 1000,
      'Level 9 must park for at least 90 minutes minus 10 percent');
    Assert.IsTrue(Controller.CooldownRemainingMs <= 99 * 60 * 1000,
      'Level 9 must park for at most 90 minutes plus 10 percent');
    for SuccessIndex := 1 to 5 do
      Controller.ReportVideoSuccess;
    Assert.AreEqual(9, Controller.ThrottleLevel,
      'In-flight successes must not reverse the parked level');

    Controller.RestoreState(9, 0, 0);
    Controller.BeforeRequest;
    Assert.AreEqual(8, Controller.ThrottleLevel,
      'An expired level-9 park must resume at level 8');
    Assert.IsFalse(Controller.IsParked);
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ThrottleWaitsFollowLevelScheduleWithJitter;
const
  CWaitMinutes: array[1..8] of Integer = (2, 5, 10, 15, 30, 45, 60, 90);
var
  Controller: TThrottleController;
  Level: Integer;
  BaseMs, LowerBoundMs, UpperBoundMs: Cardinal;
  RemainingMs: Cardinal;
begin
  Controller := TThrottleController.Create(1);
  try
    for Level := Low(CWaitMinutes) to High(CWaitMinutes) do
    begin
      Controller.ReportResult(1, 'HTTP Error 429');
      BaseMs := Cardinal(CWaitMinutes[Level]) * 60 * 1000;
      LowerBoundMs := (BaseMs * 90) div 100;
      UpperBoundMs := (BaseMs * 110) div 100;
      RemainingMs := Controller.CooldownRemainingMs;
      Assert.IsTrue(RemainingMs + 1000 >= LowerBoundMs,
        Format('Throttle level %d wait fell below minus 10 percent', [Level]));
      Assert.IsTrue(RemainingMs <= UpperBoundMs,
        Format('Throttle level %d wait exceeded plus 10 percent', [Level]));
    end;
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.RequestPacingUsesConfiguredRandomRange;
var
  Controller: TThrottleController;
  RemainingMs: Cardinal;
begin
  Controller := TThrottleController.Create(1, 10000, 10000);
  try
    Controller.ReportResult(0, 'ok');
    RemainingMs := Controller.RequestWaitRemainingMs;
    Assert.IsTrue(RemainingMs >= 9500,
      'The randomized request wait must not fall below the configured 10-second base');
    Assert.IsTrue(RemainingMs <= 20000,
      'The randomized request wait must not exceed base plus jitter');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.RequestPacingIncreasesWithThrottleLevel;
var
  Controller: TThrottleController;
  RemainingMs: Cardinal;
begin
  Controller := TThrottleController.Create(1, 10000, 0);
  try
    Controller.ReportResult(1, 'HTTP Error 429');
    RemainingMs := Controller.RequestWaitRemainingMs;
    Assert.IsTrue(RemainingMs >= 14500,
      'Throttle level 1 must increase the 10-second request interval to 15 seconds');
    Assert.IsTrue(RemainingMs <= 15000,
      'Throttle level 1 must use a 1.5x request interval');

    Controller.ReportResult(1, 'HTTP Error 429');
    RemainingMs := Controller.RequestWaitRemainingMs;
    Assert.IsTrue(RemainingMs >= 19500,
      'Throttle level 2 must increase the 10-second request interval to 20 seconds');
    Assert.IsTrue(RemainingMs <= 20000,
      'Throttle level 2 must use a 2x request interval');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.InternalYtDlpSleepsScaleWithThrottleLevel;
const
  CYaml =
    'schema: 1' + sLineBreak +
    'mode: fresh' + sLineBreak +
    'groups:' + sLineBreak +
    '  - videos:' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=defaults001';
var
  Job: TDownloadFile;
  Entries: TArray<TDownloadEntry>;
  Controller: TThrottleController;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    Entries := Job.Entries;
    Assert.AreEqual(1, Length(Entries));
    Assert.AreEqual(3, Entries[0].Options.SleepRequestsSeconds,
      'Omitted extraction-request pacing must default to 3 seconds');
    Assert.AreEqual(5, Entries[0].Options.SleepSubtitlesSeconds,
      'Omitted subtitle pacing must default to 5 seconds');
  finally
    Job.Free;
  end;

  Controller := TThrottleController.Create(1, 0, 0);
  try
    Assert.AreEqual(3, Controller.EffectiveSleepSeconds(3));
    Assert.AreEqual(5, Controller.EffectiveSleepSeconds(5));
    Assert.AreEqual(0, Controller.EffectiveSleepSeconds(0),
      'An explicit zero must continue to disable the corresponding yt-dlp sleep');

    Controller.ReportResult(1, 'HTTP Error 429');
    Assert.AreEqual(5, Controller.EffectiveSleepSeconds(3),
      'Throttle level 1 must round 4.5 seconds up to 5');
    Assert.AreEqual(8, Controller.EffectiveSleepSeconds(5),
      'Throttle level 1 must round 7.5 seconds up to 8');

    Controller.RestoreState(8, 0, 0);
    Assert.AreEqual(15, Controller.EffectiveSleepSeconds(3));
    Assert.AreEqual(25, Controller.EffectiveSleepSeconds(5));
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.RestoresAdaptiveThrottleStateAndCooldown;
var
  Controller: TThrottleController;
  RemainingMs: Cardinal;
begin
  Controller := TThrottleController.Create(4, 10000, 0);
  try
    Controller.RestoreState(6, 3, 60000);
    Assert.AreEqual(6, Controller.ThrottleLevel);
    Assert.AreEqual(3, Controller.SuccessfulVideosSinceThrottle);
    Assert.AreEqual(1, Controller.EffectiveWorkers);
    RemainingMs := Controller.CooldownRemainingMs;
    Assert.IsTrue(RemainingMs >= 59000);
    Assert.IsTrue(RemainingMs <= 60000);
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ReadsPersistedAdaptiveThrottleState;
const
  CYaml =
    'schema: 1' + sLineBreak +
    'mode: fresh' + sLineBreak +
    'groups: []' + sLineBreak +
    'state:' + sLineBreak +
    '  status: throttled' + sLineBreak +
    '  throttle_level: 7' + sLineBreak +
    '  throttle_success_count: 4' + sLineBreak +
    '  deferred_queue_entries: 12' + sLineBreak +
    '  deferred_channel_videos: 18' + sLineBreak;
var
  Job: TDownloadFile;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    Assert.AreEqual(7, Job.SavedThrottleLevel);
    Assert.AreEqual(4, Job.SavedThrottleSuccessCount);
    Assert.Contains(Job.ToYaml, 'deferred_queue_entries: 12');
    Assert.Contains(Job.ToYaml, 'deferred_channel_videos: 18');
  finally
    Job.Free;
  end;
end;

procedure TDownloadFileTests.ResumesInterruptedThrottleEntry;
const
  CYaml =
    'schema: 1' + sLineBreak +
    'mode: throttled' + sLineBreak +
    'groups:' + sLineBreak +
    '  - channels:' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=running0001' + sLineBreak +
    '        state:' + sLineBreak +
    '          status: running' + sLineBreak +
    'state:' + sLineBreak +
    '  status: running' + sLineBreak +
    '  throttle_level: 9' + sLineBreak +
    '  throttle_success_count: 0' + sLineBreak;
var
  Job: TDownloadFile;
  Entries: TArray<TDownloadEntry>;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    Entries := Job.Entries;
    Assert.AreEqual(1, Length(Entries));
    Assert.IsTrue(Job.IsEligible(Entries[0]),
      'A channel interrupted during a persisted throttle park must resume');
  finally
    Job.Free;
  end;
end;

procedure TDownloadFileTests.OrdersChannelVideosNewestFirst;
var
  Videos: TArray<TChannelVideo>;
begin
  SetLength(Videos, 5);
  Videos[0].Url := 'old';
  Videos[0].PublishedUnix := 100;
  Videos[0].OriginalOrder := 0;
  Videos[1].Url := 'newest';
  Videos[1].PublishedUnix := 300;
  Videos[1].OriginalOrder := 1;
  Videos[2].Url := 'same-first';
  Videos[2].PublishedUnix := 200;
  Videos[2].OriginalOrder := 2;
  Videos[3].Url := 'unknown';
  Videos[3].PublishedUnix := 0;
  Videos[3].OriginalOrder := 3;
  Videos[4].Url := 'same-second';
  Videos[4].PublishedUnix := 200;
  Videos[4].OriginalOrder := 4;

  SortChannelVideosNewestFirst(Videos);

  Assert.AreEqual('newest', Videos[0].Url);
  Assert.AreEqual('same-first', Videos[1].Url);
  Assert.AreEqual('same-second', Videos[2].Url);
  Assert.AreEqual('old', Videos[3].Url);
  Assert.AreEqual('unknown', Videos[4].Url);
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

procedure TDownloadFileTests.ChannelIndexRoundTripsAndDeduplicates;
var
  Dir: string;
  Store: TChannelIndexStore;
  Source, Loaded: TChannelIndexData;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    Source := Default(TChannelIndexData);
    Source.SourceUrl := 'https://www.youtube.com/@Example';
    Source.ChannelId := 'UC1234567890example';
    Source.ChannelName := 'Example';
    Source.LastFullScanUtc := EncodeDateTime(2030, 1, 2, 3, 4, 5, 0);
    Source.LastIncrementalScanUtc := EncodeDateTime(2030, 1, 3, 3, 4, 5, 0);
    SetLength(Source.Videos, 3);
    Source.Videos[0].VideoId := 'abcDEF12345';
    Source.Videos[0].Url := 'https://youtu.be/abcDEF12345?feature=shared';
    Source.Videos[0].PublishedAt := '2030-01-01T12:00:00.000Z';
    Source.Videos[0].PublishedUnix := 1893499200;
    Source.Videos[1] := Source.Videos[0];
    Source.Videos[1].Url := 'https://www.youtube.com/watch?v=abcDEF12345';
    Source.Videos[2].Url := 'https://www.youtube.com/watch?v=ZYXwvu98765&feature=shared';
    Source.Videos[2].PublishedAt := '2030-01-04';
    Source.Videos[2].PublishedUnix := 0;

    Store := TChannelIndexStore.Create(Dir);
    try
      Store.Save(Source);
      Assert.IsTrue(TFile.Exists(Store.FileName));
      Assert.IsTrue(Store.Load(Loaded));
      Assert.AreEqual(Source.SourceUrl, Loaded.SourceUrl);
      Assert.AreEqual(Source.ChannelId, Loaded.ChannelId);
      Assert.AreEqual(2, Length(Loaded.Videos));
      Assert.AreEqual('ZYXwvu98765', Loaded.Videos[0].VideoId);
      Assert.AreEqual('https://www.youtube.com/watch?v=ZYXwvu98765',
        Loaded.Videos[0].Url);
      Assert.AreEqual('abcDEF12345', Loaded.Videos[1].VideoId);
      Assert.AreEqual(Source.LastFullScanUtc, Loaded.LastFullScanUtc, 1 / MSecsPerDay);
      Assert.AreEqual(Source.LastIncrementalScanUtc,
        Loaded.LastIncrementalScanUtc, 1 / MSecsPerDay);
    finally
      Store.Free;
    end;
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.ChannelIndexRetainsLastGoodCopy;
var
  Dir, PrimaryBefore, BackupBefore: string;
  Store: TChannelIndexStore;
  First, Second, Third, Invalid, Loaded: TChannelIndexData;
  PrimaryLock: TFileStream;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    Store := TChannelIndexStore.Create(Dir);
    try
      First := Default(TChannelIndexData);
      First.SourceUrl := 'https://www.youtube.com/@Example';
      First.ChannelId := 'UC1234567890example';
      First.ChannelName := 'First';
      First.LastFullScanUtc := EncodeDateTime(2030, 1, 1, 0, 0, 0, 0);
      SetLength(First.Videos, 1);
      First.Videos[0].VideoId := 'abcDEF12345';
      First.Videos[0].Url := 'https://www.youtube.com/watch?v=abcDEF12345';
      Store.Save(First);

      Second := First;
      Second.ChannelName := 'Second';
      Second.LastFullScanUtc := EncodeDateTime(2030, 1, 2, 0, 0, 0, 0);
      Store.Save(Second);
      Assert.IsTrue(TFile.Exists(Store.BackupFileName));

      TFile.WriteAllText(Store.FileName, '{ malformed', TEncoding.UTF8);
      PrimaryBefore := TFile.ReadAllText(Store.FileName, TEncoding.UTF8);
      BackupBefore := TFile.ReadAllText(Store.BackupFileName, TEncoding.UTF8);
      Assert.IsTrue(Store.Load(Loaded), 'A valid backup must recover a corrupt primary');
      Assert.AreEqual('First', Loaded.ChannelName);

      Invalid := Second;
      Invalid.ChannelId := '';
      Assert.WillRaise(
        procedure
        begin
          Store.Save(Invalid);
        end,
        EChannelIndexError);
      Assert.AreEqual(PrimaryBefore,
        TFile.ReadAllText(Store.FileName, TEncoding.UTF8));
      Assert.AreEqual(BackupBefore,
        TFile.ReadAllText(Store.BackupFileName, TEncoding.UTF8));

      Store.Save(Second);
      Assert.IsTrue(Store.Load(Loaded));
      Assert.AreEqual('Second', Loaded.ChannelName);
      PrimaryBefore := TFile.ReadAllText(Store.FileName, TEncoding.UTF8);
      BackupBefore := TFile.ReadAllText(Store.BackupFileName, TEncoding.UTF8);
      Third := Second;
      Third.ChannelName := 'Third';
      Third.LastFullScanUtc := EncodeDateTime(2030, 1, 3, 0, 0, 0, 0);
      PrimaryLock := TFileStream.Create(Store.FileName,
        fmOpenRead or fmShareDenyWrite);
      try
        Assert.WillRaise(
          procedure
          begin
            Store.Save(Third);
          end,
          EChannelIndexError);
      finally
        PrimaryLock.Free;
      end;
      Assert.AreEqual(PrimaryBefore,
        TFile.ReadAllText(Store.FileName, TEncoding.UTF8));
      Assert.AreEqual(BackupBefore,
        TFile.ReadAllText(Store.BackupFileName, TEncoding.UTF8));
      Assert.IsTrue(Store.Load(Loaded));
      Assert.AreEqual('Second', Loaded.ChannelName);
    finally
      Store.Free;
    end;
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.FreshDiscoveryUsesRssAndPreservesHistory;
var
  Dir, ErrorMessage, BeforeMalformed: string;
  Store: TChannelIndexStore;
  Current, Updated: TChannelIndexData;
  Controller: TThrottleController;
  NowUtc: TDateTime;
  Outcome: TChannelRssOutcome;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    Store := TChannelIndexStore.Create(Dir);
    Controller := TThrottleController.Create(1, 0, 0);
    try
      Current := SampleChannelIndex;
      Store.Save(Current);
      NowUtc := EncodeDateTime(2030, 1, 10, 0, 0, 0, 0);
      Assert.AreEqual(cdaFetchRss, SelectChannelDiscoveryAction(
        cdmFresh, True, Current.LastFullScanUtc, NowUtc));

      Outcome := RefreshChannelIndexFromRss(Store, Current, Controller,
        procedure(const aUrl: string; out aStatusCode: Integer;
          out aBody, aError: string)
        begin
          Assert.AreEqual(
            'https://www.youtube.com/feeds/videos.xml?channel_id=UC1234567890example',
            aUrl);
          aStatusCode := 200;
          aBody := LoadFixture('youtube-rss.xml');
          aError := '';
        end,
        nil, NowUtc, Updated, ErrorMessage);
      Assert.AreEqual(croSuccess, Outcome);
      Assert.AreEqual('', ErrorMessage);
      Assert.AreEqual(2, Length(Updated.Videos));
      Assert.AreEqual('rssNEW12345', Updated.Videos[0].VideoId);
      Assert.AreEqual('abcDEF12345', Updated.Videos[1].VideoId,
        'RSS omissions must not delete indexed history');
      Assert.AreEqual(Current.LastFullScanUtc, Updated.LastFullScanUtc,
        1 / MSecsPerDay);
      Assert.AreEqual(NowUtc, Updated.LastIncrementalScanUtc,
        1 / MSecsPerDay);

      BeforeMalformed := TFile.ReadAllText(Store.FileName, TEncoding.UTF8);
      Outcome := RefreshChannelIndexFromRss(Store, Updated, Controller,
        procedure(const aUrl: string; out aStatusCode: Integer;
          out aBody, aError: string)
        begin
          aStatusCode := 200;
          aBody := LoadFixture('youtube-rss-malformed.xml');
          aError := '';
        end,
        nil, IncDay(NowUtc), Current, ErrorMessage);
      Assert.AreEqual(croWarning, Outcome);
      Assert.IsTrue(ErrorMessage <> '');
      Assert.AreEqual(BeforeMalformed,
        TFile.ReadAllText(Store.FileName, TEncoding.UTF8));

      Outcome := RefreshChannelIndexFromRss(Store, Updated, Controller,
        procedure(const aUrl: string; out aStatusCode: Integer;
          out aBody, aError: string)
        begin
          aStatusCode := 503;
          aBody := 'Service Unavailable';
          aError := 'temporary upstream failure';
        end,
        nil, IncDay(NowUtc, 2), Current, ErrorMessage);
      Assert.AreEqual(croWarning, Outcome);
      Assert.AreEqual(BeforeMalformed,
        TFile.ReadAllText(Store.FileName, TEncoding.UTF8));
    finally
      Controller.Free;
      Store.Free;
    end;
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.RssThrottleUsesSharedController;
var
  Dir, BeforeThrottle, ErrorMessage: string;
  Store: TChannelIndexStore;
  Current, Updated: TChannelIndexData;
  Controller: TThrottleController;
  GateObserved: Boolean;
  CheckpointedLevel: Integer;
  Outcome: TChannelRssOutcome;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    Store := TChannelIndexStore.Create(Dir);
    Controller := TThrottleController.Create(1, 1000, 0);
    try
      Current := SampleChannelIndex;
      Store.Save(Current);
      BeforeThrottle := TFile.ReadAllText(Store.FileName, TEncoding.UTF8);
      GateObserved := False;
      CheckpointedLevel := 0;
      Outcome := RefreshChannelIndexFromRss(Store, Current, Controller,
        procedure(const aUrl: string; out aStatusCode: Integer;
          out aBody, aError: string)
        begin
          GateObserved := Controller.RequestWaitRemainingMs > 0;
          aStatusCode := 429;
          aBody := '';
          aError := 'HTTP Error 429: Too Many Requests';
        end,
        procedure
        begin
          CheckpointedLevel := Controller.ThrottleLevel;
        end,
        EncodeDateTime(2030, 1, 10, 0, 0, 0, 0), Updated, ErrorMessage);
      Assert.AreEqual(croThrottled, Outcome);
      Assert.IsTrue(GateObserved, 'RSS must enter the shared request gate');
      Assert.AreEqual(1, Controller.ThrottleLevel);
      Assert.AreEqual(1, CheckpointedLevel,
        'Throttle state must be checkpointed after RSS classification');
      Assert.AreEqual(BeforeThrottle,
        TFile.ReadAllText(Store.FileName, TEncoding.UTF8));
      Assert.AreEqual(Current.LastIncrementalScanUtc,
        Updated.LastIncrementalScanUtc, 1 / MSecsPerDay);
    finally
      Controller.Free;
      Store.Free;
    end;
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.RecoveryModesAvoidFreshDiscovery;
var
  FullScan, NowUtc: TDateTime;
begin
  FullScan := EncodeDateTime(2030, 1, 1, 0, 0, 0, 0);
  NowUtc := EncodeDateTime(2030, 1, 10, 0, 0, 0, 0);
  Assert.AreEqual(cdaUseIndex, SelectChannelDiscoveryAction(
    cdmFailed, True, FullScan, IncDay(FullScan, 100)));
  Assert.AreEqual(cdaUseIndex, SelectChannelDiscoveryAction(
    cdmThrottled, True, FullScan, IncDay(FullScan, 100)));
  Assert.AreEqual(cdaFullListing, SelectChannelDiscoveryAction(
    cdmFresh, False, 0, NowUtc));
  Assert.AreEqual(cdaFullListing, SelectChannelDiscoveryAction(
    cdmFailed, False, 0, NowUtc));
  Assert.AreEqual(cdaFullListing, SelectChannelDiscoveryAction(
    cdmThrottled, False, 0, NowUtc));
  Assert.AreEqual(cdaFullListing, SelectChannelDiscoveryAction(
    cdmFresh, True, FullScan, IncDay(FullScan, 30)));
end;

procedure TDownloadFileTests.AllModeForcesSafeFullReconciliation;
var
  Dir, BeforeInvalid, ErrorMessage: string;
  Store: TChannelIndexStore;
  Current, Discovered, Invalid, Updated: TChannelIndexData;
  NowUtc: TDateTime;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    Store := TChannelIndexStore.Create(Dir);
    try
      Current := SampleChannelIndex;
      Store.Save(Current);
      NowUtc := EncodeDateTime(2030, 2, 1, 0, 0, 0, 0);
      Assert.AreEqual(cdaFullListing, SelectChannelDiscoveryAction(
        cdmAll, True, Current.LastFullScanUtc, NowUtc));

      Discovered := Current;
      Discovered.Videos := nil;
      SetLength(Discovered.Videos, 1);
      Discovered.Videos[0].VideoId := 'fullNEW1234';
      Discovered.Videos[0].Url :=
        'https://www.youtube.com/watch?v=fullNEW1234';
      Discovered.Videos[0].PublishedAt := '2030-01-31T12:00:00.000Z';
      Discovered.Videos[0].PublishedUnix := 1896091200;
      ReconcileFullChannelIndex(Store, Current, True, Discovered, NowUtc,
        Updated);
      Assert.AreEqual(2, Length(Updated.Videos));
      Assert.AreEqual('fullNEW1234', Updated.Videos[0].VideoId);
      Assert.AreEqual('abcDEF12345', Updated.Videos[1].VideoId);
      Assert.AreEqual(NowUtc, Updated.LastFullScanUtc, 1 / MSecsPerDay);

      BeforeInvalid := TFile.ReadAllText(Store.FileName, TEncoding.UTF8);
      Invalid := Discovered;
      Invalid.ChannelId := 'UCdifferentChannel';
      Assert.IsFalse(TryReconcileFullChannelIndex(Store, Updated, True,
        Invalid, IncDay(NowUtc), Current, ErrorMessage));
      Assert.IsNotEmpty(ErrorMessage);
      Assert.AreEqual(2, Length(Current.Videos));
      Assert.AreEqual('fullNEW1234', Current.Videos[0].VideoId);
      Assert.AreEqual(BeforeInvalid,
        TFile.ReadAllText(Store.FileName, TEncoding.UTF8));
      Invalid.SourceUrl := '';
      Assert.WillRaise(
        procedure
        begin
          TryReconcileFullChannelIndex(Store, Default(TChannelIndexData),
            False, Invalid, IncDay(NowUtc), Current, ErrorMessage);
        end,
        EChannelIndexError);
    finally
      Store.Free;
    end;
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDownloadFileTests);

end.
