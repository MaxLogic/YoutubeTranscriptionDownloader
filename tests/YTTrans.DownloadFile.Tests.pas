unit YTTrans.DownloadFile.Tests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TDownloadFileTests = class
  public
    [Test] procedure LoadsGroupedQueueAndResolvesInheritance;
    [Test] procedure StandaloneVideosRunBeforeChannels;
    [Test] procedure IsolatedSourcePausesWithoutGlobalEscalation;
    [Test] procedure MultiSourceFailureStillEscalates;
    [Test] procedure RejectsUnknownFieldsWithYamlPath;
    [Test] procedure RejectsAliasesAndMultipleDocuments;
    [Test] procedure PreservesCommentsWhenRemovingSuccessfulVideo;
    [Test] procedure RemovingVideosDoesNotAlterSiblingChannels;
    [Test] procedure CheckpointPreservesSiblingChannelsWhenUpdatingState;
    [Test] procedure AppliesFreshFailedAndAllEligibility;
    [Test] procedure AppliesThrottledEligibilityAndPacingInheritance;
    [Test] procedure DetectsThrottlingResponses;
    [Test] procedure ThrottleLevelDropsAfterFiveSuccessfulVideos;
    [Test] procedure ThrottleWaitsFollowLevelScheduleWithJitter;
    [Test] procedure ThrottleLevelNineParksAndResetsAtLevelZero;
    [Test] procedure RequestPacingUsesConfiguredRandomRange;
    [Test] procedure RequestPacingTracksThrottleLevel;
    [Test] procedure YamlThrottlePolicyYieldsAndRotatesTargets;
    [Test] procedure FileModeUsesOneAttemptPerSourceTurn;
    [Test] procedure RepeatedFileModeThrottleIsTargetScoped;
    [Test] procedure ThrottledTargetStopsAfterTwoAttempts;
    [Test] procedure ChannelOutcomeExcludesUnavailableChildren;
    [Test] procedure InternalYtDlpSleepsRemainStableAcrossThrottleLevels;
    [Test] procedure RestoresAdaptiveThrottleStateAndCooldown;
    [Test] procedure ThrottleLevelDecaysAfterLongRestartIdle;
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
    [Test] procedure ChannelIndexStoreOwnershipIsExplicit;
    [Test] procedure FatalRuntimeErrorsStopFileJobs;
    [Test] procedure CompletedFileJobFailuresReturnNonzero;
    [Test] procedure YtDlpClassificationIgnoresStdoutJson;
    [Test] procedure YtDlpClassificationUsesStderrDiagnostics;
    [Test] procedure BenignPoTokenWarningEarnsRecoveryCredit;
    [Test] procedure SuccessClearsTargetRateLimitAttempts;
    [Test] procedure ChannelDiscoveryThrottleStopsAfterTwoAttempts;
    [Test] procedure FatalWorkerExceptionsSurviveTaskAggregation;
    [Test] procedure ChannelDiscoveryBotChallengeDoesNotConsumeBudget;
    [Test] procedure VideoThrottleBudgetUsesEntryUrl;
    [Test] procedure ThrottleExceptionTypeIsAuthoritative;
    [Test] procedure RssRateLimitWithoutStatusTextIsClassified;
    [Test] procedure FileModePoTokenWarningCompletesProbe;
    [Test] procedure AggregateFailureKeepsInnerMessage;
    [Test] procedure SubtitleTrackPrefersManualOverAutoCaption;
    [Test] procedure SubtitleTrackUsesAutoCaptionWhenNoManualTrack;
    [Test] procedure SubtitleTrackAcceptsTranslatedAutoCaption;
    [Test] procedure SubtitleTrackFallsBackToSecondLanguage;
    [Test] procedure CaptionlessInfoSkipsSubtitleRequest;
    [Test] procedure SubtitleInfoJsonKeepsOnlyChosenTrack;
    [Test] procedure SubtitleUrlReuseHonorsExpiryMargin;
    [Test] procedure TranscriptFetchSplitsExtractionAndSubtitle;
    [Test] procedure ThrottledSubtitleRetryReusesSignedUrl;
    [Test] procedure ExpiredSubtitleUrlTriggersReextraction;
    [Test] procedure ForbiddenSubtitleUrlTriggersOneReextraction;
    [Test] procedure SubtitleFetchPreservesUtf8Text;
    [Test] procedure ExtractionStepDoesNotCompleteVideoRequest;
    [Test] procedure FileModeSubtitleThrottlesUseTargetBudget;
    [Test] procedure ExhaustedTargetForgetsSavedSubtitleUrl;
    [Test] procedure ExpiredSubtitleSourceIsNotSaved;
    [Test] procedure CaptionlessExtractionCompletesVideoRequest;
    [Test] procedure InlineRetryReextractsExpiredSubtitleUrl;
    [Test] procedure SubtitleTrackLanguageIsTrimmed;
    [Test] procedure ExtractionRequestsUseShortBaseGap;
    [Test] procedure SubtitleRequestsUseFullRandomGap;
    [Test] procedure CooldownBlocksEveryRequestClass;
    [Test] procedure CaptionlessFetchesSkipTheSubtitleGap;
    [Test] procedure SubtitleTrackPrefersOriginalOverTranslatedAuto;
    [Test] procedure SubtitleTrackRankingFollowsLanguagePriority;
    [Test] procedure FetchTranscriptPrefersEnglishOverRequestedLanguage;
    [Test] procedure RssRequestsUseExtractionPacing;
    [Test] procedure ExplicitZeroIntervalSkipsBaseGap;
    [Test] procedure SubtitleUrlExpiringBeforeGateIsReextracted;
    [Test] procedure YamlBaseIntervalOverridesCliDefault;
    [Test] procedure AutoCookiesSkipFailingBrowser;
    [Test] procedure AutoCookiesAllFailingRunsLoggedOut;
    [Test] procedure LoggedOutNoticeShowsOncePerTrigger;
    [Test] procedure CookieSourceSuppressesLoggedOutNotice;
    [Test] procedure CookieFileSuppressesThrottleNotice;
    [Test] procedure CookieProbeRequiresSignedInSession;
    [Test] procedure StaleCookieProbeJarsAreDeleted;
    [Test] procedure TranscriptWriteReplacesAtomically;
    [Test] procedure LeftoverTranscriptTempIsIgnored;
    [Test] procedure FrontMatterQuotesOnlyWhenNeeded;
    [Test] procedure FrontMatterRoundTripsThroughYaml;
    [Test] procedure LegacyFrontMatterStillYieldsVideoId;
    [Test] procedure TranscriptWriteFitsNearMaxPath;
    [Test] procedure TranscriptTempCleanupHonorsAgeAndShape;
    [Test] procedure FrontMatterEscapesC1AndNonCharacters;
    [Test] procedure FrontMatterQuotesSexagesimalValues;
    [Test] procedure DeprecatedJobsOptionIsIgnored;
    [Test] procedure OnlyCookieFailuresRetryWithoutDefaultCookies;
  end;

implementation

uses
  System.Classes,
  System.DateUtils,
  System.Diagnostics,
  System.Generics.Collections,
  System.IOUtils,
  System.JSON,
  System.StrUtils,
  System.SysUtils,
  System.Threading,
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
    // Deprecated and ignored, but old files that set it still load.
    '  jobs: 4' + sLineBreak +
    'groups:' + sLineBreak +
    '  - name: examples' + sLineBreak +
    '    subfolder: Writing' + sLineBreak +
    '    jobs: 2' + sLineBreak +
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
    Assert.AreEqual('F:\queue\output', Job.OutputRoot);
  finally
    Job.Free;
  end;
end;

procedure TDownloadFileTests.StandaloneVideosRunBeforeChannels;
var
  Job: TDownloadFile;
  Items: TArray<TDownloadEntry>;
begin
  Job := TDownloadFile.LoadForTest('schema: 1' + sLineBreak + 'mode: all' + sLineBreak +
    'groups:' + sLineBreak + '  - channels:' + sLineBreak +
    '      - url: https://youtube.com/@Channel' + sLineBreak +
    '    videos:' + sLineBreak +
    '      - url: https://youtube.com/watch?v=first' + sLineBreak +
    '  - videos:' + sLineBreak +
    '      - url: https://youtube.com/watch?v=second', 'F:\queue\download.yaml');
  try
    Items := Job.PrioritizedEntries;
    Assert.AreEqual('https://youtube.com/watch?v=first', Items[0].Url);
    Assert.AreEqual('https://youtube.com/watch?v=second', Items[1].Url);
    Assert.AreEqual(dekChannel, Items[2].Kind);
    Assert.AreEqual(1, Items[1].GroupIndex);
  finally
    Job.Free;
  end;
end;

procedure TDownloadFileTests.IsolatedSourcePausesWithoutGlobalEscalation;
var
  Policy: TSourceThrottlePolicy;
  Controller: TThrottleController;
  NowUtc: TDateTime;
  I, J: Integer;
  GlobalBackoff: Boolean;
begin
  NowUtc := EncodeDate(2030, 1, 1);
  Policy := TSourceThrottlePolicy.Create;
  Controller := TThrottleController.Create(0, 0);
  try
    Controller.RestoreState(3, 0, 0);
    for I := 1 to 3 do
    begin
      for J := 1 to 4 do
      begin
        Policy.ReportSuccess('healthy');
        Controller.ReportVideoSuccess;
      end;
      GlobalBackoff := Policy.ReportFailure('blocked', IntToStr(I), True, NowUtc);
      Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle, False,
        'transcript', IntToStr(I), True, GlobalBackoff);
      Assert.IsFalse(GlobalBackoff, 'One failing source must not delay healthy sources');
    end;
    Assert.AreEqual(1, Controller.ThrottleLevel, 'Twelve saved videos recover two levels');
    Assert.AreEqual(2, Controller.SuccessfulVideosSinceThrottle);
    Assert.AreEqual(Int64(600000), Policy.WaitRemainingMs('blocked', NowUtc));
    Assert.AreEqual(Int64(0), Policy.WaitRemainingMs('healthy', NowUtc));
    Assert.IsFalse(Policy.IsExhausted('blocked'));
    Assert.AreEqual(Int64(0), Policy.WaitRemainingMs('blocked', IncMinute(NowUtc, 10)));
    Assert.IsFalse(Policy.ReportFailure('blocked', 'probe', True, IncMinute(NowUtc, 10)));
    Assert.IsTrue(Policy.IsExhausted('blocked'), 'A failed recovery probe ends this source for the run');
    Policy.RestorePause('restored', IncMinute(NowUtc, 10));
    Assert.AreEqual(Int64(300000), Policy.WaitRemainingMs('restored', IncMinute(NowUtc, 5)));
    Policy.CompleteProbe('restored');
    Assert.AreEqual(Int64(0), Policy.WaitRemainingMs('restored', NowUtc));
  finally
    Controller.Free;
    Policy.Free;
  end;
end;

procedure TDownloadFileTests.MultiSourceFailureStillEscalates;
var
  Policy: TSourceThrottlePolicy;
  NowUtc: TDateTime;
begin
  Policy := TSourceThrottlePolicy.Create;
  try
    NowUtc := EncodeDate(2030, 1, 1);
    Policy.ReportSuccess('healthy');
    Assert.IsFalse(Policy.ReportFailure('first', 'one', True, NowUtc));
    Assert.IsFalse(Policy.ReportFailure('first', 'one', True, NowUtc));
    Assert.AreEqual(Int64(0), Policy.WaitRemainingMs('first', NowUtc),
      'Repeated attempts of one video are not three distinct failures');
    Assert.IsTrue(Policy.ReportFailure('second', 'two', True, NowUtc));
    Policy.ReportSuccess('healthy');
    Assert.IsFalse(Policy.ReportFailure('second', 'three', True, NowUtc));
    Assert.AreEqual(Int64(0), Policy.WaitRemainingMs('second', NowUtc));
  finally
    Policy.Free;
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

procedure TDownloadFileTests.DetectsThrottlingResponses;
var
  Controller: TThrottleController;
begin
  Assert.IsTrue(TThrottleController.IsThrottleMessage('HTTP Error 429: Too Many Requests'));
  Assert.IsTrue(TThrottleController.IsThrottleMessage('YouTube throttling persisted; channel processing was deferred'));
  Assert.IsFalse(TThrottleController.IsThrottleMessage('video unavailable'));
  Assert.AreEqual(Ord(trkRateLimit), Ord(TThrottleController.ClassifyResponse(
    'HTTP Error 429: Too Many Requests')));
  Assert.AreEqual(Ord(trkBotChallenge), Ord(TThrottleController.ClassifyResponse(
    'Sign in to confirm you are not a bot')));
  Assert.AreEqual(Ord(trkNone), Ord(TThrottleController.ClassifyResponse(
    'Sign in to confirm your age. Use --cookies-from-browser for authentication')),
    'An age restriction is not a bot challenge or a rate-limit response');
  Assert.IsFalse(TThrottleController.IsThrottleMessage(
    'Sign in to confirm your age. Requested format is not available'));
  Assert.AreEqual(Ord(trkConfiguration), Ord(TThrottleController.ClassifyResponse(
    'A PO Token is required for this client')));
  Controller := TThrottleController.Create;
  try
    Controller.ReportResult(0, 'HTTP Error 429: Too Many Requests', trcSubtitle);
    Assert.AreEqual(1, Controller.ThrottleLevel,
      'Throttle output must be honored even when yt-dlp returns exit code 0');
    Assert.IsTrue(Controller.CooldownRemainingMs > 0);
    Controller.ReportResult(0, 'ok', trcSubtitle);
    Controller.ReportResult(1, 'Sign in to confirm you are not a bot', trcSubtitle);
    Assert.AreEqual(9, Controller.ThrottleLevel,
      'A bot challenge must immediately use the long unattended park');
    Assert.IsTrue(Controller.IsParked);
    Assert.AreEqual(Ord(trkBotChallenge), Ord(Controller.LastThrottleKind));
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ThrottleLevelDropsAfterFiveSuccessfulVideos;
var
  Controller: TThrottleController;
  SuccessIndex: Integer;
