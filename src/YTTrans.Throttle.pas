unit YTTrans.Throttle;

interface

uses
  System.SyncObjs,
  System.SysUtils;

type
  TThrottleController = class
  private
    FLock: TCriticalSection;
    FCooldownUntil: UInt64;
    FNextRequestAt: UInt64;
    FThrottleLevel: Integer;
    FSuccessfulVideosSinceThrottle: Integer;
    FEffectiveWorkers: Integer;
    FRequestIntervalMs: Cardinal;
    FRequestJitterMs: Cardinal;
    function DelayForLevel(const aLevel: Integer): Cardinal;
    function RandomRequestDelayMs: Cardinal;
  public
    constructor Create(const aConfiguredWorkers: Integer;
      const aRequestIntervalMs: Cardinal = 10000;
      const aRequestJitterMs: Cardinal = 10000);
    destructor Destroy; override;
    procedure BeforeRequest;
    procedure ReportResult(const aExitCode: Integer; const aOutput: string);
    procedure ReportVideoSuccess;
    procedure RestoreState(const aThrottleLevel,
      aSuccessfulVideosSinceThrottle: Integer;
      const aCooldownRemainingMs: Cardinal);
    procedure SetRequestInterval(const aValueMs, aJitterMs: Cardinal);
    function CooldownRemainingMs: Cardinal;
    function RequestWaitRemainingMs: Cardinal;
    function ThrottleLevel: Integer;
    function EffectiveSleepSeconds(const aBaseSeconds: Integer): Integer;
    function SuccessfulVideosSinceThrottle: Integer;
    function EffectiveWorkers: Integer;
    function IsParked: Boolean;
    class function IsThrottleMessage(const aMessage: string): Boolean; static;
  end;

implementation

uses
  System.StrUtils,
  System.Classes;

const
  CThrottleDelayMinutes: array[1..8] of Cardinal =
    (2, 5, 10, 15, 30, 45, 60, 90);
  CTerminalThrottleLevel = 9;
  CThrottleJitterPercent = 10;
  CSuccessfulVideosPerRecoveryLevel = 5;

constructor TThrottleController.Create(const aConfiguredWorkers: Integer;
  const aRequestIntervalMs, aRequestJitterMs: Cardinal);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FEffectiveWorkers := aConfiguredWorkers;
  if FEffectiveWorkers < 1 then
    FEffectiveWorkers := 1;
  FRequestIntervalMs := aRequestIntervalMs;
  FRequestJitterMs := aRequestJitterMs;
  Randomize;
end;

destructor TThrottleController.Destroy;
begin
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

function TThrottleController.RandomRequestDelayMs: Cardinal;
var
  lDelay: UInt64;
  lMultiplierPercent: Cardinal;
begin
  lDelay := FRequestIntervalMs;
  if FRequestJitterMs > 0 then
    Inc(lDelay, Cardinal(Random(FRequestJitterMs + 1)));
  lMultiplierPercent := 100 + Cardinal(FThrottleLevel * 50);
  lDelay := (lDelay * lMultiplierPercent) div 100;
  if lDelay > High(Cardinal) then
    Result := High(Cardinal)
  else
    Result := Cardinal(lDelay);
end;

class function TThrottleController.IsThrottleMessage(
  const aMessage: string): Boolean;
var
  lText: string;
begin
  lText := LowerCase(aMessage);
  Result := ContainsText(lText, 'http error 429') or
    ContainsText(lText, 'too many requests') or
    ContainsText(lText, 'youtube throttling persisted') or
    ContainsText(lText, 'sign in to confirm you') or
    ContainsText(lText, 'not a bot') or
    ContainsText(lText, 'temporarily blocked') or
    ContainsText(lText, 'rate limit');
end;

procedure TThrottleController.BeforeRequest;
var
  lWaitUntil, lNow, lDeadline: UInt64;
