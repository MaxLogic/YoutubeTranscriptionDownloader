unit YTTransApp;

interface

uses
  System.SysUtils, System.Classes, YTTrans.Throttle, YTTrans.DownloadFile;

type
  TMetaOptions = record
    Url         : Boolean;
    Title       : Boolean;
    Channel     : Boolean;
    Created     : Boolean;
    Keywords    : Boolean;
    VideoId     : Boolean;
    TranscriptLanguage: Boolean;
    Uploader    : Boolean;
    UploaderId  : Boolean;
    ChannelId   : Boolean;
    Duration    : Boolean;
    ViewCount   : Boolean;
    LikeCount   : Boolean;
    CommentCount: Boolean;
    Tags        : Boolean;
    Description : Boolean;
  end;

  TCommandLineConfig = record
    URL        : String;
    DownloadFileName: String;
    OutputTarget: String;    // Empty = no explicit output target
    OutputDir  : String;     // From settings.ini [default] output_dir (absolute)
    Language   : String;     // e.g. 'en', 'pl'
    ShowHelp   : Boolean;
    IncludeMeta: Boolean;
    Keywords   : String;     // Comma-separated list
    Prefix     : String;
    PrefixSeparator: String;
    MetaOptions: TMetaOptions;
    ChannelMode: Boolean;
    FileMode: Boolean;
    OverrideExisting: Boolean;
    ChannelOutputRoot: String;
    IncludeShorts: Boolean;
    IncludeLive: Boolean;
    CookiesFile: String;
    CookiesFromBrowser: String;
    CookiesFileExplicit: Boolean;
    CookiesFromBrowserExplicit: Boolean;
    RequestIntervalMs: Integer;
    DelayJitterMs: Integer;
    BaseIntervalMs: Integer;
    SleepRequestsSeconds: Integer;
    SleepSubtitlesSeconds: Integer; // deprecated: parsed, no longer passed on
    SocketTimeoutSeconds: Integer;
    RetryUnavailable: Boolean;
    RetryThrottledOnly: Boolean;
  end;

  TTranscriptMetadata = record
    Url    : String;
    Title  : String;
    Channel: String;
    Created: String;
    VideoId: String;
    // Language of the saved transcript text (track key without `-orig`).
    TranscriptLanguage: String;
    Uploader: String;
    UploaderId: String;
    ChannelId: String;
    ChannelUrl: String;
    UploaderUrl: String;
    Duration: String;
    ViewCount: String;
    LikeCount: String;
    CommentCount: String;
    Tags: String;
    Description: String;
    PublishedAt: String;
    class function FromJson(const aJson: string): TTranscriptMetadata; static;
    function HasData: Boolean;
  end;

  TTranscriptResult = record
    Transcript: String;
    Meta      : TTranscriptMetadata;
  end;

  TChannelVideo = record
    Url: String;
    PublishedAt: String;
    PublishedUnix: Int64;
    OriginalOrder: Integer;
  end;

  EThrottleError = class(Exception);
  // HTTP 429 on a machine-translated track that has an original to fall back to.
  ETranslationRateLimited = class(EThrottleError);

  // stkAutoTranslated: an automatic caption whose URL has `tlang`, i.e. a
  // machine translation of another language's ASR track.
  TSubtitleTrackKind = (stkNone, stkManual, stkAuto, stkAutoTranslated);

  // One signed timedtext track chosen from yt-dlp's info.json.
  TSubtitleTrack = record
    Language: string;   // info.json key, e.g. 'en'
    Kind: TSubtitleTrackKind;
    Url: string;
    ExpiresUtc: TDateTime; // from the URL's expire= parameter; 0 when absent
    function Found: Boolean;
    function IsReusable(const aNowUtc: TDateTime): Boolean;
  end;

  // Runs yt-dlp.exe with the given arguments; replaced by a fake in tests.
  TYtDlpRunner = reference to function(const aArguments: string;
    out aOutput, aError: string): Integer;

  // One gated, logged yt-dlp invocation. Build it with YtDlpCall.
  TYtDlpCall = record
    Operation: string;        // run-log `operation`
    Target: string;
    Arguments: string;
    CountsAsVideoRequest: Boolean;
    // False for a partial step (extraction before the subtitle download):
    // its success does not complete the video request.
    CompletesRequest: Boolean;
    RequestClass: TThrottleRequestClass;
    TrackKind: string;        // run-log `track_kind`, subtitle calls only
    // Consulted before an inline throttle retry with the UTC time the retry
    // could start; False aborts with ESubtitleUrlExpired.
    CanRetryAt: TFunc<TDateTime, Boolean>;
    // On HTTP 429, raise ETranslationRateLimited without throttle escalation,
    // inline retry or queue return: the caller has another track to try.
    RaiseOnThrottle: Boolean;
  end;

  TTranscriptService = class
  private
    FThrottleRetryMode: TThrottleRetryMode;
    FRunner: TYtDlpRunner;
    function ParseSrtContent(const aSrtContent: string): string;
    function CaptureYtDlpOutput(const aCall: TYtDlpCall;
      out aOutput, aError: string): Integer;
    function RunYtDlp(const aArguments: string;
      out aOutput, aError: string): Integer;
    function ExtractJsonFromOutput(const aOutput: string): string;
  public
    constructor Create(const aThrottleRetryMode: TThrottleRetryMode =
      trmRetryInline; const aRunner: TYtDlpRunner = nil);
    function FetchTranscript(const aUrl, aLanguage, aYtDlpExtraArgs: string;
      const aFallbackLanguage: string = ''): TTranscriptResult;
    function FetchMetadata(const aUrl, aYtDlpExtraArgs: string): TTranscriptMetadata;
    function ListChannelVideos(const aListUrl,
      aYtDlpExtraArgs: string): TArray<TChannelVideo>;
  end;

function ParseCommandLine: TCommandLineConfig;
// ParseCommandLine for an explicit argument list (without the exe name).
function ParseCommandLineArgs(const aArgs: TArray<string>): TCommandLineConfig;
function Run: Integer;
function IsYouTubeVideoUrl(const aUrl: string): Boolean;
function IsFatalProcessingException(const aException: Exception): Boolean;
function IsThrottleException(const aException: Exception): Boolean;
// True when a failed yt-dlp call made with the settings.ini default cookies
// failed because of those cookies (unreadable browser store, expired login),
// so a retry without cookies can help. Content errors are False.
function IsCookieAuthFailure(const aException: Exception): Boolean;
function FailureMessage(const aException: Exception): string;
function DownloadFileExitCode(const aFailedCount: Integer): Integer;
function ChannelRunHasErrors(const aFailed: Integer;
  const aDiscoveryError: string): Boolean;
function FileModeChannelAttemptLimit: Integer;
function RecordFileModeThrottle(const aController: TThrottleController;
  const aDiscoveryThrottles: TThrottleProbeTracker; const aEntryUrl: string;
  const aIsVideoEntry, aIsChannelDiscovery: Boolean;
  const aResponseKind: TThrottleResponseKind;
  out aAttempts: Integer): Boolean;
function ReportYtDlpResponse(const aController: TThrottleController;
  const aPolicy: TSourceThrottlePolicy; const aSource: string;
  const aSourceIsChannel: Boolean; const aExitCode: Integer;
  const aStdErr, aOperation, aTarget: string;
  const aCountsAsVideoRequest, aBoundedTargetRetries: Boolean;
  const aRequestClass: TThrottleRequestClass; out aDiagnostics: string;
  const aCompletesRequest: Boolean = True;
  const aAbsorbRateLimit: Boolean = False): TThrottleResponseKind;
procedure SortChannelVideosNewestFirst(var aVideos: TArray<TChannelVideo>);
// Picks an srt track: original tracks (manual, then untranslated automatic
// captions) in aOriginalLanguages order, then machine translations in
// aTranslationLanguages order, then the video's own language. Both lists
// empty selects only the video's own language. Found = False when none exists.
function SelectSubtitleTrack(const aInfoJson: string;
  const aOriginalLanguages, aTranslationLanguages: array of string): TSubtitleTrack; overload;
// The same with one list for originals and translations.
function SelectSubtitleTrack(const aInfoJson: string;
  const aLanguages: array of string): TSubtitleTrack; overload;
// Reduces info.json to the chosen track and drops webpage_url/original_url,
// so `yt-dlp --load-info-json` makes one timedtext request and cannot fall
// back to a full re-extraction.
function BuildSubtitleInfoJson(const aInfoJson: string;
  const aTrack: TSubtitleTrack): string;
// Run-log value of `track_kind`: manual, auto or auto_translated.
function SubtitleTrackKindToString(const aKind: TSubtitleTrackKind): string;
// Installs the shared throttle state used by yt-dlp calls. Run/RunDownloadFile
// set it; tests use it to drive TTranscriptService with a controller.
procedure SetThrottleContext(const aController: TThrottleController;
  const aPolicy: TSourceThrottlePolicy; const aSource: string = '';
  const aSourceIsChannel: Boolean = False);
// Number of saved subtitle sources awaiting a retry.
function SavedSubtitleSourceCount: Integer;
// Applies a YAML entry's pacing to the shared controller. The entry's
// base_interval_ms (when set, 0 included) overrides the CLI base gap.
procedure ApplyEntryPacing(const aController: TThrottleController;
  const aOptions: TDownloadOptions; const aCliBaseIntervalMs: Integer);

type
  // Loads one browser's cookies into a temporary jar without contacting
  // YouTube. True when the jar holds .youtube.com cookies; otherwise aError
  // says why. Replaced by a fake in tests.
  TCookieBrowserProbe = reference to function(const aBrowser: string;
    out aError: string): Boolean;
  TCookieMessageWriter = reference to procedure(const aText: string);

// Installs the probe behind cookies_from_browser=auto and the console writer
// for cookie messages, and forgets the resolved browser and the notices
// already shown. nil selects the real probe / WriteLn.
procedure ResetCookieState(const aProbe: TCookieBrowserProbe = nil;
  const aWriter: TCookieMessageWriter = nil);
// Returns aValue trimmed; `auto` resolves, once per process, to the first of
// firefox, chrome, edge whose probe succeeds, or '' when none does.
function EffectiveCookiesFromBrowser(const aValue: string): string;
function HasEffectiveCookieSource(const aConfig: TCommandLineConfig): Boolean;
// Prints the logged-out notice once per process when no cookie source is
// effective. Returns True when it printed.
function ReportLoggedOutAtStart(const aHasCookieSource: Boolean): Boolean;
function BuildYtDlpAuthArguments(const aConfig: TCommandLineConfig): string;
// True when a Netscape cookie jar holds a YouTube login cookie (SAPISID,
// __Secure-3PSID or LOGIN_INFO on a youtube.com row). Reads names only.
function CookieJarHasYouTubeLogin(const aLines: TArray<string>): Boolean;
// Evaluates one probe: success needs a login cookie in the jar. Otherwise
// aError is the first yt-dlp ERROR line (the missing-URL error excluded),
// or 'no signed-in YouTube session'.
function InterpretCookieProbe(const aJarLines: TArray<string>;
  const aStdErr: string; out aError: string): Boolean;
// Deletes leftover yttrans-cookie-probe-*.txt jars from aTempDir ('' = the
// user's temp folder). Best effort and silent.
procedure DeleteStaleCookieProbeJars(const aTempDir: string = '');
// Writes aText to a temp file beside aFileName, flushes it and moves it into
// place, so a kill mid-write never leaves a partial file under the final name.
procedure WriteFileAtomic(const aFileName, aText: string);
// WriteFileAtomic for a transcript .md file. First deletes temp files
// (.yttrans-<8 hex>.tmp) older than an hour that an interrupted write left in
// the same directory.
procedure WriteTranscriptFile(const aFileName, aText: string);
// The transcript (*.md) files directly in aDir; temp files are excluded.
function TranscriptFiles(const aDir: string): TArray<string>;
// The YAML front matter block (with `---` delimiters) for a transcript file.
// Values are plain when YAML allows it, otherwise double-quoted; the
// description is a `|-` literal block. Empty when nothing is enabled.
function BuildMetaSection(const aMeta: TTranscriptMetadata;
  const aKeywords: string; const aMetaOptions: TMetaOptions): string;
// A top-level front matter value, unquoted. Also reads files written before
// values were quoted, whose raw text follows the first `:`.
function ReadFrontMatterValue(const aFilePath, aKey: string): string;
// Finds a transcript in aOutputDir whose front matter video_id matches aUrl.
function FindExistingStandaloneOutput(const aOutputDir, aUrl: string;
  out aFileName: string): Boolean;


implementation

uses
  System.IOUtils, System.IniFiles, System.JSON, System.StrUtils, System.DateUtils,
  System.SyncObjs, System.Threading, System.Generics.Collections,
  System.Generics.Defaults, System.Net.HttpClient, Winapi.Windows,
  System.Diagnostics, System.RegularExpressions,
  autoFree, MaxLogic.ioUtils, YTTrans.ChannelIndex, YTTrans.ProcessRunner,
  VSoft.YAML;

resourcestring
  RSUsage =
    'YouTrans v1.0' + sLineBreak +
    'Usage: youtrans <URL> -l <lang> [options]' + sLineBreak +
    'Downloads transcript(s) using yt-dlp. Video mode is default; channel mode is optional.' + sLineBreak +
    sLineBreak +
    'Arguments:' + sLineBreak +
    '  <URL>                   The full URL of the YouTube video.' + sLineBreak +
    '  -f, --file <yaml>       Process one mutable YAML download queue.' + sLineBreak +
    '                            Channel indexes use RSS and reconcile every 30 days.' + sLineBreak +
    sLineBreak +
    'Options:' + sLineBreak +
    '  -l, --lang <lang_code>  Language code for subtitles (e.g., "en", "pl"). default is "en".' + sLineBreak +
    '                          Original en/de/pl tracks beat translations; see readme.' + sLineBreak +
    '  -o, --output <path>     Video mode: output file path/dir. Channel mode: root output directory.' + sLineBreak +
    '  -p, --prefix <text>     Prefix text for auto-generated file names.' + sLineBreak +
    '  -meta, --meta           Prepend YouTube metadata before the transcript output.' + sLineBreak +
    '  -keywords <list>         Comma-separated keywords added to metadata. Implies -meta.' + sLineBreak +
    '  -c, --channel           Download all videos from the channel owning <URL>.' + sLineBreak +
    '  -j, --jobs <n>          Deprecated and ignored; channel mode uses one worker.' + sLineBreak +
    '  -ov, --override         In channel mode, overwrite existing file with the same video_id.' + sLineBreak +
    '  -co, --channel-output <dir>  Root output directory override for channel mode.' + sLineBreak +
    '  -is, --include-shorts   In channel mode, include Shorts tab.' + sLineBreak +
    '  -il, --include-live     In channel mode, include Live/Streams tab.' + sLineBreak +
    '  --cookies <file>        Pass yt-dlp cookies file for authenticated requests.' + sLineBreak +
    '  --cookies-from-browser <browser>  Load cookies from browser profile (yt-dlp syntax).' + sLineBreak +
    '                            "auto" tries firefox, chrome, edge and uses the first that works.' + sLineBreak +
    '                            Defaults can be set in settings.ini [default] cookies_file/cookies_from_browser.' + sLineBreak +
    '  --request-interval-ms <n>  Minimum delay between subtitle downloads. Default: 10000.' + sLineBreak +
    '  -dj, --delay-jitter-ms <n>  Random delay added between subtitle downloads. Default: 10000.' + sLineBreak +
    '  --base-interval-ms <n>  Short gap before any YouTube request, capped at the' + sLineBreak +
    '                            subtitle interval. YAML base_interval_ms overrides it. Default: 3000.' + sLineBreak +
    '  --sleep-requests <n>    yt-dlp extraction-request delay in seconds. Default: 1.' + sLineBreak +
    '  --sleep-subtitles <n>   Deprecated; accepted and ignored.' + sLineBreak +
    '                            Cooldowns use adaptive levels; per-request sleeps stay bounded.' + sLineBreak +
    '  --socket-timeout <n>    yt-dlp network socket timeout in seconds. Default: 60; 0 uses yt-dlp default.' + sLineBreak +
    '  -ru, --retry-unavailable  Retry videos recorded as having no transcript.' + sLineBreak +
    '  -h, --help              Show this help and exit.' + sLineBreak;

  RSError = 'Error: %s';

const
  CSettingsFileName = 'settings.ini';
  CAutoUpdateSection = 'auto-update';
  CDefaultSection = 'default';
  CEnabledKey = 'enabled';
  CLastCheckKey = 'last-check';
  CIntervalKey = 'interval-in-days';
  CDefaultMetaKey = 'meta';
  CDefaultOutputDirKey = 'output_dir';
  CDefaultPrefixSeparatorKey = 'prefix_separator';
  CDefaultCookiesFileKey = 'cookies_file';
  CDefaultCookiesFromBrowserKey = 'cookies_from_browser';
  CMetaSection = 'meta';
  CDefaultLanguage = 'en';
  CUnavailableManifestFileName = '.yttrans-unavailable.json';
  CUnavailableManifestSchema = 2;
  CRetryAttempts = 4;
  CRetryBaseDelayMs = 600;
  CDefaultRequestIntervalMs = 10000;
  CDefaultDelayJitterMs = 10000;
  CDefaultSleepRequestsSeconds = 1;
  CDefaultSleepSubtitlesSeconds = 5;
  CDefaultSocketTimeoutSeconds = 60;
  CProgressIntervalItems = 100;
  CProgressIntervalMs = 60000;
  CCooldownProgressIntervalMs = 300000;
  CDefaultChannelSliceAttempts = 1;
  CDefaultPersistedThrottleCooldownMs = 5400000;

type
  TChannelConflictAction = (ccaWriteNew, ccaOverwrite, ccaSkip);

  TChannelRunStats = record
    Downloaded: Integer;
    Overwritten: Integer;
    Skipped: Integer;
    Unavailable: Integer;
    UnavailableCached: Integer;
    Failed: Integer;
    Processed: Integer;
    Total: Integer;
    Deferred: Integer;
    Attempted: Integer;
    SliceLimited: Boolean;
    DiscoveryErrorKind: string;
    DiscoveryError: string;
  end;

  TChannelProgressCallback = reference to procedure(
    const aProcessed, aTotal: Integer; const aStats: TChannelRunStats);

  TUnavailableVideo = record
    VideoId: string;
    Url: string;
    Title: string;
    PublishedAt: string;
    LastAttemptUtc: string;
    Status: string;
    ErrorKind: string;
    ErrorMessage: string;
  end;

  TUnavailableVideoMap = TDictionary<string, TUnavailableVideo>;

  TChannelDiscoveryCache = class
  public
    Initialized: Boolean;
    SeedMeta: TTranscriptMetadata;
    Videos: TArray<TChannelVideo>;
    YtDlpExtraArgs: string;
    ChannelDirectory: string;
    DiscoveryErrorKind: string;
    DiscoveryError: string;
    NextVideoIndex: Integer;
    OutputStateInitialized: Boolean;
    ExistingVideoIds: TDictionary<string, Byte>;
    UnavailableVideos: TUnavailableVideoMap;
    CompletedVideoIds: TDictionary<string, Byte>;
    TerminalFailureIds: TDictionary<string, Byte>;
    ThrottleProbes: TThrottleProbeTracker;
    constructor Create;
    destructor Destroy; override;
  end;

  EMissingTranscriptError = class(EFileNotFoundException)
  private
    FMetadata: TTranscriptMetadata;
  public
    constructor Create(const aMessage: string; const aMetadata: TTranscriptMetadata);
    property Metadata: TTranscriptMetadata read FMetadata;
  end;

  ESubtitleUrlExpired = class(Exception);

  // An extraction whose signed subtitle URL can be retried without
  // re-extracting the page.
  TSubtitleSource = record
    Meta: TTranscriptMetadata;
    Track: TSubtitleTrack;
    InfoJson: string; // reduced by BuildSubtitleInfoJson
    // For a machine-translated Track: the video's original-language track
    // and its reduced info.json, saved when the translation cannot be fetched.
    Fallback: TSubtitleTrack;
    FallbackInfoJson: string;
  end;

var
  GThrottleController: TThrottleController;
  GSourceThrottlePolicy: TSourceThrottlePolicy;
  GCurrentSource: string;
  GCurrentSourceIsChannel: Boolean;
  GThrottleCheckpointCallback: TProc;
  GInvocationLogLock: TCriticalSection;
  GInvocationLogFailed: Integer;
  // Subtitle sources whose timedtext download failed with a throttle, kept
  // for the retry (file mode returns the entry to the queue, so the service
  // instance does not survive). Entries are removed on success.
  GSubtitleSources: TDictionary<string, TSubtitleSource>;
  GSubtitleSourcesLock: TCriticalSection;
  // Cookie source state, guarded by GCookieLock; see ResetCookieState.
  GCookieLock: TCriticalSection;
  GCookieProbe: TCookieBrowserProbe;
  GCookieWriter: TCookieMessageWriter;
  GAutoCookieBrowserResolved: Boolean;
  GAutoCookieBrowser: string;
  GLoggedOutStartNoticeShown: Boolean;
  GLoggedOutThrottleNoticeShown: Boolean;

constructor EMissingTranscriptError.Create(
  const aMessage: string;
  const aMetadata: TTranscriptMetadata);
begin
  inherited Create(aMessage);
  FMetadata := aMetadata;
end;

constructor TChannelDiscoveryCache.Create;
begin
  inherited Create;
  ExistingVideoIds := TDictionary<string, Byte>.Create;
  UnavailableVideos := TUnavailableVideoMap.Create;
  CompletedVideoIds := TDictionary<string, Byte>.Create;
  TerminalFailureIds := TDictionary<string, Byte>.Create;
  ThrottleProbes := TThrottleProbeTracker.Create;
end;

destructor TChannelDiscoveryCache.Destroy;
begin
  ThrottleProbes.Free;
  TerminalFailureIds.Free;
  CompletedVideoIds.Free;
  UnavailableVideos.Free;
  ExistingVideoIds.Free;
  inherited;
end;

function UtcNowIso: string;
begin
  Result := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
end;

function UtcNow: TDateTime;
begin
  Result := TTimeZone.Local.ToUniversalTime(Now);
end;

{$WARN SYMBOL_DEPRECATED OFF}
function IsFatalProcessingException(const aException: Exception): Boolean;
var
  lInner: Exception;
begin
  // TTask.WaitForAll wraps channel-worker exceptions.
  if aException is EAggregateException then
  begin
    for lInner in EAggregateException(aException) do
      if IsFatalProcessingException(lInner) then
        Exit(True);
    Exit(False);
  end;
  Result := (aException is EAccessViolation) or
            (aException is EInvalidPointer) or
            (aException is EOutOfMemory) or
            (aException is EStackOverflow) or
            (aException is EPrivilege) or
            (aException is EAssertionFailed) or
            (aException is EAbstractError);
end;
{$WARN SYMBOL_DEPRECATED ON}

function DownloadFileExitCode(const aFailedCount: Integer): Integer;
begin
  if aFailedCount > 0 then
    Result := 1
  else
    Result := 0;
end;

function ChannelRunHasErrors(const aFailed: Integer;
  const aDiscoveryError: string): Boolean;
begin
  Result := (aFailed > 0) or (Trim(aDiscoveryError) <> '');
end;

function FileModeChannelAttemptLimit: Integer;
begin
  Result := CDefaultChannelSliceAttempts;
end;

function FailureMessage(const aException: Exception): string;
begin
  if (aException is EAggregateException) and
     (EAggregateException(aException).Count > 0) then
    Exit(FailureMessage(EAggregateException(aException)[0]));
  Result := aException.Message;
end;

function RecordFileModeThrottle(const aController: TThrottleController;
  const aDiscoveryThrottles: TThrottleProbeTracker; const aEntryUrl: string;
  const aIsVideoEntry, aIsChannelDiscovery: Boolean;
  const aResponseKind: TThrottleResponseKind;
  out aAttempts: Integer): Boolean;
begin
  // Channel discovery (metadata, listing, RSS) targets differ per request and
  // RSS has none, so the budget for a channel entry is kept per entry URL.
  // Like video targets, only HTTP 429 responses consume this budget.
  if aIsChannelDiscovery then
  begin
    if aResponseKind = trkRateLimit then
      aDiscoveryThrottles.MarkProbed(aEntryUrl);
    aAttempts := aDiscoveryThrottles.AttemptCount(aEntryUrl);
    Exit(aDiscoveryThrottles.IsExhausted(aEntryUrl));
  end;
  aAttempts := aController.RateLimitAttemptsForTarget(aEntryUrl);
  Result := aIsVideoEntry and (aAttempts >= 2);
end;

function ReportYtDlpResponse(const aController: TThrottleController;
  const aPolicy: TSourceThrottlePolicy; const aSource: string;
  const aSourceIsChannel: Boolean; const aExitCode: Integer;
  const aStdErr, aOperation, aTarget: string;
  const aCountsAsVideoRequest, aBoundedTargetRetries: Boolean;
  const aRequestClass: TThrottleRequestClass; out aDiagnostics: string;
  const aCompletesRequest, aAbsorbRateLimit: Boolean): TThrottleResponseKind;
var
  lApplyGlobalBackoff: Boolean;
begin
  aDiagnostics := TThrottleController.YtDlpDiagnostics(aStdErr);
  Result := TThrottleController.ClassifyResponse(aDiagnostics);
  lApplyGlobalBackoff := True;
  // A 429 the caller absorbs with another track (a machine translation with
  // an original to fall back to) takes no level, cooldown or target budget.
  if aAbsorbRateLimit and (Result = trkRateLimit) then
  begin
    if Assigned(aController) then
      aController.ReportResult(aExitCode, aDiagnostics, aRequestClass, False,
        aOperation, aTarget, False, False, False);
    Exit;
  end;
  if Assigned(aPolicy) and aCountsAsVideoRequest then
  begin
    if Result = trkRateLimit then
    begin
      lApplyGlobalBackoff := aPolicy.ReportFailure(aSource, aTarget,
        aSourceIsChannel, UtcNow);
      if not lApplyGlobalBackoff then
        WriteLn('Source-local HTTP 429; preserving shared recovery progress: ' + aSource);
    end
    else if (aExitCode = 0) and (Result = trkNone) and aCompletesRequest then
      aPolicy.CompleteProbe(aSource);
  end;
  if Assigned(aController) then
    aController.ReportResult(aExitCode, aDiagnostics, aRequestClass,
      aCountsAsVideoRequest and not Assigned(aPolicy), aOperation, aTarget,
      aBoundedTargetRetries, lApplyGlobalBackoff, aCompletesRequest);
end;

// Completes a video request whose last yt-dlp call was reported as a partial
// step, e.g. an extraction that found no caption track.
procedure CompleteVideoRequest(const aTarget: string;
  const aBoundedTargetRetries: Boolean);
begin
  if Assigned(GSourceThrottlePolicy) then
    GSourceThrottlePolicy.CompleteProbe(GCurrentSource);
  if Assigned(GThrottleController) then
    GThrottleController.CompleteTargetRequest(aTarget,
      not Assigned(GSourceThrottlePolicy), aBoundedTargetRetries);
end;

function JsonText(const aObject: TJSONObject; const aName: string): string;
var
  lValue: TJSONValue;
begin
  Result := '';
  if not Assigned(aObject) then
    Exit;
  lValue := aObject.Values[aName];
  if Assigned(lValue) then
    Result := lValue.Value;