begin
  Controller := TThrottleController.Create;
  try
    Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle);
    Assert.AreEqual(1, Controller.ThrottleLevel);
    for SuccessIndex := 1 to 4 do
      Controller.ReportVideoSuccess;
    Assert.AreEqual(1, Controller.ThrottleLevel);
    Assert.AreEqual(4, Controller.SuccessfulVideosSinceThrottle);

    Controller.ReportVideoSuccess;
    Assert.AreEqual(0, Controller.ThrottleLevel);
    Assert.AreEqual(0, Controller.SuccessfulVideosSinceThrottle);

    Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle);
    Controller.ReportVideoSuccess;
    Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle);
    Assert.AreEqual(2, Controller.ThrottleLevel);
    Assert.AreEqual(0, Controller.SuccessfulVideosSinceThrottle,
      'A new throttle response must restart the five-video recovery count');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ThrottleLevelNineParksAndResetsAtLevelZero;
var
  Controller: TThrottleController;
  Level: Integer;
  SuccessIndex: Integer;
begin
  Controller := TThrottleController.Create;
  try
    for Level := 1 to 8 do
    begin
      Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle);
      Assert.AreEqual(Level, Controller.ThrottleLevel);
      Assert.IsFalse(Controller.IsParked);
    end;
    Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle);
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
    Assert.AreEqual(0, Controller.ThrottleLevel,
      'An expired level-9 park must reset during restart restore');
    Controller.BeforeRequest(trcSubtitle);
    Assert.AreEqual(0, Controller.ThrottleLevel,
      'An expired level-9 park must reset to level 0');
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
  Controller := TThrottleController.Create;
  try
    for Level := Low(CWaitMinutes) to High(CWaitMinutes) do
    begin
      Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle);
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
  Controller := TThrottleController.Create(10000, 10000);
  try
    Controller.ReportResult(0, 'ok', trcSubtitle);
    RemainingMs := Controller.RequestWaitRemainingMs(trcSubtitle);
    Assert.IsTrue(RemainingMs >= 9500,
      'The randomized request wait must not fall below the configured 10-second base');
    Assert.IsTrue(RemainingMs <= 20000,
      'The randomized request wait must not exceed base plus jitter');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.RequestPacingTracksThrottleLevel;
var
  Controller: TThrottleController;
  RemainingMs: Cardinal;
begin
  Controller := TThrottleController.Create(10000, 10000);
  try
    Controller.RestoreState(8, 0, 0, 5);
    Controller.ReportResult(0, 'ok', trcSubtitle, True);
    RemainingMs := Controller.RequestWaitRemainingMs(trcSubtitle);
    Assert.IsTrue(RemainingMs >= 74500,
      'Level 8 must slow recovery requests to at least about 75 seconds');
    Assert.IsTrue(RemainingMs <= 85000,
      'Level 8 pacing must remain bounded at 75 seconds plus configured jitter');

    Controller.RestoreState(7, 0, 0, 0);
    Controller.ReportResult(0, 'ok', trcSubtitle);
    RemainingMs := Controller.RequestWaitRemainingMs(trcSubtitle);
    Assert.IsTrue(RemainingMs >= 59500,
      'Level 7 must keep pacing elevated after the guarded-request counter ends');
    Assert.IsTrue(RemainingMs <= 70000,
      'Level 7 pacing must remain bounded at 60 seconds plus configured jitter');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.YamlThrottlePolicyYieldsAndRotatesTargets;
var
  Tracker: TThrottleProbeTracker;
begin
  Assert.AreEqual(Ord(trmRetryInline),
    Ord(TThrottleController.RetryModeForFileMode(False)),
    'Direct modes must retain unattended inline retry behavior');
  Assert.AreEqual(Ord(trmReturnToQueue),
    Ord(TThrottleController.RetryModeForFileMode(True)),
    'YAML mode must return a throttle to the shared queue');

  Tracker := TThrottleProbeTracker.Create;
  try
    Assert.IsFalse(Tracker.WasProbed('video-A'));
    Tracker.MarkProbed('video-A');
    Assert.IsTrue(Tracker.WasProbed('VIDEO-a'),
      'Probe tracking must normalize video IDs');
    Assert.IsFalse(Tracker.WasProbed('video-B'),
      'A throttled target must not suppress a different pending video');
    Assert.IsFalse(Tracker.CompletePass(True),
      'A pass stopped by a new throttle must retain its probe set');
    Assert.IsTrue(Tracker.WasProbed('video-A'));
    Assert.IsTrue(Tracker.CompletePass(False),
      'A natural pass end with deferred probes must request another queue slice');
    Assert.IsFalse(Tracker.WasProbed('video-A'),
      'The next queue slice must start a fresh probe cycle');
  finally
    Tracker.Free;
  end;
end;

procedure TDownloadFileTests.FileModeUsesOneAttemptPerSourceTurn;
begin
  Assert.AreEqual(1, FileModeChannelAttemptLimit,
    'Each channel must yield after one outbound video attempt');
end;

procedure TDownloadFileTests.RepeatedFileModeThrottleIsTargetScoped;
var
  Controller: TThrottleController;
begin
  Controller := TThrottleController.Create(0, 0);
  try
    Controller.ReportResult(1, 'HTTP Error 429: Too Many Requests', trcSubtitle, False,
      'transcript', 'video-A', True);
    Assert.AreEqual(1, Controller.ThrottleLevel);

    Controller.ReportResult(1, 'HTTP Error 429: Too Many Requests', trcSubtitle, False,
      'transcript', 'VIDEO-a', True);
    Assert.AreEqual(1, Controller.ThrottleLevel,
      'A second 429 from the same target must not raise the global level');
    Assert.AreEqual(2, Controller.RateLimitAttemptsForTarget('video-a'));

    Controller.ReportResult(1, 'HTTP Error 429: Too Many Requests', trcSubtitle, False,
      'transcript', 'video-B', True);
    Assert.AreEqual(2, Controller.ThrottleLevel,
      'A 429 from a different target remains global throttle evidence');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ThrottledTargetStopsAfterTwoAttempts;
var
  Tracker: TThrottleProbeTracker;
begin
  Tracker := TThrottleProbeTracker.Create;
  try
    Tracker.MarkProbed('video-A');
    Assert.IsTrue(Tracker.CompletePass(False),
      'One throttled attempt may be retried after the source rotation');

    Tracker.MarkProbed('VIDEO-a');
    Assert.IsTrue(Tracker.IsExhausted('video-a'));
    Assert.IsFalse(Tracker.CompletePass(False),
      'Two throttled attempts must not schedule another source pass');
  finally
    Tracker.Free;
  end;
end;

procedure TDownloadFileTests.ChannelOutcomeExcludesUnavailableChildren;
begin
  Assert.IsFalse(ChannelRunHasErrors(0, ''),
    'Known or newly unavailable children are reported separately from failures');
  Assert.IsTrue(ChannelRunHasErrors(1, ''));
  Assert.IsTrue(ChannelRunHasErrors(0, 'RSS discovery failed'));
end;

procedure TDownloadFileTests.InternalYtDlpSleepsRemainStableAcrossThrottleLevels;
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
    Assert.AreEqual(1, Entries[0].Options.SleepRequestsSeconds,
      'Omitted extraction-request pacing must default to 1 second');
    Assert.AreEqual(5, Entries[0].Options.SleepSubtitlesSeconds,
      'Omitted subtitle pacing must default to 5 seconds');
  finally
    Job.Free;
  end;

  Controller := TThrottleController.Create(0, 0);
  try
    Assert.AreEqual(1, Controller.EffectiveSleepSeconds(1));
    Assert.AreEqual(5, Controller.EffectiveSleepSeconds(5));
    Assert.AreEqual(0, Controller.EffectiveSleepSeconds(0),
      'An explicit zero must continue to disable the corresponding yt-dlp sleep');

    Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle);
    Assert.AreEqual(1, Controller.EffectiveSleepSeconds(1));
    Assert.AreEqual(5, Controller.EffectiveSleepSeconds(5),
      'Cooldown escalation must not multiply internal yt-dlp sleeps');

    Controller.RestoreState(8, 0, 0);
    Assert.AreEqual(1, Controller.EffectiveSleepSeconds(1));
    Assert.AreEqual(5, Controller.EffectiveSleepSeconds(5));
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.RestoresAdaptiveThrottleStateAndCooldown;
var
  Controller: TThrottleController;
  RemainingMs: Cardinal;
begin
  Controller := TThrottleController.Create(10000, 0);
  try
    Controller.RestoreState(6, 3, 60000, 2);
    Assert.AreEqual(6, Controller.ThrottleLevel);
    Assert.AreEqual(3, Controller.SuccessfulVideosSinceThrottle);
    Assert.AreEqual(2, Controller.RecoveryRequestsRemaining);
    RemainingMs := Controller.CooldownRemainingMs;
    Assert.IsTrue(RemainingMs >= 59000);
    Assert.IsTrue(RemainingMs <= 60000);
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ThrottleLevelDecaysAfterLongRestartIdle;
const
  CYaml =
    'schema: 1' + sLineBreak +
    'mode: fresh' + sLineBreak +
    'groups: []' + sLineBreak +
    'state:' + sLineBreak +
    '  throttle_level: 8' + sLineBreak +
    '  throttle_success_count: 1' + sLineBreak +
    '  throttle_recovery_remaining: 4' + sLineBreak +
    '  throttle_last_response_utc: 2030-01-01T09:00:00.000Z' + sLineBreak;
var
  Controller: TThrottleController;
  IdleMs: Int64;
  Job: TDownloadFile;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    IdleMs := Job.ThrottleIdleElapsedMs(
      EncodeDateTime(2030, 1, 1, 12, 0, 0, 0));
    Assert.AreEqual(Int64(3 * 60 * 60 * 1000), IdleMs);
  finally
    Job.Free;
  end;

  Controller := TThrottleController.Create(0, 0);
  try
    Controller.RestoreState(8, 1, 0, 4, UInt64(IdleMs));
    Assert.AreEqual(6, Controller.ThrottleLevel,
      'Each complete 90-minute idle period must lower the restored level once');
    Assert.AreEqual(0, Controller.SuccessfulVideosSinceThrottle,
      'Idle decay must start a fresh success-recovery window');
    Assert.AreEqual(5, Controller.RecoveryRequestsRemaining);

    Controller.RestoreState(8, 1, 0, 4,
      UInt64(89 * 60 * 1000 + 59 * 1000));
    Assert.AreEqual(8, Controller.ThrottleLevel,
      'A partial decay interval must preserve the persisted level');
    Assert.AreEqual(1, Controller.SuccessfulVideosSinceThrottle);
    Assert.AreEqual(4, Controller.RecoveryRequestsRemaining);

    Controller.RestoreState(8, 1, 0, 4,
      UInt64(12) * 60 * 60 * 1000);
    Assert.AreEqual(0, Controller.ThrottleLevel,
      'Twelve idle hours must fully clear level 8');
    Assert.AreEqual(0, Controller.RecoveryRequestsRemaining);

    Controller.RestoreState(8, 1, 60000, 4,
      UInt64(12) * 60 * 60 * 1000);
    Assert.AreEqual(8, Controller.ThrottleLevel,
      'Idle decay must never bypass an active persisted cooldown');
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
    '  throttle_recovery_remaining: 3' + sLineBreak +
    '  deferred_queue_entries: 12' + sLineBreak +
    '  deferred_channel_videos: 18' + sLineBreak;
var
  Job: TDownloadFile;
begin
  Job := TDownloadFile.LoadForTest(CYaml, 'F:\queue\download.yaml');
  try
    Assert.AreEqual(7, Job.SavedThrottleLevel);
    Assert.AreEqual(4, Job.SavedThrottleSuccessCount);
    Assert.AreEqual(3, Job.SavedThrottleRecoveryRemaining);
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
    Controller := TThrottleController.Create(0, 0);
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
    Controller := TThrottleController.Create(1000, 0);
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
          GateObserved := Controller.RequestWaitRemainingMs(trcExtraction) > 0;
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

procedure TDownloadFileTests.ChannelIndexStoreOwnershipIsExplicit;
var
  SourceFileName, Source: string;
begin
  SourceFileName := TPath.GetFullPath(TPath.Combine(
    ExtractFilePath(ParamStr(0)), '..\..\..\..\src\YTTransApp.pas'));
  Source := TFile.ReadAllText(SourceFileName, TEncoding.UTF8);
  Assert.Contains(Source, 'lIndexStoreOwner: IGarbo;',
    'The index store must have a function-scoped owner');
  Assert.Contains(Source,
    'gc(lIndexStore, TChannelIndexStore.Create(lChannelDir),',
    'The inner discovery block must assign the function-scoped owner');
  Assert.Contains(Source, 'lIndexStoreOwner);',
    'The index store gc call must retain its owner');
  Assert.IsFalse(Source.Contains(
    'gc(lIndexStore, TChannelIndexStore.Create(lChannelDir));'),
    'A temporary gc result frees the store before reconciliation');
end;

procedure TDownloadFileTests.FatalRuntimeErrorsStopFileJobs;
var
  Error: Exception;
begin
  Error := EAccessViolation.Create('access violation');
  try
    Assert.IsTrue(IsFatalProcessingException(Error));
  finally
    Error.Free;
  end;
  Error := EInvalidPointer.Create('invalid pointer');
  try
    Assert.IsTrue(IsFatalProcessingException(Error));
  finally
    Error.Free;
  end;
  Error := Exception.Create('ordinary item failure');
  try
    Assert.IsFalse(IsFatalProcessingException(Error));
  finally
    Error.Free;
  end;
end;

procedure TDownloadFileTests.CompletedFileJobFailuresReturnNonzero;
begin
  Assert.AreEqual(0, DownloadFileExitCode(0));
  Assert.AreEqual(1, DownloadFileExitCode(1));
  Assert.AreEqual(1, DownloadFileExitCode(5));
end;

procedure TDownloadFileTests.YtDlpClassificationIgnoresStdoutJson;
const
  CJson =
    '{"id":"abcDEF12345","title":"How to avoid a rate limit: too many requests",' +
    '"description":"I am not a bot, my account was temporarily blocked"}';
begin
  Assert.AreNotEqual(Ord(trkNone), Ord(TThrottleController.ClassifyResponse(CJson)),
    'Precondition: the metadata JSON contains throttle phrases');
  Assert.AreEqual(Ord(trkNone), Ord(TThrottleController.ClassifyResponse(
    TThrottleController.YtDlpDiagnostics(CJson + sLineBreak))),
    'Successful metadata JSON must not be classified as a throttle response');
  Assert.AreEqual(Ord(trkNone), Ord(TThrottleController.ClassifyResponse(
    TThrottleController.YtDlpDiagnostics(CJson + sLineBreak +
    'WARNING: [youtube] abcDEF12345: falling back to generic n function search'))),
    'Only diagnostic lines may drive the classification');
end;

