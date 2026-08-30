unit YTTransApp;

interface

uses
  System.SysUtils, System.Classes;

type
  TMetaOptions = record
    Url         : Boolean;
    Title       : Boolean;
    Channel     : Boolean;
    Created     : Boolean;
    Keywords    : Boolean;
    VideoId     : Boolean;
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
    Jobs: Integer;
    OverrideExisting: Boolean;
    ChannelOutputRoot: String;
    IncludeShorts: Boolean;
    IncludeLive: Boolean;
    CookiesFile: String;
    CookiesFromBrowser: String;
    CookiesFileExplicit: Boolean;
    CookiesFromBrowserExplicit: Boolean;
    DelayJitterMs: Integer;
    RetryUnavailable: Boolean;
  end;

  TTranscriptMetadata = record
    Url    : String;
    Title  : String;
    Channel: String;
    Created: String;
    VideoId: String;
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

  TTranscriptService = class
  private
    function ParseSrtContent(const aSrtContent: string): string;
    function CaptureYtDlpOutput(const aArguments: string; out aOutput, aError: string): Integer;
    function ExtractJsonFromOutput(const aOutput: string): string;
  public
    function FetchTranscript(const aUrl, aLanguage, aYtDlpExtraArgs: string): TTranscriptResult;
    function FetchMetadata(const aUrl, aYtDlpExtraArgs: string): TTranscriptMetadata;
    function ListChannelVideoUrls(const aListUrl, aYtDlpExtraArgs: string): TArray<string>;
  end;

function ParseCommandLine: TCommandLineConfig;
function Run: Integer;
function IsYouTubeVideoUrl(const aUrl: string): Boolean;


implementation

uses
  System.IOUtils, System.IniFiles, System.JSON, System.StrUtils, System.DateUtils,
  System.SyncObjs, System.Threading, System.Generics.Collections, Winapi.Windows,
  autoFree, MaxLogic.ioUtils, YTTrans.DownloadFile, YTTrans.Throttle, VSoft.YAML;

resourcestring
  RSUsage =
    'YouTrans v1.0' + sLineBreak +
    'Usage: youtrans <URL> -l <lang> [options]' + sLineBreak +
    'Downloads transcript(s) using yt-dlp. Video mode is default; channel mode is optional.' + sLineBreak +
    sLineBreak +
    'Arguments:' + sLineBreak +
    '  <URL>                   The full URL of the YouTube video.' + sLineBreak +
    '  -f, --file <yaml>       Process one mutable YAML download queue.' + sLineBreak +
    sLineBreak +
    'Options:' + sLineBreak +
    '  -l, --lang <lang_code>  Language code for subtitles (e.g., "en", "pl"). default is "en".' + sLineBreak +
    '  -o, --output <path>     Video mode: output file path/dir. Channel mode: root output directory.' + sLineBreak +
    '  -p, --prefix <text>     Prefix text for auto-generated file names.' + sLineBreak +
    '  -meta, --meta           Prepend YouTube metadata before the transcript output.' + sLineBreak +
    '  -keywords <list>         Comma-separated keywords added to metadata. Implies -meta.' + sLineBreak +
    '  -c, --channel           Download all videos from the channel owning <URL>.' + sLineBreak +
    '  -j, --jobs <n>          Parallel workers in channel mode. Default: 1.' + sLineBreak +
    '  -ov, --override         In channel mode, overwrite existing file with the same video_id.' + sLineBreak +
    '  -co, --channel-output <dir>  Root output directory override for channel mode.' + sLineBreak +
    '  -is, --include-shorts   In channel mode, include Shorts tab.' + sLineBreak +
    '  -il, --include-live     In channel mode, include Live/Streams tab.' + sLineBreak +
    '  --cookies <file>        Pass yt-dlp cookies file for authenticated requests.' + sLineBreak +
    '  --cookies-from-browser <browser>  Load cookies from browser profile (yt-dlp syntax).' + sLineBreak +
    '                            Defaults can be set in settings.ini [default] cookies_file/cookies_from_browser.' + sLineBreak +
    '  -dj, --delay-jitter-ms <n>  Max per-item jitter delay in ms for channel mode pacing.' + sLineBreak +
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
  CThrottleRetryDelaysMs: array[1..3] of Integer = (30000, 120000, 300000);
  CMaxThrottleCooldownMs = 300000;
  CDefaultDelayJitterMs = 1200;
  CDefaultChannelJobsCap = 1;

type
  TChannelConflictAction = (ccaWriteNew, ccaOverwrite, ccaSkip);

  TChannelRunStats = record
    Downloaded: Integer;
    Overwritten: Integer;
    Skipped: Integer;
    Unavailable: Integer;
    UnavailableCached: Integer;
    Failed: Integer;
  end;

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

  EMissingTranscriptError = class(EFileNotFoundException)
  private
    FMetadata: TTranscriptMetadata;
  public
    constructor Create(const aMessage: string; const aMetadata: TTranscriptMetadata);
    property Metadata: TTranscriptMetadata read FMetadata;
  end;

var
  GThrottleController: TThrottleController;

constructor EMissingTranscriptError.Create(
  const aMessage: string;
  const aMetadata: TTranscriptMetadata);
begin
  inherited Create(aMessage);
  FMetadata := aMetadata;
end;

function GetThrottleRetryDelayMs(const aAttempt: Integer): Integer;
var
  lIndex: Integer;
begin
  lIndex := aAttempt;
  if lIndex < Low(CThrottleRetryDelaysMs) then
    lIndex := Low(CThrottleRetryDelaysMs)
  else if lIndex > High(CThrottleRetryDelaysMs) then
    lIndex := High(CThrottleRetryDelaysMs);
  Result := CThrottleRetryDelaysMs[lIndex];
  if Result > CMaxThrottleCooldownMs then
    Result := CMaxThrottleCooldownMs;
