unit YTTrans.Throttle;

interface

uses
  System.Generics.Collections,
  System.SyncObjs,
  System.SysUtils;

type
  TThrottleRetryMode = (trmRetryInline, trmReturnToQueue);

  TThrottleResponseKind = (trkNone, trkRateLimit, trkBotChallenge,
    trkConfiguration);

  // trcSubtitle: a timedtext download, paced by the full randomized gap.
  // trcExtraction: page/metadata/listing work, paced by the short base gap.
  TThrottleRequestClass = (trcSubtitle, trcExtraction);

const
  CDefaultBaseIntervalMs = 3000;

type

  TSourceFailureState = class
  public
    Targets: TDictionary<string, Byte>;
    PauseUntil: TDateTime;
    Exhausted: Boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  // File-mode policy: one outbound attempt per slice serializes result updates.
  // Explicit UTC timestamps keep pause/recovery transitions deterministic.
  TSourceThrottlePolicy = class
  private
    FSources: TObjectDictionary<string, TSourceFailureState>;
    FFailedSources: TDictionary<string, Byte>;
    FLastSuccessfulSource: string;
    function StateFor(const aSource: string): TSourceFailureState;
  public
    constructor Create;
    destructor Destroy; override;
    function ReportFailure(const aSource, aTarget: string;
      const aIsChannel: Boolean; const aNowUtc: TDateTime): Boolean;
    procedure ReportSuccess(const aSource: string);
    procedure CompleteProbe(const aSource: string);
    function WaitRemainingMs(const aSource: string;
      const aNowUtc: TDateTime): Int64;
    function IsExhausted(const aSource: string): Boolean;
    function PauseUntil(const aSource: string): TDateTime;
    procedure RestorePause(const aSource: string; const aUntilUtc: TDateTime);
  end;

  TThrottleProbeTracker = class
  private
    FLock: TCriticalSection;
    FTargets: TDictionary<string, Byte>;
    FAttempts: TDictionary<string, Integer>;
    class function NormalizeTarget(const aTargetId: string): string; static;
  public
    constructor Create;
    destructor Destroy; override;
    procedure MarkProbed(const aTargetId: string);
    procedure MarkSucceeded(const aTargetId: string);
    function WasProbed(const aTargetId: string): Boolean;
    function AttemptCount(const aTargetId: string): Integer;
    function IsExhausted(const aTargetId: string): Boolean;
    function ExhaustedCount: Integer;
    function CompletePass(const aStoppedByThrottle: Boolean): Boolean;
    procedure Reset;
  end;

  TThrottleController = class
  private
    FLock: TCriticalSection;
    FCooldownUntil: UInt64;
    FNextRequestAt: UInt64;       // full randomized gap, subtitle requests
    FNextBaseRequestAt: UInt64;   // short base gap, every request
    FBaseIntervalMs: Cardinal;
    FThrottleLevel: Integer;
    FSuccessfulVideosSinceThrottle: Integer;
    FRequestIntervalMs: Cardinal;
    FRequestJitterMs: Cardinal;
    FRecoveryRequestsRemaining: Integer;
    FLastThrottleKind: TThrottleResponseKind;
    FLastThrottleMessage: string;
    FLastThrottleOperation: string;
    FLastThrottleTarget: string;
    FLastThrottleAtUtc: string;
    FLastThrottleExitCode: Integer;
    FTargetRateLimitAttempts: TDictionary<string, Integer>;
    function DelayForLevel(const aLevel: Integer): Cardinal;
    function RequestIntervalForLevelMs: Cardinal;
    function RandomRequestDelayMs: Cardinal;
    procedure ReportVideoSuccessLocked;
    procedure CompleteTargetRequestLocked(const aNormalizedTarget: string;
      const aCountsAsVideoRequest, aBoundedTargetRetries: Boolean);
    procedure SchedulePacingLocked(const aRequestClass: TThrottleRequestClass;
      const aNow: UInt64);
    function PacingDeadlineLocked(
      const aRequestClass: TThrottleRequestClass): UInt64;
    class function NormalizeTarget(const aTarget: string): string; static;
  public
    // aBaseIntervalMs is the short gap before every request; the configured
    // interval plus jitter (and recovery spacing) applies before subtitle
    // (timedtext) requests only. The base gap is capped at the subtitle
    // interval (raised to the throttle-level minimum), so an explicit
    // request interval of 0 leaves requests unpaced.
    constructor Create(const aRequestIntervalMs: Cardinal = 10000;
      const aRequestJitterMs: Cardinal = 10000;
      const aBaseIntervalMs: Cardinal = CDefaultBaseIntervalMs);
    destructor Destroy; override;
    procedure BeforeRequest(
      const aRequestClass: TThrottleRequestClass); overload;
    procedure BeforeRequest(out aPacingWaitMs, aCooldownWaitMs: Int64;
      const aRequestClass: TThrottleRequestClass); overload;
    procedure ReportResult(const aExitCode: Integer; const aOutput: string;
      const aRequestClass: TThrottleRequestClass;
      const aCountsAsVideoRequest: Boolean = False;
      const aOperation: string = ''; const aTarget: string = '';
      const aBoundedTargetRetries: Boolean = False;
      const aApplyGlobalBackoff: Boolean = True;
      const aCompletesRequest: Boolean = True);
    // Success of a whole video request (e.g. a captionless extraction, or
    // the subtitle download after extraction): clears the target's 429
    // budget and, when counted, earns recovery credit.
    procedure CompleteTargetRequest(const aTarget: string;
      const aCountsAsVideoRequest, aBoundedTargetRetries: Boolean);
    procedure ReportVideoSuccess;
    procedure RestoreState(const aThrottleLevel,
      aSuccessfulVideosSinceThrottle: Integer;
      const aCooldownRemainingMs: Cardinal;
      const aRecoveryRequestsRemaining: Integer = -1;
      const aThrottleIdleMs: UInt64 = 0);
    procedure SetRequestInterval(const aValueMs, aJitterMs,
      aBaseIntervalMs: Cardinal);
    function CooldownRemainingMs: Cardinal;
    // Pacing wait (not cooldown) before a request of this class may start.
    function RequestWaitRemainingMs(
      const aRequestClass: TThrottleRequestClass): Cardinal;
    function ThrottleLevel: Integer;
    function EffectiveSleepSeconds(const aBaseSeconds: Integer): Integer;
    function SuccessfulVideosSinceThrottle: Integer;
    function RecoveryRequestsRemaining: Integer;
    function IsParked: Boolean;
    function LastThrottleKind: TThrottleResponseKind;
    function LastThrottleMessage: string;
    function LastThrottleOperation: string;
    function LastThrottleTarget: string;
    function LastThrottleAtUtc: string;
    function LastThrottleExitCode: Integer;
    function RateLimitAttemptsForTarget(const aTarget: string): Integer;
    // The target has used its per-run 429 budget (file mode).
    function IsTargetExhausted(const aTarget: string): Boolean;
    class function ClassifyResponse(const aMessage: string):
      TThrottleResponseKind; static;
    class function YtDlpDiagnostics(const aOutput: string): string; static;
    class function ResponseKindToString(const aKind: TThrottleResponseKind):
      string; static;
    class function RetryModeForFileMode(const aFileMode: Boolean):
      TThrottleRetryMode; static;
    class function IsThrottleMessage(const aMessage: string): Boolean; static;
  end;