procedure TDownloadFileTests.YtDlpClassificationUsesStderrDiagnostics;
begin
  Assert.AreEqual(Ord(trkRateLimit), Ord(TThrottleController.ClassifyResponse(
    TThrottleController.YtDlpDiagnostics(
    'ERROR: [youtube] abcDEF12345: Unable to download API page: HTTP Error 429: Too Many Requests'))));
  Assert.AreEqual(Ord(trkRateLimit), Ord(TThrottleController.ClassifyResponse(
    TThrottleController.YtDlpDiagnostics(
    'WARNING: Unable to download video subtitles for ''en'': HTTP Error 429: Too Many Requests'))),
    'A subtitle 429 warning remains throttle evidence');
  Assert.AreEqual(Ord(trkConfiguration), Ord(TThrottleController.ClassifyResponse(
    TThrottleController.YtDlpDiagnostics(
    'ERROR: [youtube] abcDEF12345: A PO Token is required for this client'))));
  Assert.AreEqual(Ord(trkNone), Ord(TThrottleController.ClassifyResponse(
    TThrottleController.YtDlpDiagnostics(
    '[youtube] Extracting URL: https://www.youtube.com/watch?v=abcDEF12345' + sLineBreak +
    'WARNING: [youtube] abcDEF12345: Some tv client subtitles are missing subtitles ' +
    'languages because a PO Token was not provided.'))),
    'The benign PO-token warning must not turn a successful run into a failure');
end;

procedure TDownloadFileTests.BenignPoTokenWarningEarnsRecoveryCredit;
const
  CWarning =
    'WARNING: [youtube] abcDEF12345: Some tv client subtitles are missing subtitles ' +
    'languages because a PO Token was not provided.';
var
  Controller: TThrottleController;
begin
  Controller := TThrottleController.Create(0, 0);
  try
    Controller.RestoreState(1, 0, 0, 0);
    Controller.ReportResult(0, TThrottleController.YtDlpDiagnostics(CWarning),
      trcSubtitle, True, 'transcript', 'https://www.youtube.com/watch?v=abcDEF12345', True);
    Assert.AreEqual(1, Controller.SuccessfulVideosSinceThrottle,
      'A saved transcript with the benign warning must earn recovery credit');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.SuccessClearsTargetRateLimitAttempts;
var
  Controller: TThrottleController;
begin
  Controller := TThrottleController.Create(0, 0);
  try
    Controller.ReportResult(1, 'HTTP Error 429: Too Many Requests', trcSubtitle, False,
      'channel_listing', 'list-A', True);
    Assert.AreEqual(1, Controller.RateLimitAttemptsForTarget('list-A'));
    Controller.ReportResult(0, '', trcExtraction, False, 'channel_listing',
      'LIST-a', True);
    Assert.AreEqual(0, Controller.RateLimitAttemptsForTarget('list-A'),
      'A successful listing must clear the target 429 budget');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ChannelDiscoveryThrottleStopsAfterTwoAttempts;
const
  CChannelUrl = 'https://www.youtube.com/@Example';
  CListUrl = 'https://www.youtube.com/playlist?list=UU1234567890example';
var
  Controller: TThrottleController;
  Probes: TThrottleProbeTracker;
  ListingCalls, Attempts: Integer;
  Exhausted: Boolean;
begin
  Controller := TThrottleController.Create(0, 0);
  Probes := TThrottleProbeTracker.Create;
  try
    ListingCalls := 0;
    repeat
      Inc(ListingCalls);
      Controller.ReportResult(0, '', trcExtraction, False, 'metadata',
        CChannelUrl, True);
      Controller.ReportResult(1,
        'ERROR: [youtube:tab] UU1234567890example: HTTP Error 429: Too Many Requests',
        trcExtraction, False, 'channel_listing', CListUrl, True);
      Exhausted := RecordFileModeThrottle(Controller, Probes, CChannelUrl,
        False, True, trkRateLimit, Attempts);
    until Exhausted or (ListingCalls > 5);
    Assert.AreEqual(2, ListingCalls,
      'A channel listing that always returns 429 is attempted exactly twice');
    Assert.AreEqual(2, Attempts);
  finally
    Probes.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ChannelDiscoveryBotChallengeDoesNotConsumeBudget;
const
  CChannelUrl = 'https://www.youtube.com/@Example';
var
  Controller: TThrottleController;
  Probes: TThrottleProbeTracker;
  Attempts: Integer;
begin
  Controller := TThrottleController.Create(0, 0);
  Probes := TThrottleProbeTracker.Create;
  try
    Assert.IsFalse(RecordFileModeThrottle(Controller, Probes, CChannelUrl,
      False, True, trkBotChallenge, Attempts));
    Assert.IsFalse(RecordFileModeThrottle(Controller, Probes, CChannelUrl,
      False, True, trkBotChallenge, Attempts),
      'Bot challenges during discovery must not exhaust the 429 budget');
    Assert.AreEqual(0, Attempts);
    Assert.IsFalse(RecordFileModeThrottle(Controller, Probes, CChannelUrl,
      False, True, trkRateLimit, Attempts));
    Assert.IsTrue(RecordFileModeThrottle(Controller, Probes, CChannelUrl,
      False, True, trkRateLimit, Attempts),
      'Two discovery 429s exhaust the channel entry');
  finally
    Probes.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.VideoThrottleBudgetUsesEntryUrl;
const
  CVideoA = 'https://www.youtube.com/watch?v=videoAAAAAA';
  CVideoB = 'https://www.youtube.com/watch?v=videoBBBBBB';
var
  Controller: TThrottleController;
  Probes: TThrottleProbeTracker;
  Attempts: Integer;
begin
  Controller := TThrottleController.Create(0, 0);
  Probes := TThrottleProbeTracker.Create;
  try
    Controller.ReportResult(1, 'HTTP Error 429: Too Many Requests', trcSubtitle, False,
      'transcript', CVideoA, True);
    Controller.ReportResult(1, 'HTTP Error 429: Too Many Requests', trcSubtitle, False,
      'transcript', CVideoA, True);
    Controller.ReportResult(1, 'HTTP Error 429: Too Many Requests', trcSubtitle, False,
      'transcript', CVideoB, True);
    Assert.IsTrue(RecordFileModeThrottle(Controller, Probes, CVideoA, True,
      False, trkRateLimit, Attempts),
      'Video A exhausted its budget even though video B was throttled last');
    Assert.AreEqual(2, Attempts);
    Assert.IsFalse(RecordFileModeThrottle(Controller, Probes, CVideoB, True,
      False, trkRateLimit, Attempts));
    Assert.AreEqual(1, Attempts);
  finally
    Probes.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ThrottleExceptionTypeIsAuthoritative;
var
  Error: Exception;
begin
  Error := EThrottleError.Create('opaque throttle response');
  try
    Assert.IsTrue(IsThrottleException(Error));
  finally
    Error.Free;
  end;
  Error := Exception.Create('ERROR: HTTP Error 429: Too Many Requests');
  try
    Assert.IsTrue(IsThrottleException(Error), 'Text remains a fallback');
  finally
    Error.Free;
  end;
  Error := Exception.Create('video unavailable');
  try
    Assert.IsFalse(IsThrottleException(Error));
  finally
    Error.Free;
  end;
end;

procedure TDownloadFileTests.RssRateLimitWithoutStatusTextIsClassified;
var
  Dir, ErrorMessage: string;
  Store: TChannelIndexStore;
  Current, Updated: TChannelIndexData;
  Controller: TThrottleController;
  Outcome: TChannelRssOutcome;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    Store := TChannelIndexStore.Create(Dir);
    Controller := TThrottleController.Create(0, 0);
    try
      Current := SampleChannelIndex;
      Store.Save(Current);
      Outcome := RefreshChannelIndexFromRss(Store, Current, Controller,
        procedure(const aUrl: string; out aStatusCode: Integer;
          out aBody, aError: string)
        begin
          aStatusCode := 429;
          aBody := '';
          aError := '';
        end,
        nil, EncodeDateTime(2030, 1, 10, 0, 0, 0, 0), Updated, ErrorMessage);
      Assert.AreEqual(croThrottled, Outcome);
      Assert.AreEqual(Ord(trkRateLimit), Ord(Controller.LastThrottleKind),
        'An RSS 429 with empty status text must take the throttle path');
      Assert.AreEqual(1, Controller.ThrottleLevel);
      Assert.AreEqual(Ord(trkRateLimit),
        Ord(TThrottleController.ClassifyResponse(ErrorMessage)),
        'The retained RSS error must classify as a rate limit');
    finally
      Controller.Free;
      Store.Free;
    end;
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.FileModePoTokenWarningCompletesProbe;
const
  CSource = 'https://www.youtube.com/@Example';
  CWarning =
    'WARNING: [youtube] abcDEF12345: Some tv client subtitles are missing subtitles ' +
    'languages because a PO Token was not provided.';
var
  Controller: TThrottleController;
  Policy: TSourceThrottlePolicy;
  Diagnostics: string;
  NowUtc: TDateTime;
begin
  Controller := TThrottleController.Create(0, 0);
  Policy := TSourceThrottlePolicy.Create;
  try
    NowUtc := TTimeZone.Local.ToUniversalTime(Now);
    Controller.RestoreState(1, 0, 0, 0);
    Policy.RestorePause(CSource, IncMinute(NowUtc, 10));
    Assert.AreEqual(Ord(trkNone), Ord(ReportYtDlpResponse(Controller, Policy,
      CSource, True, 0, CWarning, 'transcript',
      'https://www.youtube.com/watch?v=abcDEF12345', True, True, trcSubtitle,
      Diagnostics)));
    Assert.AreEqual(Int64(0), Policy.WaitRemainingMs(CSource, NowUtc),
      'A saved transcript with the benign warning must complete the source probe');
    Assert.AreEqual(0, Controller.SuccessfulVideosSinceThrottle,
      'In file mode the saved-transcript path, not the yt-dlp call, earns credit');
  finally
    Policy.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.AggregateFailureKeepsInnerMessage;
var
  Error: Exception;
begin
  Error := EAggregateException.Create([Exception.Create('inner worker failure')]);
  try
    Assert.AreEqual('inner worker failure', FailureMessage(Error));
  finally
    Error.Free;
  end;
  Error := Exception.Create('plain failure');
  try
    Assert.AreEqual('plain failure', FailureMessage(Error));
  finally
    Error.Free;
  end;
end;

procedure TDownloadFileTests.FatalWorkerExceptionsSurviveTaskAggregation;

  function WorkerFailureIsFatal(const aWorker: TProc): Boolean;
  var
    Tasks: TArray<ITask>;
    Raised: Boolean;
  begin
    Result := False;
    Raised := False;
    Tasks := [TTask.Run(aWorker)];
    try
      TTask.WaitForAll(Tasks);
    except
      on E: Exception do
      begin
        Raised := True;
        Result := IsFatalProcessingException(E);
      end;
    end;
    Assert.IsTrue(Raised, 'The worker failure must surface from WaitForAll');
  end;

begin
  Assert.IsTrue(WorkerFailureIsFatal(
    procedure
    begin
      raise EAccessViolation.Create('access violation in worker');
    end), 'An access violation inside a channel worker must stop the job');
  Assert.IsFalse(WorkerFailureIsFatal(
    procedure
    begin
      raise Exception.Create('ordinary worker failure');
    end), 'An ordinary worker failure is retained, not fatal');
end;

const
  CSampleSrt =
    '1'#13#10'00:00:00,000 --> 00:00:01,000'#13#10'Hello world'#13#10#13#10 +
    '2'#13#10'00:00:01,000 --> 00:00:02,000'#13#10'Second line'#13#10#13#10;
  CSubtitle429 =
    'ERROR: Unable to download video subtitles for ''en'': HTTP Error 429: Too Many Requests';
  CSubtitle403 =
    'ERROR: Unable to download video subtitles for ''en'': HTTP Error 403: Forbidden';

type
  // Stands in for yt-dlp.exe: extraction writes the fixture info.json, a
  // --load-info-json run writes the SRT or fails with the queued error.
  TFakeYtDlp = class
  public
    InfoJson: string;
    SrtContent: string;
    SubtitleErrors: TArray<string>;
    OnExtraction: TProc; // runs after ExtractionCalls is counted
    ExtractionCalls: Integer;
    SubtitleCalls: Integer;
    ExtractionArgs: string;
    SubtitleArgs: string;
    SubtitleInfoJson: string;
    constructor Create(const aInfoJson: string);
    function Run(const aArguments: string; out aOutput, aError: string): Integer;
    function Runner: TYtDlpRunner;
  end;

function QuotedArgument(const aArguments, aOption: string): string;
var
  lStart, lEnd: Integer;
begin
  Result := '';
  lStart := Pos(aOption + ' "', aArguments);
  if lStart = 0 then
    Exit;
  Inc(lStart, Length(aOption) + 2);
  lEnd := PosEx('"', aArguments, lStart);
  if lEnd > lStart then
    Result := Copy(aArguments, lStart, lEnd - lStart);
end;

procedure WriteUtf8NoBom(const aFileName, aText: string);
begin
  TFile.WriteAllBytes(aFileName, TEncoding.UTF8.GetBytes(aText));
end;

constructor TFakeYtDlp.Create(const aInfoJson: string);
begin
  inherited Create;
  InfoJson := aInfoJson;
  SrtContent := CSampleSrt;
end;

function TFakeYtDlp.Run(const aArguments: string;
  out aOutput, aError: string): Integer;
var
  lDir, lError: string;
begin
  aOutput := '';
  aError := '';
  lDir := QuotedArgument(aArguments, '-P');
  if ContainsText(aArguments, '--load-info-json') then
  begin
    Inc(SubtitleCalls);
    SubtitleArgs := aArguments;
    SubtitleInfoJson := TFile.ReadAllText(
      QuotedArgument(aArguments, '--load-info-json'), TEncoding.UTF8);
    lError := '';
    if SubtitleCalls <= Length(SubtitleErrors) then
      lError := SubtitleErrors[SubtitleCalls - 1];
    if lError <> '' then
    begin
      aError := lError;
      Exit(1);
    end;
    WriteUtf8NoBom(TPath.Combine(lDir, 'transcript.en.srt'), SrtContent);
    Exit(0);
  end;
  Inc(ExtractionCalls);
  if Assigned(OnExtraction) then
    OnExtraction();
  ExtractionArgs := aArguments;
  WriteUtf8NoBom(TPath.Combine(lDir, 'transcript.info.json'), InfoJson);
  Result := 0;
