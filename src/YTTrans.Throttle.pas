unit YTTrans.Throttle;

interface

uses
  System.SyncObjs;

type
  TThrottleController = class
  private
    FLock: TCriticalSection;
    FCooldownUntil: UInt64;
    FConsecutiveThrottles: Integer;
    FEffectiveWorkers: Integer;
    FTerminal: Boolean;
    function DelayForAttempt(const aAttempt: Integer): Cardinal;
  public
    constructor Create(const aConfiguredWorkers: Integer);
    destructor Destroy; override;
    procedure BeforeRequest;
    procedure ReportResult(const aExitCode: Integer; const aOutput: string);
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
  CThrottleDelays: array[1..3] of Cardinal = (30000, 120000, 300000);

constructor TThrottleController.Create(const aConfiguredWorkers: Integer);
begin
  inherited Create;
  FLock := TCriticalSection.Create;
  FEffectiveWorkers := aConfiguredWorkers;
  if FEffectiveWorkers < 1 then
    FEffectiveWorkers := 1;
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
    finally
      FLock.Leave;
    end;
    lNow := TThread.GetTickCount64;
    if lNow >= lWaitUntil then
      Exit;
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
    if aExitCode = 0 then
    begin
      FConsecutiveThrottles := 0;
      Exit;
    end;
    if not IsThrottleMessage(aOutput) then
      Exit;
    Inc(FConsecutiveThrottles);
    FEffectiveWorkers := 1;
    lDelay := DelayForAttempt(FConsecutiveThrottles);
    lDeadline := TThread.GetTickCount64 + lDelay;
    if lDeadline > FCooldownUntil then
      FCooldownUntil := lDeadline;
    if FConsecutiveThrottles >= High(CThrottleDelays) then
      FTerminal := True;
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