implementation

uses
  System.DateUtils,
  System.StrUtils,
  System.Classes;

const
  CThrottleDelayMinutes: array[1..8] of Cardinal =
    (2, 5, 10, 15, 30, 45, 60, 90);
  CTerminalThrottleLevel = 9;
  CThrottleJitterPercent = 10;
  CSuccessfulVideosPerRecoveryLevel = 5;
  CMaximumRateLimitAttemptsPerTarget = 2;
  CThrottleIdleDecayIntervalMs = UInt64(90) * 60 * 1000;
  CThrottleRequestMinimumMs: array[0..8] of Cardinal =
    (0, 15000, 20000, 25000, 30000, 40000, 50000, 60000, 75000);

{ TThrottleProbeTracker }

constructor TSourceFailureState.Create;
begin
  inherited;
  Targets := TDictionary<string, Byte>.Create;
end;

destructor TSourceFailureState.Destroy;
begin
  Targets.Free;
  inherited;
end;

constructor TSourceThrottlePolicy.Create;
begin
  inherited;
  FSources := TObjectDictionary<string, TSourceFailureState>.Create([doOwnsValues]);
  FFailedSources := TDictionary<string, Byte>.Create;
end;

destructor TSourceThrottlePolicy.Destroy;
begin
  FFailedSources.Free;
  FSources.Free;
  inherited;