end;

function TFakeYtDlp.Runner: TYtDlpRunner;
begin
  Result := Run;
end;

// Returns 'operation:response_kind' for each run-log entry whose line
// contains aVideoId (the log escapes '/' in target URLs).
function RunLogEntries(const aVideoId: string): TArray<string>;
var
  lPath, lLine: string;
  lJson: TJSONValue;
  lList: TList<string>;
begin
  lPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'yttrans.run.jsonl');
  lList := TList<string>.Create;
  try
    if TFile.Exists(lPath) then
      for lLine in TFile.ReadAllLines(lPath, TEncoding.UTF8) do
      begin
        if not ContainsText(lLine, aVideoId) then
          Continue;
        lJson := TJSONObject.ParseJSONValue(lLine);
        try
          if lJson is TJSONObject then
            lList.Add(TJSONObject(lJson).GetValue<string>('operation') + ':' +
              TJSONObject(lJson).GetValue<string>('response_kind') +
              IfThen(TJSONObject(lJson).Values['track_kind'] <> nil,
                ':' + TJSONObject(lJson).GetValue<string>('track_kind', '')));
        finally
          lJson.Free;
        end;
      end;
    Result := lList.ToArray;
  finally
    lList.Free;
  end;
end;

function LastEntries(const aEntries: TArray<string>;
  const aCount: Integer): string;
var
  lIndex: Integer;
begin
  Result := '';
  for lIndex := Length(aEntries) - aCount to High(aEntries) do
    if lIndex >= 0 then
      Result := Result + aEntries[lIndex] + ' ';
  Result := Trim(Result);
end;

procedure TDownloadFileTests.SubtitleTrackPrefersManualOverAutoCaption;
var
  Track: TSubtitleTrack;
begin
  Track := SelectSubtitleTrack(LoadFixture('info-manual-subs.json'), ['en']);
  Assert.IsTrue(Track.Found);
  Assert.AreEqual(Ord(stkManual), Ord(Track.Kind));
  Assert.AreEqual('en', Track.Language);
  Assert.IsTrue(ContainsText(Track.Url, 'fmt=srt&expire=4102444800&track=manual'),
    'The srt entry of the manual track must win: ' + Track.Url);
  Assert.AreEqual(Double(EncodeDateTime(2100, 1, 1, 0, 0, 0, 0)),
    Double(Track.ExpiresUtc), 1 / SecsPerDay, 'expire= is a UTC Unix time');
end;

procedure TDownloadFileTests.SubtitleTrackUsesAutoCaptionWhenNoManualTrack;
var
  Track: TSubtitleTrack;
begin
  Track := SelectSubtitleTrack(LoadFixture('info-auto-only.json'), ['en']);
  Assert.IsTrue(Track.Found);
  Assert.AreEqual(Ord(stkAuto), Ord(Track.Kind));
  Assert.IsTrue(ContainsText(Track.Url, 'fmt=srt'), Track.Url);
  Assert.IsTrue(ContainsText(Track.Url, 'track=auto'), Track.Url);
end;

procedure TDownloadFileTests.SubtitleTrackAcceptsTranslatedAutoCaption;
var
  Track: TSubtitleTrack;
begin
  // Only a machine translation exists for `en`: it is used, marked as such.
  Track := SelectSubtitleTrack(LoadFixture('info-auto-translated.json'), ['en']);
  Assert.IsTrue(Track.Found);
  Assert.AreEqual('en', Track.Language);
  Assert.AreEqual(Ord(stkAutoTranslated), Ord(Track.Kind));
  Assert.AreEqual('auto_translated', SubtitleTrackKindToString(Track.Kind));
  Assert.IsTrue(ContainsText(Track.Url, 'tlang=en'), Track.Url);
end;

procedure TDownloadFileTests.SubtitleTrackFallsBackToSecondLanguage;
var
  Track: TSubtitleTrack;
  InfoJson: string;
begin
  InfoJson := LoadFixture('info-fallback-language.json');
  Track := SelectSubtitleTrack(InfoJson, ['pl', 'en']);
  Assert.IsTrue(Track.Found);
  Assert.AreEqual('en', Track.Language);
  Assert.IsTrue(ContainsText(Track.Url, 'track=fallback'), Track.Url);
  Track := SelectSubtitleTrack(InfoJson, ['fr', 'en']);
  Assert.AreEqual('fr', Track.Language, 'The requested language wins when present');
  Assert.AreEqual(Ord(stkManual), Ord(Track.Kind));
  Assert.IsFalse(SelectSubtitleTrack(InfoJson, ['pl']).Found);
end;

procedure TDownloadFileTests.CaptionlessInfoSkipsSubtitleRequest;
var
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
  Raised: string;
begin
  Assert.IsFalse(SelectSubtitleTrack(LoadFixture('info-captionless.json'),
    ['en']).Found);
  Fake := TFakeYtDlp.Create(LoadFixture('info-captionless.json'));
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  try
    Raised := '';
    try
      Service.FetchTranscript('https://www.youtube.com/watch?v=captionless',
        'pl', '', 'en');
    except
      on E: Exception do
        Raised := E.Message;
    end;
    Assert.IsTrue(ContainsText(Raised, 'did not produce an SRT subtitle file'),
      'Captionless videos keep the unavailable classification: ' + Raised);
    Assert.AreEqual(1, Fake.ExtractionCalls);
    Assert.AreEqual(0, Fake.SubtitleCalls, 'No timedtext request without a track');
  finally
    Service.Free;
    Fake.Free;
  end;
end;

procedure TDownloadFileTests.SubtitleInfoJsonKeepsOnlyChosenTrack;
var
  InfoJson: string;
  Track: TSubtitleTrack;
  Value: TJSONValue;
  Root, Subtitles: TJSONObject;
  Tracks: TJSONArray;
begin
  InfoJson := LoadFixture('info-manual-subs.json');
  Track := SelectSubtitleTrack(InfoJson, ['en']);
  Value := TJSONObject.ParseJSONValue(BuildSubtitleInfoJson(InfoJson, Track));
  try
    Assert.IsTrue(Value is TJSONObject);
    Root := TJSONObject(Value);
    Assert.AreEqual('manualAAAAA', Root.GetValue<string>('id'));
    Assert.IsNull(Root.Values['webpage_url'], 'webpage_url enables re-extraction');
    Assert.IsNull(Root.Values['original_url'], 'original_url enables re-extraction');
    Assert.IsNull(Root.Values['formats'], 'formats are not needed for subtitles');
    Assert.IsNotNull(Root.Values['http_headers'], 'request headers are kept');
    Subtitles := Root.GetValue<TJSONObject>('subtitles');
    Assert.AreEqual(1, Subtitles.Count);
    Tracks := Subtitles.GetValue<TJSONArray>('en');
    Assert.AreEqual(1, Tracks.Count);
    Assert.AreEqual(Track.Url, TJSONObject(Tracks.Items[0]).GetValue<string>('url'));
    Assert.AreEqual(0, Root.GetValue<TJSONObject>('automatic_captions').Count);
  finally
    Value.Free;
  end;

  InfoJson := LoadFixture('info-auto-only.json');
  Track := SelectSubtitleTrack(InfoJson, ['en']);
  Value := TJSONObject.ParseJSONValue(BuildSubtitleInfoJson(InfoJson, Track));
  try
    Root := TJSONObject(Value);
    Assert.AreEqual(0, Root.GetValue<TJSONObject>('subtitles').Count);
    Tracks := Root.GetValue<TJSONObject>('automatic_captions')
      .GetValue<TJSONArray>('en');
    Assert.AreEqual(1, Tracks.Count);
    Assert.IsTrue(TJSONObject(Tracks.Items[0]).GetValue<Boolean>('impersonate'),
      'yt-dlp per-track options such as impersonate are kept');
  finally
    Value.Free;
  end;
end;

procedure TDownloadFileTests.SubtitleUrlReuseHonorsExpiryMargin;
var
  Track: TSubtitleTrack;
begin
  Track := Default(TSubtitleTrack);
  Track.Url := 'https://www.youtube.com/api/timedtext?v=x';
  Assert.IsFalse(Track.IsReusable(EncodeDateTime(2030, 1, 1, 11, 0, 0, 0)),
    'A URL without expire= is never reused');
  Track.ExpiresUtc := EncodeDateTime(2030, 1, 1, 12, 0, 0, 0);
  Assert.IsTrue(Track.IsReusable(EncodeDateTime(2030, 1, 1, 11, 0, 0, 0)));
  Assert.IsFalse(Track.IsReusable(EncodeDateTime(2030, 1, 1, 11, 55, 0, 0)),
    'The safety margin retires the URL before it expires');
  Assert.IsFalse(Track.IsReusable(EncodeDateTime(2030, 1, 1, 12, 30, 0, 0)));
end;

procedure TDownloadFileTests.TranscriptFetchSplitsExtractionAndSubtitle;
const
  CUrl = 'https://www.youtube.com/watch?v=autoAAAAAAA';
var
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
  Transcript: TTranscriptResult;
begin
  Fake := TFakeYtDlp.Create(LoadFixture('info-auto-only.json'));
  Service := TTranscriptService.Create(trmRetryInline, Fake.Runner());
  try
    Transcript := Service.FetchTranscript(CUrl, 'en',
      '--sleep-requests 1 --sleep-subtitles 5 --socket-timeout 60');
    Assert.AreEqual('Hello world' + sLineBreak + 'Second line' + sLineBreak,
      Transcript.Transcript);
    Assert.AreEqual('Auto captions only', Transcript.Meta.Title);
    Assert.AreEqual(1, Fake.ExtractionCalls);
    Assert.AreEqual(1, Fake.SubtitleCalls);
    Assert.IsTrue(ContainsText(Fake.ExtractionArgs, '--write-info-json'));
    Assert.IsTrue(ContainsText(Fake.ExtractionArgs, '--skip-download'));
    Assert.IsFalse(ContainsText(Fake.ExtractionArgs, '--write-sub'));
    Assert.IsFalse(ContainsText(Fake.ExtractionArgs, '--write-auto-sub'));
    Assert.IsFalse(ContainsText(Fake.ExtractionArgs, '--sleep-subtitles'),
      'Extraction makes no subtitle request, so it skips the subtitle sleep');
    Assert.IsTrue(ContainsText(Fake.ExtractionArgs, '--sleep-requests 1'));
    Assert.IsTrue(ContainsText(Fake.SubtitleArgs, '--abort-on-error'),
      'Without it yt-dlp hides the subtitle HTTP error');
    Assert.IsTrue(ContainsText(Fake.SubtitleArgs, '--sub-lang "en"'));
    Assert.IsTrue(ContainsText(Fake.SubtitleArgs, '--socket-timeout 60'));
    Assert.IsFalse(ContainsText(Fake.SubtitleArgs, CUrl),
      'The subtitle run must not be able to re-extract the page');
    Assert.IsFalse(ContainsText(Fake.SubtitleInfoJson, 'webpage_url'));
    Assert.IsFalse(ContainsText(Fake.SubtitleArgs, '--sleep-subtitles'),
      'yttrans paces timedtext requests itself');
    Assert.AreEqual('transcript:none subtitle:none:auto',
      LastEntries(RunLogEntries('autoAAAAAAA'), 2));
  finally
    Service.Free;
    Fake.Free;
  end;
end;

procedure TDownloadFileTests.ThrottledSubtitleRetryReusesSignedUrl;
const
  CUrl = 'https://www.youtube.com/watch?v=manualAAAAA';
var
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
  Transcript: TTranscriptResult;
  Raised: TClass;
begin
  Fake := TFakeYtDlp.Create(LoadFixture('info-manual-subs.json'));
  Fake.SubtitleErrors := [CSubtitle429];
  try
    Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
    try
      Raised := nil;
      try
        Service.FetchTranscript(CUrl, 'en', '');
      except
        on E: Exception do
          Raised := E.ClassType;
      end;
      Assert.IsTrue(Raised = EThrottleError, 'A timedtext 429 is a throttle');
    finally
      Service.Free;
    end;
    // File mode builds a new service when the entry comes back from the queue.
    Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
    try
      Transcript := Service.FetchTranscript(CUrl, 'en', '');
    finally
      Service.Free;
    end;
    Assert.AreEqual('Hello world' + sLineBreak + 'Second line' + sLineBreak,
      Transcript.Transcript);
    Assert.AreEqual('Manual subtitles', Transcript.Meta.Title,
      'Metadata survives the reuse of the saved extraction');
    Assert.AreEqual(1, Fake.ExtractionCalls, 'The retry must not re-extract');
    Assert.AreEqual(2, Fake.SubtitleCalls);
    Assert.IsTrue(ContainsText(Fake.SubtitleInfoJson, 'track=manual'));
    Assert.AreEqual(
      'transcript:none subtitle:rate_limit:manual subtitle:none:manual',
      LastEntries(RunLogEntries('manualAAAAA'), 3));
  finally
    Fake.Free;
  end;
end;

procedure TDownloadFileTests.ExpiredSubtitleUrlTriggersReextraction;
const
  CUrl = 'https://www.youtube.com/watch?v=translatedA';
var
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
begin
  Fake := TFakeYtDlp.Create(StringReplace(
    LoadFixture('info-auto-translated.json'), 'expire=4102444800',
    'expire=1000000000', [rfReplaceAll]));
  Fake.SubtitleErrors := [CSubtitle429];
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  try
    Assert.WillRaise(
      procedure
      begin
        Service.FetchTranscript(CUrl, 'en', '');
      end, EThrottleError);
    Service.FetchTranscript(CUrl, 'en', '');
    Assert.AreEqual(2, Fake.ExtractionCalls,
      'An expired signed URL needs a fresh extraction');
    Assert.AreEqual(2, Fake.SubtitleCalls);
  finally
    Service.Free;
    Fake.Free;
  end;
end;

procedure TDownloadFileTests.ForbiddenSubtitleUrlTriggersOneReextraction;
var
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
  Transcript: TTranscriptResult;
