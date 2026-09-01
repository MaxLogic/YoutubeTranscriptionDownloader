unit YTTrans.DownloadFile;

interface

uses
  System.Classes,
  System.SysUtils,
  VSoft.YAML;

type
  EDownloadFileError = class(Exception);

  TDownloadMode = (dmFresh, dmFailed, dmThrottled, dmAll);
  TDownloadEntryKind = (dekChannel, dekVideo);

  TDownloadOptions = record
    Language: string;
    OutputDir: string;
    Subfolder: string;
    Jobs: Integer;
    RequestIntervalMs: Integer;
    DelayJitterMs: Integer;
    SleepRequestsSeconds: Integer;
    SleepSubtitlesSeconds: Integer;
    SocketTimeoutSeconds: Integer;
    IncludeShorts: Boolean;
    IncludeLive: Boolean;
    OverwriteExisting: Boolean;
    Metadata: Boolean;
    Keywords: string;
    Cookies: string;
    CookiesFromBrowser: string;
  end;

  TDownloadEntry = record
    Kind: TDownloadEntryKind;
    GroupIndex: Integer;
    EntryIndex: Integer;
    Url: string;
    Name: string;
    Enabled: Boolean;
    StateStatus: string;
    Options: TDownloadOptions;
    Node: IYAMLMapping;
  end;

  TDownloadFile = class
  private
    FFileName: string;
    FLockFileName: string;
    FLockStream: TFileStream;
    FDocument: IYAMLDocument;
    FRoot: IYAMLMapping;
    FMode: TDownloadMode;
    FSourceHash: string;
    FOwnsFile: Boolean;
    class function HashText(const aText: string): string; static;
    class function ParseDocument(const aText: string): IYAMLDocument; static;
    procedure Validate(const aSourceText: string);
    procedure SetMode(const aValue: TDownloadMode);
    function GetOutputRoot: string;
    function ReadOptions(const aMapping: IYAMLMapping;
      const aBase: TDownloadOptions; const aCanReadAuth: Boolean): TDownloadOptions;
    function GetGroups: IYAMLSequence;
  public
    constructor Open(const aFileName: string);
    class function LoadForTest(const aText, aFileName: string): TDownloadFile;
    destructor Destroy; override;
    function Entries: TArray<TDownloadEntry>;
    function IsEligible(const aEntry: TDownloadEntry): Boolean;
    function ThrottleCooldownRemainingMs(const aNowUtc: TDateTime): Int64;
    function SavedThrottleLevel: Integer;
    function SavedThrottleSuccessCount: Integer;
    procedure RemoveStandaloneVideo(const aGroupIndex, aVideoIndex: Integer);
    procedure RemoveStandaloneVideoByUrl(const aGroupIndex: Integer;
      const aUrl: string);
    procedure Checkpoint;
    function ToYaml: string;
    property FileName: string read FFileName;
    property Mode: TDownloadMode read FMode write SetMode;
    property OutputRoot: string read GetOutputRoot;
    property Root: IYAMLMapping read FRoot;
  end;

function DownloadModeToString(const aMode: TDownloadMode): string;

implementation

uses
  System.DateUtils,
  System.Generics.Collections,
  System.Hash,
  System.IOUtils,
  System.RegularExpressions,
  System.StrUtils,
  Winapi.Windows;