end;

function TSourceThrottlePolicy.StateFor(const aSource: string): TSourceFailureState;
begin
  if not FSources.TryGetValue(aSource, Result) then
  begin
    Result := TSourceFailureState.Create;
    FSources.Add(aSource, Result);
  end;
end;

function TSourceThrottlePolicy.ReportFailure(const aSource, aTarget: string;
  const aIsChannel: Boolean; const aNowUtc: TDateTime): Boolean;
var
  lState: TSourceFailureState;
begin
  lState := StateFor(aSource);
  if lState.PauseUntil > 0 then
  begin
    // Only the scheduler may admit the one post-pause probe.
    if aNowUtc >= lState.PauseUntil then
      lState.Exhausted := True;
    Exit(False);
  end;
  FFailedSources.AddOrSetValue(aSource, 1);
  Result := (FLastSuccessfulSource = '') or
    (FLastSuccessfulSource = aSource) or (FFailedSources.Count > 1);
  if aIsChannel then
  begin
    lState.Targets.AddOrSetValue(aTarget, 1);
    if (lState.Targets.Count >= 3) and
       (FLastSuccessfulSource <> '') and
       (FLastSuccessfulSource <> aSource) then
      lState.PauseUntil := IncMinute(aNowUtc, 10);
  end;
end;

procedure TSourceThrottlePolicy.ReportSuccess(const aSource: string);
begin
  FLastSuccessfulSource := aSource;
  FFailedSources.Clear;
  StateFor(aSource).Targets.Clear;
  CompleteProbe(aSource);
end;

procedure TSourceThrottlePolicy.CompleteProbe(const aSource: string);
var
  lState: TSourceFailureState;
begin
  lState := StateFor(aSource);
  if lState.PauseUntil > 0 then
  begin
    lState.PauseUntil := 0;
    lState.Targets.Clear;
    lState.Exhausted := False;
  end;
end;

function TSourceThrottlePolicy.WaitRemainingMs(const aSource: string;
  const aNowUtc: TDateTime): Int64;
begin
  Result := Round((StateFor(aSource).PauseUntil - aNowUtc) * MSecsPerDay);
  if Result < 0 then
    Result := 0;
end;

function TSourceThrottlePolicy.IsExhausted(const aSource: string): Boolean;
begin
  Result := StateFor(aSource).Exhausted;
end;

function TSourceThrottlePolicy.PauseUntil(const aSource: string): TDateTime;
begin
  Result := StateFor(aSource).PauseUntil;
end;

procedure TSourceThrottlePolicy.RestorePause(const aSource: string;
  const aUntilUtc: TDateTime);
begin
  StateFor(aSource).PauseUntil := aUntilUtc;
end;

constructor TThrottleProbeTracker.Create;
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FTargets := TDictionary<string, Byte>.Create;
  FAttempts := TDictionary<string, Integer>.Create;
end;

destructor TThrottleProbeTracker.Destroy;
begin
  FAttempts.Free;
  FTargets.Free;
  FLock.Free;
  inherited;
end;

procedure TThrottleProbeTracker.MarkProbed(const aTargetId: string);
var
  lTargetId: string;
  lAttempts: Integer;
begin
  lTargetId := NormalizeTarget(aTargetId);
  if lTargetId = '' then
    Exit;
  FLock.Enter;
  try
    FTargets.AddOrSetValue(lTargetId, 0);
    if not FAttempts.TryGetValue(lTargetId, lAttempts) then
      lAttempts := 0;
    FAttempts.AddOrSetValue(lTargetId, lAttempts + 1);
  finally
    FLock.Leave;
  end;
end;

procedure TThrottleProbeTracker.MarkSucceeded(const aTargetId: string);
var
  lTargetId: string;
begin
  lTargetId := NormalizeTarget(aTargetId);
  if lTargetId = '' then
    Exit;
  FLock.Enter;
  try
    FTargets.Remove(lTargetId);
    FAttempts.Remove(lTargetId);
  finally
    FLock.Leave;
  end;
end;

class function TThrottleProbeTracker.NormalizeTarget(
  const aTargetId: string): string;
begin
  Result := Trim(aTargetId).ToLower;
end;

procedure TThrottleProbeTracker.Reset;
begin
  FLock.Enter;
  try
    FTargets.Clear;
    FAttempts.Clear;
  finally
    FLock.Leave;
  end;
end;