begin
  Fake := TFakeYtDlp.Create(LoadFixture('info-fallback-language.json'));
  Fake.SubtitleErrors := [CSubtitle403];
  Service := TTranscriptService.Create(trmRetryInline, Fake.Runner());
  try
    Transcript := Service.FetchTranscript(
      'https://www.youtube.com/watch?v=fallbackAAA', 'pl', '', 'en');
    Assert.AreEqual('Hello world' + sLineBreak + 'Second line' + sLineBreak,
      Transcript.Transcript);
    Assert.AreEqual(2, Fake.ExtractionCalls);
    Assert.AreEqual(2, Fake.SubtitleCalls);
    Assert.IsTrue(ContainsText(Fake.SubtitleArgs, '--sub-lang "en"'),
      'The fallback language track is downloaded');
  finally
    Service.Free;
    Fake.Free;
  end;

  Fake := TFakeYtDlp.Create(LoadFixture('info-fallback-language.json'));
  Fake.SubtitleErrors := [CSubtitle403, CSubtitle403, CSubtitle403];
  Service := TTranscriptService.Create(trmRetryInline, Fake.Runner());
  try
    Assert.WillRaise(
      procedure
      begin
        Service.FetchTranscript(
          'https://www.youtube.com/watch?v=forbiddenAA', 'en', '');
      end, Exception);
    Assert.AreEqual(2, Fake.ExtractionCalls, 'Only one re-extraction per fetch');
    Assert.AreEqual(2, Fake.SubtitleCalls);
  finally
    Service.Free;
    Fake.Free;
  end;
end;

procedure TDownloadFileTests.SubtitleFetchPreservesUtf8Text;
const
  CText = 'Za'#$017C#$00F3#$0142#$0107' g'#$0119#$015B'l'#$0105' ja'#$017A'n'#$0107;
var
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
begin
  Fake := TFakeYtDlp.Create(LoadFixture('info-auto-only.json'));
  Fake.SrtContent := '1'#13#10'00:00:00,000 --> 00:00:01,000'#13#10 + CText +
    #13#10#13#10;
  Service := TTranscriptService.Create(trmRetryInline, Fake.Runner());
  try
    Assert.AreEqual(CText + sLineBreak, Service.FetchTranscript(
      'https://www.youtube.com/watch?v=utf8AAAAAAA', 'en', '').Transcript);
  finally
    Service.Free;
    Fake.Free;
  end;
end;

procedure TDownloadFileTests.ExtractionStepDoesNotCompleteVideoRequest;
const
  CSource = 'https://www.youtube.com/@Example';
  CTarget = 'https://www.youtube.com/watch?v=abcDEF12345';
var
  Controller: TThrottleController;
  Policy: TSourceThrottlePolicy;
  Diagnostics: string;
  NowUtc: TDateTime;
begin
  Controller := TThrottleController.Create(0, 0);
  Policy := TSourceThrottlePolicy.Create;
  try
    Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle, True, 'subtitle',
      CTarget, True);
    Assert.AreEqual(1, Controller.RateLimitAttemptsForTarget(CTarget));
    // The next extraction succeeds, but the video is not done until its
    // subtitle download succeeds.
    Controller.ReportResult(0, '', trcExtraction, True, 'transcript', CTarget,
      True, True, False);
    Assert.AreEqual(1, Controller.RateLimitAttemptsForTarget(CTarget),
      'An extraction must not reset the target''s 429 budget');
    Assert.AreEqual(0, Controller.SuccessfulVideosSinceThrottle);
    Controller.CompleteTargetRequest(CTarget, True, True);
    Assert.AreEqual(0, Controller.RateLimitAttemptsForTarget(CTarget));
    Assert.AreEqual(1, Controller.SuccessfulVideosSinceThrottle);

    NowUtc := TTimeZone.Local.ToUniversalTime(Now);
    Policy.RestorePause(CSource, IncMinute(NowUtc, 10));
    ReportYtDlpResponse(nil, Policy, CSource, True, 0, '', 'transcript',
      CTarget, True, True, trcExtraction, Diagnostics, False);
    Assert.IsTrue(Policy.WaitRemainingMs(CSource, NowUtc) > 0,
      'An extraction alone does not complete the source probe');
    ReportYtDlpResponse(nil, Policy, CSource, True, 0, '', 'subtitle',
      CTarget, True, True, trcSubtitle, Diagnostics);
    Assert.AreEqual(Int64(0), Policy.WaitRemainingMs(CSource, NowUtc));
  finally
    Policy.Free;
    Controller.Free;
  end;
end;

function ExpiredFixture(const aName: string): string;
begin
  Result := StringReplace(LoadFixture(aName), 'expire=4102444800',
    'expire=1000000000', [rfReplaceAll]);
end;

// Class name of the exception FetchTranscript raised, or ''.
function FetchRaises(const aService: TTranscriptService;
  const aUrl, aLanguage: string): string;
begin
  Result := '';
  try
    aService.FetchTranscript(aUrl, aLanguage, '');
  except
    on E: Exception do
      Result := E.ClassName;
  end;
end;

procedure TDownloadFileTests.FileModeSubtitleThrottlesUseTargetBudget;
const
  CUrl = 'https://www.youtube.com/watch?v=budgetAAAAA';
var
  Controller: TThrottleController;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
begin
  Controller := TThrottleController.Create(0, 0, 0);
  // Expired URL: every attempt re-extracts, and those extractions must not
  // reset the target's 429 budget.
  Fake := TFakeYtDlp.Create(ExpiredFixture('info-manual-subs.json'));
  Fake.SubtitleErrors := [CSubtitle429, CSubtitle429];
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  SetThrottleContext(Controller, nil);
  try
    Assert.IsTrue(FetchRaises(Service, CUrl, 'en') = 'EThrottleError');
    Assert.AreEqual(1, Controller.RateLimitAttemptsForTarget(CUrl));
    Controller.RestoreState(0, 0, 0); // skip the cooldown, keep the budget
    Assert.IsTrue(FetchRaises(Service, CUrl, 'en') = 'EThrottleError');
    Assert.AreEqual(2, Fake.ExtractionCalls);
    Assert.AreEqual(2, Controller.RateLimitAttemptsForTarget(CUrl),
      'The second extraction must not complete the video request');
    Assert.IsTrue(Controller.IsTargetExhausted(CUrl));
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ExhaustedTargetForgetsSavedSubtitleUrl;
const
  CUrl = 'https://www.youtube.com/watch?v=exhaustAAAA';
var
  Controller: TThrottleController;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
  SavedBefore: Integer;
begin
  Controller := TThrottleController.Create(0, 0, 0);
  Fake := TFakeYtDlp.Create(LoadFixture('info-manual-subs.json'));
  Fake.SubtitleErrors := [CSubtitle429, CSubtitle429];
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  SetThrottleContext(Controller, nil);
  try
    SavedBefore := SavedSubtitleSourceCount;
    Assert.IsTrue(FetchRaises(Service, CUrl, 'en') = 'EThrottleError');
    Assert.AreEqual(SavedBefore + 1, SavedSubtitleSourceCount);
    Controller.RestoreState(0, 0, 0);
    Assert.IsTrue(FetchRaises(Service, CUrl, 'en') = 'EThrottleError');
    Assert.AreEqual(1, Fake.ExtractionCalls, 'The second attempt reused the URL');
    Assert.AreEqual(SavedBefore, SavedSubtitleSourceCount,
      'An exhausted target keeps no saved subtitle URL');
    Service.FetchTranscript(CUrl, 'en', '');
    Assert.AreEqual(2, Fake.ExtractionCalls);
    Assert.AreEqual(3, Fake.SubtitleCalls);
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.ExpiredSubtitleSourceIsNotSaved;
var
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
  SavedBefore: Integer;
begin
  SavedBefore := SavedSubtitleSourceCount;
  Fake := TFakeYtDlp.Create(ExpiredFixture('info-auto-only.json'));
  Fake.SubtitleErrors := [CSubtitle429];
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  try
    Assert.IsTrue(FetchRaises(Service,
      'https://www.youtube.com/watch?v=expiredAAAA', 'en') = 'EThrottleError');
    Assert.AreEqual(SavedBefore, SavedSubtitleSourceCount,
      'A URL that cannot be reused is not kept');
  finally
    Service.Free;
    Fake.Free;
  end;
end;

procedure TDownloadFileTests.CaptionlessExtractionCompletesVideoRequest;
const
  CUrl = 'https://www.youtube.com/watch?v=captionless';
var
  Controller: TThrottleController;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
begin
  Controller := TThrottleController.Create(0, 0, 0);
  Fake := TFakeYtDlp.Create(LoadFixture('info-captionless.json'));
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  SetThrottleContext(Controller, nil);
  try
    Controller.ReportResult(1, 'HTTP Error 429', trcSubtitle, True, 'subtitle',
      CUrl, True);
    Controller.RestoreState(1, 0, 0, 5);
    Assert.AreEqual(1, Controller.RateLimitAttemptsForTarget(CUrl));
    Assert.IsTrue(FetchRaises(Service, CUrl, 'en') = 'EMissingTranscriptError');
    Assert.AreEqual(0, Fake.SubtitleCalls);
    Assert.AreEqual(0, Controller.RateLimitAttemptsForTarget(CUrl),
      'A captionless extraction completes the video request');
    Assert.AreEqual(1, Controller.SuccessfulVideosSinceThrottle,
      'Without a source policy the captionless video earns credit as before');
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.InlineRetryReextractsExpiredSubtitleUrl;
const
  CSource = 'https://www.youtube.com/@Isolated';
var
  Controller: TThrottleController;
  Policy: TSourceThrottlePolicy;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
  Transcript: TTranscriptResult;
begin
  Controller := TThrottleController.Create(0, 0, 0);
  Policy := TSourceThrottlePolicy.Create;
  // Another source succeeded, so this source-local 429 starts no global
  // cooldown and the inline retry runs at once.
  Policy.ReportSuccess('https://www.youtube.com/@Other');
  Fake := TFakeYtDlp.Create(ExpiredFixture('info-auto-only.json'));
  Fake.SubtitleErrors := [CSubtitle429];
  Service := TTranscriptService.Create(trmRetryInline, Fake.Runner());
  SetThrottleContext(Controller, Policy, CSource, True);
  try
    Transcript := Service.FetchTranscript(
      'https://www.youtube.com/watch?v=inlineAAAAA', 'en', '');
    Assert.AreEqual('Hello world' + sLineBreak + 'Second line' + sLineBreak,
      Transcript.Transcript);
    Assert.AreEqual(2, Fake.ExtractionCalls,
      'The inline retry re-extracts instead of reusing an expired URL');
    Assert.AreEqual(2, Fake.SubtitleCalls);
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Policy.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.SubtitleTrackLanguageIsTrimmed;
var
  Track: TSubtitleTrack;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
begin
  Track := SelectSubtitleTrack(LoadFixture('info-manual-subs.json'), [' EN ']);
  Assert.IsTrue(Track.Found);
  Assert.AreEqual('en', Track.Language);
  Fake := TFakeYtDlp.Create(LoadFixture('info-fallback-language.json'));
  Service := TTranscriptService.Create(trmRetryInline, Fake.Runner());
  try
    Service.FetchTranscript('https://www.youtube.com/watch?v=trimAAAAAAA',
      ' pl ', '', ' en ');
    Assert.IsTrue(ContainsText(Fake.SubtitleArgs, '--sub-lang "en"'),
      Fake.SubtitleArgs);
  finally
    Service.Free;
    Fake.Free;
  end;
end;

procedure TDownloadFileTests.ExtractionRequestsUseShortBaseGap;
var
  Controller: TThrottleController;
  WaitMs: Cardinal;
begin
  Controller := TThrottleController.Create(10000, 10000, 3000);
  try
    Controller.ReportResult(0, '', trcExtraction, True, 'transcript', 'video',
      False, True, False);
    WaitMs := Controller.RequestWaitRemainingMs(trcExtraction);
    Assert.IsTrue((WaitMs >= 2500) and (WaitMs <= 3000),
      Format('Extraction waits the base gap only, got %d ms', [WaitMs]));
    Assert.IsTrue(Controller.RequestWaitRemainingMs(trcSubtitle) <= 3000,
      'An extraction does not use up a subtitle pacing slot');

    Controller.RestoreState(8, 0, 0, 5);
    Controller.ReportResult(0, '', trcExtraction, True, 'transcript', 'video',
      False, True, False);
    Assert.IsTrue(Controller.RequestWaitRemainingMs(trcExtraction) <= 3000,
      'Recovery spacing applies to subtitle requests only');
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.SubtitleRequestsUseFullRandomGap;
var
  Controller: TThrottleController;
  WaitMs: Cardinal;
begin
  Controller := TThrottleController.Create(10000, 10000, 3000);
  try
    Controller.BeforeRequest(trcSubtitle);
    Controller.ReportResult(0, '', trcSubtitle, True, 'subtitle', 'video',
      False, True, True);
    WaitMs := Controller.RequestWaitRemainingMs(trcSubtitle);
    Assert.IsTrue((WaitMs >= 9500) and (WaitMs <= 20000),
      Format('Subtitle waits 10-20 s, got %d ms', [WaitMs]));
    WaitMs := Controller.RequestWaitRemainingMs(trcExtraction);
    Assert.IsTrue((WaitMs >= 2500) and (WaitMs <= 3000),
      Format('The next extraction waits the base gap only, got %d ms', [WaitMs]));
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.CooldownBlocksEveryRequestClass;
var
  Controller: TThrottleController;
  PacingMs, CooldownMs: Int64;
  RequestClass: TThrottleRequestClass;
begin
  Controller := TThrottleController.Create(0, 0, 0);
  try
    for RequestClass := Low(TThrottleRequestClass) to High(TThrottleRequestClass) do
    begin
      Controller.RestoreState(1, 0, 1200, 5);
      Controller.BeforeRequest(PacingMs, CooldownMs, RequestClass);
      Assert.IsTrue(CooldownMs >= 900,
        Format('Class %d must wait for the cooldown, waited %d ms',
          [Ord(RequestClass), CooldownMs]));
    end;
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.CaptionlessFetchesSkipTheSubtitleGap;
var
  Controller: TThrottleController;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
  Timer: TStopwatch;
begin
  // A 60-second subtitle gap and no base gap.
  Controller := TThrottleController.Create(60000, 0, 0);
  Fake := TFakeYtDlp.Create(LoadFixture('info-captionless.json'));
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  SetThrottleContext(Controller, nil);
  try
    Timer := TStopwatch.StartNew;
    Assert.IsTrue(FetchRaises(Service,
      'https://www.youtube.com/watch?v=gapAAAAAAA1', 'en') = 'EMissingTranscriptError');
    Assert.IsTrue(FetchRaises(Service,
      'https://www.youtube.com/watch?v=gapAAAAAAA2', 'en') = 'EMissingTranscriptError');
    Assert.IsTrue(Timer.ElapsedMilliseconds < 5000,
      'Captionless extractions do not wait for a subtitle slot');
    Assert.AreEqual(Cardinal(0), Controller.RequestWaitRemainingMs(trcSubtitle));

    Fake.InfoJson := LoadFixture('info-auto-only.json');
    Service.FetchTranscript('https://www.youtube.com/watch?v=gapAAAAAAA3', 'en', '');
    Assert.IsTrue(Controller.RequestWaitRemainingMs(trcSubtitle) >= 59000,
      'A subtitle download takes a full pacing slot');
    Assert.AreEqual(Cardinal(0), Controller.RequestWaitRemainingMs(trcExtraction));
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.SubtitleTrackPrefersOriginalOverTranslatedAuto;
var
  Track: TSubtitleTrack;
  InfoJson: string;