end;

function UtcNowIso: string;
begin
  Result := DateToISO8601(TTimeZone.Local.ToUniversalTime(Now), True);
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

procedure SaveUnavailableVideos(
  const aChannelDir: string;
  const aVideos: TUnavailableVideoMap);
var
  lManifestPath: string;
  lTempPath: string;
  lRoot: TJSONObject;
  lArray: TJSONArray;
  lItem: TJSONObject;
  lKeys: TStringList;
  lEntry: TUnavailableVideo;
begin
  lManifestPath := GetUnavailableManifestPath(aChannelDir);
  lTempPath := lManifestPath + '.' + TPath.GetGUIDFileName + '.tmp';
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

    TFile.WriteAllText(lTempPath, lRoot.Format(2), TEncoding.UTF8);
    if not MoveFileEx(
      PChar(lTempPath),
      PChar(lManifestPath),
      MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH
    ) then
      RaiseLastOSError;
  finally
    if TFile.Exists(lTempPath) then
      TFile.Delete(lTempPath);
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

procedure AppendMetaLine(const aEnabled: Boolean; const aKey, aValue: string; const aBuilder: TStringBuilder);
begin
  if aEnabled and (Trim(aValue) <> '') then
    aBuilder.AppendLine(aKey + ': ' + aValue);
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
      lBuilder.AppendLine('keywords: ' + aKeywords.Trim);

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

function GetDefaultJobCount: Integer;
begin
  Result := TThread.ProcessorCount;
  if Result < 1 then
    Result := 1;
  if Result > CDefaultChannelJobsCap then
    Result := CDefaultChannelJobsCap;
end;

function BuildYtDlpAuthArguments(const aConfig: TCommandLineConfig): string;
var
  lCookieFile: string;
begin
  Result := '';

  lCookieFile := Trim(aConfig.CookiesFile);
  if lCookieFile <> '' then
  begin
    lCookieFile := TPath.GetFullPath(lCookieFile);
    Result := Result + Format(' --cookies "%s"', [lCookieFile]);
  end;

  if Trim(aConfig.CookiesFromBrowser) <> '' then
    Result := Result + Format(' --cookies-from-browser "%s"', [Trim(aConfig.CookiesFromBrowser)]);
end;

function ShouldRetryWithoutDefaultAuth(const aConfig: TCommandLineConfig): Boolean;
begin
  Result := ((Trim(aConfig.CookiesFile) <> '') or (Trim(aConfig.CookiesFromBrowser) <> '')) and
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