function TThrottleProbeTracker.CompletePass(
  const aStoppedByThrottle: Boolean): Boolean;
var
  lAttempts: Integer;
  lTarget: string;
begin
  FLock.Enter;
  try
    Result := False;
    if not aStoppedByThrottle then
      for lTarget in FTargets.Keys do
      begin
        if not FAttempts.TryGetValue(lTarget, lAttempts) then
          lAttempts := 0;
        if lAttempts < CMaximumRateLimitAttemptsPerTarget then
        begin
          Result := True;
          Break;
        end;
      end;
    if not aStoppedByThrottle then
      FTargets.Clear;
  finally
    FLock.Leave;
  end;
end;

function TThrottleProbeTracker.AttemptCount(
  const aTargetId: string): Integer;
var
  lTargetId: string;
begin
  Result := 0;
  lTargetId := NormalizeTarget(aTargetId);
  if lTargetId = '' then
    Exit;
  FLock.Enter;
  try
    FAttempts.TryGetValue(lTargetId, Result);
  finally
    FLock.Leave;
  end;
end;

function TThrottleProbeTracker.IsExhausted(
  const aTargetId: string): Boolean;
begin
  Result := AttemptCount(aTargetId) >= CMaximumRateLimitAttemptsPerTarget;
end;

function TThrottleProbeTracker.ExhaustedCount: Integer;
var
  lAttempts: Integer;
begin
  Result := 0;
  FLock.Enter;
  try
    for lAttempts in FAttempts.Values do
      if lAttempts >= CMaximumRateLimitAttemptsPerTarget then
        Inc(Result);
  finally
    FLock.Leave;
  end;
end;

function TThrottleProbeTracker.WasProbed(const aTargetId: string): Boolean;
var
  lTargetId: string;
begin
  lTargetId := NormalizeTarget(aTargetId);
  if lTargetId = '' then
    Exit(False);
  FLock.Enter;
  try
    Result := FTargets.ContainsKey(lTargetId);
  finally
    FLock.Leave;
  end;
end;

{ TThrottleController }

constructor TThrottleController.Create(
  const aRequestIntervalMs, aRequestJitterMs, aBaseIntervalMs: Cardinal);
begin
  inherited Create;
  FBaseIntervalMs := aBaseIntervalMs;
  FLock := TCriticalSection.Create;
  FTargetRateLimitAttempts := TDictionary<string, Integer>.Create;
  FRequestIntervalMs := aRequestIntervalMs;
  FRequestJitterMs := aRequestJitterMs;
  Randomize;
end;

destructor TThrottleController.Destroy;
begin
  FTargetRateLimitAttempts.Free;
  FLock.Free;
  inherited;
end;

function TThrottleController.DelayForLevel(const aLevel: Integer): Cardinal;
var
  lBaseDelayMs: Cardinal;
  lJitterMs: Cardinal;
begin
  if (aLevel < Low(CThrottleDelayMinutes)) or
     (aLevel > High(CThrottleDelayMinutes)) then
    Exit(0);
  lBaseDelayMs := CThrottleDelayMinutes[aLevel] * 60 * 1000;
  lJitterMs := lBaseDelayMs div (100 div CThrottleJitterPercent);
  Result := lBaseDelayMs - lJitterMs + Cardinal(Random(lJitterMs * 2 + 1));
end;

// The configured subtitle interval, raised to the throttle level's minimum.
function TThrottleController.RequestIntervalForLevelMs: Cardinal;
var
  lLevel: Integer;
begin
  Result := FRequestIntervalMs;
  lLevel := FThrottleLevel;
  if lLevel < Low(CThrottleRequestMinimumMs) then
    lLevel := Low(CThrottleRequestMinimumMs)
  else if lLevel > High(CThrottleRequestMinimumMs) then
    lLevel := High(CThrottleRequestMinimumMs);
  if Result < CThrottleRequestMinimumMs[lLevel] then
    Result := CThrottleRequestMinimumMs[lLevel];
end;

function TThrottleController.RandomRequestDelayMs: Cardinal;
var
  lDelay: UInt64;
begin
  lDelay := RequestIntervalForLevelMs;
  if FRequestJitterMs > 0 then
    Inc(lDelay, Cardinal(Random(FRequestJitterMs + 1)));
  if lDelay > High(Cardinal) then
    Result := High(Cardinal)
  else
    Result := Cardinal(lDelay);
end;