begin
  InfoJson := LoadFixture('info-auto-orig-and-translated.json');
  Track := SelectSubtitleTrack(InfoJson, ['en']);
  Assert.AreEqual('en-orig', Track.Language);
  Assert.AreEqual(Ord(stkAuto), Ord(Track.Kind));
  Assert.IsTrue(ContainsText(Track.Url, 'track=orig'), Track.Url);
  Track := SelectSubtitleTrack(InfoJson, ['de']);
  Assert.AreEqual('de-orig', Track.Language);
  Assert.AreEqual(Ord(stkAuto), Ord(Track.Kind));
  // Manual still beats any automatic caption.
  Track := SelectSubtitleTrack(LoadFixture('info-manual-subs.json'), ['en']);
  Assert.AreEqual(Ord(stkManual), Ord(Track.Kind));
  Assert.AreEqual('manual', SubtitleTrackKindToString(Track.Kind));
end;

procedure TDownloadFileTests.SubtitleTrackRankingFollowsLanguagePriority;

  // info.json with the given automatic captions; `+` marks a machine
  // translation from `src`.
  function Info(const aTracks: array of string; const aManual: string = '';
    const aLanguage: string = ''): string;
  var
    lTrack, lKey, lTlang, lCaps: string;
  begin
    lCaps := '';
    for lTrack in aTracks do
    begin
      lKey := lTrack.Replace('+', '');
      lTlang := '';
      if lTrack.EndsWith('+') then
        lTlang := '&tlang=' + lKey;
      if lCaps <> '' then
        lCaps := lCaps + ',';
      lCaps := lCaps + Format('"%s":[{"ext":"srt","url":"https://www.youtube.com/' +
        'api/timedtext?v=rankAAAAAAA&kind=asr&lang=src%s&fmt=srt&track=%s"}]',
        [lKey, lTlang, lKey]);
    end;
    Result := '{"id":"rankAAAAAAA","subtitles":{';
    if aManual <> '' then
      Result := Result + Format('"%s":[{"ext":"srt","url":"https://www.youtube.com/' +
        'api/timedtext?v=rankAAAAAAA&lang=%s&fmt=srt&track=manual-%s"}]',
        [aManual, aManual, aManual]);
    Result := Result + '},"automatic_captions":{' + lCaps + '}';
    if aLanguage <> '' then
      Result := Result + Format(',"language":"%s"', [aLanguage]);
    Result := Result + '}';
  end;

  procedure Check(const aInfoJson, aLanguage: string;
    const aKind: TSubtitleTrackKind; const aStep: string);
  var
    lTrack: TSubtitleTrack;
  begin
    lTrack := SelectSubtitleTrack(aInfoJson, ['en', 'de']);
    Assert.IsTrue(lTrack.Found, aStep);
    Assert.AreEqual(aLanguage, lTrack.Language, aStep);
    Assert.AreEqual(Ord(aKind), Ord(lTrack.Kind), aStep);
  end;

begin
  Check(Info(['de-orig', 'en-orig', 'fr-orig', 'de+', 'en+']), 'en-orig',
    stkAuto, '1. original English');
  Check(Info(['fr-orig', 'en+', 'de-orig']), 'de-orig', stkAuto,
    '2. original German beats an English translation');
  Check(Info(['fr-orig', 'de+', 'en+']), 'en', stkAutoTranslated,
    '3. English translation beats a German one and the video language');
  Check(Info(['fr-orig', 'es+', 'de+']), 'de', stkAutoTranslated,
    '4. German translation beats the video language');
  Check(Info(['es+', 'fr-orig']), 'fr-orig', stkAuto,
    '5. the video''s own language as the last resort');
  Check(Info(['es+'], 'fr', 'fr'), 'fr', stkManual,
    '5. info.json language, manual subtitles');
  Check(Info(['de-orig'], 'de'), 'de', stkManual,
    'Manual beats automatic captions in the same language');
  Assert.IsFalse(SelectSubtitleTrack(Info(['es+']), ['en', 'de']).Found,
    'Only a translation into another language');
end;

procedure TDownloadFileTests.FetchTranscriptPrefersEnglishOverRequestedLanguage;
var
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
begin
  // info-manual-subs.json has manual `en` and `de` subtitles.
  Fake := TFakeYtDlp.Create(LoadFixture('info-manual-subs.json'));
  Service := TTranscriptService.Create(trmRetryInline, Fake.Runner());
  try
    Service.FetchTranscript('https://www.youtube.com/watch?v=manualAAAAA',
      'de', '', 'en');
    Assert.IsTrue(ContainsText(Fake.SubtitleArgs, '--sub-lang "en"'),
      Fake.SubtitleArgs);
  finally
    Service.Free;
    Fake.Free;
  end;
end;

procedure TDownloadFileTests.RssRequestsUseExtractionPacing;
var
  Dir, ErrorMessage: string;
  Store: TChannelIndexStore;
  Updated: TChannelIndexData;
  Controller: TThrottleController;
begin
  Dir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(Dir);
  try
    Store := TChannelIndexStore.Create(Dir);
    // A 60-second subtitle gap and a 1-second base gap.
    Controller := TThrottleController.Create(60000, 0, 1000);
    try
      Store.Save(SampleChannelIndex);
      Assert.AreEqual(croSuccess, RefreshChannelIndexFromRss(Store,
        SampleChannelIndex, Controller,
        procedure(const aUrl: string; out aStatusCode: Integer;
          out aBody, aError: string)
        begin
          aStatusCode := 200;
          aBody := LoadFixture('youtube-rss.xml');
          aError := '';
        end,
        nil, EncodeDateTime(2030, 1, 10, 0, 0, 0, 0), Updated, ErrorMessage));
      Assert.IsTrue(Controller.RequestWaitRemainingMs(trcSubtitle) <= 1000,
        'An RSS request is listing work and must not take a subtitle slot');
      Assert.IsTrue(Controller.RequestWaitRemainingMs(trcExtraction) > 0,
        'An RSS request still pushes the base gap');
    finally
      Controller.Free;
      Store.Free;
    end;
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.ExplicitZeroIntervalSkipsBaseGap;
var
  Controller: TThrottleController;
  WaitMs: Cardinal;
begin
  // request_interval_ms 0 and delay_jitter_ms 0 with the default 3 s base gap.
  Controller := TThrottleController.Create(0, 0, 3000);
  try
    Controller.BeforeRequest(trcExtraction);
    Assert.AreEqual(Cardinal(0), Controller.RequestWaitRemainingMs(trcSubtitle),
      'An explicit zero interval is not raised to the base gap');
    Controller.BeforeRequest(trcSubtitle);
    Assert.AreEqual(Cardinal(0), Controller.RequestWaitRemainingMs(trcSubtitle));
  finally
    Controller.Free;
  end;
  // The base gap never exceeds the configured subtitle interval.
  Controller := TThrottleController.Create(1000, 0, 3000);
  try
    Controller.BeforeRequest(trcExtraction);
    WaitMs := Controller.RequestWaitRemainingMs(trcExtraction);
    Assert.IsTrue((WaitMs > 0) and (WaitMs <= 1000),
      Format('Base gap capped at the 1 s interval, got %d ms', [WaitMs]));
  finally
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.SubtitleUrlExpiringBeforeGateIsReextracted;
const
  CUrl = 'https://www.youtube.com/watch?v=gateExpAAAA';
var
  Controller: TThrottleController;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
  Timer: TStopwatch;
  ExpireUnix: Int64;
  SubtitleCallsAtReextract: Integer;
  ElapsedAtReextract: Int64;
  WaitAtReextract: Cardinal;
begin
  // A 5-second subtitle gap is pending. The URL is valid now, but its expiry
  // minus the 10-minute safety margin falls inside that gap: it must be
  // re-extracted before entering the gate, not after waiting it out.
  Controller := TThrottleController.Create(5000, 0, 0);
  ExpireUnix := DateTimeToUnix(TTimeZone.Local.ToUniversalTime(Now), True) +
    10 * 60 + 3;
  Fake := TFakeYtDlp.Create(StringReplace(LoadFixture('info-auto-only.json'),
    'expire=4102444800', 'expire=' + IntToStr(ExpireUnix), [rfReplaceAll]));
  SubtitleCallsAtReextract := -1;
  ElapsedAtReextract := -1;
  WaitAtReextract := 0;
  Fake.OnExtraction :=
    procedure
    begin
      if Fake.ExtractionCalls <> 2 then
        Exit;
      SubtitleCallsAtReextract := Fake.SubtitleCalls;
      ElapsedAtReextract := Timer.ElapsedMilliseconds;
      WaitAtReextract := Controller.RequestWaitRemainingMs(trcSubtitle);
      Fake.InfoJson := LoadFixture('info-auto-only.json');
      Controller.RestoreState(0, 0, 0); // let the fresh URL go at once
    end;
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  SetThrottleContext(Controller, nil);
  try
    Controller.BeforeRequest(trcSubtitle); // takes the slot; 5 s gap pending
    Timer := TStopwatch.StartNew;
    Service.FetchTranscript(CUrl, 'en', '');
    Assert.AreEqual(2, Fake.ExtractionCalls,
      'A URL expiring inside the gate wait is re-extracted first');
    Assert.AreEqual(1, Fake.SubtitleCalls);
    Assert.AreEqual(0, SubtitleCallsAtReextract,
      'No subtitle request was spent on the doomed URL');
    Assert.IsTrue((ElapsedAtReextract >= 0) and (ElapsedAtReextract < 2000),
      Format('No gate wait was consumed, re-extracted after %d ms',
        [ElapsedAtReextract]));
    Assert.IsTrue((WaitAtReextract > 2000) and (WaitAtReextract <= 5000),
      Format('The pending subtitle slot was not consumed, %d ms left',
        [WaitAtReextract]));
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Controller.Free;
  end;
end;

procedure TDownloadFileTests.YamlBaseIntervalOverridesCliDefault;
const
  CQueue =
    'schema: 1' + sLineBreak +
    'mode: fresh' + sLineBreak +
    '%s' +
    'groups:' + sLineBreak +
    '  - videos:' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=baseAAAAAAA' + sLineBreak +
    '      - url: https://www.youtube.com/watch?v=baseBBBBBBB' + sLineBreak +
    '        base_interval_ms: 1500';
var
  Job: TDownloadFile;
  Entries: TArray<TDownloadEntry>;
  Controller: TThrottleController;
  GapMs: Cardinal;

  // The extraction gap the controller applies after ApplyEntryPacing.
  function BaseGapMs(const aEntry: TDownloadEntry;
    const aCliBaseIntervalMs: Integer): Cardinal;
  begin
    ApplyEntryPacing(Controller, aEntry.Options, aCliBaseIntervalMs);
    Controller.RestoreState(0, 0, 0); // clear earlier deadlines
    Controller.BeforeRequest(trcExtraction);
    Result := Controller.RequestWaitRemainingMs(trcExtraction);
  end;
begin
  Controller := TThrottleController.Create(10000, 0, 3000);
  try
    Job := TDownloadFile.LoadForTest(Format(CQueue,
      ['defaults:' + sLineBreak + '  base_interval_ms: 0' + sLineBreak]),
      'F:\queue\download.yaml');
    try
      Entries := Job.Entries;
      Assert.AreEqual(0, Entries[0].Options.BaseIntervalMs);
      Assert.AreEqual(1500, Entries[1].Options.BaseIntervalMs);
      Assert.AreEqual(Cardinal(0), BaseGapMs(Entries[0], 3000),
        'An explicit YAML 0 overrides the CLI base gap');
      GapMs := BaseGapMs(Entries[1], 3000);
      Assert.IsTrue((GapMs >= 1000) and (GapMs <= 1500),
        Format('The per-entry value overrides the defaults, got %d ms', [GapMs]));
    finally
      Job.Free;
    end;

    Job := TDownloadFile.LoadForTest(Format(CQueue, ['']),
      'F:\queue\download.yaml');
    try
      Entries := Job.Entries;
      Assert.AreEqual(-1, Entries[0].Options.BaseIntervalMs,
        'A missing base_interval_ms leaves the CLI value in charge');
      GapMs := BaseGapMs(Entries[0], 2000);
      Assert.IsTrue((GapMs >= 1500) and (GapMs <= 2000),
        Format('Without a YAML value the CLI --base-interval-ms applies, got %d ms',
          [GapMs]));
    finally
      Job.Free;
    end;

    Assert.WillRaise(
      procedure
      begin
        TDownloadFile.LoadForTest(Format(CQueue,
          ['defaults:' + sLineBreak + '  base_interval_ms: -1' + sLineBreak]),
          'F:\queue\download.yaml').Free;
      end, EDownloadFileError);
  finally
    Controller.Free;
  end;
end;

const
  CLoggedOutMarker = 'running logged out';
  CBotChallenge =
    'ERROR: [youtube] abc: Sign in to confirm you''re not a bot. Use --cookies-from-browser or --cookies for the authentication.';

function CountText(const aText, aPart: string): Integer;
var
  lPos: Integer;
begin
  Result := 0;
  lPos := Pos(aPart, aText);
  while lPos > 0 do
  begin
    Inc(Result);
    lPos := PosEx(aPart, aText, lPos + Length(aPart));
  end;
end;

// Service.FetchTranscript with extra yt-dlp arguments; returns the class
// name of the raised exception, or ''.
function FetchWithArgsRaises(const aService: TTranscriptService;
  const aUrl, aExtraArgs: string): string;
begin
  Result := '';
  try
    aService.FetchTranscript(aUrl, 'en', aExtraArgs);
  except
    on E: Exception do
      Result := E.ClassName;
  end;
end;

procedure TDownloadFileTests.AutoCookiesSkipFailingBrowser;
var
  Probed, Console, Args: string;
  Config: TCommandLineConfig;