begin
  while True do
  begin
    FLock.Enter;
    try
      lNow := TThread.GetTickCount64;
      if (FThrottleLevel >= CTerminalThrottleLevel) and
         (lNow >= FCooldownUntil) then
      begin
        FThrottleLevel := High(CThrottleDelayMinutes);
        FSuccessfulVideosSinceThrottle := 0;
      end;
      lWaitUntil := FCooldownUntil;
      if FNextRequestAt > lWaitUntil then
        lWaitUntil := FNextRequestAt;
      if lNow >= lWaitUntil then
      begin
        lDeadline := lNow + RandomRequestDelayMs;
        if lDeadline > FNextRequestAt then
          FNextRequestAt := lDeadline;
        Exit;
      end;
    finally
      FLock.Leave;
    end;
    TThread.Sleep(250);
  end;
end;

procedure TThrottleController.ReportResult(const aExitCode: Integer;
  const aOutput: string);
var
  lDelay: Cardinal;
  lDeadline: UInt64;
begin
  FLock.Enter;
  try
    if IsThrottleMessage(aOutput) then
    begin
      if FThrottleLevel < CTerminalThrottleLevel then
        Inc(FThrottleLevel);
      FSuccessfulVideosSinceThrottle := 0;
      FEffectiveWorkers := 1;
      if FThrottleLevel < CTerminalThrottleLevel then
        lDelay := DelayForLevel(FThrottleLevel)
      else
        lDelay := DelayForLevel(High(CThrottleDelayMinutes));
      lDeadline := TThread.GetTickCount64 + lDelay;
      if lDeadline > FCooldownUntil then
        FCooldownUntil := lDeadline;
    end;
    lDeadline := TThread.GetTickCount64 + RandomRequestDelayMs;
    if lDeadline > FNextRequestAt then
      FNextRequestAt := lDeadline;
  finally
    FLock.Leave;
  end;
end;

procedure TThrottleController.ReportVideoSuccess;
begin
  FLock.Enter;
  try
    if (FThrottleLevel <= 0) or
       (FThrottleLevel >= CTerminalThrottleLevel) then
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
  finally
    FLock.Leave;
  end;
end;

procedure TThrottleController.RestoreState(const aThrottleLevel,
  aSuccessfulVideosSinceThrottle: Integer;
  const aCooldownRemainingMs: Cardinal);
begin
  FLock.Enter;
  try
    FThrottleLevel := aThrottleLevel;
    if FThrottleLevel < 0 then
      FThrottleLevel := 0
    else if FThrottleLevel > CTerminalThrottleLevel then
      FThrottleLevel := CTerminalThrottleLevel;

    FSuccessfulVideosSinceThrottle := aSuccessfulVideosSinceThrottle;
    if FSuccessfulVideosSinceThrottle < 0 then
      FSuccessfulVideosSinceThrottle := 0
    else if FSuccessfulVideosSinceThrottle >= CSuccessfulVideosPerRecoveryLevel then
      FSuccessfulVideosSinceThrottle := CSuccessfulVideosPerRecoveryLevel - 1;
    if FThrottleLevel = 0 then
      FSuccessfulVideosSinceThrottle := 0
    else
      FEffectiveWorkers := 1;

    if aCooldownRemainingMs > 0 then
      FCooldownUntil := TThread.GetTickCount64 + aCooldownRemainingMs
    else
      FCooldownUntil := 0;
    FNextRequestAt := 0;
  finally
    FLock.Leave;
  end;
end;

procedure TThrottleController.SetRequestInterval(const aValueMs,
  aJitterMs: Cardinal);
begin
  FLock.Enter;
  try
    FRequestIntervalMs := aValueMs;
    FRequestJitterMs := aJitterMs;
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

function TThrottleController.RequestWaitRemainingMs: Cardinal;
var
  lNow: UInt64;
begin
  FLock.Enter;
  try
    lNow := TThread.GetTickCount64;
    if FNextRequestAt > lNow then
      Result := Cardinal(FNextRequestAt - lNow)
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
var
  lScaledSeconds: Int64;
begin
  if aBaseSeconds <= 0 then
    Exit(0);

  FLock.Enter;
  try
    lScaledSeconds := Int64(aBaseSeconds) * (100 + FThrottleLevel * 50);
    lScaledSeconds := (lScaledSeconds + 99) div 100;
    if lScaledSeconds > High(Integer) then
      Result := High(Integer)
    else
      Result := Integer(lScaledSeconds);
  finally
    FLock.Leave;
  end;
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

function TThrottleController.EffectiveWorkers: Integer;
begin
  FLock.Enter;
  try
    Result := FEffectiveWorkers;
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

end.