class function TThrottleController.ClassifyResponse(
  const aMessage: string): TThrottleResponseKind;
var
  lText: string;
begin
  lText := LowerCase(aMessage);
  if ContainsText(lText, 'confirm you are not a bot') or
     ContainsText(lText, 'confirm you''re not a bot') or
     ContainsText(lText, 'not a bot') then
    Exit(trkBotChallenge);
  if ContainsText(lText, 'po token') or
     ContainsText(lText, 'po_token') or
     ContainsText(lText, 'javascript runtime') or
     ContainsText(lText, 'challenge solver') or
     ContainsText(lText, 'signature solving failed') then
    Exit(trkConfiguration);
  if ContainsText(lText, 'http error 429') or
    ContainsText(lText, 'too many requests') or
    ContainsText(lText, 'youtube throttling persisted') or
    ContainsText(lText, 'temporarily blocked') or
    ContainsText(lText, 'rate limit') or
    ContainsText(lText, 'this content isn''t available, try again later') then
    Exit(trkRateLimit);
  Result := trkNone;
end;

class function TThrottleController.YtDlpDiagnostics(
  const aOutput: string): string;
var
  lLines: TStringList;
  lLine: string;
  lDiagnostics: TStringBuilder;
begin
  // Stdout carries metadata JSON (titles, descriptions); only yt-dlp's own
  // ERROR:/WARNING: lines describe the response. Configuration hints such as
  // the PO-token notice count only when yt-dlp reports them as an ERROR.
  lLines := TStringList.Create;
  lDiagnostics := TStringBuilder.Create;
  try
    lLines.Text := aOutput;
    for lLine in lLines do
      if StartsText('ERROR:', TrimLeft(lLine)) or
         (StartsText('WARNING:', TrimLeft(lLine)) and
          IsThrottleMessage(lLine)) then
        lDiagnostics.AppendLine(Trim(lLine));
    Result := lDiagnostics.ToString;
  finally
    lDiagnostics.Free;
    lLines.Free;
  end;
end;

class function TThrottleController.ResponseKindToString(
  const aKind: TThrottleResponseKind): string;
begin
  case aKind of
    trkRateLimit: Result := 'rate_limit';
    trkBotChallenge: Result := 'bot_challenge';
    trkConfiguration: Result := 'configuration';
  else
    Result := 'none';
  end;
end;

class function TThrottleController.IsThrottleMessage(
  const aMessage: string): Boolean;
var
  lKind: TThrottleResponseKind;
begin
  lKind := ClassifyResponse(aMessage);
  Result := lKind in [trkRateLimit, trkBotChallenge];
end;

class function TThrottleController.RetryModeForFileMode(
  const aFileMode: Boolean): TThrottleRetryMode;
begin
  if aFileMode then
    Result := trmReturnToQueue
  else
    Result := trmRetryInline;
end;

procedure TThrottleController.BeforeRequest(
  const aRequestClass: TThrottleRequestClass);
var
  lPacingWaitMs, lCooldownWaitMs: Int64;
begin
  BeforeRequest(lPacingWaitMs, lCooldownWaitMs, aRequestClass);
end;

procedure TThrottleController.SchedulePacingLocked(
  const aRequestClass: TThrottleRequestClass; const aNow: UInt64);
var
  lDeadline: UInt64;
  lBaseMs: Cardinal;
begin
  // Every request pushes the base gap; only subtitle requests push the full
  // randomized gap, so captionless extractions never spend a subtitle slot.
  // The base gap never exceeds the subtitle interval, so it cannot act as a
  // floor above an explicitly small (or zero) request_interval_ms.
  lBaseMs := FBaseIntervalMs;
  if lBaseMs > RequestIntervalForLevelMs then
    lBaseMs := RequestIntervalForLevelMs;
  lDeadline := aNow + lBaseMs;
  if lDeadline > FNextBaseRequestAt then
    FNextBaseRequestAt := lDeadline;
  if aRequestClass = trcSubtitle then
  begin
    lDeadline := aNow + RandomRequestDelayMs;
    if lDeadline > FNextRequestAt then
      FNextRequestAt := lDeadline;
  end;
end;

function TThrottleController.PacingDeadlineLocked(
  const aRequestClass: TThrottleRequestClass): UInt64;
begin
  Result := FNextBaseRequestAt;
  if (aRequestClass = trcSubtitle) and (FNextRequestAt > Result) then
    Result := FNextRequestAt;