begin
  Probed := '';
  Console := '';
  ResetCookieState(
    function(const aBrowser: string; out aError: string): Boolean
    begin
      Probed := Probed + aBrowser + ' ';
      Result := aBrowser = 'chrome';
      if Result then
        aError := ''
      else
        aError := 'Failed to decrypt with DPAPI';
    end,
    procedure(const aText: string)
    begin
      Console := Console + aText + sLineBreak;
    end);
  try
    Assert.AreEqual('chrome', EffectiveCookiesFromBrowser('auto'));
    Assert.AreEqual('chrome', EffectiveCookiesFromBrowser(' AUTO '));
    Assert.AreEqual('firefox chrome', Trim(Probed),
      'Firefox is tried first and auto is resolved once per process');
    Assert.AreEqual('firefox:default-release',
      EffectiveCookiesFromBrowser(' firefox:default-release '));
    Config := Default(TCommandLineConfig);
    Config.CookiesFromBrowser := 'auto';
    Assert.IsTrue(HasEffectiveCookieSource(Config));
    Args := BuildYtDlpAuthArguments(Config);
    Assert.IsTrue(ContainsText(Args, '--cookies-from-browser "chrome"'), Args);
    Assert.IsFalse(ContainsText(Args, '"auto"'), Args);
    Assert.IsTrue(ContainsText(Console, 'firefox') and
      ContainsText(Console, 'DPAPI'), 'The firefox failure is reported: ' + Console);
    Assert.AreEqual(1, CountText(Console, 'using chrome'),
      'One line names the chosen browser: ' + Console);
    Assert.IsFalse(ReportLoggedOutAtStart(HasEffectiveCookieSource(Config)));
    Assert.AreEqual(0, CountText(Console, CLoggedOutMarker));
  finally
    ResetCookieState;
  end;
end;

procedure TDownloadFileTests.AutoCookiesAllFailingRunsLoggedOut;
var
  Probed, Console, Args: string;
  Config: TCommandLineConfig;
begin
  Probed := '';
  Console := '';
  ResetCookieState(
    function(const aBrowser: string; out aError: string): Boolean
    begin
      Probed := Probed + aBrowser + ' ';
      aError := 'Could not copy Chrome cookie database';
      Result := False;
    end,
    procedure(const aText: string)
    begin
      Console := Console + aText + sLineBreak;
    end);
  try
    Config := Default(TCommandLineConfig);
    Config.CookiesFromBrowser := 'auto';
    Assert.IsFalse(HasEffectiveCookieSource(Config));
    Assert.AreEqual('', EffectiveCookiesFromBrowser('auto'));
    Assert.AreEqual('firefox chrome edge', Trim(Probed));
    Args := BuildYtDlpAuthArguments(Config);
    Assert.IsFalse(ContainsText(Args, '--cookies'), Args);
    Assert.AreEqual(1, CountText(Console, 'no browser'),
      'One warning says no browser worked: ' + Console);
    Assert.IsTrue(ReportLoggedOutAtStart(HasEffectiveCookieSource(Config)));
    Assert.AreEqual(1, CountText(Console, CLoggedOutMarker));
  finally
    ResetCookieState;
  end;
end;

procedure TDownloadFileTests.LoggedOutNoticeShowsOncePerTrigger;
const
  CUrl = 'https://www.youtube.com/watch?v=noticeAAAAA';
  CBotUrl = 'https://www.youtube.com/watch?v=noticeBBBBB';
var
  Console: string;
  Controller: TThrottleController;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
begin
  Console := '';
  ResetCookieState(
    function(const aBrowser: string; out aError: string): Boolean
    begin
      Assert.Fail('No cookie source is auto; the probe must not run');
      Result := False;
    end,
    procedure(const aText: string)
    begin
      Console := Console + aText + sLineBreak;
    end);
  Controller := TThrottleController.Create(0, 0, 0);
  Fake := TFakeYtDlp.Create(LoadFixture('info-manual-subs.json'));
  Fake.SubtitleErrors := [CSubtitle429, CSubtitle429];
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  SetThrottleContext(Controller, nil);
  try
    Assert.IsTrue(ReportLoggedOutAtStart(False));
    Assert.IsFalse(ReportLoggedOutAtStart(False));
    Assert.AreEqual(1, CountText(Console, CLoggedOutMarker), Console);
    Assert.IsTrue(FetchRaises(Service, CUrl, 'en') = 'EThrottleError');
    Assert.AreEqual(2, CountText(Console, CLoggedOutMarker),
      'The first 429 repeats the notice: ' + Console);
    Controller.RestoreState(0, 0, 0);
    Assert.IsTrue(FetchRaises(Service, CUrl, 'en') = 'EThrottleError');
    Assert.AreEqual(2, CountText(Console, CLoggedOutMarker),
      'Later 429s do not repeat it: ' + Console);
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Controller.Free;
  end;

  // A bot challenge is the other trigger.
  Console := '';
  ResetCookieState(nil,
    procedure(const aText: string)
    begin
      Console := Console + aText + sLineBreak;
    end);
  Controller := TThrottleController.Create(0, 0, 0);
  Fake := TFakeYtDlp.Create(LoadFixture('info-manual-subs.json'));
  Fake.SubtitleErrors := [CBotChallenge];
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  SetThrottleContext(Controller, nil);
  try
    Assert.IsTrue(FetchRaises(Service, CBotUrl, 'en') = 'EThrottleError');
    Assert.AreEqual(1, CountText(Console, CLoggedOutMarker), Console);
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Controller.Free;
    ResetCookieState;
  end;
end;

procedure TDownloadFileTests.CookieSourceSuppressesLoggedOutNotice;
const
  CUrl = 'https://www.youtube.com/watch?v=noticeCCCCC';
var
  Console: string;
  Config: TCommandLineConfig;
  Controller: TThrottleController;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
begin
  Console := '';
  ResetCookieState(
    function(const aBrowser: string; out aError: string): Boolean
    begin
      Assert.Fail('An explicit browser must not be probed');
      Result := False;
    end,
    procedure(const aText: string)
    begin
      Console := Console + aText + sLineBreak;
    end);
  Controller := TThrottleController.Create(0, 0, 0);
  Fake := TFakeYtDlp.Create(LoadFixture('info-manual-subs.json'));
  Fake.SubtitleErrors := [CSubtitle429];
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  SetThrottleContext(Controller, nil);
  try
    Config := Default(TCommandLineConfig);
    Config.CookiesFromBrowser := 'firefox';
    Assert.IsTrue(HasEffectiveCookieSource(Config));
    Config := Default(TCommandLineConfig);
    Config.CookiesFile := 'cookies.txt';
    Assert.IsTrue(HasEffectiveCookieSource(Config));
    Assert.IsFalse(ReportLoggedOutAtStart(HasEffectiveCookieSource(Config)));
    Assert.IsTrue(FetchWithArgsRaises(Service, CUrl,
      ' --cookies-from-browser "firefox"') = 'EThrottleError');
    Assert.AreEqual(0, CountText(Console, CLoggedOutMarker), Console);
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Controller.Free;
    ResetCookieState;
  end;
end;

procedure TDownloadFileTests.CookieFileSuppressesThrottleNotice;
const
  CUrl = 'https://www.youtube.com/watch?v=noticeDDDDD';
var
  Console: string;
  Controller: TThrottleController;
  Fake: TFakeYtDlp;
  Service: TTranscriptService;
begin
  Console := '';
  ResetCookieState(nil,
    procedure(const aText: string)
    begin
      Console := Console + aText + sLineBreak;
    end);
  Controller := TThrottleController.Create(0, 0, 0);
  Fake := TFakeYtDlp.Create(LoadFixture('info-manual-subs.json'));
  Fake.SubtitleErrors := [CSubtitle429];
  Service := TTranscriptService.Create(trmReturnToQueue, Fake.Runner());
  SetThrottleContext(Controller, nil);
  try
    Assert.IsTrue(FetchWithArgsRaises(Service, CUrl,
      ' --cookies "C:\cookies\youtube.txt"') = 'EThrottleError');
    Assert.AreEqual(0, CountText(Console, CLoggedOutMarker), Console);
  finally
    SetThrottleContext(nil, nil);
    Service.Free;
    Fake.Free;
    Controller.Free;
    ResetCookieState;
  end;
end;

procedure TDownloadFileTests.CookieProbeRequiresSignedInSession;
const
  CFakeValue = 'FAKEVALUE123';
  CUrlError = 'ERROR: You must provide at least one URL.';
var
  VisitorJar, LoginJar, HttpOnlyJar: TArray<string>;
  Error: string;