end;

function GetUnavailableManifestPath(const aChannelDir: string): string;
begin
  Result := TPath.Combine(aChannelDir, CUnavailableManifestFileName);
end;

function LoadUnavailableVideos(const aChannelDir: string): TUnavailableVideoMap;
var
  lManifestPath: string;
  lJsonText: string;
  lJsonValue: TJSONValue;
  lRoot: TJSONObject;
  lVideosValue: TJSONValue;
  lVideos: TJSONArray;
  lItem: TJSONObject;
  lEntry: TUnavailableVideo;
  lSchema: Integer;
begin
  Result := TUnavailableVideoMap.Create;
  try
    lManifestPath := GetUnavailableManifestPath(aChannelDir);
    if not TFile.Exists(lManifestPath) then
      Exit;

    try
      lJsonText := TFile.ReadAllText(lManifestPath, TEncoding.UTF8);
    except
      lJsonText := TFile.ReadAllText(lManifestPath, TEncoding.Default);
    end;

    lJsonValue := TJSONObject.ParseJSONValue(lJsonText, False, True);
    if not (lJsonValue is TJSONObject) then
    begin
      lJsonValue.Free;
      raise EConvertError.CreateFmt('Invalid unavailable-video manifest: %s', [lManifestPath]);
    end;

    lRoot := TJSONObject(lJsonValue);
    try
      lSchema := StrToIntDef(JsonText(lRoot, 'schema'), -1);
      if (lSchema <> 1) and (lSchema <> CUnavailableManifestSchema) then
        raise EConvertError.CreateFmt(
          'Unsupported unavailable-video manifest schema %d in %s',
          [lSchema, lManifestPath]
        );

      lVideosValue := lRoot.Values['videos'];
      if not (lVideosValue is TJSONArray) then
        raise EConvertError.CreateFmt('Unavailable-video manifest has no videos array: %s', [lManifestPath]);

      lVideos := TJSONArray(lVideosValue);
      for var lIndex := 0 to lVideos.Count - 1 do
      begin
        if not (lVideos.Items[lIndex] is TJSONObject) then
          raise EConvertError.CreateFmt('Unavailable-video manifest contains an invalid entry: %s', [lManifestPath]);
        lItem := TJSONObject(lVideos.Items[lIndex]);
        lEntry := Default(TUnavailableVideo);
        lEntry.VideoId := Trim(JsonText(lItem, 'video_id'));
        if lEntry.VideoId = '' then
          raise EConvertError.CreateFmt('Unavailable-video manifest entry has no video_id: %s', [lManifestPath]);
        lEntry.Url := JsonText(lItem, 'url');
        lEntry.Title := JsonText(lItem, 'title');
        lEntry.PublishedAt := JsonText(lItem, 'published_at');
        lEntry.LastAttemptUtc := JsonText(lItem, 'last_attempt_utc');
        if lSchema = 1 then
        begin
          lEntry.Status := 'unavailable';
          lEntry.ErrorKind := 'unavailable';
        end
        else
        begin
          lEntry.Status := JsonText(lItem, 'status');
          lEntry.ErrorKind := JsonText(lItem, 'error_kind');
          lEntry.ErrorMessage := JsonText(lItem, 'error');
        end;
        Result.AddOrSetValue(lEntry.VideoId.ToLower, lEntry);
      end;
    finally
      lRoot.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

const
  // .yttrans-<8 hex>.tmp: short, so the temp path is not longer than the
  // final path in practice (the exe is not long-path aware), and never *.md.
  CAtomicTempPrefix = '.yttrans-';
  CAtomicTempPattern = '^\.yttrans-[0-9a-f]{8}\.tmp$';
  CStaleAtomicTempHours = 1;

procedure WriteFileAtomic(const aFileName, aText: string);
var
  lTempPath: string;
  lStream: TFileStream;
  lBytes: TBytes;
begin
  lTempPath := TPath.Combine(ExtractFileDir(aFileName), CAtomicTempPrefix +
    Copy(TGUID.NewGuid.ToString, 2, 8).ToLower + '.tmp');
  lBytes := TEncoding.UTF8.GetPreamble + TEncoding.UTF8.GetBytes(aText);
  // fmExclusive: create a new file, never take over another writer's temp.
  lStream := TFileStream.Create(lTempPath,
    fmCreate or fmExclusive or fmShareExclusive);
  try
    try
      lStream.WriteBuffer(lBytes, Length(lBytes));
      if not FlushFileBuffers(lStream.Handle) then
        RaiseLastOSError;
    finally
      lStream.Free;
    end;
    if not MoveFileEx(
      PChar(lTempPath),
      PChar(aFileName),
      MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH
    ) then
      RaiseLastOSError;
  finally
    // Never let cleanup mask the original error.
    try
      if TFile.Exists(lTempPath) then
        TFile.Delete(lTempPath);
    except
    end;
  end;
end;

procedure WriteTranscriptFile(const aFileName, aText: string);
var
  lDir: string;
  lCutoffUtc: TDateTime;
begin
  lDir := ExtractFileDir(aFileName);
  if (lDir <> '') and TDirectory.Exists(lDir) then
  begin
    // Only our own temp shape, and only when old enough that no concurrent
    // writer can still be using it.
    lCutoffUtc := IncHour(TTimeZone.Local.ToUniversalTime(Now),
      -CStaleAtomicTempHours);
    for var lTemp in TDirectory.GetFiles(lDir, CAtomicTempPrefix + '*.tmp',
      TSearchOption.soTopDirectoryOnly) do
      try
        if TRegEx.IsMatch(ExtractFileName(lTemp), CAtomicTempPattern,
             [roIgnoreCase]) and
           (TFile.GetLastWriteTimeUtc(lTemp) < lCutoffUtc) then
          TFile.Delete(lTemp);
      except
        // Best effort: a locked leftover is retried on the next write.
      end;
  end;
  WriteFileAtomic(aFileName, aText);
end;

function TranscriptFiles(const aDir: string): TArray<string>;
begin
  // Temp files end in .tmp, so the *.md pattern never lists them.
  Result := TDirectory.GetFiles(aDir, '*.md', TSearchOption.soTopDirectoryOnly);
end;

procedure SaveUnavailableVideos(
  const aChannelDir: string;
  const aVideos: TUnavailableVideoMap);
var
  lManifestPath: string;
  lRoot: TJSONObject;
  lArray: TJSONArray;
  lItem: TJSONObject;
  lKeys: TStringList;
  lEntry: TUnavailableVideo;
begin
  lManifestPath := GetUnavailableManifestPath(aChannelDir);
  lRoot := TJSONObject.Create;
  lKeys := TStringList.Create;
  try
    lRoot.AddPair('schema', TJSONNumber.Create(CUnavailableManifestSchema));
    lArray := TJSONArray.Create;
    lRoot.AddPair('videos', lArray);

    for var lKey in aVideos.Keys do
      lKeys.Add(lKey);
    lKeys.Sort;

    for var lKey in lKeys do
    begin
      lEntry := aVideos[lKey];
      lItem := TJSONObject.Create;
      lItem.AddPair('video_id', lEntry.VideoId);
      lItem.AddPair('url', lEntry.Url);
      lItem.AddPair('title', lEntry.Title);
      lItem.AddPair('published_at', lEntry.PublishedAt);
      lItem.AddPair('last_attempt_utc', lEntry.LastAttemptUtc);
      lItem.AddPair('status', lEntry.Status);
      lItem.AddPair('error_kind', lEntry.ErrorKind);
      lItem.AddPair('error', lEntry.ErrorMessage);
      lArray.AddElement(lItem);
    end;

    WriteFileAtomic(lManifestPath, lRoot.Format(2));
  finally
    lKeys.Free;
    lRoot.Free;
  end;
end;

function ParseBoolLike(const aValue: string; const aDefault: Boolean): Boolean;
var
  lRaw: string;
begin
  lRaw := Trim(aValue).ToLower;
  if lRaw.IsEmpty then
    Exit(aDefault);

  if (lRaw = '1') or (lRaw = 'true') or (lRaw = 't') or (lRaw = 'yes') or
     (lRaw = 'y') or (lRaw = 'on') or (lRaw = 'enabled') then
    Exit(True);
  if (lRaw = '0') or (lRaw = 'false') or (lRaw = 'f') or (lRaw = 'no') or
     (lRaw = 'n') or (lRaw = 'off') or (lRaw = 'disabled') then
    Exit(False);

  Result := aDefault;
end;

function GetSettingsPath: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), CSettingsFileName);
end;

function GetYtDlpPath: string;
begin
  Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'yt-dlp.exe');
end;

procedure EnsureDefaultSettingsFile(const aSettingsPath: string);
var
  lLines: TStringList;