end;

function TThrottleController.IsTargetExhausted(const aTarget: string): Boolean;
begin
  Result := RateLimitAttemptsForTarget(aTarget) >=
    CMaximumRateLimitAttemptsPerTarget;
end;

procedure TThrottleController.BeforeRequest(out aPacingWaitMs, aCooldownWaitMs: Int64;
  const aRequestClass: TThrottleRequestClass);
var
  lWaitUntil, lNow, lPacingDeadline, lCooldownDeadline, lElapsed,
    lCooldownPart: UInt64;
begin
  aPacingWaitMs := 0;
  aCooldownWaitMs := 0;
  while True do
  begin
    FLock.Enter;
    try
      lNow := TThread.GetTickCount64;
      if (FThrottleLevel >= CTerminalThrottleLevel) and
         (lNow >= FCooldownUntil) then
      begin
        FThrottleLevel := 0;
        FSuccessfulVideosSinceThrottle := 0;
        FRecoveryRequestsRemaining := 0;
      end;
      lWaitUntil := FCooldownUntil;
      lCooldownDeadline := FCooldownUntil;
      lPacingDeadline := PacingDeadlineLocked(aRequestClass);
      if lPacingDeadline > lWaitUntil then
        lWaitUntil := lPacingDeadline;
      if lNow >= lWaitUntil then
      begin
        SchedulePacingLocked(aRequestClass, lNow);
        Exit;
      end;
    finally
      FLock.Leave;
    end;
    TThread.Sleep(250);
    lElapsed := TThread.GetTickCount64 - lNow;
    lCooldownPart := 0;
    if lCooldownDeadline > lNow then
    begin
      lCooldownPart := lCooldownDeadline - lNow;
      if lCooldownPart > lElapsed then
        lCooldownPart := lElapsed;
    end;
    Inc(aCooldownWaitMs, Int64(lCooldownPart));
    Inc(aPacingWaitMs, Int64(lElapsed - lCooldownPart));
  end;
end;

procedure TThrottleController.ReportResult(const aExitCode: Integer;
  const aOutput: string; const aRequestClass: TThrottleRequestClass;
  const aCountsAsVideoRequest: Boolean; const aOperation, aTarget: string;
  const aBoundedTargetRetries, aApplyGlobalBackoff,
  aCompletesRequest: Boolean);
var
  lDelay: Cardinal;
  lDeadline: UInt64;
  lKind: TThrottleResponseKind;
  lTarget: string;
  lTargetAttempts: Integer;
  lIsRepeatedTargetRateLimit: Boolean;
begin
  FLock.Enter;
  try
    lKind := ClassifyResponse(aOutput);
    lTarget := NormalizeTarget(aTarget);
    lIsRepeatedTargetRateLimit := False;
    if aBoundedTargetRetries and (lKind = trkRateLimit) and
       (lTarget <> '') then
    begin
      if not FTargetRateLimitAttempts.TryGetValue(lTarget,
        lTargetAttempts) then
        lTargetAttempts := 0;
      Inc(lTargetAttempts);
      FTargetRateLimitAttempts.AddOrSetValue(lTarget, lTargetAttempts);
      lIsRepeatedTargetRateLimit := lTargetAttempts > 1;
    end;
    if (lKind = trkRateLimit) and not aApplyGlobalBackoff then
      lIsRepeatedTargetRateLimit := True;
    if lKind in [trkRateLimit, trkBotChallenge] then
    begin
      if lKind = trkBotChallenge then
        FThrottleLevel := CTerminalThrottleLevel
      else if (not lIsRepeatedTargetRateLimit) and
              (FThrottleLevel < CTerminalThrottleLevel) then
        Inc(FThrottleLevel);
      if not lIsRepeatedTargetRateLimit then
      begin
        FSuccessfulVideosSinceThrottle := 0;
        FRecoveryRequestsRemaining := CSuccessfulVideosPerRecoveryLevel;
      end;
      FLastThrottleKind := lKind;
      FLastThrottleMessage := Trim(aOutput);
      FLastThrottleOperation := aOperation;
      FLastThrottleTarget := aTarget;
      FLastThrottleAtUtc := FormatDateTime('yyyy-mm-dd"T"hh:nn:ss.zzz"Z"',
        TTimeZone.Local.ToUniversalTime(Now));
      FLastThrottleExitCode := aExitCode;
      if not lIsRepeatedTargetRateLimit then
      begin
        if FThrottleLevel < CTerminalThrottleLevel then
          lDelay := DelayForLevel(FThrottleLevel)
        else
          lDelay := DelayForLevel(High(CThrottleDelayMinutes));
        lDeadline := TThread.GetTickCount64 + lDelay;
        if lDeadline > FCooldownUntil then
          FCooldownUntil := lDeadline;
      end;
    end;
    // A partial step (extraction before the subtitle download) must not
    // reset the target's 429 budget or earn recovery credit.
    if (lKind = trkNone) and (aExitCode = 0) and aCompletesRequest then
      CompleteTargetRequestLocked(lTarget, aCountsAsVideoRequest,
        aBoundedTargetRetries);
    SchedulePacingLocked(aRequestClass, TThread.GetTickCount64);
  finally
    FLock.Leave;
  end;