const
  CTopFields: array[0..4] of string =
    ('schema', 'mode', 'defaults', 'groups', 'state');
  CDefaultFields: array[0..14] of string =
    ('language', 'output_dir', 'jobs', 'request_interval_ms', 'delay_jitter_ms',
     'sleep_requests_seconds', 'sleep_subtitles_seconds',
     'socket_timeout_seconds', 'include_shorts', 'include_live',
     'overwrite_existing', 'metadata', 'keywords', 'cookies',
     'cookies_from_browser');
  CGroupFields: array[0..17] of string =
    ('name', 'enabled', 'subfolder', 'language', 'jobs', 'request_interval_ms',
     'delay_jitter_ms', 'sleep_requests_seconds', 'sleep_subtitles_seconds',
     'socket_timeout_seconds', 'include_shorts', 'include_live',
     'overwrite_existing', 'metadata', 'keywords', 'channels', 'videos',
     'notes');
  CEntryFields: array[0..17] of string =
    ('url', 'name', 'enabled', 'subfolder', 'language', 'jobs',
     'request_interval_ms', 'delay_jitter_ms', 'sleep_requests_seconds',
     'sleep_subtitles_seconds', 'socket_timeout_seconds', 'include_shorts',
     'include_live', 'overwrite_existing', 'metadata', 'keywords', 'notes',
     'state');
  CEntrySequences: array[0..1] of string = ('channels', 'videos');
  CStateFields: array[0..29] of string =
    ('status', 'last_attempt_utc', 'attempt_count', 'video_id',
     'video_published_at', 'error_kind', 'error', 'last_success_utc',
     'channel_id', 'downloaded', 'skipped', 'unavailable',
     'unavailable_cached', 'failed', 'deferred', 'last_run_started_utc',
     'last_checkpoint_utc', 'last_run_completed_utc', 'processed',
      'eligibility_skipped', 'overwritten', 'total', 'message', 'url',
      'throttle_retry_after_utc', 'throttle_level',
      'throttle_success_count', 'deferred_queue_entries',
      'deferred_channel_videos', 'channel_slices');

function DownloadModeToString(const aMode: TDownloadMode): string;
begin
  case aMode of
    dmFresh: Result := 'fresh';
    dmFailed: Result := 'failed';
    dmThrottled: Result := 'throttled';
    dmAll: Result := 'all';
  else
    Result := 'fresh';
  end;
end;

function IsAllowed(const aKey: string; const aFields: array of string): Boolean;
var
  lField: string;
begin
  for lField in aFields do
    if SameText(aKey, lField) then
      Exit(True);
  Result := False;
end;

procedure RequireMapping(const aValue: IYAMLValue; const aPath: string);
begin
  if (aValue = nil) or not aValue.IsMapping then
    raise EDownloadFileError.Create(aPath + ' must be a mapping');
end;

procedure RequireSequence(const aValue: IYAMLValue; const aPath: string);
begin
  if (aValue = nil) or not aValue.IsSequence then
    raise EDownloadFileError.Create(aPath + ' must be a sequence');
end;

procedure ValidateFields(const aMapping: IYAMLMapping; const aPath: string;
  const aFields: array of string);
var
  I: Integer;
  lKey: string;
begin
  for I := 0 to aMapping.Count - 1 do
  begin
    lKey := aMapping.Keys[I];
    if not IsAllowed(lKey, aFields) then
    begin
      if aPath = '' then
        raise EDownloadFileError.Create('Unknown field at ' + lKey)
      else
        raise EDownloadFileError.Create('Unknown field at ' + aPath + '.' + lKey);
    end;
  end;
end;

function MappingString(const aMapping: IYAMLMapping; const aKey,
  aDefault: string): string;
var
  lValue: IYAMLValue;
begin
  if (aMapping <> nil) and aMapping.TryGetValue(aKey, lValue) then
  begin
    if not lValue.IsScalar then
      raise EDownloadFileError.Create(aKey + ' must be a scalar');
    Exit(lValue.AsString);
  end;
  Result := aDefault;
end;

function MappingBool(const aMapping: IYAMLMapping; const aKey: string;
  const aDefault: Boolean): Boolean;
var
  lValue: IYAMLValue;
begin
  if (aMapping <> nil) and aMapping.TryGetValue(aKey, lValue) then
  begin
    if not lValue.IsBoolean then
      raise EDownloadFileError.Create(aKey + ' must be a boolean');
    Exit(lValue.AsBoolean);
  end;
  Result := aDefault;
end;

