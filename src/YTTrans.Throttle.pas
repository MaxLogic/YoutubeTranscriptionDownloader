unit YTTrans.Throttle;

interface

uses
  System.SyncObjs;

type
  TThrottleController = class
  private
    FLock: TCriticalSection;
    FCooldownUntil: UInt64;
    FNextRequestAt: UInt64;
    FConsecutiveThrottles: Integer;
    FEffectiveWorkers: Integer;
    FMinRequestIntervalMs: Cardinal;
    FTerminal: Boolean;
    function DelayForAttempt(const aAttempt: Integer): Cardinal;
  public
    constructor Create(const aConfiguredWorkers: Integer;
      const aMinRequestIntervalMs: Cardinal = 3000);
    destructor Destroy; override;
    procedure BeforeRequest;
    procedure ReportResult(const aExitCode: Integer; const aOutput: string);
    procedure SetMinRequestInterval(const aValueMs: Cardinal);
    function CooldownRemainingMs: Cardinal;
    function ThrottleAttempt: Integer;
    function EffectiveWorkers: Integer;
    function IsTerminal: Boolean;
    class function IsThrottleMessage(const aMessage: string): Boolean; static;
  end;

implementation

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes;

const
  CThrottleDelays: array[1..2] of Cardinal = (120000, 600000);
  CTerminalThrottleAttempt = 3;

constructor TThrottleController.Create(const aConfiguredWorkers: Integer;
  const aMinRequestIntervalMs: Cardinal);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FEffectiveWorkers := aConfiguredWorkers;
  if FEffectiveWorkers < 1 then
    FEffectiveWorkers := 1;
  FMinRequestIntervalMs := aMinRequestIntervalMs;
end;

destructor TThrottleController.Destroy;
begin
  FLock.Free;
  inherited;
end;

function TThrottleController.DelayForAttempt(const aAttempt: Integer): Cardinal;
var
  lIndex: Integer;
begin
  lIndex := aAttempt;
  if lIndex < Low(CThrottleDelays) then
    lIndex := Low(CThrottleDelays)
  else if lIndex > High(CThrottleDelays) then
    lIndex := High(CThrottleDelays);
  Result := CThrottleDelays[lIndex];
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
  lWaitUntil, lNow: UInt64;
begin
  while True do
  begin
    FLock.Enter;
    try
      lWaitUntil := FCooldownUntil;
      if FNextRequestAt > lWaitUntil then
        lWaitUntil := FNextRequestAt;
      lNow := TThread.GetTickCount64;
      if lNow >= lWaitUntil then
      begin
        FNextRequestAt := lNow + FMinRequestIntervalMs;
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
    lDeadline := TThread.GetTickCount64 + FMinRequestIntervalMs;
    if lDeadline > FNextRequestAt then
      FNextRequestAt := lDeadline;
    if IsThrottleMessage(aOutput) then
    begin
      Inc(FConsecutiveThrottles);
      FEffectiveWorkers := 1;
      FTerminal := FConsecutiveThrottles >= CTerminalThrottleAttempt;
      lDelay := DelayForAttempt(FConsecutiveThrottles);
      lDeadline := TThread.GetTickCount64 + lDelay;
      if lDeadline > FCooldownUntil then
        FCooldownUntil := lDeadline;
      Exit;
    end;
    if aExitCode = 0 then
    begin
      FConsecutiveThrottles := 0;
      FTerminal := False;
    end;
  finally
    FLock.Leave;
  end;
end;

procedure TThrottleController.SetMinRequestInterval(const aValueMs: Cardinal);
begin
  FLock.Enter;
  try
    FMinRequestIntervalMs := aValueMs;
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

function TThrottleController.ThrottleAttempt: Integer;
begin
  FLock.Enter;
  try
    Result := FConsecutiveThrottles;
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

function TThrottleController.IsTerminal: Boolean;
begin
  FLock.Enter;
  try
    Result := FTerminal;
  finally
    FLock.Leave;
  end;
end;

end.