begin
  if TFile.Exists(aSettingsPath) then
    Exit;

  lLines := TStringList.Create;
  try
    lLines.Add('[auto-update]');
    lLines.Add('enabled=1');
    lLines.Add('last-check=');
    lLines.Add('interval-in-days=7');
    lLines.Add('');
    lLines.Add('[default]');
    lLines.Add('meta=true');
    lLines.Add('output_dir=output\');
    lLines.Add('prefix_separator= - ');
    lLines.Add('cookies_file=');
    lLines.Add('cookies_from_browser=');
    lLines.Add('; cookies_from_browser=firefox');
    lLines.Add('; cookies_from_browser=auto');
    lLines.Add('; cookies_from_browser=firefox:default-release');
    lLines.Add('; cookies_from_browser=chrome:Profile 1');
    lLines.Add('');
    lLines.Add('[meta]');
    lLines.Add('url=true');
    lLines.Add('title=true');
    lLines.Add('channel=true');
    lLines.Add('created=true');
    lLines.Add('keywords=true');
    lLines.Add('video_id=true');
    lLines.Add('transcript_language=true');
    lLines.Add('uploader=true');
    lLines.Add('uploader_id=true');
    lLines.Add('channel_id=true');
    lLines.Add('duration=true');
    lLines.Add('view_count=true');
    lLines.Add('like_count=true');
    lLines.Add('comment_count=true');
    lLines.Add('tags=true');
    lLines.Add('description=false');
    lLines.SaveToFile(aSettingsPath, TEncoding.UTF8);
  finally
    lLines.Free;
  end;
end;

function ReadMetaOption(const aIni: TIniFile; const aKey: string; const aDefault: Boolean): Boolean;
begin
  Result := ParseBoolLike(aIni.ReadString(CMetaSection, aKey, BoolToStr(aDefault, True)), aDefault);
end;

procedure LoadMetaOptions(const aIni: TIniFile; var aMetaOptions: TMetaOptions);
begin
  aMetaOptions.Url := ReadMetaOption(aIni, 'url', True);
  aMetaOptions.Title := ReadMetaOption(aIni, 'title', True);
  aMetaOptions.Channel := ReadMetaOption(aIni, 'channel', True);
  aMetaOptions.Created := ReadMetaOption(aIni, 'created', True);
  aMetaOptions.Keywords := ReadMetaOption(aIni, 'keywords', True);
  aMetaOptions.VideoId := ReadMetaOption(aIni, 'video_id', True);
  aMetaOptions.TranscriptLanguage := ReadMetaOption(aIni, 'transcript_language', True);
  aMetaOptions.Uploader := ReadMetaOption(aIni, 'uploader', True);
  aMetaOptions.UploaderId := ReadMetaOption(aIni, 'uploader_id', True);
  aMetaOptions.ChannelId := ReadMetaOption(aIni, 'channel_id', True);
  aMetaOptions.Duration := ReadMetaOption(aIni, 'duration', True);
  aMetaOptions.ViewCount := ReadMetaOption(aIni, 'view_count', True);
  aMetaOptions.LikeCount := ReadMetaOption(aIni, 'like_count', True);
  aMetaOptions.CommentCount := ReadMetaOption(aIni, 'comment_count', True);
  aMetaOptions.Tags := ReadMetaOption(aIni, 'tags', True);
  aMetaOptions.Description := ReadMetaOption(aIni, 'description', False);
end;

function ReadEnabled(const aIni: TIniFile): Boolean;
var
  lRaw: string;
begin
  lRaw := Trim(aIni.ReadString(CAutoUpdateSection, CEnabledKey, '1'));
  Result := ParseBoolLike(lRaw, True);
end;

procedure LoadDefaultOptions(var aConfig: TCommandLineConfig);
var
  lSettingsPath: string;
  lIni: TIniFile;
  lOutputDirRaw: string;
begin
  lSettingsPath := GetSettingsPath;
  EnsureDefaultSettingsFile(lSettingsPath);

  lIni := TIniFile.Create(lSettingsPath);
  try
    aConfig.IncludeMeta := ParseBoolLike(
      lIni.ReadString(CDefaultSection, CDefaultMetaKey, 'true'),
      True
    );

    lOutputDirRaw := Trim(lIni.ReadString(CDefaultSection, CDefaultOutputDirKey, 'output\'));
    if not lOutputDirRaw.IsEmpty then
    begin
      if TPath.IsPathRooted(lOutputDirRaw) then
        aConfig.OutputDir := TPath.GetFullPath(lOutputDirRaw)
      else
        aConfig.OutputDir := TPath.GetFullPath(TPath.Combine(ExtractFilePath(ParamStr(0)), lOutputDirRaw));
    end;

    aConfig.PrefixSeparator := lIni.ReadString(CDefaultSection, CDefaultPrefixSeparatorKey, ' - ');
    aConfig.CookiesFile := Trim(lIni.ReadString(CDefaultSection, CDefaultCookiesFileKey, ''));
    aConfig.CookiesFromBrowser := Trim(lIni.ReadString(CDefaultSection, CDefaultCookiesFromBrowserKey, ''));
    LoadMetaOptions(lIni, aConfig.MetaOptions);
  finally
    lIni.Free;
  end;
end;

function TryParseLastCheck(const aValue: string; out aDate: TDateTime): Boolean;
var
  lYear: Integer;
  lMonth: Integer;
  lDay: Integer;
begin
  Result := False;
  if aValue.Trim.IsEmpty then
    Exit;

  Result := TryISO8601ToDate(aValue, aDate, True);
  if Result then
  begin
    aDate := DateOf(aDate);
    Exit;
  end;

  if (Length(aValue) = 10) and (aValue[5] = '-') and (aValue[8] = '-') and
     TryStrToInt(Copy(aValue, 1, 4), lYear) and
     TryStrToInt(Copy(aValue, 6, 2), lMonth) and
     TryStrToInt(Copy(aValue, 9, 2), lDay) then
    Result := TryEncodeDate(Word(lYear), Word(lMonth), Word(lDay), aDate);
end;

procedure UpdateLastCheck(const aSettingsPath: string; const aDate: TDateTime);
var
  lIni: TIniFile;
begin
  lIni := TIniFile.Create(aSettingsPath);
  try
    lIni.WriteString(CAutoUpdateSection, CLastCheckKey, FormatDateTime('yyyy-mm-dd', DateOf(aDate)));
  finally
    lIni.Free;
  end;
end;

procedure TryAutoUpdateYtDlp;
var
  lSettingsPath: string;
  lYtDlpPath: string;
  lIni: TIniFile;
  lEnabled: Boolean;
  lIntervalInDays: Integer;
  lLastCheckRaw: string;
  lLastCheck: TDateTime;
  lShouldCheck: Boolean;
begin
  lSettingsPath := GetSettingsPath;
  EnsureDefaultSettingsFile(lSettingsPath);

  lIni := TIniFile.Create(lSettingsPath);
  try
    lEnabled := ReadEnabled(lIni);
    lIntervalInDays := lIni.ReadInteger(CAutoUpdateSection, CIntervalKey, 7);
    if lIntervalInDays < 1 then
      lIntervalInDays := 1;
    lLastCheckRaw := lIni.ReadString(CAutoUpdateSection, CLastCheckKey, '');
  finally
    lIni.Free;
  end;

  if not lEnabled then
    Exit;

  lShouldCheck := not TryParseLastCheck(lLastCheckRaw, lLastCheck);
  if not lShouldCheck then
    lShouldCheck := DaysBetween(Date, DateOf(lLastCheck)) >= lIntervalInDays;
  if not lShouldCheck then
    Exit;

  lYtDlpPath := GetYtDlpPath;
  if not TFile.Exists(lYtDlpPath) then
  begin
    UpdateLastCheck(lSettingsPath, Date);
    Exit;
  end;

  try
    MaxLogic.ioutils.ExecuteFile(lYtDlpPath, '-U', '', True, True);
  except
    on E: Exception do
      WriteLn('Warning: yt-dlp auto-update failed: ', E.Message);
  end;

  UpdateLastCheck(lSettingsPath, Date);
end;

function IsYamlBreakOrControl(const aChar: Char): Boolean;
begin
  // C0, DEL, C1 (NEL included), line/paragraph separators, BOM and the
  // non-characters U+FFFE/U+FFFF: escaped as \u in double quotes.
  Result := (aChar < ' ') or ((aChar >= #$7F) and (aChar <= #$9F)) or
    (aChar = #$2028) or (aChar = #$2029) or (aChar = #$FEFF) or
    (aChar = #$FFFE) or (aChar = #$FFFF);
end;

// True when aValue can be written as a plain YAML scalar. With
// aMustStayString, values a parser would read as null, bool or number are
// rejected too, so titles such as `true` or `123` stay strings.
function IsPlainYamlScalar(const aValue: string;
  const aMustStayString: Boolean): Boolean;
var
  lFirst: Char;
  lLower: string;
  lNumber: Double;
  lInteger: Int64;
begin
  if (aValue = '') or (aValue <> Trim(aValue)) then
    Exit(False);
  for var lChar in aValue do
    if IsYamlBreakOrControl(lChar) then
      Exit(False);
  lFirst := aValue[1];
  if CharInSet(lFirst, ['!', '&', '*', '|', '>', '''', '"', '%', '@', '`',
    '#', ',', '[', ']', '{', '}']) then
    Exit(False);
  // `-`, `?` and `:` are indicators when followed by a space or alone.
  if CharInSet(lFirst, ['-', '?', ':']) and
     ((Length(aValue) = 1) or (aValue[2] = ' ')) then
    Exit(False);
  if (Pos(': ', aValue) > 0) or (Pos(' #', aValue) > 0) or
     (aValue[Length(aValue)] = ':') then
    Exit(False);
  // YAML 1.1 reads 12:34 as a base-60 integer, even for `duration`.
  if TRegEx.IsMatch(aValue, '^[0-9]+(:[0-9]+)+$') then
    Exit(False);
  if not aMustStayString then
    Exit(True);
  lLower := LowerCase(aValue);
  if MatchStr(lLower, ['~', 'null', 'true', 'false', 'yes', 'no', 'on', 'off',
    'y', 'n', '.inf', '-.inf', '+.inf', '.nan']) then
    Exit(False);
  // Numbers (0x1F and 1e3 included) and dates such as 2024-03-15.
  Result := not (TryStrToFloat(aValue, lNumber, TFormatSettings.Invariant) or
    TryStrToInt64(aValue, lInteger) or ((Length(aValue) >= 10) and
    CharInSet(aValue[1], ['0'..'9']) and (aValue[5] = '-') and
    (aValue[8] = '-')));
end;

function QuoteYamlScalar(const aValue: string): string;
var
  lBuilder: TStringBuilder;
begin
  lBuilder := TStringBuilder.Create(Length(aValue) + 2);
  try
    lBuilder.Append('"');
    for var lChar in aValue do
      case lChar of
        '"': lBuilder.Append('\"');
        '\': lBuilder.Append('\\');
        #9: lBuilder.Append('\t');
        #10: lBuilder.Append('\n');
        #13: lBuilder.Append('\r');
      else
        if IsYamlBreakOrControl(lChar) then
          lBuilder.Append('\u' + IntToHex(Ord(lChar), 4))
        else
          lBuilder.Append(lChar);
      end;
    lBuilder.Append('"');
    Result := lBuilder.ToString;
  finally
    lBuilder.Free;
  end;
end;

// A `|-` literal block, or a quoted scalar when the text holds characters a
// block cannot carry. Whitespace-only lines are written empty.
function YamlBlockScalar(const aValue: string): string;
var
  lLines: TArray<string>;
  lBuilder: TStringBuilder;
  lHeader: string;
  lText: string;
begin
  lText := StringReplace(aValue, #13#10, #10, [rfReplaceAll]);
  lText := StringReplace(lText, #13, #10, [rfReplaceAll]);
  for var lChar in lText do
    if (lChar <> #10) and (lChar <> #9) and IsYamlBreakOrControl(lChar) then
      Exit(QuoteYamlScalar(lText));
  lLines := lText.Split([#10]);
  lHeader := '|-';
  for var lLine in lLines do
    if Trim(lLine) <> '' then
    begin
      // An indented first line needs an explicit indentation indicator.
      if CharInSet(lLine[1], [' ', #9]) then
        lHeader := '|2-';
      Break;
    end;
  lBuilder := TStringBuilder.Create;
  try
    lBuilder.Append(lHeader);
    for var lLine in lLines do
    begin
      lBuilder.Append(sLineBreak);
      if Trim(lLine) <> '' then
        lBuilder.Append('  ').Append(lLine);
    end;
    Result := lBuilder.ToString;
  finally
    lBuilder.Free;
  end;
end;

function YamlScalar(const aValue: string; const aMustStayString: Boolean): string;
begin
  if IsPlainYamlScalar(aValue, aMustStayString) then
    Result := aValue
  else
    Result := QuoteYamlScalar(aValue);
end;

procedure AppendMetaLine(const aEnabled: Boolean; const aKey, aValue: string; const aBuilder: TStringBuilder);
begin
  if not (aEnabled and (Trim(aValue) <> '')) then
    Exit;
  if aKey = 'description' then
    aBuilder.AppendLine(aKey + ': ' + YamlBlockScalar(aValue))
  else
    // Dates and counts may resolve to their YAML types; text must stay text.
    aBuilder.AppendLine(aKey + ': ' + YamlScalar(aValue,
      not MatchStr(aKey, ['created', 'duration', 'view_count', 'like_count',
        'comment_count'])));
end;

function BuildMetaSection(const aMeta: TTranscriptMetadata; const aKeywords: string;
  const aMetaOptions: TMetaOptions): string;
var
  lBuilder: TStringBuilder;
  lHasKeywords: Boolean;
begin
  Result := '';
  lHasKeywords := not aKeywords.Trim.IsEmpty;
  if (not aMeta.HasData) and (not lHasKeywords) then
    Exit;

  lBuilder := TStringBuilder.Create;
  try
    lBuilder.AppendLine('---');
    AppendMetaLine(aMetaOptions.Url, 'url', aMeta.Url, lBuilder);
    AppendMetaLine(aMetaOptions.Title, 'title', aMeta.Title, lBuilder);
    AppendMetaLine(aMetaOptions.Channel, 'channel', aMeta.Channel, lBuilder);
    AppendMetaLine(aMetaOptions.Created, 'created', aMeta.Created, lBuilder);
    AppendMetaLine(aMetaOptions.VideoId, 'video_id', aMeta.VideoId, lBuilder);
    AppendMetaLine(aMetaOptions.TranscriptLanguage, 'transcript_language',
      aMeta.TranscriptLanguage, lBuilder);
    AppendMetaLine(aMetaOptions.Uploader, 'uploader', aMeta.Uploader, lBuilder);
    AppendMetaLine(aMetaOptions.UploaderId, 'uploader_id', aMeta.UploaderId, lBuilder);
    AppendMetaLine(aMetaOptions.ChannelId, 'channel_id', aMeta.ChannelId, lBuilder);
    AppendMetaLine(aMetaOptions.Duration, 'duration', aMeta.Duration, lBuilder);
    AppendMetaLine(aMetaOptions.ViewCount, 'view_count', aMeta.ViewCount, lBuilder);
    AppendMetaLine(aMetaOptions.LikeCount, 'like_count', aMeta.LikeCount, lBuilder);
    AppendMetaLine(aMetaOptions.CommentCount, 'comment_count', aMeta.CommentCount, lBuilder);
    AppendMetaLine(aMetaOptions.Tags, 'tags', aMeta.Tags, lBuilder);
    AppendMetaLine(aMetaOptions.Description, 'description', aMeta.Description, lBuilder);

    if lHasKeywords and aMetaOptions.Keywords then
      lBuilder.AppendLine('keywords: ' + YamlScalar(aKeywords.Trim, True));

    if lBuilder.Length > Length('---' + sLineBreak) then
    begin
      lBuilder.AppendLine('---');
      lBuilder.AppendLine;
      Result := lBuilder.ToString;
    end;
  finally
    lBuilder.Free;
  end;
end;

function NormalizeKeywords(const aRaw: string): string;
var
  lParts: TStringList;
  lItem: string;
begin
  Result := '';
  lParts := TStringList.Create;
  try
    lParts.StrictDelimiter := True;
    lParts.Delimiter := ',';
    lParts.DelimitedText := aRaw;
    for var x := 0 to lParts.Count - 1 do
    begin
      lItem := lParts[x];
      lItem := Trim(lItem);
      if lItem.IsEmpty then
        Continue;
      if Result <> '' then
        Result := Result + ', ';
      Result := Result + lItem;
    end;
  finally
    lParts.Free;
  end;
end;

function SanitizeFileNamePart(const aValue: string): string;
const
  CInvalidChars: array [0 .. 8] of Char = ('<', '>', ':', '"', '/', '\', '|', '?', '*');
var
  lChar: Char;
  lInvalid: Char;
  lSanitizedChar: Char;
  lReservedNames: TArray<string>;
begin
  Result := '';
  for lChar in aValue do
  begin
    lSanitizedChar := lChar;
    if Ord(lChar) < 32 then
    begin
      Result := Result + '_';
      Continue;
    end;

    for lInvalid in CInvalidChars do
      if lSanitizedChar = lInvalid then
      begin
        lSanitizedChar := '_';
        Break;
      end;

    Result := Result + lSanitizedChar;
  end;

  Result := Trim(Result);
  while (Result <> '') and ((Result[Length(Result)] = '.') or (Result[Length(Result)] = ' ')) do
    Delete(Result, Length(Result), 1);

  if Result = '' then
    Result := 'transcript';

  lReservedNames := TArray<string>.Create(
    'CON', 'PRN', 'AUX', 'NUL',
    'COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8', 'COM9',
    'LPT1', 'LPT2', 'LPT3', 'LPT4', 'LPT5', 'LPT6', 'LPT7', 'LPT8', 'LPT9'
  );
  for var lName in lReservedNames do
    if SameText(Result, lName) then
    begin
      Result := '_' + Result;
      Break;
    end;
end;

function IsDirectoryTarget(const aPath: string): Boolean;
var
  lPath: string;
begin
  lPath := Trim(aPath);
  if lPath = '' then
    Exit(False);

  if (lPath[Length(lPath)] = '\') or (lPath[Length(lPath)] = '/') then
    Exit(True);

  if TDirectory.Exists(TPath.GetFullPath(lPath)) then
    Exit(True);

  Result := False;
end;

function BuildGeneratedBaseName(const aConfig: TCommandLineConfig; const aMeta: TTranscriptMetadata): string;
var
  lTitle: string;
  lPrefix: string;
begin
  lTitle := SanitizeFileNamePart(aMeta.Title);
  lPrefix := SanitizeFileNamePart(aConfig.Prefix);

  if lPrefix.IsEmpty then
    Exit(lTitle);

  Result := lPrefix + aConfig.PrefixSeparator + lTitle;
end;

function EnsureUniqueFilePath(const aFilePath: string): string;
var
  lDir: string;
  lBaseName: string;
  lExt: string;
  lCandidate: string;
  lIndex: Integer;
begin
  if not TFile.Exists(aFilePath) then
    Exit(aFilePath);

  lDir := ExtractFileDir(aFilePath);
  lBaseName := ChangeFileExt(ExtractFileName(aFilePath), '');
  lExt := ExtractFileExt(aFilePath);

  lIndex := 2;
  repeat
    lCandidate := TPath.Combine(lDir, Format('%s (%d)%s', [lBaseName, lIndex, lExt]));
    Inc(lIndex);
  until not TFile.Exists(lCandidate);

  Result := lCandidate;
end;

function BuildOutputFilePath(const aConfig: TCommandLineConfig; const aMeta: TTranscriptMetadata): string;
var
  lBaseName: string;
  lBaseDir: string;
begin
  Result := '';
  lBaseName := BuildGeneratedBaseName(aConfig, aMeta);

  if not aConfig.OutputTarget.IsEmpty then
  begin
    if IsDirectoryTarget(aConfig.OutputTarget) then
    begin
      lBaseDir := TPath.GetFullPath(aConfig.OutputTarget);
      Result := TPath.Combine(lBaseDir, lBaseName + '.md');
    end
    else
      Result := TPath.GetFullPath(aConfig.OutputTarget);
    Exit;
  end;

  if not aConfig.OutputDir.IsEmpty then
    Result := TPath.Combine(aConfig.OutputDir, lBaseName + '.md');
end;

function NodeRuntimeAvailable: Boolean;
var
  lBuffer: array[0..MAX_PATH] of Char;
  lFilePart: PChar;
begin
  lFilePart := nil;
  Result := SearchPath(nil, 'node.exe', nil, Length(lBuffer), lBuffer,
    lFilePart) > 0;
end;

function BuildYtDlpPacingArguments(const aConfig: TCommandLineConfig): string;
var
  lSleepRequestsSeconds: Integer;
begin
  // No --sleep-subtitles: the throttle controller paces subtitle downloads
  // (TThrottleRequestClass.trcSubtitle), so SleepSubtitlesSeconds is unused.
  Result := '';
  lSleepRequestsSeconds := aConfig.SleepRequestsSeconds;
  if Assigned(GThrottleController) then
    lSleepRequestsSeconds := GThrottleController.EffectiveSleepSeconds(
      lSleepRequestsSeconds);
  if lSleepRequestsSeconds > 0 then
    Result := Result + Format(' --sleep-requests %d', [lSleepRequestsSeconds]);
  if aConfig.SocketTimeoutSeconds > 0 then
    Result := Result + Format(' --socket-timeout %d', [aConfig.SocketTimeoutSeconds]);
  if NodeRuntimeAvailable then
    Result := Result + ' --js-runtimes node';
end;

const
  CAutoCookieBrowsers: array[0..2] of string = ('firefox', 'chrome', 'edge');
  CCookieProbeJarPrefix = 'yttrans-cookie-probe-';
  CLoggedOutFix =
    '  Fix: set cookies_from_browser=firefox (or auto) under [default] in settings.ini,' + sLineBreak +
    '  or pass --cookies-from-browser firefox. Chrome/Edge on Windows usually fail' + sLineBreak +
    '  (DPAPI/app-bound cookie encryption, locked cookie database).';
  CLoggedOutStartNotice =
    'Notice: running logged out (no cookies). YouTube rate-limits logged-out' + sLineBreak +
    '  requests per IP, so subtitle downloads may get HTTP 429 or bot checks.' + sLineBreak +
    CLoggedOutFix;
  CLoggedOutThrottleNotice =
    'Notice: YouTube throttled a request while running logged out (no cookies);' + sLineBreak +
    '  logged-out requests are rate-limited per IP.' + sLineBreak +
    CLoggedOutFix;

procedure WriteCookieMessage(const aText: string);
begin
  if Assigned(GCookieWriter) then
    GCookieWriter(aText)
  else
    WriteLn(aText);
end;

function CookieJarHasYouTubeLogin(const aLines: TArray<string>): Boolean;
var
  lLine, lDomain, lName: string;
  lTabs: array[1..6] of Integer;
  lIndex, lPos: Integer;
  lComplete: Boolean;
begin
  // Netscape format: domain, subdomains, path, secure, expiry, name, value.
  // Only the domain and name fields are extracted; the value is never read.
  for lLine in aLines do
  begin
    lPos := 0;
    lComplete := True;
    for lIndex := Low(lTabs) to High(lTabs) do
    begin
      lPos := PosEx(#9, lLine, lPos + 1);
      if lPos = 0 then
      begin
        lComplete := False;
        Break;
      end;
      lTabs[lIndex] := lPos;
    end;
    if not lComplete then
      Continue;
    lDomain := Copy(lLine, 1, lTabs[1] - 1);
    if StartsText('#HttpOnly_', lDomain) then
      Delete(lDomain, 1, Length('#HttpOnly_'));
    if not (SameText(lDomain, 'youtube.com') or
            EndsText('.youtube.com', lDomain)) then
      Continue;
    lName := Copy(lLine, lTabs[5] + 1, lTabs[6] - lTabs[5] - 1);
    if (lName = 'SAPISID') or (lName = '__Secure-3PSID') or
       (lName = 'LOGIN_INFO') then
      Exit(True);
  end;
  Result := False;
end;

function InterpretCookieProbe(const aJarLines: TArray<string>;
  const aStdErr: string; out aError: string): Boolean;
var
  lLine: string;
begin
  aError := '';
  Result := CookieJarHasYouTubeLogin(aJarLines);
  if Result then
    Exit;
  for lLine in aStdErr.Split([#13, #10], TStringSplitOptions.ExcludeEmpty) do
    if StartsText('ERROR:', Trim(lLine)) and
       not ContainsText(lLine, 'at least one URL') then
    begin
      aError := Trim(Copy(Trim(lLine), 7, 200));
      Break;
    end;
  if aError = '' then
    aError := 'no signed-in YouTube session';
end;

procedure DeleteStaleCookieProbeJars(const aTempDir: string);
var
  lDir, lFile: string;
begin
  try
    lDir := aTempDir;
    if lDir = '' then
      lDir := TPath.GetTempPath;
    if not TDirectory.Exists(lDir) then
      Exit;
    for lFile in TDirectory.GetFiles(lDir, CCookieProbeJarPrefix + '*.txt') do
      try
        TFile.Delete(lFile);
      except
        // best effort: a jar still held by another process stays
      end;
  except
    // best effort: never fail a run over a leftover temp file
  end;
end;

// The real probe: yt-dlp without a URL loads the browser cookies, saves them
// to the jar and exits 2 ("You must provide at least one URL"). It makes no
// YouTube request, so it bypasses the throttle gate and the run log.
// The console runner has no timeout, so a hung yt-dlp blocks the probe.
function ProbeBrowserCookies(const aBrowser: string; out aError: string): Boolean;
var
  lJar: string;
  lStdOut, lStdErr: string;
  lJarLines: TArray<string>;
begin
  aError := '';
  lJar := TPath.Combine(TPath.GetTempPath,
    CCookieProbeJarPrefix + TGUID.NewGuid.ToString + '.txt');
  try
    try
      RunConsoleProcess(GetYtDlpPath,
        Format('--ignore-config --cookies-from-browser "%s" --cookies "%s"',
          [aBrowser, lJar]),
        lStdOut, lStdErr);
      lJarLines := nil;
      if TFile.Exists(lJar) then
        lJarLines := TFile.ReadAllLines(lJar);
      Result := InterpretCookieProbe(lJarLines, lStdErr, aError);
    except
      on E: Exception do
      begin
        Result := False;
        aError := E.Message;
      end;
    end;
  finally
    if TFile.Exists(lJar) then
      try
        TFile.Delete(lJar);
      except
        WriteCookieMessage('Warning: could not delete the temporary cookie jar ' + lJar);
      end;
  end;
end;

procedure ResetCookieState(const aProbe: TCookieBrowserProbe;
  const aWriter: TCookieMessageWriter);
begin
  GCookieLock.Enter;
  try
    GCookieProbe := aProbe;
    GCookieWriter := aWriter;
    GAutoCookieBrowserResolved := False;
    GAutoCookieBrowser := '';
    GLoggedOutStartNoticeShown := False;
    GLoggedOutThrottleNoticeShown := False;
  finally
    GCookieLock.Leave;
  end;
end;

function ResolveAutoCookieBrowser: string;
var
  lBrowser, lError: string;
  lOk: Boolean;
begin
  GCookieLock.Enter;
  try
    if not GAutoCookieBrowserResolved then
    begin
      GAutoCookieBrowser := '';
      for lBrowser in CAutoCookieBrowsers do
      begin
        if Assigned(GCookieProbe) then
          lOk := GCookieProbe(lBrowser, lError)
        else
          lOk := ProbeBrowserCookies(lBrowser, lError);
        if lOk then
        begin
          GAutoCookieBrowser := lBrowser;
          Break;
        end;
        WriteCookieMessage(Format('Cookies: %s cookies unavailable: %s',
          [lBrowser, lError]));
      end;
      GAutoCookieBrowserResolved := True;
      if GAutoCookieBrowser <> '' then
        WriteCookieMessage(Format(
          'Cookies: using %s cookies (cookies_from_browser=auto).',
          [GAutoCookieBrowser]))
      else
        WriteCookieMessage(
          'Warning: cookies_from_browser=auto: no browser gave usable YouTube ' +
          'cookies (tried firefox, chrome, edge); continuing logged out.');
    end;
    Result := GAutoCookieBrowser;
  finally
    GCookieLock.Leave;
  end;
end;

function EffectiveCookiesFromBrowser(const aValue: string): string;
begin
  Result := Trim(aValue);
  if SameText(Result, 'auto') then
    Result := ResolveAutoCookieBrowser;
end;

function HasEffectiveCookieSource(const aConfig: TCommandLineConfig): Boolean;
begin
  Result := (Trim(aConfig.CookiesFile) <> '') or
    (EffectiveCookiesFromBrowser(aConfig.CookiesFromBrowser) <> '');
end;

function ReportLoggedOutAtStart(const aHasCookieSource: Boolean): Boolean;
begin
  Result := False;
  if aHasCookieSource then
    Exit;
  GCookieLock.Enter;
  try
    if GLoggedOutStartNoticeShown then
      Exit;
    GLoggedOutStartNoticeShown := True;
    WriteCookieMessage(CLoggedOutStartNotice);
    Result := True;
  finally
    GCookieLock.Leave;
  end;
end;

// Repeats the notice on the first rate limit or bot challenge of a request
// made without cookies.
procedure ReportLoggedOutThrottle;
begin
  GCookieLock.Enter;
  try
    if GLoggedOutThrottleNoticeShown then
      Exit;
    GLoggedOutThrottleNoticeShown := True;
    WriteCookieMessage(CLoggedOutThrottleNotice);
  finally
    GCookieLock.Leave;
  end;
end;

function BuildYtDlpAuthArguments(const aConfig: TCommandLineConfig): string;
var
  lCookieFile, lBrowser: string;
begin
  Result := BuildYtDlpPacingArguments(aConfig);

  lCookieFile := Trim(aConfig.CookiesFile);
  if lCookieFile <> '' then
  begin
    lCookieFile := TPath.GetFullPath(lCookieFile);
    Result := Result + Format(' --cookies "%s"', [lCookieFile]);
  end;

  lBrowser := EffectiveCookiesFromBrowser(aConfig.CookiesFromBrowser);
  if lBrowser <> '' then
    Result := Result + Format(' --cookies-from-browser "%s"', [lBrowser]);
end;

function ShouldRetryWithoutDefaultAuth(const aConfig: TCommandLineConfig): Boolean;
begin
  Result := HasEffectiveCookieSource(aConfig) and
    (not aConfig.CookiesFileExplicit) and
    (not aConfig.CookiesFromBrowserExplicit);
end;

function IsMissingSubtitleError(const aMessage: string): Boolean;
var
  lMsg: string;
begin
  lMsg := aMessage.ToLower;
  Result := Pos('did not produce an srt subtitle file', lMsg) > 0;
end;

function IsThrottleError(const aMessage: string): Boolean;
begin
  Result := TThrottleController.IsThrottleMessage(aMessage);
end;

function IsThrottleException(const aException: Exception): Boolean;
begin
  Result := (aException is EThrottleError) or
    IsThrottleError(aException.Message);
end;

function IsCookieAuthFailure(const aException: Exception): Boolean;
const
  // yt-dlp output when the browser store cannot be read or the login expired.
  // Plain 'cookie' is too broad: successful loads also print
  // "Extracting cookies from firefox".
  CPatterns: array[0..6] of string = (
    'cookies database', 'cookie database', 'failed to decrypt', 'dpapi',
    'cookies are no longer valid', 'database is locked',
    'unsupported browser specified for cookies');
var
  lPattern: string;
begin
  Result := False;
  if (aException is EMissingTranscriptError) or
     IsThrottleException(aException) or
     IsMissingSubtitleError(aException.Message) then
    Exit;
  for lPattern in CPatterns do
    if ContainsText(aException.Message, lPattern) then
      Exit(True);
end;

function NormalizeErrorMessage(const aMessage: string): string;
begin
  Result := StringReplace(Trim(aMessage), #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
  if Length(Result) > 2048 then
    SetLength(Result, 2048);
end;

procedure AppendInvocationLogUnsafe(const aStartedUtc, aOperation,
  aTarget: string;
  const aWaitMs, aDurationMs: Int64; const aExitCode: Integer;
  const aResponseKind: TThrottleResponseKind; const aMessage: string;
  const aPacingWaitMs, aCooldownWaitMs: Int64; const aTrackKind: string);
var
  lJson: TJSONObject;
  lEncoding: TEncoding;
  lPath: string;
  lThrottleLevel, lRecoveryRemaining, lTargetThrottleAttempts: Integer;
  lCooldownMs: Cardinal;
begin
  if not Assigned(GInvocationLogLock) then
    Exit;
  lThrottleLevel := 0;
  lRecoveryRemaining := 0;
  lCooldownMs := 0;
  lTargetThrottleAttempts := 0;
  if Assigned(GThrottleController) then
  begin
    lThrottleLevel := GThrottleController.ThrottleLevel;
    lRecoveryRemaining := GThrottleController.RecoveryRequestsRemaining;
    lCooldownMs := GThrottleController.CooldownRemainingMs;
    lTargetThrottleAttempts := GThrottleController.RateLimitAttemptsForTarget(
      aTarget);
  end;
  lJson := TJSONObject.Create;
  try
    lJson.AddPair('started_utc', aStartedUtc);
    lJson.AddPair('finished_utc', UtcNowIso);
    lJson.AddPair('operation', aOperation);
    lJson.AddPair('target', aTarget);
    lJson.AddPair('gate_wait_ms', TJSONNumber.Create(aWaitMs));
    if aPacingWaitMs >= 0 then
      lJson.AddPair('pacing_wait_ms', TJSONNumber.Create(aPacingWaitMs));
    if aCooldownWaitMs >= 0 then
      lJson.AddPair('global_cooldown_wait_ms', TJSONNumber.Create(aCooldownWaitMs));
    if Assigned(GSourceThrottlePolicy) then
      lJson.AddPair('source', GCurrentSource);
    lJson.AddPair('duration_ms', TJSONNumber.Create(aDurationMs));
    lJson.AddPair('exit_code', TJSONNumber.Create(aExitCode));
    lJson.AddPair('response_kind',
      TThrottleController.ResponseKindToString(aResponseKind));
    if aTrackKind <> '' then
      lJson.AddPair('track_kind', aTrackKind);
    lJson.AddPair('throttle_level', TJSONNumber.Create(lThrottleLevel));
    lJson.AddPair('recovery_requests_remaining',
      TJSONNumber.Create(lRecoveryRemaining));
    lJson.AddPair('cooldown_remaining_ms', TJSONNumber.Create(lCooldownMs));
    if lTargetThrottleAttempts > 0 then
      lJson.AddPair('target_throttle_attempts',
        TJSONNumber.Create(lTargetThrottleAttempts));
    if Trim(aMessage) <> '' then
      lJson.AddPair('message', NormalizeErrorMessage(aMessage));
    lPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'yttrans.run.jsonl');
    lEncoding := TUTF8Encoding.Create(False);
    try
      GInvocationLogLock.Enter;
      try
        TFile.AppendAllText(lPath, lJson.ToJSON + sLineBreak, lEncoding);
      finally
        GInvocationLogLock.Leave;
      end;
    finally
      lEncoding.Free;
    end;
  finally
    lJson.Free;
  end;
end;

procedure AppendInvocationLog(const aStartedUtc, aOperation, aTarget: string;
  const aWaitMs, aDurationMs: Int64; const aExitCode: Integer;
  const aResponseKind: TThrottleResponseKind; const aMessage: string;
  const aPacingWaitMs: Int64 = -1; const aCooldownWaitMs: Int64 = -1;
  const aTrackKind: string = '');
begin
  if TInterlocked.Add(GInvocationLogFailed, 0) <> 0 then
    Exit;
  try
    AppendInvocationLogUnsafe(aStartedUtc, aOperation, aTarget, aWaitMs,
      aDurationMs, aExitCode, aResponseKind, aMessage, aPacingWaitMs,
      aCooldownWaitMs, aTrackKind);
  except
    on E: Exception do
      if TInterlocked.CompareExchange(GInvocationLogFailed, 1, 0) = 0 then
        WriteLn('Warning: structured invocation logging disabled: ' + E.Message);
  end;
end;

function ClassifyError(const aMessage: string): string;
var
  lText: string;
  lResponseKind: TThrottleResponseKind;
begin
  lText := LowerCase(aMessage);
  if IsMissingSubtitleError(aMessage) then
    Exit('unavailable');
  lResponseKind := TThrottleController.ClassifyResponse(aMessage);
  case lResponseKind of
    trkRateLimit: Exit('throttled');
    trkBotChallenge: Exit('authentication');
    trkConfiguration: Exit('configuration');
  end;
  if ContainsText(lText, 'cookie') or ContainsText(lText, 'sign in') or
     ContainsText(lText, 'authentication') then
    Exit('authentication');
  if ContainsText(lText, 'network') or ContainsText(lText, 'timeout') or
     ContainsText(lText, 'connection') then
    Exit('network');
  Result := 'other';
end;

function ExtractVideoIdFromUrl(const aUrl: string): string;
var
  lUrl: string;
  lPart: string;
  lPos: Integer;
  lStopPos: Integer;
begin
  Result := '';
  lUrl := Trim(aUrl);
  if lUrl = '' then
    Exit;

  lPos := Pos('v=', lUrl);
  if lPos > 0 then
  begin
    lPart := Copy(lUrl, lPos + 2, MaxInt);
    lStopPos := Pos('&', lPart);
    if lStopPos = 0 then
      lStopPos := Pos('#', lPart);
    if lStopPos > 0 then
      lPart := Copy(lPart, 1, lStopPos - 1);
    Exit(Trim(lPart));
  end;

  lPos := Pos('youtu.be/', lUrl.ToLower);
  if lPos > 0 then
  begin
    lPart := Copy(lUrl, lPos + Length('youtu.be/'), MaxInt);
    lStopPos := Pos('?', lPart);
    if lStopPos = 0 then
      lStopPos := Pos('&', lPart);
    if lStopPos = 0 then
      lStopPos := Pos('/', lPart);
    if lStopPos > 0 then
      lPart := Copy(lPart, 1, lStopPos - 1);
    Exit(Trim(lPart));
  end;

  lPos := Pos('/shorts/', lUrl.ToLower);
  if lPos > 0 then
  begin
    lPart := Copy(lUrl, lPos + Length('/shorts/'), MaxInt);
    lStopPos := Pos('?', lPart);
    if lStopPos = 0 then
      lStopPos := Pos('&', lPart);
    if lStopPos = 0 then
      lStopPos := Pos('/', lPart);
    if lStopPos > 0 then
      lPart := Copy(lPart, 1, lStopPos - 1);
    Exit(Trim(lPart));
  end;

  if Pos('://', lUrl) = 0 then
    Result := lUrl;
end;

function IsYouTubeVideoUrl(const aUrl: string): Boolean;
begin
  Result := ExtractVideoIdFromUrl(aUrl) <> '';
end;

function NormalizeVideoUrl(const aCandidate: string): string;
var
  lVideoId: string;
begin
  lVideoId := ExtractVideoIdFromUrl(aCandidate);
  if lVideoId <> '' then
    Exit('https://www.youtube.com/watch?v=' + lVideoId);
  Result := Trim(aCandidate);
end;

function BuildUploadsPlaylistUrl(const aChannelId: string): string;
begin
  Result := '';
  if StartsText('UC', aChannelId) and (Length(aChannelId) > 2) then
    Result := 'https://www.youtube.com/playlist?list=UU' + Copy(aChannelId, 3, MaxInt);
end;

function BuildChannelBaseUrl(const aMeta: TTranscriptMetadata): string;
var
  lUploaderId: string;
begin
  Result := Trim(aMeta.ChannelUrl);
  if Result = '' then
  begin
    if aMeta.ChannelId <> '' then
      Result := 'https://www.youtube.com/channel/' + aMeta.ChannelId
    else
    begin
      lUploaderId := Trim(aMeta.UploaderId);
      if lUploaderId <> '' then
      begin
        if StartsText('@', lUploaderId) then
          Result := 'https://www.youtube.com/' + lUploaderId
        else
          Result := 'https://www.youtube.com/@' + lUploaderId;
      end;
    end;
  end;

  Result := ExcludeTrailingPathDelimiter(Result);
  if EndsText('/videos', Result) then
    SetLength(Result, Length(Result) - Length('/videos'))
  else if EndsText('/shorts', Result) then
    SetLength(Result, Length(Result) - Length('/shorts'))
  else if EndsText('/streams', Result) then
    SetLength(Result, Length(Result) - Length('/streams'));
end;

function BuildChannelOutputDir(const aConfig: TCommandLineConfig; const aMeta: TTranscriptMetadata): string;
var
  lRoot: string;
  lChannelName: string;
begin
  lRoot := Trim(aConfig.ChannelOutputRoot);
  if lRoot = '' then
    lRoot := Trim(aConfig.OutputTarget);
  if lRoot = '' then
    lRoot := Trim(aConfig.OutputDir);
  if lRoot = '' then
    lRoot := TPath.Combine(ExtractFilePath(ParamStr(0)), 'output');

  lRoot := TPath.GetFullPath(lRoot);

  lChannelName := SanitizeFileNamePart(aMeta.Channel);
  if (lChannelName = 'transcript') and (Trim(aMeta.ChannelId) <> '') then
    lChannelName := SanitizeFileNamePart(aMeta.ChannelId);

  Result := TPath.Combine(lRoot, lChannelName);
end;

function ChannelOutputRoot(const aConfig: TCommandLineConfig): string;
begin
  Result := Trim(aConfig.ChannelOutputRoot);
  if Result = '' then
    Result := Trim(aConfig.OutputTarget);
  if Result = '' then
    Result := Trim(aConfig.OutputDir);
  if Result = '' then
    Result := TPath.Combine(ExtractFilePath(ParamStr(0)), 'output');
  Result := TPath.GetFullPath(Result);
end;

function SameSourceUrl(const aLeft, aRight: string): Boolean;
begin
  Result := SameText(ExcludeTrailingPathDelimiter(Trim(aLeft)),
    ExcludeTrailingPathDelimiter(Trim(aRight)));
end;

function TryFindChannelIndex(const aConfig: TCommandLineConfig;
  out aStore: TChannelIndexStore; out aData: TChannelIndexData): Boolean;
var
  lRoot, lDirectory: string;
  lCandidate: TChannelIndexStore;
begin
  Result := False;
  aStore := nil;
  aData := Default(TChannelIndexData);
  if not aConfig.FileMode then
    Exit;
  lRoot := ChannelOutputRoot(aConfig);
  if not TDirectory.Exists(lRoot) then
    Exit;
  for lDirectory in TDirectory.GetDirectories(lRoot, '*',
    TSearchOption.soTopDirectoryOnly) do
  begin
    lCandidate := TChannelIndexStore.Create(lDirectory);
    try
      if (TFile.Exists(lCandidate.FileName) or
          TFile.Exists(lCandidate.BackupFileName)) and
         lCandidate.Load(aData) and SameSourceUrl(aData.SourceUrl, aConfig.URL) then
      begin
        aStore := lCandidate;
        lCandidate := nil;
        Exit(True);
      end;
    finally
      lCandidate.Free;
    end;
  end;
end;

function TryFindChannelIndexById(const aConfig: TCommandLineConfig;
  const aChannelId: string; out aStore: TChannelIndexStore;
  out aData: TChannelIndexData): Boolean;
var
  lRoot, lDirectory: string;
  lCandidate: TChannelIndexStore;
begin
  Result := False;
  aStore := nil;
  aData := Default(TChannelIndexData);
  if not aConfig.FileMode or (Trim(aChannelId) = '') then
    Exit;
  lRoot := ChannelOutputRoot(aConfig);
  if not TDirectory.Exists(lRoot) then
    Exit;
  for lDirectory in TDirectory.GetDirectories(lRoot, '*',
    TSearchOption.soTopDirectoryOnly) do
  begin
    lCandidate := TChannelIndexStore.Create(lDirectory);
    try
      if (TFile.Exists(lCandidate.FileName) or
          TFile.Exists(lCandidate.BackupFileName)) and
         lCandidate.Load(aData) and
         SameText(aData.ChannelId, aChannelId) then
      begin
        aStore := lCandidate;
        lCandidate := nil;
        Exit(True);
      end;
    finally
      lCandidate.Free;
    end;
  end;
end;

function DiscoveryModeForDownloadMode(
  const aMode: TDownloadMode): TChannelDiscoveryMode;
begin
  case aMode of
    dmFailed:
      Result := cdmFailed;
    dmThrottled:
      Result := cdmThrottled;
    dmAll:
      Result := cdmAll;
  else
    Result := cdmFresh;
  end;
end;

function MetadataFromChannelIndex(
  const aIndex: TChannelIndexData): TTranscriptMetadata;
begin
  Result := Default(TTranscriptMetadata);
  Result.Channel := aIndex.ChannelName;
  Result.Uploader := aIndex.ChannelName;
  Result.ChannelId := aIndex.ChannelId;
  Result.ChannelUrl := 'https://www.youtube.com/channel/' + aIndex.ChannelId;
end;

function VideosFromChannelIndex(
  const aIndex: TChannelIndexData): TArray<TChannelVideo>;
var
  I: Integer;
begin
  SetLength(Result, Length(aIndex.Videos));
  for I := 0 to Length(aIndex.Videos) - 1 do
  begin
    Result[I].Url := aIndex.Videos[I].Url;
    Result[I].PublishedAt := aIndex.Videos[I].PublishedAt;
    Result[I].PublishedUnix := aIndex.Videos[I].PublishedUnix;
    Result[I].OriginalOrder := I;
  end;
end;

function ChannelIndexFromDiscovery(const aSourceUrl: string;
  const aMeta: TTranscriptMetadata;
  const aVideos: TArray<TChannelVideo>): TChannelIndexData;
var
  I: Integer;
begin
  Result := Default(TChannelIndexData);
  Result.SourceUrl := aSourceUrl;
  Result.ChannelId := aMeta.ChannelId;
  Result.ChannelName := aMeta.Channel;
  SetLength(Result.Videos, Length(aVideos));
  for I := 0 to Length(aVideos) - 1 do
  begin
    Result.Videos[I].VideoId := ExtractVideoIdFromUrl(aVideos[I].Url);
    Result.Videos[I].Url := aVideos[I].Url;
    Result.Videos[I].PublishedAt := aVideos[I].PublishedAt;
    Result.Videos[I].PublishedUnix := aVideos[I].PublishedUnix;
  end;
end;

procedure FetchYouTubeRss(const aUrl: string; out aStatusCode: Integer;
  out aBody, aError: string);
var
  lClient: THTTPClient;
  lResponse: IHTTPResponse;
begin
  aStatusCode := 0;
  aBody := '';
  aError := '';
  lClient := THTTPClient.Create;
  try
    try
      lResponse := lClient.Get(aUrl);
      aStatusCode := lResponse.StatusCode;
      aBody := lResponse.ContentAsString(TEncoding.UTF8);
      if (aStatusCode < 200) or (aStatusCode >= 300) then
        aError := lResponse.StatusText;
    except
      on E: Exception do
      begin
        if IsFatalProcessingException(E) then
          raise;
        aError := E.Message;
      end;
    end;
  finally
    lClient.Free;
  end;
end;

// The value of a double-quoted scalar. Anything else, including a legacy
// value that merely starts with a quote (`"Hi" #shorts`), is returned as is.
function UnquoteYamlScalar(const aValue: string): string;
var
  lBuilder: TStringBuilder;
  lIndex, lCode: Integer;
begin
  if (Length(aValue) < 2) or (aValue[1] <> '"') then
    Exit(aValue);
  lBuilder := TStringBuilder.Create;
  try
    lIndex := 2;
    while lIndex <= Length(aValue) do
    begin
      case aValue[lIndex] of
        '"':
          if lIndex = Length(aValue) then
            Exit(lBuilder.ToString)
          else
            Exit(aValue);
        '\':
          begin
            Inc(lIndex);
            if lIndex > Length(aValue) then
              Exit(aValue);
            case aValue[lIndex] of
              'n': lBuilder.Append(#10);
              't': lBuilder.Append(#9);
              'r': lBuilder.Append(#13);
              '0': lBuilder.Append(#0);
              'u':
                begin
                  if not TryStrToInt('$' + Copy(aValue, lIndex + 1, 4), lCode) then
                    Exit(aValue);
                  lBuilder.Append(Char(lCode));
                  Inc(lIndex, 4);
                end;
            else
              lBuilder.Append(aValue[lIndex]); // \" \\ \/ and the like
            end;
          end;
      else
        lBuilder.Append(aValue[lIndex]);
      end;
      Inc(lIndex);
    end;
    Result := aValue; // no closing quote
  finally
    lBuilder.Free;
  end;
end;

// The `|-` block that starts at aLines[aStart], without its indentation and
// trailing empty lines, joined with LF.
function ReadYamlBlockLines(const aLines: TStrings; const aStart: Integer): string;
var
  lBlock: TStringList;
  lLine: string;
begin
  lBlock := TStringList.Create;
  try
    for var lIndex := aStart to aLines.Count - 1 do
    begin
      lLine := aLines[lIndex];
      if Trim(lLine) = '' then
        lBlock.Add('')
      else if StartsStr('  ', lLine) then
        lBlock.Add(Copy(lLine, 3, MaxInt))
      else
        Break;
    end;
    while (lBlock.Count > 0) and (lBlock[lBlock.Count - 1] = '') do
      lBlock.Delete(lBlock.Count - 1);
    Result := string.Join(#10, lBlock.ToStringArray);
  finally
    lBlock.Free;
  end;
end;

function ReadFrontMatterValue(const aFilePath, aKey: string): string;
var
  lText: string;
  lLines: TStringList;
  lLine: string;
  lValue: string;
  lPos: Integer;
begin
  Result := '';
  if not TFile.Exists(aFilePath) then
    Exit;

  try
    lText := TFile.ReadAllText(aFilePath, TEncoding.UTF8);
  except
    lText := TFile.ReadAllText(aFilePath, TEncoding.Default);
  end;

  lLines := TStringList.Create;
  try
    lLines.Text := lText;
    if lLines.Count < 2 then
      Exit;
    if Trim(lLines[0]) <> '---' then
      Exit;

    for var lIndex := 1 to lLines.Count - 1 do
    begin
      lLine := TrimRight(lLines[lIndex]);
      if lLine = '---' then
        Break;
      // Indented lines belong to a block value, not to a key.
      if (lLine = '') or CharInSet(lLine[1], [' ', #9]) then
        Continue;
      lPos := Pos(':', lLine);
      if lPos <= 1 then
        Continue;
      if SameText(Trim(Copy(lLine, 1, lPos - 1)), aKey) then
      begin
        lValue := Trim(Copy(lLine, lPos + 1, MaxInt));
        if MatchStr(lValue, ['|-', '|2-']) then
          Exit(ReadYamlBlockLines(lLines, lIndex + 1));
        Exit(UnquoteYamlScalar(lValue));
      end;
    end;
  finally
    lLines.Free;
  end;
end;

procedure ResolveChannelFilePath(
  const aChannelDir: string;
  const aMeta: TTranscriptMetadata;
  const aOverride: Boolean;
  out aFilePath: string;
  out aAction: TChannelConflictAction);
var
  lBaseName: string;
  lCandidateBase: string;
  lCandidatePath: string;
  lExistingVideoId: string;
  lVideoId: string;
  lIndex: Integer;
begin
  lBaseName := SanitizeFileNamePart(aMeta.Title);
  lVideoId := Trim(aMeta.VideoId);
  lIndex := 1;

  while lIndex < 100000 do
  begin
    if lIndex = 1 then
      lCandidateBase := lBaseName
    else
      lCandidateBase := Format('%s (%d)', [lBaseName, lIndex]);

    lCandidatePath := TPath.Combine(aChannelDir, lCandidateBase + '.md');
    if not TFile.Exists(lCandidatePath) then
    begin
      aFilePath := lCandidatePath;
      aAction := ccaWriteNew;
      Exit;
    end;

    lExistingVideoId := Trim(ReadFrontMatterValue(lCandidatePath, 'video_id'));
    if (lVideoId <> '') and SameText(lExistingVideoId, lVideoId) then
    begin
      aFilePath := lCandidatePath;
      if aOverride then
        aAction := ccaOverwrite
      else
        aAction := ccaSkip;
      Exit;
    end;

    Inc(lIndex);
  end;

  raise Exception.CreateFmt('Could not resolve output path for title: %s', [aMeta.Title]);
end;

function FetchTranscriptWithFallback(
  const aService: TTranscriptService;
  const aUrl, aRequestedLanguage, aYtDlpExtraArgs: string): TTranscriptResult;
var
  lRequested: string;
begin
  lRequested := Trim(aRequestedLanguage).ToLower;
  if lRequested = '' then
    lRequested := CDefaultLanguage;
  // One extraction serves both languages: the track is chosen from info.json.
  Result := aService.FetchTranscript(aUrl, lRequested, aYtDlpExtraArgs,
    CDefaultLanguage);
end;

procedure SortChannelVideosNewestFirst(var aVideos: TArray<TChannelVideo>);
begin
  TArray.Sort<TChannelVideo>(aVideos,
    TComparer<TChannelVideo>.Construct(
      function(const aLeft, aRight: TChannelVideo): Integer
      begin
        if aLeft.PublishedUnix > aRight.PublishedUnix then
          Exit(-1);
        if aLeft.PublishedUnix < aRight.PublishedUnix then
          Exit(1);
        Result := aLeft.OriginalOrder - aRight.OriginalOrder;
      end));
end;

function BuildChannelVideoQueue(
  const aService: TTranscriptService;
  const aSeedMeta: TTranscriptMetadata;
  const aConfig: TCommandLineConfig;
  const aYtDlpExtraArgs: string; out aDiscoveryError: string): TArray<TChannelVideo>;
var
  lVideos: TList<TChannelVideo>;
  lSeen: TDictionary<string, Byte>;
  lSource: string;
  lFoundVideos: TArray<TChannelVideo>;
  lSortedVideos: TArray<TChannelVideo>;
  lOriginalOrder: Integer;

  procedure RecordDiscoveryError(const aMessage: string);
  begin
    if aDiscoveryError = '' then
      aDiscoveryError := aMessage
    else
      aDiscoveryError := aDiscoveryError + '; ' + aMessage;
  end;

  procedure AddVideo(const aVideo: TChannelVideo);
  var
    lItem: TChannelVideo;
    lUrl: string;
    lKey: string;
  begin
    lUrl := NormalizeVideoUrl(aVideo.Url);
    if lUrl = '' then
      Exit;
    lKey := ExtractVideoIdFromUrl(lUrl);
    if lKey = '' then
      lKey := lUrl.ToLower;
    if lSeen.ContainsKey(lKey) then
      Exit;
    lSeen.Add(lKey, 1);
    lItem := aVideo;
    lItem.Url := lUrl;
    lItem.OriginalOrder := lOriginalOrder;
    Inc(lOriginalOrder);
    lVideos.Add(lItem);
  end;

  procedure AddUrl(const aRawUrl: string);
  var
    lVideo: TChannelVideo;
  begin
    lVideo := Default(TChannelVideo);
    lVideo.Url := aRawUrl;
    AddVideo(lVideo);
  end;

begin
  aDiscoveryError := '';
  lVideos := TList<TChannelVideo>.Create;
  lSeen := TDictionary<string, Byte>.Create;
  try
    lOriginalOrder := 0;
    if ExtractVideoIdFromUrl(aConfig.URL) <> '' then
      AddUrl(aConfig.URL);

    lSource := BuildUploadsPlaylistUrl(aSeedMeta.ChannelId);
    if lSource = '' then
    begin
      lSource := BuildChannelBaseUrl(aSeedMeta);
      if lSource <> '' then
        lSource := lSource + '/videos';
    end;

    if lSource <> '' then
    begin
      try
        lFoundVideos := aService.ListChannelVideos(lSource, aYtDlpExtraArgs);
        for var lVideo in lFoundVideos do
          AddVideo(lVideo);
      except
        on E: Exception do
          if IsFatalProcessingException(E) or IsThrottleException(E) then
            raise
          else
          begin
            RecordDiscoveryError('uploads/videos: ' + E.Message);
            WriteLn(Format('Warning: could not list uploads/videos: %s', [E.Message]));
          end;
      end;
    end;

    lSource := BuildChannelBaseUrl(aSeedMeta);
    if aConfig.IncludeShorts and (lSource <> '') then
    begin
      try
        lFoundVideos := aService.ListChannelVideos(lSource + '/shorts', aYtDlpExtraArgs);
        for var lVideo in lFoundVideos do
          AddVideo(lVideo);
      except
        on E: Exception do
          if IsFatalProcessingException(E) or IsThrottleException(E) then
            raise
          else
          begin
            RecordDiscoveryError('shorts: ' + E.Message);
            WriteLn(Format('Warning: could not list shorts tab: %s', [E.Message]));
          end;
      end;
    end;

    if aConfig.IncludeLive and (lSource <> '') then
    begin
      try
        lFoundVideos := aService.ListChannelVideos(lSource + '/streams', aYtDlpExtraArgs);
        for var lVideo in lFoundVideos do
          AddVideo(lVideo);
      except
        on E: Exception do
          if IsFatalProcessingException(E) or IsThrottleException(E) then
            raise
          else
          begin
            RecordDiscoveryError('live: ' + E.Message);
            WriteLn(Format('Warning: could not list live tab: %s', [E.Message]));
          end;
      end;
    end;

    lSortedVideos := lVideos.ToArray;
    SortChannelVideosNewestFirst(lSortedVideos);
    Result := lSortedVideos;
  finally
    lSeen.Free;
    lVideos.Free;
  end;
end;

procedure ReportChannelProgress(const aLogLock: TCriticalSection;
  const aProcessed, aTotal: Integer; const aStats: TChannelRunStats;
  var aLastProgressTick: UInt64; var aLastReportedProcessed: Integer;
  var aLastCooldownProgressTick: UInt64; const aHeartbeat: Boolean;
  const aCallback: TChannelProgressCallback);
var
  lNow: UInt64;
  lShouldReport: Boolean;
  lCooldownMs: Cardinal;
  lTotalSeconds: UInt64;
  lRetryAtUtc: string;
begin
  aLogLock.Enter;
  try
    lNow := TThread.GetTickCount64;
    lCooldownMs := 0;
    if Assigned(GThrottleController) then
      lCooldownMs := GThrottleController.CooldownRemainingMs;
    if (lCooldownMs > 0) and
       ((aLastCooldownProgressTick = 0) or
        (lNow - aLastCooldownProgressTick >= CCooldownProgressIntervalMs)) then
    begin
      aLastCooldownProgressTick := lNow;
      lTotalSeconds := (UInt64(lCooldownMs) + 999) div 1000;
      lRetryAtUtc := DateToISO8601(
        IncMilliSecond(UtcNow, lCooldownMs), True);
      WriteLn(Format(
        'Throttle level %d: retry in %d:%.2d:%.2d (at %s); channel progress %d/%d.',
        [GThrottleController.ThrottleLevel, lTotalSeconds div 3600,
         (lTotalSeconds div 60) mod 60, lTotalSeconds mod 60,
         lRetryAtUtc, aProcessed, aTotal]));
    end;

    lShouldReport := (aProcessed <> aLastReportedProcessed) and
      ((aProcessed = aTotal) or
       (aProcessed - aLastReportedProcessed >= CProgressIntervalItems) or
       (lNow - aLastProgressTick >= CProgressIntervalMs));
    if lShouldReport then
    begin
      aLastProgressTick := lNow;
      aLastReportedProcessed := aProcessed;
      WriteLn(Format(
        'Progress: %d/%d processed; downloaded=%d skipped=%d unavailable=%d failed=%d',
        [aProcessed, aTotal, aStats.Downloaded, aStats.Skipped,
         aStats.Unavailable + aStats.UnavailableCached, aStats.Failed]
      ));
    end;
    if Assigned(aCallback) and (lShouldReport or aHeartbeat) then
      aCallback(aProcessed, aTotal, aStats);
  finally
    aLogLock.Leave;
  end;
end;

procedure WaitForDiscoveryCooldown(const aStats: TChannelRunStats;
  const aTotal: Integer; const aCallback: TChannelProgressCallback);
var
  lCooldownMs: Cardinal;
  lNow, lLastCheckpoint, lLastLog: UInt64;
  lRetryAtUtc: string;
begin
  lLastCheckpoint := 0;
  lLastLog := 0;
  while Assigned(GThrottleController) do
  begin
    lCooldownMs := GThrottleController.CooldownRemainingMs;
    if lCooldownMs = 0 then
      Exit;
    lNow := TThread.GetTickCount64;
    if (lLastCheckpoint = 0) or (lNow - lLastCheckpoint >= 60000) then
    begin
      lLastCheckpoint := lNow;
      if Assigned(aCallback) then
        aCallback(0, aTotal, aStats);
    end;
    if (lLastLog = 0) or (lNow - lLastLog >= CCooldownProgressIntervalMs) then
    begin
      lLastLog := lNow;
      lRetryAtUtc := DateToISO8601(IncMilliSecond(UtcNow, lCooldownMs), True);
      WriteLn(Format(
        'RSS throttle level %d: retry in %d seconds at %s; indexed videos=%d.',
        [GThrottleController.ThrottleLevel,
         (UInt64(lCooldownMs) + 999) div 1000, lRetryAtUtc, aTotal]));
    end;
    TThread.Sleep(250);
  end;
end;

function RunChannelMode(const aConfig: TCommandLineConfig;
  out aStats: TChannelRunStats;
  const aProgressCallback: TChannelProgressCallback = nil;
  const aMaxVideoAttempts: Integer = 0;
  const aDiscoveryCache: TChannelDiscoveryCache = nil;
  const aDiscoveryMode: TChannelDiscoveryMode = cdmFresh): Integer;
var
  lSetupService: TTranscriptService;
  lSeedMeta: TTranscriptMetadata;
  lVideos: TArray<TChannelVideo>;
  lChannelDir: string;
  lStats: TChannelRunStats;
  lEffectiveMetaOptions: TMetaOptions;
  lFileLock: TCriticalSection;
  lLogLock: TCriticalSection;
  lHeartbeatStop: TEvent;
  lHeartbeatTask: ITask;
  lNextIndex: Integer;
  lProgressProcessed: Integer;
  lLastProgressTick: UInt64;
  lLastReportedProcessed: Integer;
  lLastCooldownProgressTick: UInt64;
  lWorkerTask: ITask;
  lYtDlpExtraArgs: string;
  lStopScheduling: Integer;
  lExistingVideoIds: TDictionary<string, Byte>;
  lUnavailableVideos: TUnavailableVideoMap;
  lUnavailableManifestChanged: Boolean;
  lProcessedCount: Integer;
  lDeferredCount: Integer;
  lProgressError: string;
  lAttemptedCount: Integer;
  lSliceLimitReached: Integer;
  lThrottleProbeSkipped: Integer;
  lThrottleExhaustedSkipped: Integer;
  lThrottleDeferredCount: Integer;
  lOwnOutputState: Boolean;
  lIndexStore, lFoundStore: TChannelIndexStore;
  lIndexStoreOwner: IGarbo;
  lIndexData, lUpdatedIndex, lDiscoveredIndex: TChannelIndexData;
  lHasIndex: Boolean;
  lDiscoveryAction: TChannelDiscoveryAction;
  lRssOutcome: TChannelRssOutcome;
  lDiscoveryError: string;
  lContinueFullDiscovery: Boolean;
  lDeferredCachedEntry: TUnavailableVideo;

  procedure UsePersistentIndex(const aIndex: TChannelIndexData;
    const aMessage: string);
  begin
    lIndexData := aIndex;
    lSeedMeta := MetadataFromChannelIndex(lIndexData);
    lVideos := VideosFromChannelIndex(lIndexData);
    lChannelDir := ExtractFileDir(lIndexStore.FileName);
    if aMessage <> '' then
      WriteLn(Format(aMessage, [Length(lVideos)]));
  end;

  procedure LoadPersistentIndexFromRss;
  var
    lRssCurrent: TChannelIndexData;
  begin
    lRssCurrent := lIndexData;
    lRssCurrent.SourceUrl := aConfig.URL;
    if Trim(lSeedMeta.Channel) <> '' then
      lRssCurrent.ChannelName := lSeedMeta.Channel;
    repeat
      lRssOutcome := RefreshChannelIndexFromRss(lIndexStore, lRssCurrent,
        GThrottleController, FetchYouTubeRss,
        procedure
        begin
          lStats.DiscoveryErrorKind := 'throttled';
          lStats.DiscoveryError := 'YouTube RSS discovery was throttled';
          if Assigned(aProgressCallback) then
            aProgressCallback(0, Length(lIndexData.Videos), lStats);
        end,
        UtcNow, lUpdatedIndex, lDiscoveryError);
      if lRssOutcome = croThrottled then
      begin
        lStats.DiscoveryErrorKind := 'throttled';
        lStats.DiscoveryError := lDiscoveryError;
        if aConfig.FileMode then
          raise EThrottleError.Create(lDiscoveryError);
        WaitForDiscoveryCooldown(lStats, Length(lIndexData.Videos),
          aProgressCallback);
        lStats.DiscoveryErrorKind := '';
        lStats.DiscoveryError := '';
        Continue;
      end;
      Break;
    until False;
    if lRssOutcome = croWarning then
    begin
      lStats.DiscoveryErrorKind := 'discovery';
      lStats.DiscoveryError := lDiscoveryError;
      lUpdatedIndex := lIndexData;
      WriteLn('Warning: RSS discovery failed; using the last valid index: ' +
        lDiscoveryError);
    end;
    UsePersistentIndex(lUpdatedIndex,
      'Persistent channel index after RSS merge: %d videos.');
  end;
begin
  Result := 1;
  lStats := Default(TChannelRunStats);
  aStats := lStats;
  lIndexStore := nil;
  lFoundStore := nil;
  lIndexStoreOwner := nil;
  lChannelDir := '';

  if Assigned(aDiscoveryCache) and aDiscoveryCache.Initialized then
  begin
    lSeedMeta := aDiscoveryCache.SeedMeta;
    lVideos := Copy(aDiscoveryCache.Videos);
    lYtDlpExtraArgs := aDiscoveryCache.YtDlpExtraArgs;
    lChannelDir := aDiscoveryCache.ChannelDirectory;
    lStats.DiscoveryErrorKind := aDiscoveryCache.DiscoveryErrorKind;
    lStats.DiscoveryError := aDiscoveryCache.DiscoveryError;
    WriteLn(Format('Reusing cached channel listing: %d videos.',
      [Length(lVideos)]));
  end
  else
  begin
    lYtDlpExtraArgs := BuildYtDlpAuthArguments(aConfig);
    lHasIndex := TryFindChannelIndex(aConfig, lFoundStore, lIndexData);
    if lHasIndex then
      gc(lIndexStore, lFoundStore, lIndexStoreOwner);
    if aConfig.FileMode then
      lDiscoveryAction := SelectChannelDiscoveryAction(aDiscoveryMode,
        lHasIndex, lIndexData.LastFullScanUtc, UtcNow)
    else
      lDiscoveryAction := cdaFullListing;

    if lDiscoveryAction = cdaUseIndex then
      UsePersistentIndex(lIndexData,
        'Using persistent channel index: %d videos.')
    else if lDiscoveryAction = cdaFetchRss then
      LoadPersistentIndexFromRss;
    if lDiscoveryAction = cdaFullListing then
    begin
      gc(lSetupService, TTranscriptService.Create(
        TThrottleController.RetryModeForFileMode(aConfig.FileMode)));
      lDiscoveryError := '';
      try
        try
          lSeedMeta := lSetupService.FetchMetadata(aConfig.URL,
            lYtDlpExtraArgs);
        except
          on E: Exception do
          begin
            if IsFatalProcessingException(E) then
              raise;
            if ShouldRetryWithoutDefaultAuth(aConfig) and
               (Trim(lYtDlpExtraArgs) <> '') and
               IsCookieAuthFailure(E) then
            begin
              WriteLn('Warning: default cookie auth failed; retrying without cookies.');
              lYtDlpExtraArgs := BuildYtDlpPacingArguments(aConfig);
              lSeedMeta := lSetupService.FetchMetadata(aConfig.URL,
                lYtDlpExtraArgs);
            end
            else
              raise;
          end;
        end;
      except
        on E: Exception do
        begin
          if IsFatalProcessingException(E) then
            raise;
          if aConfig.FileMode and lHasIndex and
             (not IsThrottleException(E)) then
            lDiscoveryError := 'metadata: ' + E.Message
          else
            raise;
        end;
      end;
      lContinueFullDiscovery := True;
      if (lDiscoveryError = '') and aConfig.FileMode and
         (not lHasIndex) and TryFindChannelIndexById(aConfig,
           lSeedMeta.ChannelId, lFoundStore, lIndexData) then
      begin
        gc(lIndexStore, lFoundStore, lIndexStoreOwner);
        lHasIndex := True;
        lDiscoveryAction := SelectChannelDiscoveryAction(aDiscoveryMode,
          True, lIndexData.LastFullScanUtc, UtcNow);
        if lDiscoveryAction = cdaUseIndex then
        begin
          UsePersistentIndex(lIndexData,
            'Matched canonical channel index: %d videos.');
          lContinueFullDiscovery := False;
        end
        else if lDiscoveryAction = cdaFetchRss then
        begin
          LoadPersistentIndexFromRss;
          lContinueFullDiscovery := False;
        end;
      end;
      if lContinueFullDiscovery then
      begin
        if lDiscoveryError = '' then
          lVideos := BuildChannelVideoQueue(lSetupService, lSeedMeta, aConfig,
            lYtDlpExtraArgs, lDiscoveryError)
        else
          lVideos := nil;
        if aConfig.FileMode then
        begin
          if lDiscoveryError <> '' then
          begin
            if not lHasIndex then
              raise Exception.Create('Channel discovery failed: ' +
                lDiscoveryError);
            lStats.DiscoveryErrorKind := 'discovery';
            lStats.DiscoveryError := lDiscoveryError;
            UsePersistentIndex(lIndexData, '');
            WriteLn('Warning: full channel discovery failed; using the last valid index: ' +
              lDiscoveryError);
          end
          else
          begin
            lDiscoveredIndex := ChannelIndexFromDiscovery(aConfig.URL,
              lSeedMeta, lVideos);
            if not Assigned(lIndexStore) then
            begin
              lChannelDir := BuildChannelOutputDir(aConfig, lSeedMeta);
              gc(lIndexStore, TChannelIndexStore.Create(lChannelDir),
                lIndexStoreOwner);
            end
            else
              lChannelDir := ExtractFileDir(lIndexStore.FileName);
            if TryReconcileFullChannelIndex(lIndexStore, lIndexData,
              lHasIndex, lDiscoveredIndex, UtcNow, lUpdatedIndex,
              lDiscoveryError) then
            begin
              lVideos := VideosFromChannelIndex(lUpdatedIndex);
              WriteLn(Format(
                'Reconciled persistent channel index: %d videos.',
                [Length(lVideos)]));
            end
            else
            begin
              lStats.DiscoveryErrorKind := 'discovery';
              lStats.DiscoveryError := lDiscoveryError;
              UsePersistentIndex(lUpdatedIndex, '');
              WriteLn(
                'Warning: full channel reconciliation failed; using the last valid index: ' +
                lDiscoveryError);
            end;
          end;
        end
        else
          lChannelDir := BuildChannelOutputDir(aConfig, lSeedMeta);
      end
    end;
    if Assigned(aDiscoveryCache) then
    begin
      aDiscoveryCache.SeedMeta := lSeedMeta;
      aDiscoveryCache.Videos := Copy(lVideos);
      aDiscoveryCache.YtDlpExtraArgs := lYtDlpExtraArgs;
      aDiscoveryCache.ChannelDirectory := lChannelDir;
      aDiscoveryCache.DiscoveryErrorKind := lStats.DiscoveryErrorKind;
      aDiscoveryCache.DiscoveryError := lStats.DiscoveryError;
      aDiscoveryCache.Initialized := True;
    end;
  end;
  if Length(lVideos) = 0 then
    raise Exception.Create('Channel mode could not find any videos to process.');

  if lChannelDir = '' then
    lChannelDir := BuildChannelOutputDir(aConfig, lSeedMeta);
  TDirectory.CreateDirectory(lChannelDir);

  lExistingVideoIds := nil;
  lUnavailableVideos := nil;
  lFileLock := nil;
  lLogLock := nil;
  lHeartbeatStop := nil;
  lHeartbeatTask := nil;
  lOwnOutputState := False;
  try
    lOwnOutputState := not Assigned(aDiscoveryCache);
    if Assigned(aDiscoveryCache) then
    begin
      lExistingVideoIds := aDiscoveryCache.ExistingVideoIds;
      lUnavailableVideos := aDiscoveryCache.UnavailableVideos;
    end
    else
    begin
      lExistingVideoIds := TDictionary<string, Byte>.Create;
      lUnavailableVideos := LoadUnavailableVideos(lChannelDir);
    end;
    lUnavailableManifestChanged := False;
    if Assigned(aDiscoveryCache) and
       (not aDiscoveryCache.OutputStateInitialized) then
    begin
      var lLoadedUnavailableVideos := LoadUnavailableVideos(lChannelDir);
      aDiscoveryCache.UnavailableVideos.Free;
      aDiscoveryCache.UnavailableVideos := lLoadedUnavailableVideos;
      lUnavailableVideos := aDiscoveryCache.UnavailableVideos;
    end;
    if (not Assigned(aDiscoveryCache)) or
       (not aDiscoveryCache.OutputStateInitialized) then
      for var lExistingFile in TranscriptFiles(lChannelDir) do
      begin
        var lExistingVideoId := Trim(ReadFrontMatterValue(lExistingFile,
          'video_id')).ToLower;
        if (lExistingVideoId <> '') and
           (not lExistingVideoIds.ContainsKey(lExistingVideoId)) then
          lExistingVideoIds.Add(lExistingVideoId, 1);
        if (lExistingVideoId <> '') and
           lUnavailableVideos.ContainsKey(lExistingVideoId) then
        begin
          lUnavailableVideos.Remove(lExistingVideoId);
          lUnavailableManifestChanged := True;
        end;
      end;
    if Assigned(aDiscoveryCache) then
      aDiscoveryCache.OutputStateInitialized := True;
    if lUnavailableManifestChanged then
      SaveUnavailableVideos(lChannelDir, lUnavailableVideos);

    lEffectiveMetaOptions := aConfig.MetaOptions;
    lEffectiveMetaOptions.Channel := True;
    lEffectiveMetaOptions.VideoId := True;
    lEffectiveMetaOptions.ChannelId := True;

    lFileLock := TCriticalSection.Create;
    lLogLock := TCriticalSection.Create;
    if Assigned(aDiscoveryCache) then
      lNextIndex := aDiscoveryCache.NextVideoIndex - 1
    else
      lNextIndex := -1;
    lProgressProcessed := 0;
    lLastProgressTick := TThread.GetTickCount64;
    lLastReportedProcessed := 0;
    lLastCooldownProgressTick := 0;
    lStopScheduling := 0;
    lProgressError := '';
    lAttemptedCount := 0;
    lSliceLimitReached := 0;
    lThrottleProbeSkipped := 0;
    lThrottleExhaustedSkipped := 0;
    lThrottleDeferredCount := 0;

    WriteLn('Channel: ' + lSeedMeta.Channel);
    WriteLn(Format('Queued: %d', [Length(lVideos)]));
    WriteLn('Output: ' + lChannelDir);

    lHeartbeatStop := TEvent.Create(nil, True, False, '');
    lHeartbeatTask := TTask.Run(
      procedure
      var
        lHeartbeatProcessed: Integer;
      begin
        while lHeartbeatStop.WaitFor(CProgressIntervalMs) = wrTimeout do
        begin
          lHeartbeatProcessed := TInterlocked.Add(lProgressProcessed, 0);
          try
            ReportChannelProgress(lLogLock, lHeartbeatProcessed,
              Length(lVideos), lStats, lLastProgressTick,
              lLastReportedProcessed, lLastCooldownProgressTick, True,
              aProgressCallback);
          except
            on E: Exception do
            begin
              lLogLock.Enter;
              try
                lProgressError := E.Message;
              finally
                lLogLock.Leave;
              end;
              TInterlocked.Exchange(lStopScheduling, 1);
              Break;
            end;
          end;
        end;
      end);

    // One worker. The shared throttle gate spaces subtitle downloads 10-20 s
    // apart for every caller, so more workers cannot raise throughput (T-033).
    // The task keeps the heartbeat and the EAggregateException handling.
      lWorkerTask := TTask.Run(
        procedure
        var
          lService: TTranscriptService;
          lIndex: Integer;
          lAttempt: Integer;
          lResult: TTranscriptResult;
          lOutputText: string;
          lOutputPath: string;
          lAction: TChannelConflictAction;
          lDelayMs: Integer;
          lFailedMessage: string;
          lProcessedSnapshot: Integer;
          lUnavailable: Boolean;
          lVideoId: string;
          lAlreadyExists: Boolean;
          lCachedUnavailable: Boolean;
          lCachedEntry: TUnavailableVideo;
          lUnavailableMeta: TTranscriptMetadata;
          lUnavailableEntry: TUnavailableVideo;
          lIsThrottle: Boolean;
        begin
          lService := TTranscriptService.Create(
            TThrottleController.RetryModeForFileMode(aConfig.FileMode));
          try
            while True do
            begin
              if TInterlocked.Add(lStopScheduling, 0) <> 0 then
                Break;
              lIndex := TInterlocked.Increment(lNextIndex);
              if lIndex >= Length(lVideos) then
              begin
                if Assigned(aDiscoveryCache) then
                  aDiscoveryCache.NextVideoIndex := 0;
                Break;
              end;
              lVideoId := ExtractVideoIdFromUrl(lVideos[lIndex].Url).ToLower;
              if Assigned(aDiscoveryCache) then
                aDiscoveryCache.NextVideoIndex := lIndex + 1;

              if Assigned(aDiscoveryCache) and
                 aDiscoveryCache.CompletedVideoIds.ContainsKey(lVideoId) then
              begin
                lProcessedSnapshot := TInterlocked.Increment(lProgressProcessed);
                ReportChannelProgress(lLogLock, lProcessedSnapshot,
                  Length(lVideos), lStats, lLastProgressTick,
                  lLastReportedProcessed, lLastCooldownProgressTick, False,
                  aProgressCallback);
                Continue;
              end;

              if Assigned(aDiscoveryCache) and
                 aDiscoveryCache.ThrottleProbes.IsExhausted(lVideoId) then
              begin
                TInterlocked.Increment(lThrottleExhaustedSkipped);
                lProcessedSnapshot := TInterlocked.Increment(lProgressProcessed);
                ReportChannelProgress(lLogLock, lProcessedSnapshot,
                  Length(lVideos), lStats, lLastProgressTick,
                  lLastReportedProcessed, lLastCooldownProgressTick, False,
                  aProgressCallback);
                Continue;
              end;

              if Assigned(aDiscoveryCache) and
                 aDiscoveryCache.ThrottleProbes.WasProbed(lVideoId) then
              begin
                TInterlocked.Increment(lThrottleProbeSkipped);
                lProcessedSnapshot := TInterlocked.Increment(lProgressProcessed);
                ReportChannelProgress(lLogLock, lProcessedSnapshot,
                  Length(lVideos), lStats, lLastProgressTick,
                  lLastReportedProcessed, lLastCooldownProgressTick, False,
                  aProgressCallback);
                Continue;
              end;

              if not aConfig.OverrideExisting then
              begin
                lFileLock.Enter;
                try
                  lAlreadyExists := (lVideoId <> '') and lExistingVideoIds.ContainsKey(lVideoId);
                finally
                  lFileLock.Leave;
                end;
                if lAlreadyExists then
                begin
                  TInterlocked.Increment(lStats.Skipped);
                  lProcessedSnapshot := TInterlocked.Increment(lProgressProcessed);
                  ReportChannelProgress(lLogLock, lProcessedSnapshot,
                    Length(lVideos), lStats, lLastProgressTick,
                    lLastReportedProcessed, lLastCooldownProgressTick, False,
                    aProgressCallback);
                  Continue;
                end;
              end;

              if not aConfig.RetryUnavailable then
              begin
                lFileLock.Enter;
                try
                  lCachedUnavailable := (lVideoId <> '') and lUnavailableVideos.ContainsKey(lVideoId);
                  if lCachedUnavailable and
                     lUnavailableVideos.TryGetValue(lVideoId, lCachedEntry) and
                     SameText(lCachedEntry.Status, 'throttled') and
                     (aConfig.RetryThrottledOnly or
                      (Assigned(aDiscoveryCache) and
                       (aDiscoveryCache.ThrottleProbes.AttemptCount(lVideoId) > 0) and
                       (not aDiscoveryCache.ThrottleProbes.IsExhausted(lVideoId)))) then
                    lCachedUnavailable := False;
                finally
                  lFileLock.Leave;
                end;
                if lCachedUnavailable then
                begin
                  TInterlocked.Increment(lStats.UnavailableCached);
                  lProcessedSnapshot := TInterlocked.Increment(lProgressProcessed);
                  ReportChannelProgress(lLogLock, lProcessedSnapshot,
                    Length(lVideos), lStats, lLastProgressTick,
                    lLastReportedProcessed, lLastCooldownProgressTick, False,
                    aProgressCallback);
                  Continue;
                end;
              end;

              if (aMaxVideoAttempts > 0) and
                 (TInterlocked.Increment(lAttemptedCount) > aMaxVideoAttempts) then
              begin
                TInterlocked.Decrement(lAttemptedCount);
                if Assigned(aDiscoveryCache) then
                  aDiscoveryCache.NextVideoIndex := lIndex;
                TInterlocked.Exchange(lSliceLimitReached, 1);
                TInterlocked.Exchange(lStopScheduling, 1);
                Break;
              end;

              begin
                lFailedMessage := '';
                lUnavailable := False;
                lIsThrottle := False;
                lUnavailableMeta := Default(TTranscriptMetadata);
                for lAttempt := 1 to CRetryAttempts do
                begin
                  try
                    lResult := FetchTranscriptWithFallback(lService,
                      lVideos[lIndex].Url, aConfig.Language, lYtDlpExtraArgs);
                    lOutputText := BuildMetaSection(lResult.Meta, aConfig.Keywords, lEffectiveMetaOptions) + lResult.Transcript;

                    lFileLock.Enter;
                    try
                      ResolveChannelFilePath(lChannelDir, lResult.Meta, aConfig.OverrideExisting, lOutputPath, lAction);
                      if lAction = ccaSkip then
                        TInterlocked.Increment(lStats.Skipped)
                      else
                      begin
                        WriteTranscriptFile(lOutputPath, lOutputText);
                        if aConfig.FileMode and Assigned(GSourceThrottlePolicy) then
                        begin
                          GSourceThrottlePolicy.ReportSuccess(GCurrentSource);
                          GThrottleController.ReportVideoSuccess;
                          WriteLn('Saved transcript: ' + lResult.Meta.VideoId);
                          AppendInvocationLog(UtcNowIso, 'transcript_saved',
                            lVideos[lIndex].Url, 0, 0, 0, trkNone, lOutputPath);
                        end;
                        if lAction = ccaOverwrite then
                          TInterlocked.Increment(lStats.Overwritten)
                        else
                          TInterlocked.Increment(lStats.Downloaded);
                      end;
                      lVideoId := Trim(lResult.Meta.VideoId).ToLower;
                      if (lVideoId <> '') and
                         (not lExistingVideoIds.ContainsKey(lVideoId)) then
                        lExistingVideoIds.Add(lVideoId, 1);
                      if (lVideoId <> '') and lUnavailableVideos.ContainsKey(lVideoId) then
                      begin
                        lUnavailableVideos.Remove(lVideoId);
                        SaveUnavailableVideos(lChannelDir, lUnavailableVideos);
                      end;
                    finally
                      lFileLock.Leave;
                    end;
                    if Assigned(aDiscoveryCache) then
                    begin
                      aDiscoveryCache.ThrottleProbes.MarkSucceeded(lVideoId);
                      if (lVideoId <> '') and
                         (not aDiscoveryCache.CompletedVideoIds.ContainsKey(lVideoId)) then
                        aDiscoveryCache.CompletedVideoIds.Add(lVideoId, 1);
                    end;

                    lFailedMessage := '';
                    Break;
                  except
                    on E: Exception do
                    begin
                      if IsFatalProcessingException(E) then
                        raise;
                      lFailedMessage := E.Message;
                      if IsMissingSubtitleError(lFailedMessage) then
                      begin
                        lUnavailable := True;
                        if E is EMissingTranscriptError then
                          lUnavailableMeta := EMissingTranscriptError(E).Metadata;
                        Break;
                      end;
                      lIsThrottle := IsThrottleException(E);
                      if lIsThrottle then
                      begin
                        if Assigned(aDiscoveryCache) then
                          aDiscoveryCache.ThrottleProbes.MarkProbed(lVideoId);
                        TInterlocked.Increment(lThrottleDeferredCount);
                        if TInterlocked.CompareExchange(lStopScheduling, 1, 0) = 0 then
                        begin
                          lLogLock.Enter;
                          try
                            WriteLn(
                              'Warning: shared throttle retries exhausted; stopping this channel with remaining videos deferred.'
                            );
                          finally
                            lLogLock.Leave;
                          end;
                        end;
                        Break;
                      end;
                      if lAttempt = CRetryAttempts then
                        Break;
                      lDelayMs := CRetryBaseDelayMs * (1 shl (lAttempt - 1));
                      lDelayMs := lDelayMs + ((lIndex + lAttempt * 53) mod 350);
                      Sleep(lDelayMs);
                    end;
                  end;
                end;

                if lFailedMessage <> '' then
                begin
                  if lUnavailable then
                  begin
                    TInterlocked.Increment(lStats.Unavailable);
                    lUnavailableEntry := Default(TUnavailableVideo);
                    lUnavailableEntry.VideoId := Trim(lUnavailableMeta.VideoId);
                    if lUnavailableEntry.VideoId = '' then
                      lUnavailableEntry.VideoId := ExtractVideoIdFromUrl(lVideos[lIndex].Url);
                    lUnavailableEntry.Url := lVideos[lIndex].Url;
                    lUnavailableEntry.Title := lUnavailableMeta.Title;
                    lUnavailableEntry.PublishedAt := lUnavailableMeta.PublishedAt;
                    if lUnavailableEntry.PublishedAt = '' then
                      lUnavailableEntry.PublishedAt := lVideos[lIndex].PublishedAt;
                    lUnavailableEntry.LastAttemptUtc := UtcNowIso;
                    lUnavailableEntry.Status := 'unavailable';
                    lUnavailableEntry.ErrorKind := 'unavailable';
                    lUnavailableEntry.ErrorMessage := NormalizeErrorMessage(lFailedMessage);
                    if lUnavailableEntry.VideoId <> '' then
                    begin
                      lFileLock.Enter;
                      try
                        lUnavailableVideos.AddOrSetValue(lUnavailableEntry.VideoId.ToLower, lUnavailableEntry);
                        SaveUnavailableVideos(lChannelDir, lUnavailableVideos);
                      finally
                        lFileLock.Leave;
                      end;
                      if Assigned(aDiscoveryCache) and
                         (not aDiscoveryCache.CompletedVideoIds.ContainsKey(
                           lUnavailableEntry.VideoId.ToLower)) then
                        aDiscoveryCache.CompletedVideoIds.Add(
                          lUnavailableEntry.VideoId.ToLower, 1);
                    end;
                  end
                  else
                  begin
                    if lIsThrottle then
                    begin
                      if Assigned(aDiscoveryCache) and
                         aDiscoveryCache.ThrottleProbes.IsExhausted(lVideoId) and
                         (not aDiscoveryCache.TerminalFailureIds.ContainsKey(lVideoId)) then
                        aDiscoveryCache.TerminalFailureIds.Add(lVideoId, 1);
                    end
                    else
                    begin
                      TInterlocked.Increment(lStats.Failed);
                      if Assigned(aDiscoveryCache) and (lVideoId <> '') and
                         (not aDiscoveryCache.TerminalFailureIds.ContainsKey(lVideoId)) then
                        aDiscoveryCache.TerminalFailureIds.Add(lVideoId, 1);
                      if Assigned(aDiscoveryCache) and (lVideoId <> '') and
                         (not aDiscoveryCache.CompletedVideoIds.ContainsKey(lVideoId)) then
                        aDiscoveryCache.CompletedVideoIds.Add(lVideoId, 1);
                    end;
                    lUnavailableEntry := Default(TUnavailableVideo);
                    lUnavailableEntry.VideoId := ExtractVideoIdFromUrl(lVideos[lIndex].Url);
                    lUnavailableEntry.Url := lVideos[lIndex].Url;
                    lUnavailableEntry.PublishedAt := lVideos[lIndex].PublishedAt;
                    lUnavailableEntry.LastAttemptUtc := UtcNowIso;
                    lUnavailableEntry.ErrorKind := ClassifyError(lFailedMessage);
                    if lUnavailableEntry.ErrorKind = 'throttled' then
                      lUnavailableEntry.Status := 'throttled'
                    else
                      lUnavailableEntry.Status := 'failed';
                    lUnavailableEntry.ErrorMessage := NormalizeErrorMessage(lFailedMessage);
                    if lUnavailableEntry.VideoId <> '' then
                    begin
                      lFileLock.Enter;
                      try
                        lUnavailableVideos.AddOrSetValue(lUnavailableEntry.VideoId.ToLower, lUnavailableEntry);
                        SaveUnavailableVideos(lChannelDir, lUnavailableVideos);
                      finally
                        lFileLock.Leave;
                      end;
                    end;
                  end;
                  try
                    lLogLock.Enter;
                    try
                      if lUnavailable then
                        WriteLn(Format('Unavailable: no transcript for %s', [lVideos[lIndex].Url]))
                      else
                        WriteLn(Format('Warning: failed to process %s (%s)',
                          [lVideos[lIndex].Url, lFailedMessage]));
                    finally
                      lLogLock.Leave;
                    end;
                  except
                    on Exception do
                    begin
                      // Logging errors should not stop the channel run.
                    end;
                  end;
                end;
                lProcessedSnapshot := TInterlocked.Increment(lProgressProcessed);
                ReportChannelProgress(lLogLock, lProcessedSnapshot,
                  Length(lVideos), lStats, lLastProgressTick,
                  lLastReportedProcessed, lLastCooldownProgressTick, False,
                  aProgressCallback);
              end;
            end;
          finally
            lService.Free;
          end;
        end
      );

    try
      TTask.WaitForAll([lWorkerTask]);
    finally
      lHeartbeatStop.SetEvent;
      lHeartbeatTask.Wait;
    end;
    if lProgressError <> '' then
      raise Exception.Create('Channel progress checkpoint failed: ' +
        lProgressError);
  finally
    if Assigned(lHeartbeatStop) then
      lHeartbeatStop.SetEvent;
    if Assigned(lHeartbeatTask) then
      lHeartbeatTask.Wait;
    lHeartbeatStop.Free;
    lFileLock.Free;
    lLogLock.Free;
    if lOwnOutputState then
    begin
      lExistingVideoIds.Free;
      lUnavailableVideos.Free;
    end;
  end;

  if Assigned(aDiscoveryCache) and
     aDiscoveryCache.ThrottleProbes.CompletePass(
       TInterlocked.Add(lStopScheduling, 0) <> 0) then
  begin
    TInterlocked.Exchange(lSliceLimitReached, 1);
    WriteLn('Throttle probe cycle completed; deferred targets will rotate through another channel slice.');
  end;
  if TInterlocked.Add(lSliceLimitReached, 0) <> 0 then
    WriteLn('Channel slice completed; remaining videos will rotate to the end of the queue.')
  else if TInterlocked.Add(lStopScheduling, 0) <> 0 then
    WriteLn('Channel processing stopped; remaining videos are deferred.')
  else
    WriteLn('Channel download completed.');
  WriteLn('Channel: ' + lSeedMeta.Channel);
  WriteLn('Output: ' + lChannelDir);
  if Assigned(aDiscoveryCache) then
  begin
    lDeferredCount := 0;
    for var lDeferredVideo in lVideos do
    begin
      var lDeferredVideoId := ExtractVideoIdFromUrl(
        lDeferredVideo.Url).ToLower;
      if aDiscoveryCache.CompletedVideoIds.ContainsKey(lDeferredVideoId) then
        Continue;
      if (not aConfig.OverrideExisting) and
         aDiscoveryCache.ExistingVideoIds.ContainsKey(lDeferredVideoId) then
        Continue;
      if aDiscoveryCache.ThrottleProbes.IsExhausted(lDeferredVideoId) or
         aDiscoveryCache.ThrottleProbes.WasProbed(lDeferredVideoId) then
      begin
        Inc(lDeferredCount);
        Continue;
      end;
      var lDeferredUnavailable := False;
      if (not aConfig.RetryUnavailable) and
         aDiscoveryCache.UnavailableVideos.TryGetValue(lDeferredVideoId,
           lDeferredCachedEntry) then
      begin
        lDeferredUnavailable := SameText(lDeferredCachedEntry.Status,
          'throttled') and
          (aConfig.RetryThrottledOnly or
           (aDiscoveryCache.ThrottleProbes.AttemptCount(lDeferredVideoId) > 0));
      end;
      if not lDeferredUnavailable and (not aConfig.RetryUnavailable) and
         aDiscoveryCache.UnavailableVideos.ContainsKey(lDeferredVideoId) then
        Continue;
      Inc(lDeferredCount);
    end;
    lProcessedCount := Length(lVideos) - lDeferredCount;
    if aDiscoveryCache.TerminalFailureIds.Count > lStats.Failed then
      lStats.Failed := aDiscoveryCache.TerminalFailureIds.Count;
  end
  else
  begin
    lProcessedCount := TInterlocked.Add(lProgressProcessed, 0) -
      TInterlocked.Add(lThrottleProbeSkipped, 0) -
      TInterlocked.Add(lThrottleExhaustedSkipped, 0) -
      TInterlocked.Add(lThrottleDeferredCount, 0);
    if lProcessedCount < 0 then
      lProcessedCount := 0;
    lDeferredCount := Length(lVideos) - lProcessedCount;
    if lDeferredCount < 0 then
      lDeferredCount := 0;
  end;
  lStats.Processed := lProcessedCount;
  lStats.Total := Length(lVideos);
  lStats.Deferred := lDeferredCount;
  lStats.Attempted := TInterlocked.Add(lAttemptedCount, 0);
  lStats.SliceLimited := TInterlocked.Add(lSliceLimitReached, 0) <> 0;
  WriteLn(Format('Queued: %d', [Length(lVideos)]));
  WriteLn(Format('Processed: %d', [lProcessedCount]));
  WriteLn(Format('Deferred: %d', [lDeferredCount]));
  WriteLn(Format('Downloaded: %d', [lStats.Downloaded]));
  WriteLn(Format('Overwritten: %d', [lStats.Overwritten]));
  WriteLn(Format('Skipped: %d', [lStats.Skipped]));
  WriteLn(Format('Unavailable: %d', [lStats.Unavailable]));
  WriteLn(Format('Unavailable cached: %d', [lStats.UnavailableCached]));
  WriteLn(Format('Failed: %d', [lStats.Failed]));

  aStats := lStats;
  if aConfig.FileMode and (TInterlocked.Add(lStopScheduling, 0) <> 0) and
     (not lStats.SliceLimited) then
    Result := 2
  else
    Result := 0;
end;

function RunSingleVideo(const aConfig: TCommandLineConfig;
  out aMeta: TTranscriptMetadata; out aOutputPath: string): Integer;
var
  lOutputText : String;
  lService    : TTranscriptService;
  lTranscript : TTranscriptResult;
  lOutputDir  : string;
  lMetaOptions: TMetaOptions;
  lYtDlpExtraArgs: string;
begin
  Result := 1;
  aMeta := Default(TTranscriptMetadata);
  aOutputPath := '';
  lYtDlpExtraArgs := BuildYtDlpAuthArguments(aConfig);
  gc(lService, TTranscriptService.Create(
    TThrottleController.RetryModeForFileMode(aConfig.FileMode)));
  try
    lTranscript := lService.FetchTranscript(aConfig.URL, aConfig.Language,
      lYtDlpExtraArgs, CDefaultLanguage);
  except
    on E: Exception do
    begin
      if IsFatalProcessingException(E) then
        raise;
      if E is EMissingTranscriptError then
        aMeta := EMissingTranscriptError(E).Metadata;
      if ShouldRetryWithoutDefaultAuth(aConfig) and
         (Trim(lYtDlpExtraArgs) <> '') and IsCookieAuthFailure(E) then
      begin
        WriteLn('Warning: default cookie auth failed; retrying without cookies.');
        lYtDlpExtraArgs := BuildYtDlpPacingArguments(aConfig);
        lTranscript := lService.FetchTranscript(aConfig.URL, aConfig.Language,
          lYtDlpExtraArgs, CDefaultLanguage);
      end
      else
        raise;
    end;
  end;
  lOutputText := lTranscript.Transcript;
  lMetaOptions := aConfig.MetaOptions;
  if aConfig.FileMode then
    lMetaOptions.VideoId := True;
  if aConfig.IncludeMeta or aConfig.FileMode then
    lOutputText := BuildMetaSection(lTranscript.Meta, aConfig.Keywords, lMetaOptions) + lOutputText;

  aOutputPath := BuildOutputFilePath(aConfig, lTranscript.Meta);
  if aOutputPath.IsEmpty then
    WriteLn(lOutputText)
  else
  begin
    aOutputPath := EnsureUniqueFilePath(aOutputPath);
    lOutputDir := ExtractFileDir(aOutputPath);
    if not lOutputDir.IsEmpty then
      TDirectory.CreateDirectory(lOutputDir);
    WriteTranscriptFile(aOutputPath, lOutputText);
    if aConfig.FileMode and Assigned(GSourceThrottlePolicy) then
    begin
      GSourceThrottlePolicy.ReportSuccess(GCurrentSource);
      GThrottleController.ReportVideoSuccess;
      AppendInvocationLog(UtcNowIso, 'transcript_saved', aConfig.URL,
        0, 0, 0, trkNone, aOutputPath);
    end;
    WriteLn('Transcript saved to: ', aOutputPath);
  end;
  aMeta := lTranscript.Meta;
  Result := 0;
end;

function RunSingleVideoWithRetries(const aConfig: TCommandLineConfig;
  out aMeta: TTranscriptMetadata; out aOutputPath: string): Integer;
var
  lAttempt, lDelayMs: Integer;
begin
  for lAttempt := 1 to CRetryAttempts do
  begin
    try
      Exit(RunSingleVideo(aConfig, aMeta, aOutputPath));
    except
      on E: Exception do
      begin
        if IsFatalProcessingException(E) then
          raise;
        if IsMissingSubtitleError(E.Message) or (lAttempt = CRetryAttempts) then
          raise;
        if IsThrottleException(E) then
          raise;
        lDelayMs := CRetryBaseDelayMs * (1 shl (lAttempt - 1));
        Sleep(lDelayMs);
      end;
    end;
  end;
  Result := 1;
end;

function CombineOutputFolder(const aRoot, aSubfolder: string): string;
var
  lCandidate, lRootWithSlash: string;
begin
  Result := TPath.GetFullPath(aRoot);
  if Trim(aSubfolder) = '' then
    Exit;
  if TPath.IsPathRooted(aSubfolder) then
    raise EDownloadFileError.Create('subfolder must be relative: ' + aSubfolder);
  lCandidate := TPath.GetFullPath(TPath.Combine(Result, aSubfolder));
  lRootWithSlash := IncludeTrailingPathDelimiter(Result);
  if not StartsText(lRootWithSlash, IncludeTrailingPathDelimiter(lCandidate)) and
     not SameText(Result, lCandidate) then
    raise EDownloadFileError.Create('subfolder escapes output_dir: ' + aSubfolder);
  Result := lCandidate;
end;

procedure ApplyEntryPacing(const aController: TThrottleController;
  const aOptions: TDownloadOptions; const aCliBaseIntervalMs: Integer);
var
  lBaseIntervalMs: Integer;
begin
  lBaseIntervalMs := aOptions.BaseIntervalMs;
  if lBaseIntervalMs < 0 then // not set in the YAML
    lBaseIntervalMs := aCliBaseIntervalMs;
  aController.SetRequestInterval(aOptions.RequestIntervalMs,
    aOptions.DelayJitterMs, lBaseIntervalMs);
end;

// YAML cookies/cookies_from_browser replace the settings.ini defaults.
procedure ApplyEntryCookies(var aConfig: TCommandLineConfig;
  const aOptions: TDownloadOptions);
begin
  if Trim(aOptions.Cookies) <> '' then
  begin
    aConfig.CookiesFile := aOptions.Cookies;
    aConfig.CookiesFromBrowser := '';
  end;
  if Trim(aOptions.CookiesFromBrowser) <> '' then
  begin
    aConfig.CookiesFromBrowser := aOptions.CookiesFromBrowser;
    aConfig.CookiesFile := '';
  end;
end;

procedure ApplyEntryConfig(var aConfig: TCommandLineConfig;
  const aJob: TDownloadFile; const aEntry: TDownloadEntry);
begin
  aConfig.URL := aEntry.Url;
  aConfig.FileMode := True;
  aConfig.ChannelMode := aEntry.Kind = dekChannel;
  aConfig.Language := aEntry.Options.Language;
  aConfig.RequestIntervalMs := aEntry.Options.RequestIntervalMs;
  aConfig.DelayJitterMs := aEntry.Options.DelayJitterMs;
  aConfig.SleepRequestsSeconds := aEntry.Options.SleepRequestsSeconds;
  aConfig.SleepSubtitlesSeconds := aEntry.Options.SleepSubtitlesSeconds;
  aConfig.SocketTimeoutSeconds := aEntry.Options.SocketTimeoutSeconds;
  aConfig.IncludeShorts := aEntry.Options.IncludeShorts;
  aConfig.IncludeLive := aEntry.Options.IncludeLive;
  aConfig.OverrideExisting := aEntry.Options.OverwriteExisting;
  aConfig.IncludeMeta := aEntry.Options.Metadata;
  aConfig.Keywords := aEntry.Options.Keywords;
  aConfig.OutputTarget := '';
  aConfig.OutputDir := CombineOutputFolder(aJob.OutputRoot, aEntry.Options.Subfolder);
  aConfig.ChannelOutputRoot := aConfig.OutputDir;
  ApplyEntryCookies(aConfig, aEntry.Options);
  aConfig.RetryUnavailable := aJob.Mode <> dmFresh;
  aConfig.RetryThrottledOnly := aJob.Mode = dmThrottled;
  if aConfig.RetryThrottledOnly then
    aConfig.RetryUnavailable := False;
  aConfig.MetaOptions.VideoId := True;
end;

function EnsureState(const aOwner: IYAMLMapping): IYAMLMapping;
begin
  if aOwner.ContainsKey('state') then
    Result := aOwner['state'].AsMapping
  else
    Result := aOwner.AddOrSetMapping('state');
end;

function ReplaceState(const aOwner: IYAMLMapping): IYAMLMapping;
var
  lComments: TStringList;
  lInlineComment: string;
  lOldState: IYAMLMapping;
begin
  lComments := TStringList.Create;
  try
    if aOwner.ContainsKey('state') then
    begin
      lOldState := aOwner['state'].AsMapping;
      lComments.Assign(lOldState.Comments);
      lInlineComment := lOldState.Comment;
    end;
    Result := aOwner.AddOrSetMapping('state');
    Result.Comments := lComments;
    Result.Comment := lInlineComment;
  finally
    lComments.Free;
  end;
end;

procedure MarkEntryAttempt(const aEntry: TDownloadEntry);
var
  lState: IYAMLMapping;
  lAttempts: Integer;
begin
  lState := EnsureState(aEntry.Node);
  lAttempts := 0;
  if lState.ContainsKey('attempt_count') then
    lAttempts := lState.I['attempt_count'];
  lState.AddOrSetValue('status', 'running');
  lState.AddOrSetValue('last_attempt_utc', UtcNowIso);
  lState.AddOrSetValue('attempt_count', lAttempts + 1);
end;

procedure MarkEntryFailure(const aEntry: TDownloadEntry; const aMessage: string;
  const aMeta: TTranscriptMetadata);
var
  lKind, lStatus: string;
  lState: IYAMLMapping;
begin
  lKind := ClassifyError(aMessage);
  if lKind = 'unavailable' then lStatus := 'unavailable'
  else if lKind = 'throttled' then lStatus := 'throttled'
  else lStatus := 'failed';
  lState := EnsureState(aEntry.Node);
  lState.AddOrSetValue('status', lStatus);
  lState.AddOrSetValue('last_attempt_utc', UtcNowIso);
  lState.AddOrSetValue('error_kind', lKind);
  lState.AddOrSetValue('error', NormalizeErrorMessage(aMessage));
  if Trim(aMeta.VideoId) <> '' then
    lState.AddOrSetValue('video_id', aMeta.VideoId);
  if Trim(aMeta.PublishedAt) <> '' then
    lState.AddOrSetValue('video_published_at', aMeta.PublishedAt);
end;

procedure MarkChannelSuccess(const aEntry: TDownloadEntry;
  const aStats: TChannelRunStats);
var
  lAttempts: Integer;
  lState: IYAMLMapping;
begin
  lAttempts := 0;
  if aEntry.Node.ContainsKey('state') then
  begin
    lState := aEntry.Node['state'].AsMapping;
    if lState.ContainsKey('attempt_count') then
      lAttempts := lState.I['attempt_count'];
  end;

  // Replace the application-owned runtime state on success. In particular,
  // omit stale error fields instead of serializing empty strings as YAML nulls.
  lState := ReplaceState(aEntry.Node);
  if ChannelRunHasErrors(aStats.Failed, aStats.DiscoveryError) then
    lState.AddOrSetValue('status', 'completed_with_errors')
  else
    lState.AddOrSetValue('status', 'completed');
  lState.AddOrSetValue('last_attempt_utc', UtcNowIso);
  lState.AddOrSetValue('last_success_utc', UtcNowIso);
  lState.AddOrSetValue('attempt_count', lAttempts);
  lState.AddOrSetValue('downloaded', aStats.Downloaded);
  lState.AddOrSetValue('overwritten', aStats.Overwritten);
  lState.AddOrSetValue('skipped', aStats.Skipped);
  lState.AddOrSetValue('unavailable', aStats.Unavailable);
  lState.AddOrSetValue('unavailable_cached', aStats.UnavailableCached);
  lState.AddOrSetValue('failed', aStats.Failed);
  lState.AddOrSetValue('processed', aStats.Processed);
  lState.AddOrSetValue('total', aStats.Total);
  lState.AddOrSetValue('deferred', aStats.Deferred);
  if aStats.DiscoveryError <> '' then
  begin
    lState.AddOrSetValue('error_kind', aStats.DiscoveryErrorKind);
    lState.AddOrSetValue('error', NormalizeErrorMessage(
      aStats.DiscoveryError));
  end;
end;

procedure MarkChannelProgress(const aEntry: TDownloadEntry;
  const aStats: TChannelRunStats; const aProcessed, aTotal: Integer);
var
  lState: IYAMLMapping;
begin
  lState := EnsureState(aEntry.Node);
  lState.AddOrSetValue('status', 'running');
  lState.AddOrSetValue('last_checkpoint_utc', UtcNowIso);
  lState.AddOrSetValue('downloaded', aStats.Downloaded);
  lState.AddOrSetValue('overwritten', aStats.Overwritten);
  lState.AddOrSetValue('skipped', aStats.Skipped);
  lState.AddOrSetValue('unavailable', aStats.Unavailable);
  lState.AddOrSetValue('unavailable_cached', aStats.UnavailableCached);
  lState.AddOrSetValue('failed', aStats.Failed);
  lState.AddOrSetValue('processed', aProcessed);
  lState.AddOrSetValue('total', aTotal);
  lState.AddOrSetValue('deferred', aTotal - aProcessed);
  if aStats.DiscoveryError <> '' then
  begin
    lState.AddOrSetValue('error_kind', aStats.DiscoveryErrorKind);
    lState.AddOrSetValue('error', NormalizeErrorMessage(
      aStats.DiscoveryError));
  end;
end;

procedure UpdateJobState(const aJob: TDownloadFile; const aStatus: string;
  const aStartedUtc: string; const aProcessed, aEligibilitySkipped,
  aFailed, aDeferredQueueEntries, aDeferredChannelVideos,
  aChannelSlices: Integer; const aTerminal: Boolean;
  const aThrottleRetryAfterUtc: string = '');
var
  lState: IYAMLMapping;
  lCooldownMs: Cardinal;
  lRetryAfterUtc: string;
begin
  lState := ReplaceState(aJob.Root);
  lState.AddOrSetValue('status', aStatus);
  lState.AddOrSetValue('last_run_started_utc', aStartedUtc);
  lState.AddOrSetValue('last_checkpoint_utc', UtcNowIso);
  if aTerminal then
    lState.AddOrSetValue('last_run_completed_utc', UtcNowIso);
  lState.AddOrSetValue('processed', aProcessed);
  lState.AddOrSetValue('eligibility_skipped', aEligibilitySkipped);
  lState.AddOrSetValue('failed', aFailed);
  lState.AddOrSetValue('deferred_queue_entries', aDeferredQueueEntries);
  lState.AddOrSetValue('deferred_channel_videos', aDeferredChannelVideos);
  lState.AddOrSetValue('deferred',
    aDeferredQueueEntries + aDeferredChannelVideos);
  lState.AddOrSetValue('channel_slices', aChannelSlices);
  lRetryAfterUtc := Trim(aThrottleRetryAfterUtc);
  if Assigned(GThrottleController) then
  begin
    lState.AddOrSetValue('throttle_level',
      GThrottleController.ThrottleLevel);
    lState.AddOrSetValue('throttle_success_count',
      GThrottleController.SuccessfulVideosSinceThrottle);
    lState.AddOrSetValue('throttle_recovery_remaining',
      GThrottleController.RecoveryRequestsRemaining);
    if GThrottleController.LastThrottleKind <> trkNone then
    begin
      lState.AddOrSetValue('throttle_kind',
        TThrottleController.ResponseKindToString(
          GThrottleController.LastThrottleKind));
      lState.AddOrSetValue('throttle_message', NormalizeErrorMessage(
        GThrottleController.LastThrottleMessage));
      lState.AddOrSetValue('throttle_operation',
        GThrottleController.LastThrottleOperation);
      lState.AddOrSetValue('throttle_target',
        GThrottleController.LastThrottleTarget);
      lState.AddOrSetValue('throttle_last_response_utc',
        GThrottleController.LastThrottleAtUtc);
      lState.AddOrSetValue('throttle_exit_code',
        GThrottleController.LastThrottleExitCode);
    end;
    if lRetryAfterUtc = '' then
    begin
      lCooldownMs := GThrottleController.CooldownRemainingMs;
      if lCooldownMs > 0 then
        lRetryAfterUtc := DateToISO8601(
          IncMilliSecond(UtcNow, lCooldownMs), True);
    end;
  end;
  if lRetryAfterUtc <> '' then
    lState.AddOrSetValue('throttle_retry_after_utc', lRetryAfterUtc);
end;

function FindExistingStandaloneOutput(const aOutputDir, aUrl: string;
  out aFileName: string): Boolean;
var
  lVideoId: string;
begin
  Result := False;
  aFileName := '';
  lVideoId := ExtractVideoIdFromUrl(aUrl);
  if (lVideoId = '') or not TDirectory.Exists(aOutputDir) then
    Exit;
  for var lCandidate in TranscriptFiles(aOutputDir) do
    if SameText(Trim(ReadFrontMatterValue(lCandidate, 'video_id')), lVideoId) then
    begin
      aFileName := lCandidate;
      Exit(True);
    end;
end;

procedure SyncSourcePause(const aEntry: TDownloadEntry);
var
  lState: IYAMLMapping;
  lUntil: TDateTime;
begin
  lState := EnsureState(aEntry.Node);
  lUntil := GSourceThrottlePolicy.PauseUntil(aEntry.Url);
  lState.AddOrSetValue('source_retry_exhausted',
    GSourceThrottlePolicy.IsExhausted(aEntry.Url));
  lState.AddOrSetValue('source_pause_active', (lUntil > 0) and
    not GSourceThrottlePolicy.IsExhausted(aEntry.Url));
  if lUntil > 0 then
    lState.AddOrSetValue('source_pause_until_utc', DateToISO8601(lUntil, True));
end;

// True when some queued entry runs with cookies: the settings.ini defaults
// overridden by the entry's YAML options.
function QueueHasCookieSource(const aQueue: TQueue<TDownloadEntry>): Boolean;
var
  lDefaults, lConfig: TCommandLineConfig;
  lEntry: TDownloadEntry;
begin
  lDefaults := Default(TCommandLineConfig);
  LoadDefaultOptions(lDefaults);
  for lEntry in aQueue do
  begin
    lConfig := lDefaults;
    ApplyEntryCookies(lConfig, lEntry.Options);
    if HasEffectiveCookieSource(lConfig) then
      Exit(True);
  end;
  Result := False;
end;

function RunDownloadFile(const aFileName: string;
  const aBaseIntervalMs: Integer): Integer;
var
  lJob: TDownloadFile;
  lEntries: TArray<TDownloadEntry>;
  lEntry: TDownloadEntry;
  lQueue: TQueue<TDownloadEntry>;
  lChannelCaches: TObjectDictionary<string, TChannelDiscoveryCache>;
  lChannelCache: TChannelDiscoveryCache;
  lChannelCacheKey: string;
  lDiscoveryThrottles: TThrottleProbeTracker;
  lConfig: TCommandLineConfig;
  lMeta: TTranscriptMetadata;
  lOutputPath, lStartedUtc, lStatus: string;
  lRetryAfterUtc: string;
  lStats: TChannelRunStats;
  lProcessed, lSkipped, lFailed, lChannelResult: Integer;
  lChannelSlices, lDeferredChannelVideos: Integer;
  lTargetThrottleAttempts: Integer;
  lSavedThrottleLevel, lRestoredThrottleLevel: Integer;
  lCooldownMs, lThrottleIdleMs: Int64;
  lRestoreCooldownMs: Cardinal;
  lNowUtc: TDateTime;
  lJobLock: TCriticalSection;
  lPausedTurns: Integer;
  lSourceWaitMs: Int64;
  lLastPauseMessage: UInt64;
  lSourceState: IYAMLMapping;
  lPauseUntil: TDateTime;
  lRotate: Integer;

  procedure WithJobLock(const aAction: TProc);
  begin
    lJobLock.Enter;
    try
      aAction;
    finally
      lJobLock.Leave;
    end;
  end;
begin
  Result := 1;
  lJob := TDownloadFile.Open(aFileName);
  lJobLock := nil;
  try
    lJobLock := TCriticalSection.Create;
    lNowUtc := UtcNow;
    lCooldownMs := lJob.ThrottleCooldownRemainingMs(lNowUtc);
    if lCooldownMs <= 0 then
      lThrottleIdleMs := lJob.ThrottleIdleElapsedMs(lNowUtc)
    else
      lThrottleIdleMs := 0;
    TryAutoUpdateYtDlp;
    GThrottleController := TThrottleController.Create(
      CDefaultRequestIntervalMs, CDefaultDelayJitterMs, aBaseIntervalMs);
    try
      GSourceThrottlePolicy := TSourceThrottlePolicy.Create;
      lSavedThrottleLevel := lJob.SavedThrottleLevel;
      if (lSavedThrottleLevel = 0) and lJob.Root.ContainsKey('state') and
         lJob.Root['state'].AsMapping.ContainsKey('status') and
         SameText(lJob.Root['state'].AsMapping.S['status'], 'throttled') then
        lSavedThrottleLevel := 8;
      lRestoredThrottleLevel := lSavedThrottleLevel;
      if lCooldownMs <= 0 then
        lRestoreCooldownMs := 0
      else if lCooldownMs > High(Cardinal) then
        lRestoreCooldownMs := High(Cardinal)
      else
        lRestoreCooldownMs := Cardinal(lCooldownMs);
      GThrottleController.RestoreState(lRestoredThrottleLevel,
        lJob.SavedThrottleSuccessCount, lRestoreCooldownMs,
        lJob.SavedThrottleRecoveryRemaining, UInt64(lThrottleIdleMs));
      if GThrottleController.ThrottleLevel <> lRestoredThrottleLevel then
        WriteLn(Format(
          'Aged persisted YouTube throttle level from %d to %d after %d idle minutes.',
          [lRestoredThrottleLevel, GThrottleController.ThrottleLevel,
           lThrottleIdleMs div (60 * 1000)]));
      lRestoredThrottleLevel := GThrottleController.ThrottleLevel;
      if (lRestoredThrottleLevel > 0) or (lRestoreCooldownMs > 0) then
        WriteLn(Format(
          'Restored YouTube throttle level %d with %d recovery successes, %d guarded requests, and %d seconds of cooldown remaining.',
          [lRestoredThrottleLevel,
           GThrottleController.SuccessfulVideosSinceThrottle,
           GThrottleController.RecoveryRequestsRemaining,
           (UInt64(lRestoreCooldownMs) + 999) div 1000]));

      lStartedUtc := UtcNowIso;
      lProcessed := 0;
      lSkipped := 0;
      lFailed := 0;
      lChannelSlices := 0;
      lEntries := lJob.PrioritizedEntries;
      lPausedTurns := 0;
      lLastPauseMessage := 0;
      lQueue := TQueue<TDownloadEntry>.Create;
      lChannelCaches := TObjectDictionary<string, TChannelDiscoveryCache>.Create(
        [doOwnsValues]);
      lDiscoveryThrottles := TThrottleProbeTracker.Create;
      try
        for lEntry in lEntries do
          if lJob.IsEligible(lEntry) then
          begin
            if lEntry.Node.ContainsKey('state') then
            begin
              lSourceState := lEntry.Node['state'].AsMapping;
              if lSourceState.ContainsKey('source_pause_until_utc') and
                 lSourceState.ContainsKey('source_pause_active') and
                 lSourceState.B['source_pause_active'] and
                 ((not lSourceState.ContainsKey('source_retry_exhausted')) or
                  not lSourceState.B['source_retry_exhausted']) and
                 TryISO8601ToDate(lSourceState.S['source_pause_until_utc'], lPauseUntil, True) then
                GSourceThrottlePolicy.RestorePause(lEntry.Url, lPauseUntil);
            end;
            lQueue.Enqueue(lEntry);
          end
          else
            Inc(lSkipped);
        if lQueue.Count > 0 then
          ReportLoggedOutAtStart(QueueHasCookieSource(lQueue));
        WithJobLock(
          procedure
          begin
            UpdateJobState(lJob, 'running', lStartedUtc, 0, lSkipped, 0,
              lQueue.Count, 0, 0, False);
            lJob.Checkpoint;
          end);

        while lQueue.Count > 0 do
        begin
          lEntry := lQueue.Dequeue;
          lSourceWaitMs := GSourceThrottlePolicy.WaitRemainingMs(lEntry.Url, UtcNow);
          if lSourceWaitMs > 0 then
          begin
            lQueue.Enqueue(lEntry);
            Inc(lPausedTurns);
            if lPausedTurns >= lQueue.Count then
            begin
              if TThread.GetTickCount64 - lLastPauseMessage >= 30000 then
              begin
                WriteLn(Format('All %d remaining sources are paused; next checked source retries in %d seconds. Global cooldown: %d seconds.',
                  [lQueue.Count, (lSourceWaitMs + 999) div 1000,
                   (GThrottleController.CooldownRemainingMs + 999) div 1000]));
                UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                  lSkipped, lFailed, lQueue.Count, 0, lChannelSlices, False);
                lJob.Checkpoint;
                lLastPauseMessage := TThread.GetTickCount64;
              end;
              Sleep(1000);
              lPausedTurns := 0;
            end;
            Continue;
          end;
          lPausedTurns := 0;
          GCurrentSource := lEntry.Url;
          GCurrentSourceIsChannel := lEntry.Kind = dekChannel;
          lStats := Default(TChannelRunStats);
          lDeferredChannelVideos := 0;
          lConfig := Default(TCommandLineConfig);
          LoadDefaultOptions(lConfig);
          ApplyEntryConfig(lConfig, lJob, lEntry);
          ApplyEntryPacing(GThrottleController, lEntry.Options,
            aBaseIntervalMs);
          if (lEntry.Kind = dekVideo) and
             FindExistingStandaloneOutput(lConfig.OutputDir, lEntry.Url, lOutputPath) then
          begin
            WriteLn('Already downloaded; removing queue entry: ' + lEntry.Url);
            WithJobLock(
              procedure
              begin
                lJob.RemoveStandaloneVideoByUrl(lEntry.GroupIndex, lEntry.Url);
                Inc(lProcessed);
                UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                  lSkipped, lFailed, lQueue.Count, 0, lChannelSlices, False);
                lJob.Checkpoint;
              end);
            Continue;
          end;
          WithJobLock(
            procedure
            begin
              MarkEntryAttempt(lEntry);
              UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                lSkipped, lFailed, lQueue.Count, 0, lChannelSlices, False);
              lJob.Checkpoint;
            end);
          lMeta := Default(TTranscriptMetadata);
          try
            if lEntry.Kind = dekChannel then
            begin
              lChannelCacheKey := Format('%d:%d',
                [lEntry.GroupIndex, lEntry.EntryIndex]);
              if not lChannelCaches.TryGetValue(lChannelCacheKey,
                lChannelCache) then
              begin
                lChannelCache := TChannelDiscoveryCache.Create;
                lChannelCaches.Add(lChannelCacheKey, lChannelCache);
              end;
              GThrottleCheckpointCallback :=
                procedure
                begin
                  lJobLock.Enter;
                  try
                    UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                      lSkipped, lFailed, lQueue.Count, lStats.Deferred,
                      lChannelSlices, False);
                    lJob.Checkpoint;
                  finally
                    lJobLock.Leave;
                  end;
                end;
              try
                lChannelResult := RunChannelMode(lConfig, lStats,
                  procedure(const aProcessed, aTotal: Integer;
                    const aProgressStats: TChannelRunStats)
                  begin
                    lJobLock.Enter;
                    try
                      MarkChannelProgress(lEntry, aProgressStats, aProcessed,
                        aTotal);
                      UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                        lSkipped, lFailed, lQueue.Count, aTotal - aProcessed,
                        lChannelSlices, False);
                      lJob.Checkpoint;
                    finally
                      lJobLock.Leave;
                    end;
                  end,
                  FileModeChannelAttemptLimit, lChannelCache,
                  DiscoveryModeForDownloadMode(lJob.Mode));
              finally
                GThrottleCheckpointCallback := nil;
              end;
              WithJobLock(
                procedure
                begin
                  MarkChannelProgress(lEntry, lStats, lStats.Processed,
                    lStats.Total);
                  SyncSourcePause(lEntry);
                end);
              Inc(lChannelSlices);
              if lChannelResult = 2 then
                raise EThrottleError.Create(
                  'YouTube throttling persisted; channel processing was deferred');
              if lStats.SliceLimited and (lStats.Deferred > 0) then
              begin
                lQueue.Enqueue(lEntry);
                WriteLn(Format(
                  'Queue rotation: deferred %d videos from %s; %d queue entries will run first.',
                  [lStats.Deferred, lEntry.Url, lQueue.Count - 1]));
                WithJobLock(
                  procedure
                  begin
                    UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                      lSkipped, lFailed, lQueue.Count, lStats.Deferred,
                      lChannelSlices, False);
                    lJob.Checkpoint;
                  end);
                Continue;
              end;
              WithJobLock(
                procedure
                begin
                  MarkChannelSuccess(lEntry, lStats);
                end);
              if ChannelRunHasErrors(lStats.Failed,
                 lStats.DiscoveryError) then
                Inc(lFailed);
              lChannelCaches.Remove(lChannelCacheKey);
            end
            else
            begin
              GThrottleCheckpointCallback :=
                procedure
                begin
                  lJobLock.Enter;
                  try
                    UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                      lSkipped, lFailed, lQueue.Count, 0, lChannelSlices,
                      False);
                    lJob.Checkpoint;
                  finally
                    lJobLock.Leave;
                  end;
                end;
              try
                RunSingleVideoWithRetries(lConfig, lMeta, lOutputPath);
              finally
                GThrottleCheckpointCallback := nil;
              end;
              if (not TFile.Exists(lOutputPath)) or
                 (not SameText(Trim(ReadFrontMatterValue(lOutputPath, 'video_id')),
                   Trim(lMeta.VideoId))) then
                raise Exception.Create('Downloaded output could not be verified by video_id');
              WithJobLock(
                procedure
                begin
                  lJob.RemoveStandaloneVideoByUrl(lEntry.GroupIndex,
                    lEntry.Url);
                end);
            end;
            Inc(lProcessed);
          except
            on E: Exception do
            begin
              WithJobLock(
                procedure
                begin
                  MarkEntryFailure(lEntry, FailureMessage(E), lMeta);
                  SyncSourcePause(lEntry);
                end);
              WriteLn(Format('Warning: retained %s (%s)',
                [lEntry.Url, FailureMessage(E)]));
              if IsFatalProcessingException(E) then
              begin
                Inc(lFailed);
                if lEntry.Kind = dekChannel then
                  lDeferredChannelVideos := lStats.Deferred;
                WithJobLock(
                  procedure
                  begin
                    UpdateJobState(lJob, 'failed', lStartedUtc, lProcessed,
                      lSkipped, lFailed, lQueue.Count,
                      lDeferredChannelVideos, lChannelSlices, True);
                    lJob.Checkpoint;
                  end);
                WriteLn('Fatal runtime error; YAML job checkpointed and stopped.');
                raise;
              end;
              if IsThrottleException(E) then
              begin
                if GSourceThrottlePolicy.IsExhausted(lEntry.Url) then
                begin
                  Inc(lFailed);
                  Inc(lProcessed);
                  WriteLn('Source recovery probe failed; remaining videos retained for the next run: ' + lEntry.Url);
                  UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                    lSkipped, lFailed, lQueue.Count, 0, lChannelSlices, False);
                  lJob.Checkpoint;
                  Continue;
                end;
                if GSourceThrottlePolicy.WaitRemainingMs(lEntry.Url, UtcNow) > 0 then
                  WriteLn('Channel paused for 10 minutes; other sources continue: ' + lEntry.Url);
                if lEntry.Kind = dekChannel then
                  lDeferredChannelVideos := lStats.Deferred;
                if RecordFileModeThrottle(GThrottleController,
                  lDiscoveryThrottles, lEntry.Url, lEntry.Kind = dekVideo,
                  (lEntry.Kind = dekChannel) and
                  not lChannelCache.Initialized,
                  TThrottleController.ClassifyResponse(E.Message),
                  lTargetThrottleAttempts) then
                begin
                  Inc(lFailed);
                  WithJobLock(
                    procedure
                    begin
                      UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                        lSkipped, lFailed, lQueue.Count, 0, lChannelSlices,
                        False);
                      lJob.Checkpoint;
                    end);
                  WriteLn(Format(
                    'Target retry budget exhausted: retained %s after %d throttled attempts; continuing with the remaining queue.',
                    [lEntry.Url, lTargetThrottleAttempts]));
                  Continue;
                end;
                lQueue.Enqueue(lEntry);
                if lEntry.Kind = dekVideo then
                  for lRotate := 1 to lQueue.Count - 1 do
                    lQueue.Enqueue(lQueue.Dequeue);
                lCooldownMs := GThrottleController.CooldownRemainingMs;
                lStatus := 'running';
                if lCooldownMs > 0 then
                begin
                  lStatus := 'throttled';
                  lRetryAfterUtc := DateToISO8601(
                    IncMilliSecond(UtcNow, lCooldownMs), True);
                end
                else
                  lRetryAfterUtc := '';
                WithJobLock(
                  procedure
                  begin
                    UpdateJobState(lJob, lStatus, lStartedUtc, lProcessed,
                      lSkipped, lFailed, lQueue.Count,
                      lDeferredChannelVideos, lChannelSlices, False,
                      lRetryAfterUtc);
                    lJob.Checkpoint;
                  end);
                WriteLn(Format(
                  'Throttle queue rotation at level %d: retained %s; processed=%d skipped=%d failed=%d deferred_queue_entries=%d deferred_channel_videos=%d.',
                  [GThrottleController.ThrottleLevel, lEntry.Url, lProcessed,
                   lSkipped, lFailed, lQueue.Count, lDeferredChannelVideos]));
                Continue;
              end;
              Inc(lFailed);
            end;
          end;
          WithJobLock(
            procedure
            begin
              UpdateJobState(lJob, 'running', lStartedUtc, lProcessed,
                lSkipped, lFailed, lQueue.Count, 0, lChannelSlices, False);
              lJob.Checkpoint;
            end);
        end;
      finally
        lDiscoveryThrottles.Free;
        lChannelCaches.Free;
        lQueue.Free;
      end;
      if lFailed > 0 then lStatus := 'completed_with_errors'
      else lStatus := 'completed';
      WithJobLock(
        procedure
        begin
          UpdateJobState(lJob, lStatus, lStartedUtc, lProcessed, lSkipped,
            lFailed, 0, 0, lChannelSlices, True);
          lJob.Checkpoint;
        end);
      WriteLn(Format(
        'YAML job completed: processed=%d skipped=%d failed=%d deferred_queue_entries=0 deferred_channel_videos=0 channel_slices=%d',
        [lProcessed, lSkipped, lFailed, lChannelSlices]));
      Result := DownloadFileExitCode(lFailed);
    finally
      GThrottleCheckpointCallback := nil;
      FreeAndNil(GSourceThrottlePolicy);
      GCurrentSource := '';
      FreeAndNil(GThrottleController);
    end;
  finally
    lJobLock.Free;
    lJob.Free;
  end;
end;

function Run: Integer;
var
  lConfig: TCommandLineConfig;
  lMeta: TTranscriptMetadata;
  lOutputPath: string;
  lStats: TChannelRunStats;
begin
  Result := 1;
  try
    DeleteStaleCookieProbeJars;
    lConfig := ParseCommandLine;

    if lConfig.ShowHelp then
    begin
      WriteLn(RSUsage);
      Exit(0);
    end;

    if not lConfig.DownloadFileName.IsEmpty then
      Exit(RunDownloadFile(lConfig.DownloadFileName, lConfig.BaseIntervalMs));

    TryAutoUpdateYtDlp;
    if lConfig.URL.IsEmpty then
      raise EArgumentException.Create('YouTube URL is a required argument.');
    ReportLoggedOutAtStart(HasEffectiveCookieSource(lConfig));

    GThrottleController := TThrottleController.Create(
      lConfig.RequestIntervalMs, lConfig.DelayJitterMs,
      lConfig.BaseIntervalMs);
    try
      if lConfig.ChannelMode then
        Result := RunChannelMode(lConfig, lStats)
      else
        Result := RunSingleVideo(lConfig, lMeta, lOutputPath);
    finally
      FreeAndNil(GThrottleController);
    end;
  except
    on E: Exception do
    begin
      WriteLn(Format(RSError, [E.Message]));
      if IsFatalProcessingException(E) then
        raise;
      // Result is already 1
    end;
  end;
end;

function ParseCommandLine: TCommandLineConfig;
var
  lArgs: TArray<string>;
begin
  SetLength(lArgs, System.ParamCount);
  for var lIndex := 1 to System.ParamCount do
    lArgs[lIndex - 1] := System.ParamStr(lIndex);
  Result := ParseCommandLineArgs(lArgs);
end;

function ParseCommandLineArgs(const aArgs: TArray<string>): TCommandLineConfig;

  // Shadow System.ParamCount/ParamStr so the parser reads aArgs.
  function ParamCount: Integer;
  begin
    Result := Length(aArgs);
  end;

  function ParamStr(const aIndex: Integer): string;
  begin
    Result := aArgs[aIndex - 1];
  end;

var
  x: Integer;
  lArg: string;
  lJobs: Integer;
  lCookiesFileProvided: Boolean;
  lCookiesBrowserProvided: Boolean;
begin
  Result := Default(TCommandLineConfig);
  LoadDefaultOptions(Result);
  Result.RequestIntervalMs := CDefaultRequestIntervalMs;
  Result.DelayJitterMs := CDefaultDelayJitterMs;
  Result.BaseIntervalMs := CDefaultBaseIntervalMs;
  Result.SleepRequestsSeconds := CDefaultSleepRequestsSeconds;
  Result.SleepSubtitlesSeconds := CDefaultSleepSubtitlesSeconds;
  Result.SocketTimeoutSeconds := CDefaultSocketTimeoutSeconds;
  lCookiesFileProvided := False;
  lCookiesBrowserProvided := False;

  x := 1;
  while x <= ParamCount do
  begin
    lArg := ParamStr(x);

    if (lArg = '-h') or (lArg = '--help') then
    begin
      Result.ShowHelp := True;
      Exit; // Short-circuit for help
    end
    else if (lArg = '-f') or (lArg = '--file') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      Result.DownloadFileName := ParamStr(x);
    end
    else if (lArg = '-o') or (lArg = '--output') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      Result.OutputTarget := ParamStr(x);
    end
    else if (lArg = '-l') or (lArg = '--lang') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      Result.Language := ParamStr(x).ToLower;
    end
    else if (lArg = '-p') or (lArg = '--prefix') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      Result.Prefix := Trim(ParamStr(x));
    end
    else if (lArg = '-keywords') or (lArg = '--keywords') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      Result.Keywords := NormalizeKeywords(ParamStr(x));
      Result.IncludeMeta := True;
    end
    else if (lArg = '-meta') or (lArg = '--meta') then
    begin
      Result.IncludeMeta := True;
    end
    else if (lArg = '-c') or (lArg = '--channel') then
    begin
      Result.ChannelMode := True;
    end
    else if (lArg = '-j') or (lArg = '--jobs') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      if not TryStrToInt(ParamStr(x), lJobs) then
        raise EArgumentException.CreateFmt('Invalid integer value for option %s: %s', [lArg, ParamStr(x)]);
      if lJobs < 1 then
        raise EArgumentException.CreateFmt('Option %s must be >= 1', [lArg]);
      // Deprecated: validated and ignored. Channels use one worker (T-033).
    end
    else if (lArg = '-ov') or (lArg = '--override') then
    begin
      Result.OverrideExisting := True;
    end
    else if (lArg = '-co') or (lArg = '--channel-output') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      Result.ChannelOutputRoot := ParamStr(x);
    end
    else if (lArg = '-is') or (lArg = '--include-shorts') then
    begin
      Result.IncludeShorts := True;
    end
    else if (lArg = '-il') or (lArg = '--include-live') then
    begin
      Result.IncludeLive := True;
    end
    else if (lArg = '--cookies') or (lArg = '-ck') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      Result.CookiesFile := Trim(ParamStr(x));
      lCookiesFileProvided := True;
    end
    else if (lArg = '--cookies-from-browser') or (lArg = '-cb') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      Result.CookiesFromBrowser := Trim(ParamStr(x));
      lCookiesBrowserProvided := True;
    end
    else if (lArg = '-dj') or (lArg = '--delay-jitter-ms') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      if not TryStrToInt(ParamStr(x), lJobs) then
        raise EArgumentException.CreateFmt('Invalid integer value for option %s: %s', [lArg, ParamStr(x)]);
      if lJobs < 0 then
        raise EArgumentException.CreateFmt('Option %s must be >= 0', [lArg]);
      Result.DelayJitterMs := lJobs;
    end
    else if lArg = '--request-interval-ms' then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      if not TryStrToInt(ParamStr(x), lJobs) then
        raise EArgumentException.CreateFmt('Invalid integer value for option %s: %s', [lArg, ParamStr(x)]);
      if lJobs < 0 then
        raise EArgumentException.CreateFmt('Option %s must be >= 0', [lArg]);
      Result.RequestIntervalMs := lJobs;
    end
    else if lArg = '--base-interval-ms' then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      if not TryStrToInt(ParamStr(x), lJobs) then
        raise EArgumentException.CreateFmt('Invalid integer value for option %s: %s', [lArg, ParamStr(x)]);
      if lJobs < 0 then
        raise EArgumentException.CreateFmt('Option %s must be >= 0', [lArg]);
      Result.BaseIntervalMs := lJobs;
    end
    else if lArg = '--sleep-requests' then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      if not TryStrToInt(ParamStr(x), lJobs) then
        raise EArgumentException.CreateFmt('Invalid integer value for option %s: %s', [lArg, ParamStr(x)]);
      if lJobs < 0 then
        raise EArgumentException.CreateFmt('Option %s must be >= 0', [lArg]);
      Result.SleepRequestsSeconds := lJobs;
    end
    else if lArg = '--sleep-subtitles' then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      if not TryStrToInt(ParamStr(x), lJobs) then
        raise EArgumentException.CreateFmt('Invalid integer value for option %s: %s', [lArg, ParamStr(x)]);
      if lJobs < 0 then
        raise EArgumentException.CreateFmt('Option %s must be >= 0', [lArg]);
      Result.SleepSubtitlesSeconds := lJobs;
    end
    else if lArg = '--socket-timeout' then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      if not TryStrToInt(ParamStr(x), lJobs) then
        raise EArgumentException.CreateFmt('Invalid integer value for option %s: %s', [lArg, ParamStr(x)]);
      if lJobs < 0 then
        raise EArgumentException.CreateFmt('Option %s must be >= 0', [lArg]);
      Result.SocketTimeoutSeconds := lJobs;
    end
    else if (lArg = '-ru') or (lArg = '--retry-unavailable') then
    begin
      Result.RetryUnavailable := True;
    end
    else if StartsText('-', lArg) then
    begin
      raise EArgumentException.CreateFmt('Unknown option: %s', [lArg]);
    end
    else if Result.URL.IsEmpty then
    begin
      Result.URL := lArg;
    end
    else
    begin
      raise EArgumentException.CreateFmt('Unexpected parameter: %s', [lArg]);
    end;
    Inc(x);
  end;

  if Result.Language = '' then
    Result.Language := CDefaultLanguage;
  if (Result.DownloadFileName <> '') and (ParamCount <> 2) then
    raise EArgumentException.Create('--file/-f cannot be combined with a URL or URL-specific options.');
  if lCookiesFileProvided and lCookiesBrowserProvided then
    raise EArgumentException.Create('Use either --cookies or --cookies-from-browser, not both at once.');
  if lCookiesFileProvided then
    Result.CookiesFromBrowser := ''
  else if lCookiesBrowserProvided then
    Result.CookiesFile := '';
  if (Trim(Result.CookiesFile) <> '') and (Trim(Result.CookiesFromBrowser) <> '') then
    raise EArgumentException.Create(
      'Use only one settings default: either [default].cookies_file or [default].cookies_from_browser.'
    );
  Result.CookiesFileExplicit := lCookiesFileProvided;
  Result.CookiesFromBrowserExplicit := lCookiesBrowserProvided;
  if Result.ChannelMode then
    Result.IncludeMeta := True;
end;

class function TTranscriptMetadata.FromJson(const aJson: string): TTranscriptMetadata;
  function JsonValueAsText(const aValue: TJSONValue): string;
  begin
    Result := '';
    if not Assigned(aValue) then
      Exit;
    if aValue is TJSONString then
      Exit(TJSONString(aValue).Value);
    if aValue is TJSONNumber then
      Exit(TJSONNumber(aValue).ToString);
    if aValue is TJSONTrue then
      Exit('true');
    if aValue is TJSONFalse then
      Exit('false');
    Result := aValue.Value;
  end;

  function GetText(const aJsonObject: TJSONObject; const aName: string): string;
  begin
    Result := JsonValueAsText(aJsonObject.Values[aName]);
  end;

  function GetArrayCsv(const aJsonObject: TJSONObject; const aName: string): string;
  var
    lValue: TJSONValue;
    lArray: TJSONArray;
    lPart: string;
  begin
    Result := '';
    lValue := aJsonObject.Values[aName];
    if not (lValue is TJSONArray) then
      Exit;
    lArray := TJSONArray(lValue);
    for var x := 0 to lArray.Count - 1 do
    begin
      lPart := Trim(JsonValueAsText(lArray.Items[x]));
      if lPart.IsEmpty then
        Continue;
      if Result <> '' then
        Result := Result + ', ';
      Result := Result + lPart;
    end;
  end;

  function FormatDurationSeconds(const aValue: string): string;
  var
    lTotalSeconds: Int64;
    lHours: Int64;
    lMinutes: Int64;
    lSeconds: Int64;
  begin
    if not TryStrToInt64(aValue, lTotalSeconds) then
      Exit(aValue);
    if lTotalSeconds < 0 then
      lTotalSeconds := 0;
    lHours := lTotalSeconds div 3600;
    lMinutes := (lTotalSeconds mod 3600) div 60;
    lSeconds := lTotalSeconds mod 60;
    if lHours > 0 then
      Exit(Format('%d:%.2d:%.2d', [lHours, lMinutes, lSeconds]));
    Result := Format('%d:%.2d', [lMinutes, lSeconds]);
  end;

  function FormatUploadDate(const aValue: string): string;
  begin
    if Length(aValue) >= 8 then
      Result := Format('%.4s-%.2s-%.2s', [Copy(aValue, 1, 4), Copy(aValue, 5, 2), Copy(aValue, 7, 2)])
    else
      Result := aValue;
  end;

  function FormatEpochDate(const aValue: string): string;
  var
    lEpoch: Int64;
  begin
    if TryStrToInt64(aValue, lEpoch) then
      Result := FormatDateTime('yyyy-mm-dd', UnixToDateTime(lEpoch))
    else
      Result := aValue;
  end;

  function FormatEpochDateTime(const aValue: string): string;
  var
    lEpoch: Int64;
  begin
    if TryStrToInt64(aValue, lEpoch) then
      Result := DateToISO8601(UnixToDateTime(lEpoch), True)
    else
      Result := aValue;
  end;
var
  lJsonValue: TJSONValue;
  lJson     : TJSONObject;
  lTemp     : string;
begin
  Result := Default(TTranscriptMetadata);
  if aJson.IsEmpty then
    Exit;

  lJsonValue := TJSONObject.ParseJSONValue(aJson, False, True);
  if not Assigned(lJsonValue) then
    Exit;
  if not (lJsonValue is TJSONObject) then
  begin
    lJsonValue.Free;
    Exit;
  end;

  lJson := lJsonValue as TJSONObject;
  if not Assigned(lJson) then
  begin
    lJsonValue.Free;
    Exit;
  end;

  try
    if lJson.TryGetValue<string>('webpage_url', lTemp) then
      Result.Url := lTemp
    else if lJson.TryGetValue<string>('url', lTemp) then
      Result.Url := lTemp;

    Result.Title := GetText(lJson, 'title');
    Result.VideoId := GetText(lJson, 'id');
    Result.Uploader := GetText(lJson, 'uploader');
    Result.UploaderId := GetText(lJson, 'uploader_id');
    Result.ChannelId := GetText(lJson, 'channel_id');
    Result.ChannelUrl := GetText(lJson, 'channel_url');
    Result.UploaderUrl := GetText(lJson, 'uploader_url');
    Result.Duration := FormatDurationSeconds(GetText(lJson, 'duration'));
    Result.ViewCount := GetText(lJson, 'view_count');
    Result.LikeCount := GetText(lJson, 'like_count');
    Result.CommentCount := GetText(lJson, 'comment_count');
    Result.Tags := GetArrayCsv(lJson, 'tags');
    Result.Description := GetText(lJson, 'description');

    if not lJson.TryGetValue<string>('channel', lTemp) then
      lTemp := Result.Uploader;
    Result.Channel := lTemp;

    if lJson.TryGetValue<string>('upload_date', lTemp) then
      Result.Created := FormatUploadDate(lTemp)
    else if lJson.TryGetValue<string>('release_timestamp', lTemp) then
      Result.Created := FormatEpochDate(lTemp)
    else if lJson.TryGetValue<string>('timestamp', lTemp) then
      Result.Created := FormatEpochDate(lTemp);

    if lJson.TryGetValue<string>('release_timestamp', lTemp) then
      Result.PublishedAt := FormatEpochDateTime(lTemp)
    else if lJson.TryGetValue<string>('timestamp', lTemp) then
      Result.PublishedAt := FormatEpochDateTime(lTemp)
    else if lJson.TryGetValue<string>('upload_date', lTemp) then
      Result.PublishedAt := FormatUploadDate(lTemp);
  finally
    lJson.Free;
  end;
end;

function TTranscriptMetadata.HasData: Boolean;
begin
  Result := (Url <> '') or (Title <> '') or (Channel <> '') or (Created <> '') or
    (VideoId <> '') or (Uploader <> '') or (UploaderId <> '') or (ChannelId <> '') or
    (ChannelUrl <> '') or (UploaderUrl <> '') or
    (Duration <> '') or (ViewCount <> '') or (LikeCount <> '') or (CommentCount <> '') or
    (Tags <> '') or (Description <> '') or (PublishedAt <> '');
end;

{ TTranscriptService }

constructor TTranscriptService.Create(
  const aThrottleRetryMode: TThrottleRetryMode; const aRunner: TYtDlpRunner);
begin
  inherited Create;
  FThrottleRetryMode := aThrottleRetryMode;
  FRunner := aRunner;
end;

function TTranscriptService.RunYtDlp(const aArguments: string;
  out aOutput, aError: string): Integer;
begin
  if Assigned(FRunner) then
    Exit(FRunner(aArguments, aOutput, aError));
  Result := RunConsoleProcess(GetYtDlpPath, aArguments, aOutput, aError);
end;

function YtDlpCall(const aOperation, aTarget, aArguments: string;
  const aCountsAsVideoRequest: Boolean;
  const aRequestClass: TThrottleRequestClass = trcExtraction): TYtDlpCall;
begin
  Result := Default(TYtDlpCall);
  Result.Operation := aOperation;
  Result.Target := aTarget;
  Result.Arguments := aArguments;
  Result.CountsAsVideoRequest := aCountsAsVideoRequest;
  Result.CompletesRequest := True;
  Result.RequestClass := aRequestClass;
end;

function TTranscriptService.CaptureYtDlpOutput(const aCall: TYtDlpCall;
  out aOutput, aError: string): Integer;
var
  lCombined: string;
  lDiagnostics: string;
  lMessage: string;
  lCooldownMs: Cardinal;
  lThrottleLevel: Integer;
  lRetryAtUtc: string;
  lStartedUtc: string;
  lGateTimer, lExecutionTimer: TStopwatch;
  lResponseKind: TThrottleResponseKind;
  lLogMessage: string;
  lTargetThrottleAttempts: Integer;
  lPacingWaitMs, lGlobalCooldownWaitMs: Int64;
  lIsRetry: Boolean;
  lReadyInMs: Cardinal;
begin
  lIsRetry := False;
  while True do
  begin
    // A cooldown or pending subtitle gap can outlast a signed subtitle URL,
    // also on the first attempt (a saved URL of a requeued YAML target).
    // Decide before entering the gate, so a doomed URL takes no pacing slot
    // and no wait; the caller then re-extracts. A first attempt with a URL
    // that is not reusable even now (no expire=, or just extracted as such)
    // still runs: re-extracting would only return the same kind of URL.
    if Assigned(aCall.CanRetryAt) and
       (lIsRetry or aCall.CanRetryAt(UtcNow)) then
    begin
      lReadyInMs := 0;
      if Assigned(GThrottleController) then
      begin
        lReadyInMs := GThrottleController.CooldownRemainingMs;
        if GThrottleController.RequestWaitRemainingMs(aCall.RequestClass) >
           lReadyInMs then
          lReadyInMs := GThrottleController.RequestWaitRemainingMs(
            aCall.RequestClass);
      end;
      if not aCall.CanRetryAt(IncMilliSecond(UtcNow, lReadyInMs)) then
        raise ESubtitleUrlExpired.Create(
          'Signed subtitle URL expires before the request can start.');
    end;
    lIsRetry := True;
    lStartedUtc := UtcNowIso;
    lGateTimer := TStopwatch.StartNew;
    lPacingWaitMs := 0;
    lGlobalCooldownWaitMs := 0;
    if Assigned(GThrottleController) then
      GThrottleController.BeforeRequest(lPacingWaitMs, lGlobalCooldownWaitMs,
        aCall.RequestClass);
    lGateTimer.Stop;
    lExecutionTimer := TStopwatch.StartNew;
    Result := RunYtDlp(aCall.Arguments, aOutput, aError);
    lExecutionTimer.Stop;

    lCombined := aOutput + sLineBreak + aError;
    lResponseKind := ReportYtDlpResponse(GThrottleController,
      GSourceThrottlePolicy, GCurrentSource, GCurrentSourceIsChannel, Result,
      aError, aCall.Operation, aCall.Target, aCall.CountsAsVideoRequest,
      FThrottleRetryMode = trmReturnToQueue, aCall.RequestClass, lDiagnostics,
      aCall.CompletesRequest, aCall.RaiseOnThrottle);
    if (Result <> 0) or (lResponseKind <> trkNone) then
      lLogMessage := lCombined
    else
      lLogMessage := '';
    AppendInvocationLog(lStartedUtc, aCall.Operation, aCall.Target,
      lGateTimer.ElapsedMilliseconds, lExecutionTimer.ElapsedMilliseconds,
      Result, lResponseKind, lLogMessage, lPacingWaitMs, lGlobalCooldownWaitMs,
      aCall.TrackKind);
    // `--cookies` also matches --cookies-from-browser.
    if (lResponseKind in [trkRateLimit, trkBotChallenge]) and
       not ContainsText(aCall.Arguments, '--cookies') then
      ReportLoggedOutThrottle;
    if not IsThrottleError(lDiagnostics) then
      Exit;
    if Assigned(GThrottleCheckpointCallback) then
      GThrottleCheckpointCallback;

    lMessage := NormalizeErrorMessage(lDiagnostics);
    if lMessage = '' then
      lMessage := 'YouTube returned a throttling response.';
    if aCall.RaiseOnThrottle and (lResponseKind = trkRateLimit) then
      raise ETranslationRateLimited.Create(lMessage);
    if not Assigned(GThrottleController) then
      raise EThrottleError.Create(lMessage);
    lThrottleLevel := GThrottleController.ThrottleLevel;
    lCooldownMs := GThrottleController.CooldownRemainingMs;
    lTargetThrottleAttempts := GThrottleController.RateLimitAttemptsForTarget(
      aCall.Target);
    lRetryAtUtc := DateToISO8601(
      TTimeZone.Local.ToUniversalTime(IncMilliSecond(Now, lCooldownMs)), True);
    if FThrottleRetryMode = trmReturnToQueue then
    begin
      if lTargetThrottleAttempts >= 2 then
        WriteLn(Format(
          'Warning: target throttle attempt %d/2 for %s; no further global escalation or retry in this run.',
          [lTargetThrottleAttempts, aCall.Target]))
      else
        WriteLn(Format(
          'Warning: YouTube throttling level %d; returning %s to the YAML queue. Shared cooldown: %d seconds, next request no earlier than %s.',
          [lThrottleLevel, aCall.Target, (lCooldownMs + 999) div 1000,
           lRetryAtUtc]));
      raise EThrottleError.Create(lMessage);
    end;
    if GThrottleController.IsParked then
      WriteLn(Format(
        'Warning: YouTube throttling level 9; parked for %d seconds until %s, then resuming at level 0.',
        [(lCooldownMs + 999) div 1000, lRetryAtUtc]
      ))
    else
      WriteLn(Format(
        'Warning: YouTube throttling level %d; cooldown %d seconds, retry at %s.',
        [lThrottleLevel, (lCooldownMs + 999) div 1000, lRetryAtUtc]
      ));
  end;
end;

function TTranscriptService.ExtractJsonFromOutput(const aOutput: string): string;
var
  lStartPos: Integer;
  lEndPos: Integer;
begin
  Result := Trim(aOutput);
  if Result = '' then
    Exit;

  lStartPos := Pos('{', Result);
  lEndPos := LastDelimiter('}', Result);
  if (lStartPos > 0) and (lEndPos > 0) and (lEndPos >= lStartPos) then
    Result := Copy(Result, lStartPos, lEndPos - lStartPos + 1);
end;

function TTranscriptService.FetchMetadata(const aUrl, aYtDlpExtraArgs: string): TTranscriptMetadata;
var
  lOutput: string;
  lError: string;
  lExitCode: Integer;
  lJson: string;
  lCommandArgs: string;
begin
  Result := Default(TTranscriptMetadata);
  lCommandArgs := '--dump-single-json --quiet --no-warnings --skip-download --ignore-no-formats-error ' +
    '--extractor-args "youtube:skip=hls,dash" ';
  if ExtractVideoIdFromUrl(aUrl) <> '' then
    lCommandArgs := lCommandArgs + '--no-playlist '
  else
    lCommandArgs := lCommandArgs + '--playlist-items 0 ';
  if Trim(aYtDlpExtraArgs) <> '' then
    lCommandArgs := lCommandArgs + Trim(aYtDlpExtraArgs) + ' ';
  lCommandArgs := lCommandArgs + Format('"%s"', [aUrl]);
  lExitCode := CaptureYtDlpOutput(
    YtDlpCall('metadata', aUrl, lCommandArgs, False), lOutput, lError);
  if lExitCode <> 0 then
    raise Exception.CreateFmt('yt-dlp metadata fetch failed (exit %d): %s',
      [lExitCode, Trim(lError)]);

  lJson := ExtractJsonFromOutput(lOutput);
  if lJson = '' then
    raise Exception.Create('yt-dlp metadata fetch returned no JSON output.');

  Result := TTranscriptMetadata.FromJson(lJson);
  if Result.VideoId = '' then
    Result.VideoId := ExtractVideoIdFromUrl(aUrl);
  if Result.Url = '' then
    Result.Url := NormalizeVideoUrl(aUrl);
  if Result.Channel = '' then
    Result.Channel := Result.Uploader;
end;

function TTranscriptService.ListChannelVideos(const aListUrl,
  aYtDlpExtraArgs: string): TArray<TChannelVideo>;
  function JsonValueAsText(const aValue: TJSONValue): string;
  begin
    Result := '';
    if not Assigned(aValue) then
      Exit;
    if aValue is TJSONString then
      Exit(TJSONString(aValue).Value);
    if aValue is TJSONNumber then
      Exit(TJSONNumber(aValue).ToString);
    if aValue is TJSONTrue then
      Exit('true');
    if aValue is TJSONFalse then
      Exit('false');
    Result := aValue.Value;
  end;
  function PublishedUnix(const aItem: TJSONObject;
    out aPublishedAt: string): Int64;
  var
    lText: string;
    lYearValue, lMonthValue, lDayValue: Integer;
    lDate: TDateTime;
  begin
    Result := 0;
    aPublishedAt := '';
    lText := JsonValueAsText(aItem.Values['release_timestamp']);
    if lText = '' then
      lText := JsonValueAsText(aItem.Values['timestamp']);
    if (lText <> '') and TryStrToInt64(lText, Result) then
    begin
      aPublishedAt := DateToISO8601(UnixToDateTime(Result, True), True);
      Exit;
    end;

    lText := JsonValueAsText(aItem.Values['upload_date']);
    if Length(lText) <> 8 then
      Exit(0);
    if not TryStrToInt(Copy(lText, 1, 4), lYearValue) or
       not TryStrToInt(Copy(lText, 5, 2), lMonthValue) or
       not TryStrToInt(Copy(lText, 7, 2), lDayValue) or
       not TryEncodeDate(lYearValue, lMonthValue, lDayValue, lDate) then
      Exit(0);
    Result := DateTimeToUnix(lDate, True);
    aPublishedAt := FormatDateTime('yyyy-mm-dd', lDate);
  end;
var
  lOutput: string;
  lError: string;
  lExitCode: Integer;
  lJson: string;
  lCommandArgs: string;
  lJsonValue: TJSONValue;
  lJsonObj: TJSONObject;
  lEntriesValue: TJSONValue;
  lEntries: TJSONArray;
  lItemObj: TJSONObject;
  lVideoUrl: string;
  lVideoId: string;
  lList: TList<TChannelVideo>;
  lVideo: TChannelVideo;
begin
  lCommandArgs := '--flat-playlist --dump-single-json --quiet --no-warnings --skip-download --ignore-no-formats-error ';
  if Trim(aYtDlpExtraArgs) <> '' then
    lCommandArgs := lCommandArgs + Trim(aYtDlpExtraArgs) + ' ';
  lCommandArgs := lCommandArgs + Format('"%s"', [aListUrl]);
  lExitCode := CaptureYtDlpOutput(
    YtDlpCall('channel_listing', aListUrl, lCommandArgs, False),
    lOutput, lError);
  if lExitCode <> 0 then
    raise Exception.CreateFmt('yt-dlp listing failed for %s (exit %d): %s',
      [aListUrl, lExitCode, Trim(lError)]);

  lJson := ExtractJsonFromOutput(lOutput);
  if lJson = '' then
    raise Exception.CreateFmt('yt-dlp listing for %s returned no JSON output.', [aListUrl]);

  lJsonValue := TJSONObject.ParseJSONValue(lJson, False, True);
  if not Assigned(lJsonValue) then
    raise Exception.CreateFmt('yt-dlp listing for %s returned invalid JSON.', [aListUrl]);
  if not (lJsonValue is TJSONObject) then
  begin
    lJsonValue.Free;
    raise Exception.CreateFmt('yt-dlp listing for %s returned unexpected JSON shape.', [aListUrl]);
  end;

  lList := TList<TChannelVideo>.Create;
  lJsonObj := lJsonValue as TJSONObject;
  try
    lEntriesValue := lJsonObj.Values['entries'];
    if not (lEntriesValue is TJSONArray) then
      raise Exception.CreateFmt(
        'yt-dlp listing for %s returned no entries array.', [aListUrl]);

    lEntries := TJSONArray(lEntriesValue);
    for var lIndex := 0 to lEntries.Count - 1 do
    begin
      if not (lEntries.Items[lIndex] is TJSONObject) then
        Continue;
      lItemObj := TJSONObject(lEntries.Items[lIndex]);

      lVideoUrl := JsonValueAsText(lItemObj.Values['url']);
      if lVideoUrl = '' then
        lVideoUrl := JsonValueAsText(lItemObj.Values['webpage_url']);
      lVideoId := JsonValueAsText(lItemObj.Values['id']);
      if (lVideoUrl = '') and (lVideoId <> '') then
        lVideoUrl := 'https://www.youtube.com/watch?v=' + lVideoId;
      if lVideoUrl <> '' then
      begin
        lVideo := Default(TChannelVideo);
        lVideo.Url := NormalizeVideoUrl(lVideoUrl);
        lVideo.PublishedUnix := PublishedUnix(lItemObj, lVideo.PublishedAt);
        lVideo.OriginalOrder := lIndex;
        lList.Add(lVideo);
      end;
    end;
    Result := lList.ToArray;
  finally
    lList.Free;
    lJsonObj.Free;
  end;
end;

function TSubtitleTrack.Found: Boolean;
begin
  Result := Url <> '';
end;

function TSubtitleTrack.IsReusable(const aNowUtc: TDateTime): Boolean;
const
  CExpirySafetyMarginMinutes = 10;
begin
  Result := Found and (ExpiresUtc > 0) and
    (aNowUtc < IncMinute(ExpiresUtc, -CExpirySafetyMarginMinutes));
end;

function SubtitleUrlExpiresUtc(const aUrl: string): TDateTime;
var
  lMatch: TMatch;
  lUnix: Int64;
begin
  Result := 0;
  lMatch := TRegEx.Match(aUrl, '[?&]expire=(\d+)');
  if lMatch.Success and TryStrToInt64(lMatch.Groups[1].Value, lUnix) then
    Result := UnixToDateTime(lUnix, True);
end;

function ParseInfoJsonObject(const aInfoJson: string): TJSONObject;
var
  lValue: TJSONValue;
begin
  lValue := TJSONObject.ParseJSONValue(aInfoJson, False, True);
  if not (lValue is TJSONObject) then
  begin
    lValue.Free;
    raise Exception.Create('yt-dlp info.json is not a JSON object.');
  end;
  Result := TJSONObject(lValue);
end;

function SelectSubtitleTrack(const aInfoJson: string;
  const aOriginalLanguages, aTranslationLanguages: array of string): TSubtitleTrack;
var
  lRoot: TJSONObject;
  lTrack: TSubtitleTrack;

  // The srt entry of info.json[aSection][aKey] (key compared ignoring case).
  function FindSrt(const aSection, aKey: string; out aActualKey: string): string;
  var
    lSection: TJSONValue;
    lPair: TJSONPair;
    lItem: TJSONValue;
  begin
    Result := '';
    aActualKey := '';
    lSection := lRoot.Values[aSection];
    if not (lSection is TJSONObject) then
      Exit;
    for lPair in TJSONObject(lSection) do
    begin
      if not SameText(lPair.JsonString.Value, aKey) or
         not (lPair.JsonValue is TJSONArray) then
        Continue;
      for lItem in TJSONArray(lPair.JsonValue) do
        if (lItem is TJSONObject) and
           SameText(JsonText(TJSONObject(lItem), 'ext'), 'srt') and
           (JsonText(TJSONObject(lItem), 'url') <> '') then
        begin
          aActualKey := lPair.JsonString.Value;
          Exit(JsonText(TJSONObject(lItem), 'url'));
        end;
    end;
  end;

  // Automatic captions for aLanguage live under `<lang>` and `<lang>-orig`.
  // A URL with `tlang` is a machine translation of another language's ASR.
  function FindAuto(const aLanguage: string; const aTranslated: Boolean;
    out aActualKey: string): string;
  var
    lKey: string;
    lKeys: TArray<string>;
  begin
    lKeys := [aLanguage, aLanguage + '-orig'];
    for lKey in lKeys do
    begin
      Result := FindSrt('automatic_captions', lKey, aActualKey);
      if (Result <> '') and
         (TRegEx.IsMatch(Result, '[?&]tlang=') = aTranslated) then
        Exit;
    end;
    Result := '';
    aActualKey := '';
  end;

  function Pick(const aUrl, aKey: string;
    const aKind: TSubtitleTrackKind): Boolean;
  begin
    Result := aUrl <> '';
    if not Result then
      Exit;
    lTrack.Language := aKey;
    lTrack.Kind := aKind;
    lTrack.Url := aUrl;
    lTrack.ExpiresUtc := SubtitleUrlExpiresUtc(aUrl);
  end;

  // Manual subtitles, then automatic captions that are not translations.
  function PickOriginal(const aLanguage: string): Boolean;
  var
    lKey: string;
  begin
    Result := Pick(FindSrt('subtitles', aLanguage, lKey), lKey, stkManual) or
      Pick(FindAuto(aLanguage, False, lKey), lKey, stkAuto);
  end;

  // The video's own language: info.json `language`, else the ASR source
  // that YouTube marks as `<lang>-orig`.
  function PickVideoLanguage: Boolean;
  var
    lSection: TJSONValue;
    lPair: TJSONPair;
    lName: string;
  begin
    lName := Trim(JsonText(lRoot, 'language'));
    if (lName <> '') and PickOriginal(lName) then
      Exit(True);
    lSection := lRoot.Values['automatic_captions'];
    if lSection is TJSONObject then
      for lPair in TJSONObject(lSection) do
      begin
        lName := lPair.JsonString.Value;
        if EndsText('-orig', lName) and
           PickOriginal(Copy(lName, 1, Length(lName) - Length('-orig'))) then
          Exit(True);
      end;
    Result := False;
  end;

var
  lLanguage, lKey: string;
begin
  // Original tracks in every preferred language first, then machine
  // translations (the most 429-prone guess) in the same order, then the
  // video's own language.
  lTrack := Default(TSubtitleTrack);
  lRoot := ParseInfoJsonObject(aInfoJson);
  try
    for lLanguage in aOriginalLanguages do
      if (Trim(lLanguage) <> '') and PickOriginal(Trim(lLanguage)) then
        Exit(lTrack);
    for lLanguage in aTranslationLanguages do
      if (Trim(lLanguage) <> '') and
         Pick(FindAuto(Trim(lLanguage), True, lKey), lKey, stkAutoTranslated) then
        Exit(lTrack);
    PickVideoLanguage;
  finally
    lRoot.Free;
  end;
  Result := lTrack;
end;

function SelectSubtitleTrack(const aInfoJson: string;
  const aLanguages: array of string): TSubtitleTrack;
begin
  Result := SelectSubtitleTrack(aInfoJson, aLanguages, aLanguages);
end;

function BuildSubtitleInfoJson(const aInfoJson: string;
  const aTrack: TSubtitleTrack): string;
const
  CDroppedKeys: array[0..4] of string = ('webpage_url', 'original_url',
    'formats', 'requested_formats', 'subtitles');
var
  lRoot, lChosen, lEmpty, lTrackObj: TJSONObject;
  lSection, lTracks, lItem: TJSONValue;
  lKey: string;
begin
  lRoot := ParseInfoJsonObject(aInfoJson);
  try
    // Keep the original entry: it carries yt-dlp's per-track options such
    // as `impersonate`.
    lTrackObj := nil;
    if aTrack.Kind = stkManual then
      lSection := lRoot.Values['subtitles']
    else
      lSection := lRoot.Values['automatic_captions'];
    if lSection is TJSONObject then
    begin
      lTracks := TJSONObject(lSection).Values[aTrack.Language];
      if lTracks is TJSONArray then
        for lItem in TJSONArray(lTracks) do
          if (lItem is TJSONObject) and
             (JsonText(TJSONObject(lItem), 'url') = aTrack.Url) then
          begin
            lTrackObj := TJSONObject(lItem.Clone);
            Break;
          end;
    end;
    if not Assigned(lTrackObj) then
      raise Exception.Create('The chosen subtitle track is missing from info.json.');
    for lKey in CDroppedKeys do
      lRoot.RemovePair(lKey).Free;
    lRoot.RemovePair('automatic_captions').Free;
    lChosen := TJSONObject.Create;
    lChosen.AddPair(aTrack.Language, TJSONArray.Create(lTrackObj));
    lEmpty := TJSONObject.Create;
    if aTrack.Kind = stkManual then
    begin
      lRoot.AddPair('subtitles', lChosen);
      lRoot.AddPair('automatic_captions', lEmpty);
    end
    else
    begin
      lRoot.AddPair('subtitles', lEmpty);
      lRoot.AddPair('automatic_captions', lChosen);
    end;
    Result := lRoot.ToJSON;
  finally
    lRoot.Free;
  end;
end;

function SubtitleTrackKindToString(const aKind: TSubtitleTrackKind): string;
begin
  case aKind of
    stkManual: Result := 'manual';
    stkAuto: Result := 'auto';
    stkAutoTranslated: Result := 'auto_translated';
  else
    Result := '';
  end;
end;

procedure SetThrottleContext(const aController: TThrottleController;
  const aPolicy: TSourceThrottlePolicy; const aSource: string;
  const aSourceIsChannel: Boolean);
begin
  GThrottleController := aController;
  GSourceThrottlePolicy := aPolicy;
  GCurrentSource := aSource;
  GCurrentSourceIsChannel := aSourceIsChannel;
end;

function SavedSubtitleSourceCount: Integer;
begin
  GSubtitleSourcesLock.Enter;
  try
    Result := GSubtitleSources.Count;
  finally
    GSubtitleSourcesLock.Leave;
  end;
end;

function SubtitleSourceKey(const aUrl: string;
  const aLanguages: TArray<string>): string;
begin
  Result := LowerCase(Trim(aUrl)) + '|' +
    LowerCase(string.Join(',', aLanguages));
end;

// Returns a saved source only while its signed URL is still reusable.
function TakeSubtitleSource(const aKey: string; const aNowUtc: TDateTime;
  out aSource: TSubtitleSource): Boolean;
begin
  GSubtitleSourcesLock.Enter;
  try
    Result := GSubtitleSources.TryGetValue(aKey, aSource);
    if Result and not aSource.Track.IsReusable(aNowUtc) then
    begin
      GSubtitleSources.Remove(aKey);
      Result := False;
    end;
  finally
    GSubtitleSourcesLock.Leave;
  end;
end;

// Saves a source for a later retry. Expired entries are purged here, so the
// map holds only URLs that can still be reused.
procedure StoreSubtitleSource(const aKey: string;
  const aSource: TSubtitleSource; const aNowUtc: TDateTime);
var
  lStale: TList<string>;
  lPair: TPair<string, TSubtitleSource>;
  lStaleKey: string;
begin
  GSubtitleSourcesLock.Enter;
  lStale := TList<string>.Create;
  try
    for lPair in GSubtitleSources do
      if not lPair.Value.Track.IsReusable(aNowUtc) then
        lStale.Add(lPair.Key);
    for lStaleKey in lStale do
      GSubtitleSources.Remove(lStaleKey);
    if aSource.Track.IsReusable(aNowUtc) then
      GSubtitleSources.AddOrSetValue(aKey, aSource)
    else
      GSubtitleSources.Remove(aKey);
  finally
    lStale.Free;
    GSubtitleSourcesLock.Leave;
  end;
end;

procedure ForgetSubtitleSource(const aKey: string);
begin
  GSubtitleSourcesLock.Enter;
  try
    GSubtitleSources.Remove(aKey);
  finally
    GSubtitleSourcesLock.Leave;
  end;
end;

// Removes "<option> <value>" from a yt-dlp argument string.
function WithoutYtDlpOption(const aArguments, aOption: string): string;
begin
  Result := Trim(TRegEx.Replace(aArguments,
    '(^|\s)' + TRegEx.Escape(aOption) + '\s+\S+', ''));
end;

// 403/410 mean the signed URL itself is no longer accepted; a fresh
// extraction issues a new one.
function IsSubtitleUrlRejected(const aDiagnostics: string): Boolean;
begin
  Result := ContainsText(aDiagnostics, 'HTTP Error 403') or
    ContainsText(aDiagnostics, 'HTTP Error 410');
end;

function ReadTextFileUtf8OrAnsi(const aFileName: string): string;
begin
  try
    Result := TFile.ReadAllText(aFileName, TEncoding.UTF8);
  except
    Result := TFile.ReadAllText(aFileName, TEncoding.Default); // non-UTF-8 fallback
  end;
end;

function TTranscriptService.FetchTranscript(const aUrl, aLanguage,
  aYtDlpExtraArgs: string; const aFallbackLanguage: string): TTranscriptResult;
const
  CMissingSubtitleMessage =
    'yt-dlp did not produce an SRT subtitle file. The requested language might not be available or may have a different code.';
  // Original tracks in these languages are kept as they are; any other
  // language is fetched as a machine translation first.
  CPreferredOriginalLanguages: array[0..1] of string = ('de', 'pl');
var
  lLanguages, lOriginalLanguages: TArray<string>;
  lKey, lExtraArgs: string;
  lSource: TSubtitleSource;
  lReextracted: Boolean;
  lExpiryReextracts: Integer;
  lTempDir, lInfoFile: string;
  lCall: TYtDlpCall;
  lFiles: TArray<string>;
  lExitCode: Integer;
  lOutput, lError: string;
  lPreferOriginal: Boolean; // set once a translation failed in this fetch

  function FailureText(const aOutput, aError: string): string;
  begin
    Result := Trim(aError);
    if Result = '' then
      Result := Trim(aOutput);
  end;

  // Step 1: extraction only, paced by the short base gap. Its success is a
  // partial step: only the subtitle download completes the video request.
  function Extract: TSubtitleSource;
  var
    lDir, lArgs, lOut, lErr, lInfoJson: string;
    lMetaFiles: TArray<string>;
    lCode: Integer;
    lExtractCall: TYtDlpCall;
  begin
    Result := Default(TSubtitleSource);
    lDir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
    TDirectory.CreateDirectory(lDir);
    try
      lArgs := '--skip-download --ignore-no-formats-error --write-info-json ' +
        '--extractor-args "youtube:skip=hls,dash" ';
      if lExtraArgs <> '' then
        lArgs := lArgs + lExtraArgs + ' ';
      lArgs := lArgs + Format('-P "%s" -o "%s" "%s"', [lDir, 'transcript', aUrl]);
      lExtractCall := YtDlpCall('transcript', aUrl, lArgs, True, trcExtraction);
      lExtractCall.CompletesRequest := False;
      lCode := CaptureYtDlpOutput(lExtractCall, lOut, lErr);
      if lCode <> 0 then
        raise Exception.CreateFmt('yt-dlp transcript fetch failed (exit %d): %s',
          [lCode, FailureText(lOut, lErr)]);

      lMetaFiles := TDirectory.GetFiles(lDir, '*.info.json');
      if Length(lMetaFiles) = 0 then
        raise Exception.Create('yt-dlp extraction did not write info.json.');
      lInfoJson := ReadTextFileUtf8OrAnsi(lMetaFiles[0]);
      Result.Meta := TTranscriptMetadata.FromJson(lInfoJson);
      if Result.Meta.VideoId = '' then
        Result.Meta.VideoId := ExtractVideoIdFromUrl(aUrl);
      if Result.Meta.Url = '' then
        Result.Meta.Url := NormalizeVideoUrl(aUrl);

      Result.Track := SelectSubtitleTrack(lInfoJson, lOriginalLanguages,
        lLanguages);
      if not Result.Track.Found then
      begin
        // Captionless: the extraction was the whole video request.
        CompleteVideoRequest(aUrl, FThrottleRetryMode = trmReturnToQueue);
        raise EMissingTranscriptError.Create(CMissingSubtitleMessage,
          Result.Meta);
      end;
      Result.InfoJson := BuildSubtitleInfoJson(lInfoJson, Result.Track);
      if Result.Track.Kind = stkAutoTranslated then
      begin
        Result.Fallback := SelectSubtitleTrack(lInfoJson, [], []);
        if Result.Fallback.Found then
          Result.FallbackInfoJson := BuildSubtitleInfoJson(lInfoJson,
            Result.Fallback);
        // A re-extraction after a failed translation keeps the original.
        if lPreferOriginal and Result.Fallback.Found then
        begin
          Result.Track := Result.Fallback;
          Result.InfoJson := Result.FallbackInfoJson;
          Result.Fallback := Default(TSubtitleTrack);
          Result.FallbackInfoJson := '';
        end;
      end;
    finally
      TDirectory.Delete(lDir, True);
    end;
  end;

  // A machine translation that cannot be downloaded (HTTP 429 or another
  // error) gives way to the original track of the same extraction; the
  // original text can be translated later.
  function SwitchToOriginal: Boolean;
  begin
    Result := (lSource.Track.Kind = stkAutoTranslated) and
      lSource.Fallback.Found;
    if not Result then
      Exit;
    WriteLn(Format('Notice: the %s translation of %s could not be downloaded; ' +
      'saving the original %s track instead.',
      [lSource.Track.Language, aUrl, lSource.Fallback.Language]));
    lPreferOriginal := True;
    lSource.Track := lSource.Fallback;
    lSource.InfoJson := lSource.FallbackInfoJson;
    lSource.Fallback := Default(TSubtitleTrack);
    lSource.FallbackInfoJson := '';
  end;

begin
  Result := Default(TTranscriptResult);
  lPreferOriginal := False;
  if (not Assigned(FRunner)) and (not TFile.Exists(GetYtDlpPath)) then
    raise EFileNotFoundException.CreateFmt('Required executable not found: %s',
      [GetYtDlpPath]);

  // The fallback (English) is preferred over the requested language: an
  // original English track beats an original track in the requested one.
  lLanguages := [Trim(aLanguage)];
  if (Trim(aFallbackLanguage) <> '') and
     not SameText(Trim(aFallbackLanguage), Trim(aLanguage)) then
    lLanguages := [Trim(aFallbackLanguage)] + lLanguages;
  lOriginalLanguages := Copy(lLanguages);
  for var lPreferred in CPreferredOriginalLanguages do
    if IndexText(lPreferred, lOriginalLanguages) < 0 then
      lOriginalLanguages := lOriginalLanguages + [lPreferred];
  // yttrans paces subtitle requests itself; yt-dlp's subtitle sleep would
  // stack another delay on top.
  lExtraArgs := WithoutYtDlpOption(aYtDlpExtraArgs, '--sleep-subtitles');
  lKey := SubtitleSourceKey(aUrl, lLanguages);
  if not TakeSubtitleSource(lKey, UtcNow, lSource) then
    lSource := Extract;

  // Step 2: download only the chosen signed timedtext URL. yt-dlp keeps its
  // cookie, header and impersonation handling; the reduced info.json has no
  // webpage_url, so a failure cannot turn into a second extraction, and
  // --abort-on-error makes yt-dlp print the HTTP error it would otherwise hide.
  lReextracted := False;
  lExpiryReextracts := 0;
  lTempDir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(lTempDir);
  try
    try
      lInfoFile := TPath.Combine(lTempDir, 'subtitle.info.json');
      while True do
      begin
        StoreSubtitleSource(lKey, lSource, UtcNow);
        TFile.WriteAllBytes(lInfoFile, TEncoding.UTF8.GetBytes(lSource.InfoJson));
        lCall := YtDlpCall('subtitle', aUrl, Format(
          '--load-info-json "%s" --abort-on-error ' +
          '--skip-download --write-sub --write-auto-sub --sub-format srt ' +
          '--sub-lang "%s" --ignore-no-formats-error ',
          [lInfoFile, lSource.Track.Language]), True, trcSubtitle);
        if lExtraArgs <> '' then
          lCall.Arguments := lCall.Arguments + lExtraArgs + ' ';
        lCall.Arguments := lCall.Arguments +
          Format('-P "%s" -o "%s"', [lTempDir, 'transcript']);
        lCall.TrackKind := SubtitleTrackKindToString(lSource.Track.Kind);
        lCall.RaiseOnThrottle := (lSource.Track.Kind = stkAutoTranslated) and
          lSource.Fallback.Found;
        // Bounded, so URLs that never outlive the wait cannot loop forever.
        if lExpiryReextracts < 2 then
          lCall.CanRetryAt :=
            function(aStartUtc: TDateTime): Boolean
            begin
              Result := lSource.Track.IsReusable(aStartUtc);
            end;
        try
          lExitCode := CaptureYtDlpOutput(lCall, lOutput, lError);
        except
          on ESubtitleUrlExpired do
          begin
            Inc(lExpiryReextracts);
            ForgetSubtitleSource(lKey);
            lSource := Extract;
            Continue;
          end;
          on ETranslationRateLimited do
          begin
            if SwitchToOriginal then
              Continue;
            raise;
          end;
        end;
        if lExitCode = 0 then
          Break;
        if (not lReextracted) and IsSubtitleUrlRejected(
          TThrottleController.YtDlpDiagnostics(lError)) then
        begin
          lReextracted := True;
          ForgetSubtitleSource(lKey);
          lSource := Extract;
          Continue;
        end;
        if SwitchToOriginal then
          Continue;
        raise Exception.CreateFmt('yt-dlp subtitle download failed (exit %d): %s',
          [lExitCode, FailureText(lOutput, lError)]);
      end;
    except
      on E: Exception do
      begin
        // A throttled download keeps its source for the retry, unless the
        // target has used its per-run 429 budget and will not come back.
        if not (E is EThrottleError) or
           ((FThrottleRetryMode = trmReturnToQueue) and
            Assigned(GThrottleController) and
            GThrottleController.IsTargetExhausted(aUrl)) then
          ForgetSubtitleSource(lKey);
        raise;
      end;
    end;
    ForgetSubtitleSource(lKey);

    Result.Meta := lSource.Meta;
    // `de-orig` is still German; `no` is quoted by YamlScalar (YAML bool).
    Result.Meta.TranscriptLanguage := lSource.Track.Language;
    if Result.Meta.TranscriptLanguage.EndsWith('-orig', True) then
      SetLength(Result.Meta.TranscriptLanguage,
        Length(Result.Meta.TranscriptLanguage) - Length('-orig'));
    lFiles := TDirectory.GetFiles(lTempDir, '*.srt');
    if Length(lFiles) = 0 then
      raise EMissingTranscriptError.Create(CMissingSubtitleMessage, Result.Meta);
    if Length(lFiles) > 1 then
      raise Exception.Create('yt-dlp produced multiple SRT files, which is unexpected.');
    Result.Transcript := ParseSrtContent(ReadTextFileUtf8OrAnsi(lFiles[0]));
  finally
    TDirectory.Delete(lTempDir, True);
  end;
end;

function TTranscriptService.ParseSrtContent(const aSrtContent: string): string;
var
  lSourceLines: TStringList;
  lResultLines: TStringList;
  lLine: string;
  lDummy: Integer;
begin
  gc(lSourceLines, TStringList.Create);
  gc(lResultLines, TStringList.Create);

  lSourceLines.Text := aSrtContent;

  for var lLoopLine in lSourceLines do
  begin
    lLine := lLoopLine .Trim;

    // Skip empty lines
    if lLine.IsEmpty then
      Continue;

    // Skip numeric-only lines (the subtitle index)
    if TryStrToInt(lLine, lDummy) then
      Continue;

    // Skip timestamp lines
    if Pos('-->', lLine) > 0 then
      Continue;

    // This must be a text line
    lResultLines.Add(lLine);
  end;

  Result := lResultLines.Text;
end;

initialization
  GInvocationLogLock := TCriticalSection.Create;
  GSubtitleSourcesLock := TCriticalSection.Create;
  GSubtitleSources := TDictionary<string, TSubtitleSource>.Create;
  GCookieLock := TCriticalSection.Create;

finalization
  GCookieLock.Free;
  GSubtitleSources.Free;
  GSubtitleSourcesLock.Free;
  GInvocationLogLock.Free;

end.