function MappingInt(const aMapping: IYAMLMapping; const aKey: string;
  const aDefault, aMinimum: Integer): Integer;
var
  lValue: IYAMLValue;
begin
  Result := aDefault;
  if (aMapping <> nil) and aMapping.TryGetValue(aKey, lValue) then
  begin
    if not lValue.IsInteger then
      raise EDownloadFileError.Create(aKey + ' must be an integer');
    Result := lValue.AsInteger;
    if Result < aMinimum then
      raise EDownloadFileError.CreateFmt('%s must be at least %d', [aKey, aMinimum]);
  end;
end;

function ReadKeywords(const aMapping: IYAMLMapping; const aDefault: string): string;
var
  I: Integer;
  lSequence: IYAMLSequence;
  lValue: IYAMLValue;
begin
  if (aMapping = nil) or not aMapping.TryGetValue('keywords', lValue) then
    Exit(aDefault);
  RequireSequence(lValue, 'keywords');
  lSequence := lValue.AsSequence;
  Result := '';
  for I := 0 to lSequence.Count - 1 do
  begin
    if not lSequence[I].IsScalar then
      raise EDownloadFileError.CreateFmt('keywords[%d] must be a scalar', [I]);
    if Result <> '' then
      Result := Result + ', ';
    Result := Result + lSequence[I].AsString;
  end;
end;

function NormalizeQueueUrl(const aUrl: string): string;
var
  lPos: Integer;
begin
  Result := LowerCase(Trim(aUrl));
  lPos := Pos('&', Result);
  if lPos > 0 then
    SetLength(Result, lPos - 1);
  while EndsText('/', Result) do
    Delete(Result, Length(Result), 1);
end;

procedure ValidateState(const aMapping: IYAMLMapping; const aPath: string);
begin
  ValidateFields(aMapping, aPath, CStateFields);
end;

procedure ValidateNoUnsupportedNodes(const aValue: IYAMLValue; const aPath: string);
var
  I: Integer;
  lMapping: IYAMLMapping;
  lSequence: IYAMLSequence;
begin
  if aValue = nil then
    Exit;
  if aValue.IsAlias then
    raise EDownloadFileError.Create('Aliases are not supported at ' + aPath);
  if (aValue.TagInfo <> nil) and aValue.TagInfo.IsCustomTag then
    raise EDownloadFileError.Create('Custom tags are not supported at ' + aPath);
  if aValue.IsMapping then
  begin
    lMapping := aValue.AsMapping;
    for I := 0 to lMapping.Count - 1 do
      ValidateNoUnsupportedNodes(lMapping[lMapping.Keys[I]], aPath + '.' + lMapping.Keys[I]);
  end
  else if aValue.IsSequence then
  begin
    lSequence := aValue.AsSequence;
    for I := 0 to lSequence.Count - 1 do
      ValidateNoUnsupportedNodes(lSequence[I], Format('%s[%d]', [aPath, I]));
  end;
end;

class function TDownloadFile.HashText(const aText: string): string;
begin
  Result := THashSHA2.GetHashString(aText);
end;

class function TDownloadFile.ParseDocument(const aText: string): IYAMLDocument;
var
  lNormalizedText: string;
  lDocuments: TArray<IYAMLDocument>;