begin
  VisitorJar := [
    '# Netscape HTTP Cookie File',
    '.youtube.com'#9'TRUE'#9'/'#9'TRUE'#9'1800000000'#9'VISITOR_INFO1_LIVE'#9 + CFakeValue,
    '.youtube.com'#9'TRUE'#9'/'#9'TRUE'#9'0'#9'YSC'#9 + CFakeValue,
    // A login cookie for another domain does not count.
    '.google.com'#9'TRUE'#9'/'#9'TRUE'#9'1800000000'#9'SAPISID'#9 + CFakeValue,
    // The value field must not be matched as a name.
    '.youtube.com'#9'TRUE'#9'/'#9'TRUE'#9'1800000000'#9'PREF'#9'LOGIN_INFO'];
  LoginJar := VisitorJar + [
    '.youtube.com'#9'TRUE'#9'/'#9'TRUE'#9'1800000000'#9'SAPISID'#9 + CFakeValue];
  HttpOnlyJar := [
    '#HttpOnly_.youtube.com'#9'TRUE'#9'/'#9'TRUE'#9'1800000000'#9'__Secure-3PSID'#9 + CFakeValue];

  Assert.IsFalse(CookieJarHasYouTubeLogin(VisitorJar));
  Assert.IsTrue(CookieJarHasYouTubeLogin(LoginJar));
  Assert.IsTrue(CookieJarHasYouTubeLogin(HttpOnlyJar));
  Assert.IsTrue(CookieJarHasYouTubeLogin(
    ['.youtube.com'#9'TRUE'#9'/'#9'TRUE'#9'1800000000'#9'LOGIN_INFO'#9 + CFakeValue]));
  Assert.IsFalse(CookieJarHasYouTubeLogin([]));

  Assert.IsTrue(InterpretCookieProbe(LoginJar, CUrlError, Error));
  Assert.IsFalse(InterpretCookieProbe(VisitorJar, CUrlError, Error));
  Assert.AreEqual('no signed-in YouTube session', Error);
  Assert.IsFalse(InterpretCookieProbe([], 'Extracting cookies from chrome' + sLineBreak +
    'ERROR: Failed to decrypt with DPAPI. See https://github.com/yt-dlp/yt-dlp/issues/10927' +
    sLineBreak + CUrlError, Error));
  Assert.AreEqual('Failed to decrypt with DPAPI. See https://github.com/yt-dlp/yt-dlp/issues/10927',
    Error);
  Assert.IsFalse(ContainsText(Error, CFakeValue));
end;

procedure TDownloadFileTests.StaleCookieProbeJarsAreDeleted;
var
  Dir: string;
begin
  Dir := TPath.Combine(TPath.GetTempPath, 'yttrans-probe-cleanup-' +
    TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(Dir);
  try
    TFile.WriteAllText(TPath.Combine(Dir, 'yttrans-cookie-probe-a.txt'), 'x');
    TFile.WriteAllText(TPath.Combine(Dir, 'yttrans-cookie-probe-{B}.txt'), 'x');
    TFile.WriteAllText(TPath.Combine(Dir, 'yttrans-cookie-probe-c.log'), 'x');
    TFile.WriteAllText(TPath.Combine(Dir, 'cookies.txt'), 'x');
    DeleteStaleCookieProbeJars(Dir);
    Assert.IsFalse(TFile.Exists(TPath.Combine(Dir, 'yttrans-cookie-probe-a.txt')));
    Assert.IsFalse(TFile.Exists(TPath.Combine(Dir, 'yttrans-cookie-probe-{B}.txt')));
    Assert.IsTrue(TFile.Exists(TPath.Combine(Dir, 'yttrans-cookie-probe-c.log')));
    Assert.IsTrue(TFile.Exists(TPath.Combine(Dir, 'cookies.txt')));
    // Best effort: a missing directory is ignored silently.
    DeleteStaleCookieProbeJars(TPath.Combine(Dir, 'missing'));
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.TranscriptWriteReplacesAtomically;
var
  Dir, Target: string;
begin
  Dir := TPath.Combine(TPath.GetTempPath, 'yttrans-atomic-' +
    TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(Dir);
  try
    Target := TPath.Combine(Dir, 'Video.md');
    TFile.WriteAllText(Target, 'old text', TEncoding.UTF8);

    WriteTranscriptFile(Target, 'new text');

    Assert.AreEqual('new text', TFile.ReadAllText(Target, TEncoding.UTF8));
    Assert.AreEqual(1, Length(TDirectory.GetFiles(Dir)),
      'The write leaves the final file and no temp file');
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.LeftoverTranscriptTempIsIgnored;
var
  Dir, FileName: string;
begin
  Dir := TPath.Combine(TPath.GetTempPath, 'yttrans-leftover-' +
    TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(Dir);
  try
    TFile.WriteAllText(TPath.Combine(Dir, '.yttrans-0123abcd.tmp'),
      '---' + sLineBreak + 'video_id: abcDEF12345' + sLineBreak,
      TEncoding.UTF8);
    Assert.IsFalse(FindExistingStandaloneOutput(Dir,
      'https://www.youtube.com/watch?v=abcDEF12345', FileName),
      'A partial temp file must not count as a saved transcript');
    Assert.AreEqual(0, Length(TranscriptFiles(Dir)));

    TFile.WriteAllText(TPath.Combine(Dir, 'Video.md'),
      '---' + sLineBreak + 'video_id: abcDEF12345' + sLineBreak,
      TEncoding.UTF8);
    Assert.IsTrue(FindExistingStandaloneOutput(Dir,
      'https://www.youtube.com/watch?v=abcDEF12345', FileName));
    Assert.AreEqual(TPath.Combine(Dir, 'Video.md'), FileName);
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

function AllMetaOptions: TMetaOptions;
begin
  Result.Url := True;
  Result.Title := True;
  Result.Channel := True;
  Result.Created := True;
  Result.Keywords := True;
  Result.VideoId := True;
  Result.Uploader := True;
  Result.UploaderId := True;
  Result.ChannelId := True;
  Result.Duration := True;
  Result.ViewCount := True;
  Result.LikeCount := True;
  Result.CommentCount := True;
  Result.Tags := True;
  Result.Description := True;
end;

// The YAML text between the opening and closing `---` lines.
function FrontMatterBody(const aSection: string): string;
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.Text := aSection;
    Assert.AreEqual('---', Lines[0]);
    Lines.Delete(0);
    while (Lines.Count > 0) and (Lines[Lines.Count - 1] <> '---') do
      Lines.Delete(Lines.Count - 1);
    Lines.Delete(Lines.Count - 1);
    Result := Lines.Text;
  finally
    Lines.Free;
  end;
end;

procedure TDownloadFileTests.FrontMatterQuotesOnlyWhenNeeded;
var
  Meta: TTranscriptMetadata;
  Text: string;
begin
  Meta := Default(TTranscriptMetadata);
  Meta.Url := 'https://www.youtube.com/watch?v=abcDEF12345';
  Meta.Title := 'Plot Twists: Why "Surprise" Works #1';
  Meta.Channel := 'Example Story Lab';
  Meta.Created := '2024-03-15';
  Meta.VideoId := 'abcDEF12345';
  Meta.ViewCount := '20035';
  Meta.Tags := 'writing, plot twists';
  Meta.Description := 'Chapters:'#10'00:00 Intro'#10#10'---'#10'video_id: fake';
  Text := BuildMetaSection(Meta, '', AllMetaOptions);

  // Simple values stay plain.
  Assert.Contains(Text, sLineBreak + 'url: https://www.youtube.com/watch?v=abcDEF12345' + sLineBreak);
  Assert.Contains(Text, sLineBreak + 'channel: Example Story Lab' + sLineBreak);
  Assert.Contains(Text, sLineBreak + 'created: 2024-03-15' + sLineBreak);
  Assert.Contains(Text, sLineBreak + 'video_id: abcDEF12345' + sLineBreak);
  Assert.Contains(Text, sLineBreak + 'view_count: 20035' + sLineBreak);
  Assert.Contains(Text, sLineBreak + 'tags: writing, plot twists' + sLineBreak);
  // `: ` and ` #` force double quotes with escaping.
  Assert.Contains(Text, sLineBreak +
    'title: "Plot Twists: Why \"Surprise\" Works #1"' + sLineBreak);
  // The description is an indented literal block.
  Assert.Contains(Text, sLineBreak + 'description: |-' + sLineBreak +
    '  Chapters:' + sLineBreak + '  00:00 Intro' + sLineBreak + sLineBreak +
    '  ---' + sLineBreak + '  video_id: fake' + sLineBreak + '---' + sLineBreak);
end;

procedure TDownloadFileTests.FrontMatterRoundTripsThroughYaml;
const
  CTitles: array[0..33] of string = (
    'Plot Twists: Why "Surprise" Works', 'Ends with colon:',
    'Hash #tag inside', '- Leading dash', '-dash-no-space', '"Quoted" start',
    '''Single'' start', '#hashtag first', '[Bracket] title', '{Brace} title',
    '& ampersand', '* star', '! bang', '| pipe', '> greater', '% percent',
    '@ at', '`tick`', '? question', ': colon first', 'true', 'No', 'null', '~',
    '123', '1.5', 'Back\slash', 'Tab'#9'inside', 'Normal title',
    'Emoji '#$2705' title', 'a: b', 'C:\path', ' padded ', 'x, y');
  CDescription = '  Indented first line'#13#10'second: line'#13#10#13#10 +
    '# not a comment'#13#10'"quoted" line'#13#10'---'#13#10'last';
var
  Meta: TTranscriptMetadata;
  Section, Dir, FileName, Expected: string;
  Map: IYAMLMapping;
begin
  Expected := StringReplace(CDescription, #13#10, #10, [rfReplaceAll]);
  Dir := TPath.Combine(TPath.GetTempPath, 'yttrans-front-matter-' +
    TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(Dir);
  try
    FileName := TPath.Combine(Dir, 'Video.md');
    for var Title in CTitles do
    begin
      Meta := Default(TTranscriptMetadata);
      Meta.Url := 'https://www.youtube.com/watch?v=-bcDEF12345';
      Meta.Title := Title;
      Meta.Channel := 'Example: Lab';
      Meta.VideoId := '-bcDEF12345';
      Meta.ViewCount := '42';
      Meta.Description := CDescription;
      Section := BuildMetaSection(Meta, 'alpha, beta', AllMetaOptions);

      Map := TYAML.LoadFromString(FrontMatterBody(Section)).AsMapping;
      Assert.IsTrue(Map['title'].IsString, 'title type: ' + Title);
      Assert.AreEqual(Title, Map['title'].AsString, 'title: ' + Title);
      Assert.AreEqual('Example: Lab', Map['channel'].AsString);
      Assert.IsTrue(Map['video_id'].IsString);
      Assert.AreEqual('-bcDEF12345', Map['video_id'].AsString);
      Assert.IsTrue(Map['view_count'].IsInteger);
      // VSoft.YAML keeps the file's CRLF breaks inside a block value.
      Assert.AreEqual(Expected, StringReplace(Map['description'].AsString,
        #13#10, #10, [rfReplaceAll]), 'description: ' + Title);
      Assert.AreEqual('alpha, beta', Map['keywords'].AsString);

      TFile.WriteAllText(FileName, Section + 'transcript text', TEncoding.UTF8);
      Assert.AreEqual(Title, ReadFrontMatterValue(FileName, 'title'),
        'reader title: ' + Title);
      Assert.AreEqual('-bcDEF12345', ReadFrontMatterValue(FileName, 'video_id'));
      Assert.AreEqual('Example: Lab', ReadFrontMatterValue(FileName, 'channel'));
      Assert.AreEqual(Expected, ReadFrontMatterValue(FileName, 'description'));
      Assert.AreEqual('alpha, beta', ReadFrontMatterValue(FileName, 'keywords'),
        'Lines inside the description block are not keys');
    end;
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.LegacyFrontMatterStillYieldsVideoId;
var
  FileName: string;
begin
  // Shape of a file written before front matter was quoted: a title with
  // `: ` and a leading quote, and a multi-line unindented description.
  FileName := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\tests\fixtures\transcript-legacy-front-matter.md'));
  Assert.AreEqual('Lg7cyA0x9Qk', ReadFrontMatterValue(FileName, 'video_id'));
  Assert.AreEqual('Example Story Lab', ReadFrontMatterValue(FileName, 'channel'));
  Assert.AreEqual('"Surprise" Isn''t Enough: Plot Twists #writing',
    ReadFrontMatterValue(FileName, 'title'));
  Assert.AreEqual('', ReadFrontMatterValue(FileName, 'missing_key'));
end;

procedure TDownloadFileTests.TranscriptWriteFitsNearMaxPath;
const
  CFinalPathLength = 250; // under MAX_PATH (260); the exe is not long-path aware
var
  Dir, Target: string;
  NameLength: Integer;
begin
  Dir := TPath.Combine(TPath.GetTempPath, 'yttrans-long-' +
    Copy(TGUID.NewGuid.ToString, 2, 8));
  TDirectory.CreateDirectory(Dir);
  try
    NameLength := CFinalPathLength - Length(Dir) - 1;
    Assert.IsTrue(NameLength >= 30, 'Temp directory path is too long for this test');
    Target := TPath.Combine(Dir, StringOfChar('a', NameLength - 3) + '.md');
    Assert.AreEqual(CFinalPathLength, Length(Target));

    WriteTranscriptFile(Target, 'text');

    Assert.AreEqual('text', TFile.ReadAllText(Target, TEncoding.UTF8));
    Assert.AreEqual(1, Length(TDirectory.GetFiles(Dir)));
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.TranscriptTempCleanupHonorsAgeAndShape;
var
  Dir, OldTemp, FreshTemp, IndexTemp, UserFile: string;
  Old: TDateTime;
begin
  Dir := TPath.Combine(TPath.GetTempPath, 'yttrans-cleanup-' +
    TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(Dir);
  try
    Old := IncHour(TTimeZone.Local.ToUniversalTime(Now), -2);
    // Left behind by a write that was killed before the move.
    OldTemp := TPath.Combine(Dir, '.yttrans-0123abcd.tmp');
    // Possibly another process's in-flight write.
    FreshTemp := TPath.Combine(Dir, '.yttrans-89abcdef.tmp');
    // The channel index keeps a failed candidate on purpose.
    IndexTemp := TPath.Combine(Dir, '.yttrans-channel-index.json.{B2}.tmp');
    UserFile := TPath.Combine(Dir, 'notes.tmp');
    for var FileName in [OldTemp, FreshTemp, IndexTemp, UserFile] do
      TFile.WriteAllText(FileName, '---' + sLineBreak + 'video_id: partial',
        TEncoding.UTF8);
    for var FileName in [OldTemp, IndexTemp, UserFile] do
      TFile.SetLastWriteTimeUtc(FileName, Old);

    WriteTranscriptFile(TPath.Combine(Dir, 'Video.md'), 'text');

    Assert.IsFalse(TFile.Exists(OldTemp), 'A stale yttrans temp file is removed');
    Assert.IsTrue(TFile.Exists(FreshTemp), 'A temp file younger than an hour stays');
    Assert.IsTrue(TFile.Exists(IndexTemp), 'Other temp shapes stay');
    Assert.IsTrue(TFile.Exists(UserFile), 'User files stay');
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.FrontMatterEscapesC1AndNonCharacters;
var
  Meta: TTranscriptMetadata;
  Section, Dir, FileName: string;
begin
  Meta := Default(TTranscriptMetadata);
  Meta.Title := 'a'#$0081'b'#$009F'c'#$FFFE'd'#$FFFF;
  Meta.VideoId := 'abcDEF12345';
  Meta.Description := 'line one'#10'bad'#$0086;
  Section := BuildMetaSection(Meta, '', AllMetaOptions);
  Assert.Contains(Section, sLineBreak +
    'title: "a\u0081b\u009Fc\u' + 'FFFEd\u' + 'FFFF"' + sLineBreak);
  Assert.Contains(Section, sLineBreak +
    'description: "line one\nbad\u0086"' + sLineBreak);

  Dir := TPath.Combine(TPath.GetTempPath, 'yttrans-c1-' + TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(Dir);
  try
    FileName := TPath.Combine(Dir, 'Video.md');
    TFile.WriteAllText(FileName, Section, TEncoding.UTF8);
    Assert.AreEqual(Meta.Title, ReadFrontMatterValue(FileName, 'title'));
    Assert.AreEqual(Meta.Description, ReadFrontMatterValue(FileName, 'description'));
  finally
    TDirectory.Delete(Dir, True);
  end;
end;

procedure TDownloadFileTests.FrontMatterQuotesSexagesimalValues;
var
  Meta: TTranscriptMetadata;
  Section: string;
begin
  // YAML 1.1 reads 12:34 as the base-60 integer 754.
  Meta := Default(TTranscriptMetadata);
  Meta.Title := '1:30';
  Meta.VideoId := 'abcDEF12345';
  Meta.Duration := '12:34';
  Meta.Uploader := '1:02:03';
  Meta.Channel := 'Part 1:30';
  Section := BuildMetaSection(Meta, '', AllMetaOptions);
  Assert.Contains(Section, sLineBreak + 'title: "1:30"' + sLineBreak);
  Assert.Contains(Section, sLineBreak + 'duration: "12:34"' + sLineBreak);
  Assert.Contains(Section, sLineBreak + 'uploader: "1:02:03"' + sLineBreak);
  Assert.Contains(Section, sLineBreak + 'channel: Part 1:30' + sLineBreak);
end;

// T-037: the settings.ini cookie fallback retries without cookies only when
// the cookies themselves failed, not on content errors reported with cookies.
procedure TDownloadFileTests.OnlyCookieFailuresRetryWithoutDefaultCookies;
const
  CExtracted = 'Extracting cookies from firefox' + sLineBreak +
    'Extracted 413 cookies from firefox' + sLineBreak;

  function Classify(const aMessage: string): Boolean;
  var
    lError: Exception;
  begin
    lError := Exception.Create(aMessage);
    try
      Result := IsCookieAuthFailure(lError);
    finally
      lError.Free;
    end;
  end;

var
  lThrottle: EThrottleError;
begin
  Assert.IsTrue(Classify('ERROR: could not find firefox cookies database in ' +
    'C:\Users\x\AppData\Roaming\Mozilla\Firefox\Profiles'));
  Assert.IsTrue(Classify('ERROR: Failed to decrypt with DPAPI. See ' +
    'https://github.com/yt-dlp/yt-dlp/issues/10927 for more info'));
  Assert.IsTrue(Classify('ERROR: Could not copy Chrome cookie database. See ' +
    'https://github.com/yt-dlp/yt-dlp/issues/7271 for more info'));
  Assert.IsTrue(Classify(CExtracted + 'WARNING: [youtube] The provided YouTube ' +
    'account cookies are no longer valid. They have likely been rotated'));
  Assert.IsTrue(Classify('sqlite3.OperationalError: database is locked'));

  Assert.IsFalse(Classify(CExtracted + 'yt-dlp did not produce an SRT subtitle ' +
    'file. The requested language might not be available or may have a ' +
    'different code.'), 'missing subtitles');
  Assert.IsFalse(Classify(CExtracted +
    'ERROR: [youtube] abc: Video unavailable. This video is private'),
    'unavailable video');
  Assert.IsFalse(Classify(CExtracted + 'ERROR: Unable to download video ' +
    'subtitles for ''en'': HTTP Error 429: Too Many Requests'), '429');
  lThrottle := EThrottleError.Create('could not find firefox cookies database');
  try
    Assert.IsFalse(IsCookieAuthFailure(lThrottle), 'throttle exception');
  finally
    lThrottle.Free;
  end;
end;

procedure TDownloadFileTests.DeprecatedJobsOptionIsIgnored;
var
  Config: TCommandLineConfig;
begin
  Config := ParseCommandLineArgs(['https://www.youtube.com/watch?v=abcDEF12345',
    '-c', '-j', '4', '--override']);
  Assert.IsTrue(Config.ChannelMode);
  Assert.IsTrue(Config.OverrideExisting, 'Options after -j <n> still parse');
  Assert.WillRaise(
    procedure
    begin
      ParseCommandLineArgs(['https://www.youtube.com/watch?v=abcDEF12345',
        '--jobs', '0']);
    end, EArgumentException);
end;

initialization
  TDUnitX.RegisterTestFixture(TDownloadFileTests);

end.