end;

class function TThrottleController.NormalizeTarget(
  const aTarget: string): string;
begin
  Result := Trim(aTarget).ToLower;
end;

procedure TThrottleController.CompleteTargetRequestLocked(
  const aNormalizedTarget: string;
  const aCountsAsVideoRequest, aBoundedTargetRetries: Boolean);
begin
  if aBoundedTargetRetries and (aNormalizedTarget <> '') then
    FTargetRateLimitAttempts.Remove(aNormalizedTarget);
  if aCountsAsVideoRequest then
    ReportVideoSuccessLocked;
end;

procedure TThrottleController.CompleteTargetRequest(const aTarget: string;
  const aCountsAsVideoRequest, aBoundedTargetRetries: Boolean);
begin
  FLock.Enter;
  try
    CompleteTargetRequestLocked(NormalizeTarget(aTarget),
      aCountsAsVideoRequest, aBoundedTargetRetries);
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.RateLimitAttemptsForTarget(
  const aTarget: string): Integer;
var
  lTarget: string;
begin
  Result := 0;
  lTarget := NormalizeTarget(aTarget);
  if lTarget = '' then
    Exit;
  FLock.Enter;
  try
    FTargetRateLimitAttempts.TryGetValue(lTarget, Result);
  finally
    FLock.Leave;
  end;
end;

procedure TThrottleController.ReportVideoSuccessLocked;
begin
  if FThrottleLevel >= CTerminalThrottleLevel then
  begin
    FSuccessfulVideosSinceThrottle := 0;
    Exit;
  end;
  if FRecoveryRequestsRemaining > 0 then
    Dec(FRecoveryRequestsRemaining);
  if FThrottleLevel <= 0 then
  begin
    FSuccessfulVideosSinceThrottle := 0;
    Exit;
  end;
  Inc(FSuccessfulVideosSinceThrottle);
  if FSuccessfulVideosSinceThrottle >= CSuccessfulVideosPerRecoveryLevel then
  begin
    Dec(FThrottleLevel);
    FSuccessfulVideosSinceThrottle := 0;
  end;
end;

procedure TThrottleController.ReportVideoSuccess;
begin
  FLock.Enter;
  try
    ReportVideoSuccessLocked;
  finally
    FLock.Leave;
  end;
end;

procedure TThrottleController.RestoreState(const aThrottleLevel,
  aSuccessfulVideosSinceThrottle: Integer;
  const aCooldownRemainingMs: Cardinal;
  const aRecoveryRequestsRemaining: Integer;
  const aThrottleIdleMs: UInt64);
var
  lDecayLevels: UInt64;
  lLevelDecayed: Boolean;