begin
  // Older yttrans versions emitted these empty runtime-state values as YAML
  // nulls. VSoft.YAML currently stops a surrounding sequence after such a
  // nested null, so normalize only the application-owned fields before parse.
  // The next checkpoint rewrites them as quoted empty strings.
  lNormalizedText := TRegEx.Replace(aText,
    '^([ \t]+)(error_kind|error):[ \t]*(#.*)?$', '$1$2: ''''$3',
    [roMultiLine]);
  try
    lDocuments := TYAML.LoadAllFromString(lNormalizedText);
  except
    on E: Exception do
      raise EDownloadFileError.Create('Invalid YAML: ' + E.Message);
  end;
  if Length(lDocuments) <> 1 then
    raise EDownloadFileError.Create('Schema 1 requires exactly one YAML document');
  Result := lDocuments[0];
  if (Result = nil) or not Result.IsMapping then
    raise EDownloadFileError.Create('The YAML root must be a mapping');
end;

constructor TDownloadFile.Open(const aFileName: string);
var
  lText: string;
begin
  inherited Create;
  FFileName := TPath.GetFullPath(aFileName);
  if not TFile.Exists(FFileName) then
    raise EDownloadFileError.Create('Download file not found: ' + FFileName);
  FLockFileName := FFileName + '.lock';
  try
    FLockStream := TFileStream.Create(FLockFileName, fmCreate or fmShareExclusive);
  except
    on E: Exception do
      raise EDownloadFileError.Create('Download file is already in use: ' + FFileName);
  end;
  FOwnsFile := True;
  try
    lText := TFile.ReadAllText(FFileName, TEncoding.UTF8);
    FSourceHash := HashText(lText);
    FDocument := ParseDocument(lText);
    FRoot := FDocument.AsMapping;
    Validate(lText);
  except
    FreeAndNil(FLockStream);
    if TFile.Exists(FLockFileName) then
      TFile.Delete(FLockFileName);
    raise;
  end;
end;

class function TDownloadFile.LoadForTest(const aText,
  aFileName: string): TDownloadFile;
begin
  Result := TDownloadFile.Create;
  try
    Result.FFileName := TPath.GetFullPath(aFileName);
    Result.FSourceHash := HashText(aText);
    Result.FDocument := ParseDocument(aText);
    Result.FRoot := Result.FDocument.AsMapping;
    Result.Validate(aText);
  except
    Result.Free;
    raise;
  end;
end;

destructor TDownloadFile.Destroy;
begin
  FRoot := nil;
  FDocument := nil;
  FreeAndNil(FLockStream);
  if FOwnsFile and TFile.Exists(FLockFileName) then
  begin
    try
      TFile.Delete(FLockFileName);
    except
      // A stale lock pathname is harmless once its exclusive handle is closed.
    end;
  end;
  inherited;
end;

procedure TDownloadFile.Validate(const aSourceText: string);
var
  I, J: Integer;
  lDefaults, lGroup, lEntry, lState: IYAMLMapping;
  lGroups, lEntries: IYAMLSequence;
  lValue: IYAMLValue;
  lMode, lPath, lKey: string;
  lSeen: TDictionary<string, Boolean>;
begin
  if TRegEx.IsMatch(aSourceText, '(^|[\s\[{,])&[A-Za-z0-9_-]+', [roMultiLine]) or
     TRegEx.IsMatch(aSourceText, '(^|[\s\[{,])\*[A-Za-z0-9_-]+', [roMultiLine]) then
    raise EDownloadFileError.Create('YAML anchors and aliases are not supported');
  if TRegEx.IsMatch(aSourceText, '^\s*<<\s*:', [roMultiLine]) then
    raise EDownloadFileError.Create('YAML merge keys are not supported');
  ValidateNoUnsupportedNodes(FRoot, '$');
  ValidateFields(FRoot, '', CTopFields);
  if not FRoot.TryGetValue('schema', lValue) or not lValue.IsInteger or
     (lValue.AsInteger <> 1) then
    raise EDownloadFileError.Create('schema must be integer 1');
  if not FRoot.TryGetValue('mode', lValue) or not lValue.IsScalar then
    raise EDownloadFileError.Create('mode is required');
  lMode := LowerCase(lValue.AsString);
  if lMode = 'fresh' then FMode := dmFresh
  else if lMode = 'failed' then FMode := dmFailed
  else if lMode = 'throttled' then FMode := dmThrottled
  else if lMode = 'all' then FMode := dmAll
  else raise EDownloadFileError.Create('mode must be fresh, failed, throttled, or all');

  if FRoot.TryGetValue('defaults', lValue) then
  begin
    RequireMapping(lValue, 'defaults');
    lDefaults := lValue.AsMapping;
    ValidateFields(lDefaults, 'defaults', CDefaultFields);
    MappingInt(lDefaults, 'jobs', 1, 1);
    MappingInt(lDefaults, 'request_interval_ms', 10000, 0);
    MappingInt(lDefaults, 'delay_jitter_ms', 10000, 0);
    MappingInt(lDefaults, 'sleep_requests_seconds', 3, 0);
    MappingInt(lDefaults, 'sleep_subtitles_seconds', 5, 0);
    MappingInt(lDefaults, 'socket_timeout_seconds', 60, 0);
    if lDefaults.ContainsKey('cookies') and lDefaults.ContainsKey('cookies_from_browser') and
       (Trim(lDefaults.S['cookies']) <> '') and (Trim(lDefaults.S['cookies_from_browser']) <> '') then
      raise EDownloadFileError.Create('defaults.cookies and defaults.cookies_from_browser are mutually exclusive');
  end;
  if FRoot.TryGetValue('state', lValue) then
  begin
    RequireMapping(lValue, 'state');
    ValidateState(lValue.AsMapping, 'state');
  end;
  if not FRoot.TryGetValue('groups', lValue) then
    raise EDownloadFileError.Create('groups is required');
  RequireSequence(lValue, 'groups');
  lGroups := lValue.AsSequence;
  lSeen := TDictionary<string, Boolean>.Create;
  try
    for I := 0 to lGroups.Count - 1 do
    begin
      RequireMapping(lGroups[I], Format('groups[%d]', [I]));
      lGroup := lGroups[I].AsMapping;
      lPath := Format('groups[%d]', [I]);
      ValidateFields(lGroup, lPath, CGroupFields);
      MappingInt(lGroup, 'jobs', 1, 1);
      MappingInt(lGroup, 'request_interval_ms', 10000, 0);
      MappingInt(lGroup, 'delay_jitter_ms', 10000, 0);
      MappingInt(lGroup, 'sleep_requests_seconds', 3, 0);
      MappingInt(lGroup, 'sleep_subtitles_seconds', 5, 0);
      MappingInt(lGroup, 'socket_timeout_seconds', 60, 0);
      for lKey in CEntrySequences do
        if lGroup.TryGetValue(lKey, lValue) then
        begin
          RequireSequence(lValue, lPath + '.' + lKey);
          lEntries := lValue.AsSequence;
          for J := 0 to lEntries.Count - 1 do
          begin
            RequireMapping(lEntries[J], Format('%s.%s[%d]', [lPath, lKey, J]));
            lEntry := lEntries[J].AsMapping;
            ValidateFields(lEntry, Format('%s.%s[%d]', [lPath, lKey, J]), CEntryFields);
            if lEntry.ContainsKey('state') then
            begin
              RequireMapping(lEntry['state'], Format('%s.%s[%d].state', [lPath, lKey, J]));
              lState := lEntry['state'].AsMapping;
              ValidateState(lState, Format('%s.%s[%d].state', [lPath, lKey, J]));
            end;
            if Trim(MappingString(lEntry, 'url', '')) = '' then
              raise EDownloadFileError.CreateFmt('%s.%s[%d].url is required', [lPath, lKey, J]);
            MappingInt(lEntry, 'jobs', 1, 1);
            MappingInt(lEntry, 'request_interval_ms', 10000, 0);
            MappingInt(lEntry, 'delay_jitter_ms', 10000, 0);
            MappingInt(lEntry, 'sleep_requests_seconds', 3, 0);
            MappingInt(lEntry, 'sleep_subtitles_seconds', 5, 0);
            MappingInt(lEntry, 'socket_timeout_seconds', 60, 0);
            if MappingBool(lGroup, 'enabled', True) and MappingBool(lEntry, 'enabled', True) then
            begin
              lPath := lKey + '|' + NormalizeQueueUrl(lEntry.S['url']);
              if lSeen.ContainsKey(lPath) then
                raise EDownloadFileError.Create('Duplicate enabled entry: ' + lEntry.S['url']);
              lSeen.Add(lPath, True);
              lPath := Format('groups[%d]', [I]);
            end;
          end;
        end;
    end;
  finally
    lSeen.Free;
  end;
end;

function TDownloadFile.GetGroups: IYAMLSequence;
begin
  Result := FRoot['groups'].AsSequence;
end;

function TDownloadFile.ReadOptions(const aMapping: IYAMLMapping;
  const aBase: TDownloadOptions; const aCanReadAuth: Boolean): TDownloadOptions;
var
  lValue: IYAMLValue;
begin
  Result := aBase;
  Result.Language := MappingString(aMapping, 'language', Result.Language);
  Result.Jobs := MappingInt(aMapping, 'jobs', Result.Jobs, 1);
  Result.RequestIntervalMs := MappingInt(aMapping, 'request_interval_ms', Result.RequestIntervalMs, 0);
  Result.DelayJitterMs := MappingInt(aMapping, 'delay_jitter_ms', Result.DelayJitterMs, 0);
  Result.SleepRequestsSeconds := MappingInt(aMapping, 'sleep_requests_seconds', Result.SleepRequestsSeconds, 0);
  Result.SleepSubtitlesSeconds := MappingInt(aMapping, 'sleep_subtitles_seconds', Result.SleepSubtitlesSeconds, 0);
  Result.SocketTimeoutSeconds := MappingInt(aMapping, 'socket_timeout_seconds', Result.SocketTimeoutSeconds, 0);
  Result.IncludeShorts := MappingBool(aMapping, 'include_shorts', Result.IncludeShorts);
  Result.IncludeLive := MappingBool(aMapping, 'include_live', Result.IncludeLive);
  Result.OverwriteExisting := MappingBool(aMapping, 'overwrite_existing', Result.OverwriteExisting);
  Result.Metadata := MappingBool(aMapping, 'metadata', Result.Metadata);
  Result.Keywords := ReadKeywords(aMapping, Result.Keywords);
  if aMapping.TryGetValue('subfolder', lValue) then
    Result.Subfolder := lValue.AsString;
  if aCanReadAuth then
  begin
    Result.Cookies := MappingString(aMapping, 'cookies', Result.Cookies);
    Result.CookiesFromBrowser := MappingString(aMapping, 'cookies_from_browser', Result.CookiesFromBrowser);
  end;
end;

function TDownloadFile.Entries: TArray<TDownloadEntry>;
var
  I, J, lCount: Integer;
  lDefaults, lGroup, lEntry, lState: IYAMLMapping;
  lGroups, lItems: IYAMLSequence;
  lBase, lGroupOptions: TDownloadOptions;
  lEnabled: Boolean;
  lKey: string;
  lKind: TDownloadEntryKind;
begin
  lBase := Default(TDownloadOptions);
  lBase.Language := 'en';
  lBase.OutputDir := 'output';
  lBase.Jobs := 1;
  lBase.RequestIntervalMs := 10000;
  lBase.DelayJitterMs := 10000;
  lBase.SleepRequestsSeconds := 3;
  lBase.SleepSubtitlesSeconds := 5;
  lBase.SocketTimeoutSeconds := 60;
  lBase.Metadata := True;
  if FRoot.ContainsKey('defaults') then
  begin
    lDefaults := FRoot['defaults'].AsMapping;
    lBase := ReadOptions(lDefaults, lBase, True);
    lBase.OutputDir := MappingString(lDefaults, 'output_dir', lBase.OutputDir);
  end;
  if (lBase.Cookies <> '') and not TPath.IsPathRooted(lBase.Cookies) then
    lBase.Cookies := TPath.GetFullPath(TPath.Combine(TPath.GetDirectoryName(FFileName), lBase.Cookies));

  lGroups := GetGroups;
  lCount := 0;
  SetLength(Result, 0);
  for I := 0 to lGroups.Count - 1 do
  begin
    lGroup := lGroups[I].AsMapping;
    lEnabled := MappingBool(lGroup, 'enabled', True);
    lGroupOptions := ReadOptions(lGroup, lBase, False);
    for lKey in CEntrySequences do
      if lGroup.ContainsKey(lKey) then
      begin
        if lKey = 'channels' then lKind := dekChannel else lKind := dekVideo;
        lItems := lGroup[lKey].AsSequence;
        for J := 0 to lItems.Count - 1 do
        begin
          lEntry := lItems[J].AsMapping;
          SetLength(Result, lCount + 1);
          Result[lCount] := Default(TDownloadEntry);
          Result[lCount].Kind := lKind;
          Result[lCount].GroupIndex := I;
          Result[lCount].EntryIndex := J;
          Result[lCount].Url := lEntry.S['url'];
          Result[lCount].Name := MappingString(lEntry, 'name', '');
          Result[lCount].Enabled := lEnabled and MappingBool(lEntry, 'enabled', True);
          Result[lCount].Options := ReadOptions(lEntry, lGroupOptions, False);
          Result[lCount].Node := lEntry;
          if lEntry.ContainsKey('state') then
          begin
            lState := lEntry['state'].AsMapping;
            Result[lCount].StateStatus := LowerCase(MappingString(lState, 'status', ''));
          end;
          Inc(lCount);
        end;
      end;
  end;
end;

function TDownloadFile.GetOutputRoot: string;
var
  lOutput: string;
begin
  lOutput := 'output';
  if FRoot.ContainsKey('defaults') then
    lOutput := MappingString(FRoot['defaults'].AsMapping, 'output_dir', lOutput);
  if TPath.IsPathRooted(lOutput) then
    Result := TPath.GetFullPath(lOutput)
  else
    Result := TPath.GetFullPath(TPath.Combine(TPath.GetDirectoryName(FFileName), lOutput));
end;

function TDownloadFile.IsEligible(const aEntry: TDownloadEntry): Boolean;
var
  lFailed: Boolean;
begin
  if not aEntry.Enabled then
    Exit(False);
  lFailed := MatchText(aEntry.StateStatus,
    ['failed', 'unavailable', 'throttled', 'completed_with_errors']);
  case FMode of
    dmFresh:
      if aEntry.Kind = dekChannel then
        Result := not MatchText(aEntry.StateStatus, ['failed', 'throttled'])
      else
        Result := not lFailed;
    dmFailed:
      Result := lFailed;
    dmThrottled:
      Result := SameText(aEntry.StateStatus, 'throttled') or
        (SameText(aEntry.StateStatus, 'running') and
         (SavedThrottleLevel > 0));
    dmAll:
      Result := True;
  else
    Result := False;
  end;
end;

function TDownloadFile.ThrottleCooldownRemainingMs(
  const aNowUtc: TDateTime): Int64;
var
  lRetryAtUtc: TDateTime;
  lState: IYAMLMapping;
begin
  Result := 0;
  if not FRoot.ContainsKey('state') then
    Exit;
  lState := FRoot['state'].AsMapping;
  if not lState.ContainsKey('throttle_retry_after_utc') then
    Exit;
  if not TryISO8601ToDate(
    Trim(lState.S['throttle_retry_after_utc']), lRetryAtUtc, True) then
    Exit;
  if lRetryAtUtc <= aNowUtc then
    Exit;
  Result := MilliSecondsBetween(lRetryAtUtc, aNowUtc);
end;

function TDownloadFile.SavedThrottleLevel: Integer;
begin
  Result := 0;
  if FRoot.ContainsKey('state') then
    Result := MappingInt(FRoot['state'].AsMapping, 'throttle_level', 0, 0);
end;

function TDownloadFile.SavedThrottleSuccessCount: Integer;
begin
  Result := 0;
  if FRoot.ContainsKey('state') then
    Result := MappingInt(FRoot['state'].AsMapping,
      'throttle_success_count', 0, 0);
end;

procedure TDownloadFile.SetMode(const aValue: TDownloadMode);
begin
  FMode := aValue;
  FRoot.AddOrSetValue('mode', DownloadModeToString(aValue));
end;

procedure TDownloadFile.RemoveStandaloneVideo(const aGroupIndex,
  aVideoIndex: Integer);
var
  I: Integer;
  lGroup: IYAMLMapping;
  lVideos: IYAMLSequence;
  lRetained: TArray<IYAMLValue>;
  lComments: TStringList;
begin
  lGroup := GetGroups[aGroupIndex].AsMapping;
  if not lGroup.ContainsKey('videos') then
    raise EDownloadFileError.Create('Group has no videos sequence');
  lVideos := lGroup['videos'].AsSequence;
  if (aVideoIndex < 0) or (aVideoIndex >= lVideos.Count) then
    raise EDownloadFileError.Create('Video index is out of range');
  SetLength(lRetained, lVideos.Count - 1);
  for I := 0 to aVideoIndex - 1 do
    lRetained[I] := lVideos[I];
  for I := aVideoIndex + 1 to lVideos.Count - 1 do
    lRetained[I - 1] := lVideos[I];
  lComments := TStringList.Create;
  try
    lComments.Assign(lVideos.Comments);
    lVideos.Clear;
    lVideos.Comments := lComments;
    for I := 0 to High(lRetained) do
      lVideos.AddValue(lRetained[I]);
  finally
    lComments.Free;
  end;
end;

procedure TDownloadFile.RemoveStandaloneVideoByUrl(const aGroupIndex: Integer;
  const aUrl: string);
var
  I: Integer;
  lGroup: IYAMLMapping;
  lVideos: IYAMLSequence;
begin
  lGroup := GetGroups[aGroupIndex].AsMapping;
  if not lGroup.ContainsKey('videos') then
    raise EDownloadFileError.Create('Group has no videos sequence');
  lVideos := lGroup['videos'].AsSequence;
  for I := 0 to lVideos.Count - 1 do
    if SameText(NormalizeQueueUrl(lVideos[I].AsMapping.S['url']),
      NormalizeQueueUrl(aUrl)) then
    begin
      RemoveStandaloneVideo(aGroupIndex, I);
      Exit;
    end;
  raise EDownloadFileError.Create('Standalone video no longer exists in the queue: ' + aUrl);
end;

function TDownloadFile.ToYaml: string;
begin
  Result := TYAML.WriteToString(FDocument);
end;

procedure TDownloadFile.Checkpoint;
var
  lCurrent, lText, lTemp, lBackup: string;
  lStream: TFileStream;
begin
  if not FOwnsFile then
    Exit;
  lCurrent := TFile.ReadAllText(FFileName, TEncoding.UTF8);
  if HashText(lCurrent) <> FSourceHash then
    raise EDownloadFileError.Create('Download file changed outside yttrans; refusing to overwrite it');
  lText := ToYaml;
  lTemp := FFileName + '.tmp';
  lBackup := FFileName + '.bak';
  TFile.WriteAllText(lTemp, lText, TEncoding.UTF8);
  lStream := TFileStream.Create(lTemp, fmOpenReadWrite or fmShareExclusive);
  try
    if not FlushFileBuffers(lStream.Handle) then
      RaiseLastOSError;
  finally
    lStream.Free;
  end;
  if not CopyFile(PChar(FFileName), PChar(lBackup), False) then
    RaiseLastOSError;
  if not MoveFileEx(PChar(lTemp), PChar(FFileName),
    MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then
    RaiseLastOSError;
  FSourceHash := HashText(lText);
end;

end.