function NormalizeErrorMessage(const aMessage: string): string;
begin
  Result := StringReplace(Trim(aMessage), #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [rfReplaceAll]);
  if Length(Result) > 2048 then
    SetLength(Result, 2048);
end;

function ClassifyError(const aMessage: string): string;
var
  lText: string;
begin
  lText := LowerCase(aMessage);
  if IsMissingSubtitleError(aMessage) then
    Exit('unavailable');
  if IsThrottleError(aMessage) then
    Exit('throttled');
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

function ReadFrontMatterValue(const aFilePath, aKey: string): string;
var
  lText: string;
  lLines: TStringList;
  lLine: string;
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
      lLine := Trim(lLines[lIndex]);
      if lLine = '---' then
        Break;
      lPos := Pos(':', lLine);
      if lPos <= 1 then
        Continue;
      if SameText(Trim(Copy(lLine, 1, lPos - 1)), aKey) then
        Exit(Trim(Copy(lLine, lPos + 1, MaxInt)));
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

  try
    Result := aService.FetchTranscript(aUrl, lRequested, aYtDlpExtraArgs);
    Exit;
  except
    on E: Exception do
    begin
      if SameText(lRequested, CDefaultLanguage) or (not IsMissingSubtitleError(E.Message)) then
        raise;
    end;
  end;

  Result := aService.FetchTranscript(aUrl, CDefaultLanguage, aYtDlpExtraArgs);
end;

function BuildChannelVideoQueue(
  const aService: TTranscriptService;
  const aSeedMeta: TTranscriptMetadata;
  const aConfig: TCommandLineConfig;
  const aYtDlpExtraArgs: string): TArray<string>;
var
  lUrls: TList<string>;
  lSeen: TDictionary<string, Byte>;
  lSource: string;
  lFoundUrls: TArray<string>;

  procedure AddUrl(const aRawUrl: string);
  var
    lUrl: string;
    lKey: string;
  begin
    lUrl := NormalizeVideoUrl(aRawUrl);
    if lUrl = '' then
      Exit;
    lKey := ExtractVideoIdFromUrl(lUrl);
    if lKey = '' then
      lKey := lUrl.ToLower;
    if lSeen.ContainsKey(lKey) then
      Exit;
    lSeen.Add(lKey, 1);
    lUrls.Add(lUrl);
  end;

begin
  lUrls := TList<string>.Create;
  lSeen := TDictionary<string, Byte>.Create;
  try
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
        lFoundUrls := aService.ListChannelVideoUrls(lSource, aYtDlpExtraArgs);
        for var lUrl in lFoundUrls do
          AddUrl(lUrl);
      except
        on E: Exception do
          WriteLn(Format('Warning: could not list uploads/videos: %s', [E.Message]));
      end;
    end;

    lSource := BuildChannelBaseUrl(aSeedMeta);
    if aConfig.IncludeShorts and (lSource <> '') then
    begin
      try
        lFoundUrls := aService.ListChannelVideoUrls(lSource + '/shorts', aYtDlpExtraArgs);
        for var lUrl in lFoundUrls do
          AddUrl(lUrl);
      except
        on E: Exception do
          WriteLn(Format('Warning: could not list shorts tab: %s', [E.Message]));
      end;
    end;

    if aConfig.IncludeLive and (lSource <> '') then
    begin
      try
        lFoundUrls := aService.ListChannelVideoUrls(lSource + '/streams', aYtDlpExtraArgs);
        for var lUrl in lFoundUrls do
          AddUrl(lUrl);
      except
        on E: Exception do
          WriteLn(Format('Warning: could not list live tab: %s', [E.Message]));
      end;
    end;

    Result := lUrls.ToArray;
  finally
    lSeen.Free;
    lUrls.Free;
  end;
end;

function RunChannelMode(const aConfig: TCommandLineConfig;
  out aStats: TChannelRunStats): Integer;
var
  lSetupService: TTranscriptService;
  lSeedMeta: TTranscriptMetadata;
  lVideoUrls: TArray<string>;
  lChannelDir: string;
  lStats: TChannelRunStats;
  lEffectiveMetaOptions: TMetaOptions;
  lFileLock: TCriticalSection;
  lLogLock: TCriticalSection;
  lNextIndex: Integer;
  lCooldownUntil: Int64;
  lWorkerTasks: TArray<ITask>;
  lWorkerCount: Integer;
  lYtDlpExtraArgs: string;
  lActiveWorkers: Integer;
  lWorkerLimit: Integer;
  lStopScheduling: Integer;
  lExistingVideoIds: TDictionary<string, Byte>;
  lUnavailableVideos: TUnavailableVideoMap;
  lUnavailableManifestChanged: Boolean;
  lProcessedCount: Integer;
  lDeferredCount: Integer;
begin
  Result := 1;
  aStats := Default(TChannelRunStats);

  lYtDlpExtraArgs := BuildYtDlpAuthArguments(aConfig);
  gc(lSetupService, TTranscriptService.Create);
  try
    lSeedMeta := lSetupService.FetchMetadata(aConfig.URL, lYtDlpExtraArgs);
  except
    on Exception do
    begin
      if ShouldRetryWithoutDefaultAuth(aConfig) and (Trim(lYtDlpExtraArgs) <> '') then
      begin
        WriteLn('Warning: default cookie auth failed; retrying without cookies.');
        lYtDlpExtraArgs := '';
        lSeedMeta := lSetupService.FetchMetadata(aConfig.URL, lYtDlpExtraArgs);
      end
      else
        raise;
    end;
  end;
  lVideoUrls := BuildChannelVideoQueue(lSetupService, lSeedMeta, aConfig, lYtDlpExtraArgs);
  if Length(lVideoUrls) = 0 then
    raise Exception.Create('Channel mode could not find any videos to process.');

  lChannelDir := BuildChannelOutputDir(aConfig, lSeedMeta);
  TDirectory.CreateDirectory(lChannelDir);

  lExistingVideoIds := nil;
  lUnavailableVideos := nil;
  lFileLock := nil;
  lLogLock := nil;
  try
    lExistingVideoIds := TDictionary<string, Byte>.Create;
    lUnavailableVideos := LoadUnavailableVideos(lChannelDir);
    lUnavailableManifestChanged := False;
    for var lExistingFile in TDirectory.GetFiles(lChannelDir, '*.md', TSearchOption.soTopDirectoryOnly) do
    begin
      var lExistingVideoId := Trim(ReadFrontMatterValue(lExistingFile, 'video_id')).ToLower;
      if (lExistingVideoId <> '') and (not lExistingVideoIds.ContainsKey(lExistingVideoId)) then
        lExistingVideoIds.Add(lExistingVideoId, 1);
      if (lExistingVideoId <> '') and lUnavailableVideos.ContainsKey(lExistingVideoId) then
      begin
        lUnavailableVideos.Remove(lExistingVideoId);
        lUnavailableManifestChanged := True;
      end;
    end;
    if lUnavailableManifestChanged then
      SaveUnavailableVideos(lChannelDir, lUnavailableVideos);

    lEffectiveMetaOptions := aConfig.MetaOptions;
    lEffectiveMetaOptions.Channel := True;
    lEffectiveMetaOptions.VideoId := True;
    lEffectiveMetaOptions.ChannelId := True;

    lFileLock := TCriticalSection.Create;
    lLogLock := TCriticalSection.Create;
    lNextIndex := -1;
    lCooldownUntil := 0;
    lStats := Default(TChannelRunStats);
    lActiveWorkers := 0;
    lStopScheduling := 0;

    lWorkerCount := aConfig.Jobs;
    if lWorkerCount < 1 then
      lWorkerCount := GetDefaultJobCount;
    if lWorkerCount > Length(lVideoUrls) then
      lWorkerCount := Length(lVideoUrls);
    if lWorkerCount < 1 then
      lWorkerCount := 1;
    lWorkerLimit := lWorkerCount;
    WriteLn(Format('Workers configured: %d', [lWorkerCount]));

    SetLength(lWorkerTasks, lWorkerCount);
    for var lWorkerIdx := 0 to lWorkerCount - 1 do
    begin
      lWorkerTasks[lWorkerIdx] := TTask.Run(
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
          lWaitUntil: Int64;
          lNow: Int64;
          lObserved: Int64;
          lFailedMessage: string;
          lActiveSnapshot: Integer;
          lLimitSnapshot: Integer;
          lJitterMs: Integer;
          lUnavailable: Boolean;
          lVideoId: string;
          lAlreadyExists: Boolean;
          lCachedUnavailable: Boolean;
          lUnavailableMeta: TTranscriptMetadata;
          lUnavailableEntry: TUnavailableVideo;
          lIsThrottle: Boolean;
        begin
          Sleep(lWorkerIdx * 150);
          lService := TTranscriptService.Create;
          try
            while True do
            begin
              if TInterlocked.Add(lStopScheduling, 0) <> 0 then
                Break;
              lIndex := TInterlocked.Increment(lNextIndex);
              if lIndex >= Length(lVideoUrls) then
                Break;

              if not aConfig.OverrideExisting then
              begin
                lVideoId := ExtractVideoIdFromUrl(lVideoUrls[lIndex]).ToLower;
                lFileLock.Enter;
                try
                  lAlreadyExists := (lVideoId <> '') and lExistingVideoIds.ContainsKey(lVideoId);
                finally
                  lFileLock.Leave;
                end;
                if lAlreadyExists then
                begin
                  TInterlocked.Increment(lStats.Skipped);
                  Continue;
                end;
              end;

              if not aConfig.RetryUnavailable then
              begin
                lVideoId := ExtractVideoIdFromUrl(lVideoUrls[lIndex]).ToLower;
                lFileLock.Enter;
                try
                  lCachedUnavailable := (lVideoId <> '') and lUnavailableVideos.ContainsKey(lVideoId);
                finally
                  lFileLock.Leave;
                end;
                if lCachedUnavailable then
                begin
                  TInterlocked.Increment(lStats.UnavailableCached);
                  Continue;
                end;
              end;

              while True do
              begin
                lLimitSnapshot := TInterlocked.Add(lWorkerLimit, 0);
                lActiveSnapshot := TInterlocked.Add(lActiveWorkers, 0);
                if lActiveSnapshot < lLimitSnapshot then
                begin
                  if TInterlocked.CompareExchange(lActiveWorkers, lActiveSnapshot + 1, lActiveSnapshot) = lActiveSnapshot then
                    Break;
                end;
                Sleep(70);
              end;

              try
                lFailedMessage := '';
                lUnavailable := False;
                lUnavailableMeta := Default(TTranscriptMetadata);
                for lAttempt := 1 to CRetryAttempts do
                begin
                  lDelayMs := 0;
                  while True do
                  begin
                    lWaitUntil := TInterlocked.Read(lCooldownUntil);
                    lNow := TThread.GetTickCount64;
                    if lNow >= lWaitUntil then
                      Break;
                    Sleep(150);
                  end;

                  lJitterMs := 0;
                  if aConfig.DelayJitterMs > 0 then
                    lJitterMs := Integer(
                      (UInt64(lIndex + 1) * 1103515245 + UInt64(lAttempt * 12345) + UInt64((lWorkerIdx + 1) * 73)) mod
                      UInt64(aConfig.DelayJitterMs + 1)
                    );
                  if lJitterMs > 0 then
                    Sleep(lJitterMs);

                  try
                    lResult := FetchTranscriptWithFallback(lService, lVideoUrls[lIndex], aConfig.Language, lYtDlpExtraArgs);
                    lOutputText := BuildMetaSection(lResult.Meta, aConfig.Keywords, lEffectiveMetaOptions) + lResult.Transcript;

                    lFileLock.Enter;
                    try
                      ResolveChannelFilePath(lChannelDir, lResult.Meta, aConfig.OverrideExisting, lOutputPath, lAction);
                      if lAction = ccaSkip then
                        TInterlocked.Increment(lStats.Skipped)
                      else
                      begin
                        TFile.WriteAllText(lOutputPath, lOutputText, TEncoding.UTF8);
                        if lAction = ccaOverwrite then
                          TInterlocked.Increment(lStats.Overwritten)
                        else
                          TInterlocked.Increment(lStats.Downloaded);
                      end;
                      lVideoId := Trim(lResult.Meta.VideoId).ToLower;
                      if (lVideoId <> '') and lUnavailableVideos.ContainsKey(lVideoId) then
                      begin
                        lUnavailableVideos.Remove(lVideoId);
                        SaveUnavailableVideos(lChannelDir, lUnavailableVideos);
                      end;
                    finally
                      lFileLock.Leave;
                    end;

                    lFailedMessage := '';
                    Break;
                  except
                    on E: Exception do
                    begin
                      lFailedMessage := E.Message;
                      if IsMissingSubtitleError(lFailedMessage) then
                      begin
                        lUnavailable := True;
                        if E is EMissingTranscriptError then
                          lUnavailableMeta := EMissingTranscriptError(E).Metadata;
                        Break;
                      end;
                      lIsThrottle := IsThrottleError(lFailedMessage);
                      if lIsThrottle then
                      begin
                        if lAttempt = CRetryAttempts then
                        begin
                          if TInterlocked.CompareExchange(lStopScheduling, 1, 0) = 0 then
                          begin
                            lLogLock.Enter;
                            try
                              WriteLn(Format(
                                'Warning: throttling persisted after %d attempts; stopping this channel with remaining videos deferred.',
                                [CRetryAttempts]
                              ));
                            finally
                              lLogLock.Leave;
                            end;
                          end;
                          Break;
                        end;

                        lDelayMs := GetThrottleRetryDelayMs(lAttempt);
                        lDelayMs := lDelayMs + ((lIndex + lAttempt * 997) mod 5001);

                        lNow := TThread.GetTickCount64;
                        lWaitUntil := lNow + lDelayMs;
                        repeat
                          lObserved := TInterlocked.Read(lCooldownUntil);
                          if lObserved >= lWaitUntil then
                            Break;
                        until TInterlocked.CompareExchange(lCooldownUntil, lWaitUntil, lObserved) = lObserved;

                        lLimitSnapshot := TInterlocked.Exchange(lWorkerLimit, 1);
                        if lLimitSnapshot > 1 then
                        begin
                          lLogLock.Enter;
                          try
                            WriteLn('Warning: throttling detected, reducing active workers to 1');
                          finally
                            lLogLock.Leave;
                          end;
                        end;
                      end;
                      if not lIsThrottle then
                      begin
                        if lAttempt = CRetryAttempts then
                          Break;
                        lDelayMs := CRetryBaseDelayMs * (1 shl (lAttempt - 1));
                        lDelayMs := lDelayMs + ((lIndex + lAttempt * 53) mod 350);
                      end;
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
                      lUnavailableEntry.VideoId := ExtractVideoIdFromUrl(lVideoUrls[lIndex]);
                    lUnavailableEntry.Url := lVideoUrls[lIndex];
                    lUnavailableEntry.Title := lUnavailableMeta.Title;
                    lUnavailableEntry.PublishedAt := lUnavailableMeta.PublishedAt;
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
                    end;
                  end
                  else
                  begin
                    TInterlocked.Increment(lStats.Failed);
                    lUnavailableEntry := Default(TUnavailableVideo);
                    lUnavailableEntry.VideoId := ExtractVideoIdFromUrl(lVideoUrls[lIndex]);
                    lUnavailableEntry.Url := lVideoUrls[lIndex];
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
                        WriteLn(Format('Unavailable: no transcript for %s', [lVideoUrls[lIndex]]))
                      else
                        WriteLn(Format('Warning: failed to process %s (%s)', [lVideoUrls[lIndex], lFailedMessage]));
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
              finally
                TInterlocked.Decrement(lActiveWorkers);
              end;
            end;
          finally
            lService.Free;
          end;
        end
      );
    end;

    TTask.WaitForAll(lWorkerTasks);
  finally
    lFileLock.Free;
    lLogLock.Free;
    lExistingVideoIds.Free;
    lUnavailableVideos.Free;
  end;

  WriteLn('Channel download completed.');
  WriteLn('Channel: ' + lSeedMeta.Channel);
  WriteLn('Output: ' + lChannelDir);
  WriteLn(Format('Workers configured: %d', [lWorkerCount]));
  WriteLn(Format('Workers final limit: %d', [TInterlocked.Add(lWorkerLimit, 0)]));
  lProcessedCount := lStats.Downloaded + lStats.Overwritten + lStats.Skipped +
    lStats.Unavailable + lStats.UnavailableCached + lStats.Failed;
  lDeferredCount := Length(lVideoUrls) - lProcessedCount;
  if lDeferredCount < 0 then
    lDeferredCount := 0;
  WriteLn(Format('Queued: %d', [Length(lVideoUrls)]));
  WriteLn(Format('Processed: %d', [lProcessedCount]));
  WriteLn(Format('Deferred: %d', [lDeferredCount]));
  WriteLn(Format('Downloaded: %d', [lStats.Downloaded]));
  WriteLn(Format('Overwritten: %d', [lStats.Overwritten]));
  WriteLn(Format('Skipped: %d', [lStats.Skipped]));
  WriteLn(Format('Unavailable: %d', [lStats.Unavailable]));
  WriteLn(Format('Unavailable cached: %d', [lStats.UnavailableCached]));
  WriteLn(Format('Failed: %d', [lStats.Failed]));

  aStats := lStats;
  if aConfig.FileMode and (TInterlocked.Add(lStopScheduling, 0) <> 0) then
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
  gc(lService, TTranscriptService.Create);
  try
    lTranscript := lService.FetchTranscript(aConfig.URL, aConfig.Language, lYtDlpExtraArgs);
  except
    on E: Exception do
    begin
      if E is EMissingTranscriptError then
        aMeta := EMissingTranscriptError(E).Metadata;
      if ShouldRetryWithoutDefaultAuth(aConfig) and (Trim(lYtDlpExtraArgs) <> '') then
      begin
        WriteLn('Warning: default cookie auth failed; retrying without cookies.');
        lYtDlpExtraArgs := '';
        lTranscript := lService.FetchTranscript(aConfig.URL, aConfig.Language, lYtDlpExtraArgs);
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
    TFile.WriteAllText(aOutputPath, lOutputText, TEncoding.UTF8);
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
        if IsMissingSubtitleError(E.Message) or (lAttempt = CRetryAttempts) then
          raise;
        if IsThrottleError(E.Message) then
        begin
          if Assigned(GThrottleController) and GThrottleController.IsTerminal then
            raise;
          WriteLn(Format('Warning: YouTube throttled the request; shared cooldown before retry %d.',
            [lAttempt + 1]));
          Continue;
        end;
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

procedure ApplyEntryConfig(var aConfig: TCommandLineConfig;
  const aJob: TDownloadFile; const aEntry: TDownloadEntry);
begin
  aConfig.URL := aEntry.Url;
  aConfig.FileMode := True;
  aConfig.ChannelMode := aEntry.Kind = dekChannel;
  aConfig.Language := aEntry.Options.Language;
  aConfig.Jobs := aEntry.Options.Jobs;
  aConfig.DelayJitterMs := aEntry.Options.DelayJitterMs;
  aConfig.IncludeShorts := aEntry.Options.IncludeShorts;
  aConfig.IncludeLive := aEntry.Options.IncludeLive;
  aConfig.OverrideExisting := aEntry.Options.OverwriteExisting;
  aConfig.IncludeMeta := aEntry.Options.Metadata;
  aConfig.Keywords := aEntry.Options.Keywords;
  aConfig.OutputTarget := '';
  aConfig.OutputDir := CombineOutputFolder(aJob.OutputRoot, aEntry.Options.Subfolder);
  aConfig.ChannelOutputRoot := aConfig.OutputDir;
  if Trim(aEntry.Options.Cookies) <> '' then
  begin
    aConfig.CookiesFile := aEntry.Options.Cookies;
    aConfig.CookiesFromBrowser := '';
  end;
  if Trim(aEntry.Options.CookiesFromBrowser) <> '' then
  begin
    aConfig.CookiesFromBrowser := aEntry.Options.CookiesFromBrowser;
    aConfig.CookiesFile := '';
  end;
  aConfig.RetryUnavailable := aJob.Mode <> dmFresh;
  aConfig.MetaOptions.VideoId := True;
end;

function EnsureState(const aOwner: IYAMLMapping): IYAMLMapping;
begin
  if aOwner.ContainsKey('state') then
    Result := aOwner['state'].AsMapping
  else
    Result := aOwner.AddOrSetMapping('state');
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
  lState: IYAMLMapping;
begin
  lState := EnsureState(aEntry.Node);
  if (aStats.Failed > 0) or (aStats.Unavailable > 0) or
     (aStats.UnavailableCached > 0) then
    lState.AddOrSetValue('status', 'completed_with_errors')
  else
    lState.AddOrSetValue('status', 'completed');
  lState.AddOrSetValue('last_attempt_utc', UtcNowIso);
  lState.AddOrSetValue('last_success_utc', UtcNowIso);
  lState.AddOrSetValue('downloaded', aStats.Downloaded);
  lState.AddOrSetValue('overwritten', aStats.Overwritten);
  lState.AddOrSetValue('skipped', aStats.Skipped);
  lState.AddOrSetValue('unavailable', aStats.Unavailable);
  lState.AddOrSetValue('unavailable_cached', aStats.UnavailableCached);
  lState.AddOrSetValue('failed', aStats.Failed);
  lState.AddOrSetValue('error_kind', '');
  lState.AddOrSetValue('error', '');
end;

procedure UpdateJobState(const aJob: TDownloadFile; const aStatus: string;
  const aStartedUtc: string; const aProcessed, aEligibilitySkipped,
  aFailed, aDeferred: Integer; const aTerminal: Boolean);
var
  lState: IYAMLMapping;
begin
  lState := EnsureState(aJob.Root);
  lState.AddOrSetValue('status', aStatus);
  lState.AddOrSetValue('last_run_started_utc', aStartedUtc);
  lState.AddOrSetValue('last_checkpoint_utc', UtcNowIso);
  if aTerminal then
    lState.AddOrSetValue('last_run_completed_utc', UtcNowIso);
  lState.AddOrSetValue('processed', aProcessed);
  lState.AddOrSetValue('eligibility_skipped', aEligibilitySkipped);
  lState.AddOrSetValue('failed', aFailed);
  lState.AddOrSetValue('deferred', aDeferred);
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
  for var lCandidate in TDirectory.GetFiles(aOutputDir, '*.md',
    TSearchOption.soTopDirectoryOnly) do
    if SameText(Trim(ReadFrontMatterValue(lCandidate, 'video_id')), lVideoId) then
    begin
      aFileName := lCandidate;
      Exit(True);
    end;
end;

function RunDownloadFile(const aFileName: string): Integer;
var
  lJob: TDownloadFile;
  lEntries: TArray<TDownloadEntry>;
  lEntry: TDownloadEntry;
  lConfig: TCommandLineConfig;
  lMeta: TTranscriptMetadata;
  lOutputPath, lStartedUtc, lStatus: string;
  lStats: TChannelRunStats;
  lProcessed, lSkipped, lFailed, lDeferred, lChannelResult: Integer;
begin
  Result := 1;
  lJob := TDownloadFile.Open(aFileName);
  try
    TryAutoUpdateYtDlp;
    GThrottleController := TThrottleController.Create(1);
    try
      lStartedUtc := UtcNowIso;
      lProcessed := 0;
      lSkipped := 0;
      lFailed := 0;
      lDeferred := 0;
      UpdateJobState(lJob, 'running', lStartedUtc, 0, 0, 0, 0, False);
      lJob.Checkpoint;
      lEntries := lJob.Entries;
      for lEntry in lEntries do
      begin
        if not lJob.IsEligible(lEntry) then
        begin
          Inc(lSkipped);
          Continue;
        end;
        lConfig := Default(TCommandLineConfig);
        LoadDefaultOptions(lConfig);
        ApplyEntryConfig(lConfig, lJob, lEntry);
        if (lEntry.Kind = dekVideo) and
           FindExistingStandaloneOutput(lConfig.OutputDir, lEntry.Url, lOutputPath) then
        begin
          WriteLn('Already downloaded; removing queue entry: ' + lEntry.Url);
          lJob.RemoveStandaloneVideoByUrl(lEntry.GroupIndex, lEntry.Url);
          Inc(lProcessed);
          UpdateJobState(lJob, 'running', lStartedUtc, lProcessed, lSkipped,
            lFailed, lDeferred, False);
          lJob.Checkpoint;
          Continue;
        end;
        MarkEntryAttempt(lEntry);
        UpdateJobState(lJob, 'running', lStartedUtc, lProcessed, lSkipped,
          lFailed, lDeferred, False);
        lJob.Checkpoint;
        lMeta := Default(TTranscriptMetadata);
        try
          if lEntry.Kind = dekChannel then
          begin
            lChannelResult := RunChannelMode(lConfig, lStats);
            if lChannelResult = 2 then
              raise Exception.Create('YouTube throttling persisted; channel processing was deferred');
            MarkChannelSuccess(lEntry, lStats);
          end
          else
          begin
            RunSingleVideoWithRetries(lConfig, lMeta, lOutputPath);
            if (not TFile.Exists(lOutputPath)) or
               (not SameText(Trim(ReadFrontMatterValue(lOutputPath, 'video_id')),
                 Trim(lMeta.VideoId))) then
              raise Exception.Create('Downloaded output could not be verified by video_id');
            lJob.RemoveStandaloneVideoByUrl(lEntry.GroupIndex, lEntry.Url);
          end;
          Inc(lProcessed);
        except
          on E: Exception do
          begin
            Inc(lFailed);
            MarkEntryFailure(lEntry, E.Message, lMeta);
            WriteLn(Format('Warning: retained %s (%s)', [lEntry.Url, E.Message]));
            if IsThrottleError(E.Message) or
               (Assigned(GThrottleController) and GThrottleController.IsTerminal) then
            begin
              lDeferred := Length(lEntries) - lProcessed - lSkipped - lFailed;
              if lDeferred < 0 then lDeferred := 0;
              UpdateJobState(lJob, 'throttled', lStartedUtc, lProcessed,
                lSkipped, lFailed, lDeferred, True);
              lJob.Checkpoint;
              Exit(2);
            end;
          end;
        end;
        UpdateJobState(lJob, 'running', lStartedUtc, lProcessed, lSkipped,
          lFailed, lDeferred, False);
        lJob.Checkpoint;
      end;
      if lFailed > 0 then lStatus := 'completed_with_errors'
      else lStatus := 'completed';
      UpdateJobState(lJob, lStatus, lStartedUtc, lProcessed, lSkipped,
        lFailed, lDeferred, True);
      lJob.Checkpoint;
      WriteLn(Format('YAML job completed: processed=%d skipped=%d failed=%d deferred=%d',
        [lProcessed, lSkipped, lFailed, lDeferred]));
      Result := 0;
    finally
      FreeAndNil(GThrottleController);
    end;
  finally
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
    lConfig := ParseCommandLine;

    if lConfig.ShowHelp then
    begin
      WriteLn(RSUsage);
      Exit(0);
    end;

    if not lConfig.DownloadFileName.IsEmpty then
      Exit(RunDownloadFile(lConfig.DownloadFileName));

    TryAutoUpdateYtDlp;
    if lConfig.URL.IsEmpty then
      raise EArgumentException.Create('YouTube URL is a required argument.');

    GThrottleController := TThrottleController.Create(lConfig.Jobs);
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
      // Result is already 1
    end;
  end;
end;

function ParseCommandLine: TCommandLineConfig;
var
  x: Integer;
  lArg: string;
  lJobs: Integer;
  lCookiesFileProvided: Boolean;
  lCookiesBrowserProvided: Boolean;
begin
  Result := Default(TCommandLineConfig);
  LoadDefaultOptions(Result);
  Result.DelayJitterMs := CDefaultDelayJitterMs;
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
      Result.Jobs := lJobs;
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
  if Result.Jobs < 1 then
    Result.Jobs := GetDefaultJobCount;
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

function TTranscriptService.CaptureYtDlpOutput(const aArguments: string; out aOutput, aError: string): Integer;
var
  lCmd: string;
  lStdOut: TStringBuilder;
  lStdErr: TStringBuilder;
begin
  if Assigned(GThrottleController) then
    GThrottleController.BeforeRequest;
  lCmd := Format('"%s" %s', [GetYtDlpPath, aArguments]);
  lStdOut := TStringBuilder.Create;
  lStdErr := TStringBuilder.Create;
  try
    MaxLogic.ioutils.ExecuteFile(
      lCmd,
      '',
      Result,
      procedure(const aText: string)
      begin
        lStdOut.Append(aText);
      end,
      procedure(const aText: string)
      begin
        lStdErr.Append(aText);
      end,
      True
    );
    aOutput := lStdOut.ToString;
    aError := lStdErr.ToString;
    if Assigned(GThrottleController) then
      GThrottleController.ReportResult(Result, aOutput + sLineBreak + aError);
  finally
    lStdErr.Free;
    lStdOut.Free;
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
  lAttempt: Integer;
  lDelayMs: Integer;
  lCommandArgs: string;
begin
  Result := Default(TTranscriptMetadata);
  lCommandArgs := '--dump-single-json --quiet --no-warnings --skip-download ';
  if ExtractVideoIdFromUrl(aUrl) <> '' then
    lCommandArgs := lCommandArgs + '--no-playlist '
  else
    lCommandArgs := lCommandArgs + '--playlist-items 0 ';
  if Trim(aYtDlpExtraArgs) <> '' then
    lCommandArgs := lCommandArgs + Trim(aYtDlpExtraArgs) + ' ';
  lCommandArgs := lCommandArgs + Format('"%s"', [aUrl]);
  for lAttempt := 1 to CRetryAttempts do
  begin
    lExitCode := CaptureYtDlpOutput(lCommandArgs, lOutput, lError);
    if lExitCode = 0 then
      Break;

    if (lAttempt >= CRetryAttempts) or (not IsThrottleError(lError)) then
      raise Exception.CreateFmt('yt-dlp metadata fetch failed (exit %d): %s', [lExitCode, Trim(lError)]);

    lDelayMs := GetThrottleRetryDelayMs(lAttempt);
    Sleep(lDelayMs);
  end;

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

function TTranscriptService.ListChannelVideoUrls(const aListUrl, aYtDlpExtraArgs: string): TArray<string>;
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
var
  lOutput: string;
  lError: string;
  lExitCode: Integer;
  lJson: string;
  lAttempt: Integer;
  lDelayMs: Integer;
  lCommandArgs: string;
  lJsonValue: TJSONValue;
  lJsonObj: TJSONObject;
  lEntriesValue: TJSONValue;
  lEntries: TJSONArray;
  lItemObj: TJSONObject;
  lVideoUrl: string;
  lVideoId: string;
  lList: TList<string>;
begin
  lCommandArgs := '--flat-playlist --dump-single-json --quiet --no-warnings --skip-download ';
  if Trim(aYtDlpExtraArgs) <> '' then
    lCommandArgs := lCommandArgs + Trim(aYtDlpExtraArgs) + ' ';
  lCommandArgs := lCommandArgs + Format('"%s"', [aListUrl]);
  for lAttempt := 1 to CRetryAttempts do
  begin
    lExitCode := CaptureYtDlpOutput(lCommandArgs, lOutput, lError);
    if lExitCode = 0 then
      Break;

    if (lAttempt >= CRetryAttempts) or (not IsThrottleError(lError)) then
      raise Exception.CreateFmt('yt-dlp listing failed for %s (exit %d): %s', [aListUrl, lExitCode, Trim(lError)]);

    lDelayMs := GetThrottleRetryDelayMs(lAttempt);
    Sleep(lDelayMs);
  end;

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

  lList := TList<string>.Create;
  lJsonObj := lJsonValue as TJSONObject;
  try
    lEntriesValue := lJsonObj.Values['entries'];
    if not (lEntriesValue is TJSONArray) then
      Exit(lList.ToArray);

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
        lList.Add(NormalizeVideoUrl(lVideoUrl));
    end;
    Result := lList.ToArray;
  finally
    lList.Free;
    lJsonObj.Free;
  end;
end;

function TTranscriptService.FetchTranscript(const aUrl, aLanguage, aYtDlpExtraArgs: string): TTranscriptResult;
var
  lTempDir: string;
  lYtDlpPath: string;
  lParams: TStringBuilder;
  lFiles: TArray<string>;
  lMetaFiles: TArray<string>;
  lSrtFile: string;
  lSrtContent: string;
  lMetaContent: string;
  lExitCode: Integer;
  lStdErr: TStringBuilder;
  lStdOut: TStringBuilder;
  lCmd: string;
begin
  Result := Default(TTranscriptResult);
  lYtDlpPath := GetYtDlpPath;
  if not TFile.Exists(lYtDlpPath) then
    raise EFileNotFoundException.CreateFmt('Required executable not found: %s', [lYtDlpPath]);

  lTempDir := TPath.Combine(TPath.GetTempPath, TPath.GetGUIDFileName);
  TDirectory.CreateDirectory(lTempDir);
  try
    gc(lParams, TStringBuilder.Create);

    lParams.Append('--skip-download ');
    lParams.Append('--write-sub ');
    lParams.Append('--write-auto-sub ');
    lParams.Append('--sub-format srt ');
    lParams.AppendFormat('--sub-lang %s ', [aLanguage]);
    lParams.Append('--write-info-json ');
    if Trim(aYtDlpExtraArgs) <> '' then
      lParams.Append(Trim(aYtDlpExtraArgs) + ' ');
    // Use -P for path instead of -o to avoid filename templating issues
    lParams.AppendFormat('-P "%s" ', [lTempDir]);
    lParams.AppendFormat('-o "%s" ', ['transcript']);
    lParams.AppendFormat('"%s"', [aUrl]);

    lCmd := Format('"%s" %s', [lYtDlpPath, lParams.ToString]);
    lExitCode := 1;
    lStdErr := TStringBuilder.Create;
    lStdOut := TStringBuilder.Create;
    try
      if Assigned(GThrottleController) then
        GThrottleController.BeforeRequest;
      MaxLogic.ioutils.ExecuteFile(
        lCmd,
        '',
        lExitCode,
        procedure(const aText: string)
        begin
          lStdOut.Append(aText);
        end,
        procedure(const aText: string)
        begin
          lStdErr.Append(aText);
        end,
        True
      );
      if Assigned(GThrottleController) then
        GThrottleController.ReportResult(lExitCode,
          lStdOut.ToString + sLineBreak + lStdErr.ToString);
    finally
      if lExitCode <> 0 then
      begin
        if Trim(lStdErr.ToString) <> '' then
          raise Exception.CreateFmt('yt-dlp transcript fetch failed (exit %d): %s', [lExitCode, Trim(lStdErr.ToString)])
        else
          raise Exception.CreateFmt('yt-dlp transcript fetch failed (exit %d): %s', [lExitCode, Trim(lStdOut.ToString)]);
      end;
      lStdOut.Free;
      lStdErr.Free;
    end;

    lMetaFiles := TDirectory.GetFiles(lTempDir, '*.info.json');
    if Length(lMetaFiles) > 0 then
    begin
      try
        lMetaContent := TFile.ReadAllText(lMetaFiles[0], TEncoding.UTF8);
      except
        lMetaContent := TFile.ReadAllText(lMetaFiles[0], TEncoding.default);
      end;
      Result.Meta := TTranscriptMetadata.FromJson(lMetaContent);
    end;
    if Result.Meta.VideoId = '' then
      Result.Meta.VideoId := ExtractVideoIdFromUrl(aUrl);
    if Result.Meta.Url = '' then
      Result.Meta.Url := NormalizeVideoUrl(aUrl);

    lFiles := TDirectory.GetFiles(lTempDir, '*.srt');
    if Length(lFiles) = 0 then
      raise EMissingTranscriptError.Create(
        'yt-dlp did not produce an SRT subtitle file. The requested language might not be available or may have a different code.',
        Result.Meta
      );
    if Length(lFiles) > 1 then
      raise Exception.Create('yt-dlp produced multiple SRT files, which is unexpected.');

    lSrtFile := lFiles[0];
    try
      lSrtContent := TFile.ReadAllText(lSrtFile, TEncoding.UTF8);
    Except
      lSrtContent := TFile.ReadAllText(lSrtFile, TEncoding.default); // retry with non utf8 system encoding
    end;

    Result.Transcript := ParseSrtContent(lSrtContent);
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

end.