begin
  FLock.Enter;
  try
    FThrottleLevel := aThrottleLevel;
    if FThrottleLevel < 0 then
      FThrottleLevel := 0
    else if FThrottleLevel > CTerminalThrottleLevel then
      FThrottleLevel := CTerminalThrottleLevel;

    lLevelDecayed := False;
    if (aCooldownRemainingMs = 0) and
       (FThrottleLevel >= CTerminalThrottleLevel) then
    begin
      FThrottleLevel := 0;
      lLevelDecayed := True;
    end
    else if (aCooldownRemainingMs = 0) and (FThrottleLevel > 0) then
    begin
      lDecayLevels := aThrottleIdleMs div CThrottleIdleDecayIntervalMs;
      if lDecayLevels > 0 then
      begin
        lLevelDecayed := True;
        if lDecayLevels >= UInt64(FThrottleLevel) then
          FThrottleLevel := 0
        else
          Dec(FThrottleLevel, Integer(lDecayLevels));
      end;
    end;

    FSuccessfulVideosSinceThrottle := aSuccessfulVideosSinceThrottle;
    if FSuccessfulVideosSinceThrottle < 0 then
      FSuccessfulVideosSinceThrottle := 0
    else if FSuccessfulVideosSinceThrottle >= CSuccessfulVideosPerRecoveryLevel then
      FSuccessfulVideosSinceThrottle := CSuccessfulVideosPerRecoveryLevel - 1;
    if (FThrottleLevel = 0) or lLevelDecayed then
      FSuccessfulVideosSinceThrottle := 0;

    if FThrottleLevel = 0 then
      FRecoveryRequestsRemaining := 0
    else if lLevelDecayed then
      FRecoveryRequestsRemaining := CSuccessfulVideosPerRecoveryLevel
    else if aRecoveryRequestsRemaining < 0 then
      FRecoveryRequestsRemaining := CSuccessfulVideosPerRecoveryLevel
    else if aRecoveryRequestsRemaining > CSuccessfulVideosPerRecoveryLevel then
      FRecoveryRequestsRemaining := CSuccessfulVideosPerRecoveryLevel
    else
      FRecoveryRequestsRemaining := aRecoveryRequestsRemaining;

    if aCooldownRemainingMs > 0 then
      FCooldownUntil := TThread.GetTickCount64 + aCooldownRemainingMs
    else
      FCooldownUntil := 0;
    FNextRequestAt := 0;
    FNextBaseRequestAt := 0;
  finally
    FLock.Leave;
  end;
end;

procedure TThrottleController.SetRequestInterval(const aValueMs, aJitterMs,
  aBaseIntervalMs: Cardinal);
begin
  FLock.Enter;
  try
    FRequestIntervalMs := aValueMs;
    FRequestJitterMs := aJitterMs;
    FBaseIntervalMs := aBaseIntervalMs;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.CooldownRemainingMs: Cardinal;
var
  lNow: UInt64;
begin
  FLock.Enter;
  try
    lNow := TThread.GetTickCount64;
    if FCooldownUntil > lNow then
      Result := Cardinal(FCooldownUntil - lNow)
    else
      Result := 0;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.RequestWaitRemainingMs(
  const aRequestClass: TThrottleRequestClass): Cardinal;
var
  lNow, lDeadline: UInt64;
begin
  FLock.Enter;
  try
    lNow := TThread.GetTickCount64;
    lDeadline := PacingDeadlineLocked(aRequestClass);
    if lDeadline > lNow then
      Result := Cardinal(lDeadline - lNow)
    else
      Result := 0;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.ThrottleLevel: Integer;
begin
  FLock.Enter;
  try
    Result := FThrottleLevel;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.EffectiveSleepSeconds(
  const aBaseSeconds: Integer): Integer;
begin
  if aBaseSeconds <= 0 then
    Exit(0);
  Result := aBaseSeconds;
end;

function TThrottleController.SuccessfulVideosSinceThrottle: Integer;
begin
  FLock.Enter;
  try
    Result := FSuccessfulVideosSinceThrottle;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.RecoveryRequestsRemaining: Integer;
begin
  FLock.Enter;
  try
    Result := FRecoveryRequestsRemaining;
  finally
    FLock.Leave;
  end;
end;


function TThrottleController.IsParked: Boolean;
begin
  FLock.Enter;
  try
    Result := FThrottleLevel >= CTerminalThrottleLevel;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.LastThrottleKind: TThrottleResponseKind;
begin
  FLock.Enter;
  try
    Result := FLastThrottleKind;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.LastThrottleMessage: string;
begin
  FLock.Enter;
  try
    Result := FLastThrottleMessage;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.LastThrottleOperation: string;
begin
  FLock.Enter;
  try
    Result := FLastThrottleOperation;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.LastThrottleTarget: string;
begin
  FLock.Enter;
  try
    Result := FLastThrottleTarget;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.LastThrottleAtUtc: string;
begin
  FLock.Enter;
  try
    Result := FLastThrottleAtUtc;
  finally
    FLock.Leave;
  end;
end;

function TThrottleController.LastThrottleExitCode: Integer;
begin
  FLock.Enter;
  try
    Result := FLastThrottleExitCode;
  finally
    FLock.Leave;
  end;
end;

end.
