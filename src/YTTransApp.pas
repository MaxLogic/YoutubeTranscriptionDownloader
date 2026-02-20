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
    Jobs: Integer;
    OverrideExisting: Boolean;
    ChannelOutputRoot: String;
    IncludeShorts: Boolean;
    IncludeLive: Boolean;
    CookiesFile: String;
    CookiesFromBrowser: String;
    DelayJitterMs: Integer;
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


implementation

uses
  System.IOUtils, System.IniFiles, System.JSON, System.StrUtils, System.DateUtils,
  System.SyncObjs, System.Threading, System.Generics.Collections, autoFree, MaxLogic.ioUtils;

resourcestring
  RSUsage =
    'YouTrans v1.0' + sLineBreak +
    'Usage: youtrans <URL> -l <lang> [options]' + sLineBreak +
    'Downloads transcript(s) using yt-dlp. Video mode is default; channel mode is optional.' + sLineBreak +
    sLineBreak +
    'Arguments:' + sLineBreak +
    '  <URL>                   The full URL of the YouTube video.' + sLineBreak +
    sLineBreak +
    'Options:' + sLineBreak +
    '  -l, --lang <lang_code>  Language code for subtitles (e.g., "en", "pl"). default is "en".' + sLineBreak +
    '  -o, --output <path>     Video mode: output file path/dir. Channel mode: root output directory.' + sLineBreak +
    '  -p, --prefix <text>     Prefix text for auto-generated file names.' + sLineBreak +
    '  -meta, --meta           Prepend YouTube metadata before the transcript output.' + sLineBreak +
    '  -keywords <list>         Comma-separated keywords added to metadata. Implies -meta.' + sLineBreak +
    '  -c, --channel           Download all videos from the channel owning <URL>.' + sLineBreak +
    '  -j, --jobs <n>          Parallel workers in channel mode. Default: min(logical CPU, 2).' + sLineBreak +
    '  -ov, --override         In channel mode, overwrite existing file with the same video_id.' + sLineBreak +
    '  -co, --channel-output <dir>  Root output directory override for channel mode.' + sLineBreak +
    '  -is, --include-shorts   In channel mode, include Shorts tab.' + sLineBreak +
    '  -il, --include-live     In channel mode, include Live/Streams tab.' + sLineBreak +
    '  --cookies <file>        Pass yt-dlp cookies file for authenticated requests.' + sLineBreak +
    '  --cookies-from-browser <browser>  Load cookies from browser profile (yt-dlp syntax).' + sLineBreak +
    '                            Defaults can be set in settings.ini [default] cookies_file/cookies_from_browser.' + sLineBreak +
    '  -dj, --delay-jitter-ms <n>  Max per-item jitter delay in ms for channel mode pacing.' + sLineBreak +
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
  CRetryAttempts = 3;
  CRetryBaseDelayMs = 600;
  CThrottleCooldownMs = 3000;
  CMaxThrottleCooldownMs = 60000;
  CDefaultDelayJitterMs = 1200;
  CDefaultChannelJobsCap = 2;

type
  TChannelConflictAction = (ccaWriteNew, ccaOverwrite, ccaSkip);

  TChannelRunStats = record
    Downloaded: Integer;
    Overwritten: Integer;
    Skipped: Integer;
    Failed: Integer;
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
    lLines.Add('cookies_from_browser=firefox');
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
    aConfig.CookiesFromBrowser := Trim(lIni.ReadString(CDefaultSection, CDefaultCookiesFromBrowserKey, 'firefox'));
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

function IsMissingSubtitleError(const aMessage: string): Boolean;
var
  lMsg: string;
begin
  lMsg := aMessage.ToLower;
  Result := Pos('did not produce an srt subtitle file', lMsg) > 0;
end;

function IsThrottleError(const aMessage: string): Boolean;
var
  lMsg: string;
begin
  lMsg := aMessage.ToLower;
  Result := (Pos('429', lMsg) > 0) or
    (Pos('too many requests', lMsg) > 0) or
    (Pos('rate limit', lMsg) > 0) or
    (Pos('sign in to confirm', lMsg) > 0) or
    (Pos('captcha', lMsg) > 0);
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
    if lLines.Count = 0 then
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

function RunChannelMode(const aConfig: TCommandLineConfig): Integer;
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
  lThrottleScore: Integer;
begin
  Result := 1;

  lYtDlpExtraArgs := BuildYtDlpAuthArguments(aConfig);
  gc(lSetupService, TTranscriptService.Create);
  lSeedMeta := lSetupService.FetchMetadata(aConfig.URL, lYtDlpExtraArgs);
  lVideoUrls := BuildChannelVideoQueue(lSetupService, lSeedMeta, aConfig, lYtDlpExtraArgs);
  if Length(lVideoUrls) = 0 then
    raise Exception.Create('Channel mode could not find any videos to process.');

  lChannelDir := BuildChannelOutputDir(aConfig, lSeedMeta);
  TDirectory.CreateDirectory(lChannelDir);

  lEffectiveMetaOptions := aConfig.MetaOptions;
  lEffectiveMetaOptions.Channel := True;
  lEffectiveMetaOptions.VideoId := True;
  lEffectiveMetaOptions.ChannelId := True;

  lFileLock := TCriticalSection.Create;
  lLogLock := TCriticalSection.Create;
  try
    lNextIndex := -1;
    lCooldownUntil := 0;
    lStats := Default(TChannelRunStats);
    lActiveWorkers := 0;
    lThrottleScore := 0;

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
          lNextLimit: Integer;
          lThrottleValue: Integer;
          lDelayFloor: Integer;
          lJitterMs: Integer;
        begin
          Sleep(lWorkerIdx * 150);
          lService := TTranscriptService.Create;
          try
            while True do
            begin
              lIndex := TInterlocked.Increment(lNextIndex);
              if lIndex >= Length(lVideoUrls) then
                Break;

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
                for lAttempt := 1 to CRetryAttempts do
                begin
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
                    finally
                      lFileLock.Leave;
                    end;

                    if TInterlocked.Add(lThrottleScore, 0) > 0 then
                      TInterlocked.Decrement(lThrottleScore);
                    lFailedMessage := '';
                    Break;
                  except
                    on E: Exception do
                    begin
                      lFailedMessage := E.Message;
                      if lAttempt = CRetryAttempts then
                        Break;

                      lDelayMs := CRetryBaseDelayMs * (1 shl (lAttempt - 1));
                      lDelayMs := lDelayMs + ((lIndex + lAttempt * 53) mod 350);
                      if IsThrottleError(E.Message) then
                      begin
                        lThrottleValue := TInterlocked.Increment(lThrottleScore);
                        lDelayFloor := CThrottleCooldownMs * lAttempt * lThrottleValue;
                        if lDelayFloor > CMaxThrottleCooldownMs then
                          lDelayFloor := CMaxThrottleCooldownMs;
                        if lDelayMs < lDelayFloor then
                          lDelayMs := lDelayFloor;

                        lNow := TThread.GetTickCount64;
                        lWaitUntil := lNow + lDelayMs;
                        repeat
                          lObserved := TInterlocked.Read(lCooldownUntil);
                          if lObserved >= lWaitUntil then
                            Break;
                        until TInterlocked.CompareExchange(lCooldownUntil, lWaitUntil, lObserved) = lObserved;

                        while True do
                        begin
                          lLimitSnapshot := TInterlocked.Add(lWorkerLimit, 0);
                          if lLimitSnapshot <= 1 then
                            Break;
                          lNextLimit := lLimitSnapshot - 1;
                          if TInterlocked.CompareExchange(lWorkerLimit, lNextLimit, lLimitSnapshot) = lLimitSnapshot then
                          begin
                            lLogLock.Enter;
                            try
                              WriteLn(Format('Warning: throttling detected, reducing active workers to %d', [lNextLimit]));
                            finally
                              lLogLock.Leave;
                            end;
                            Break;
                          end;
                        end;
                      end;
                      Sleep(lDelayMs);
                    end;
                  end;
                end;

                if lFailedMessage <> '' then
                begin
                  TInterlocked.Increment(lStats.Failed);
                  try
                    lLogLock.Enter;
                    try
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
  end;

  WriteLn('Channel download completed.');
  WriteLn('Channel: ' + lSeedMeta.Channel);
  WriteLn('Output: ' + lChannelDir);
  WriteLn(Format('Workers configured: %d', [lWorkerCount]));
  WriteLn(Format('Workers final limit: %d', [TInterlocked.Add(lWorkerLimit, 0)]));
  WriteLn(Format('Processed: %d', [Length(lVideoUrls)]));
  WriteLn(Format('Downloaded: %d', [lStats.Downloaded]));
  WriteLn(Format('Overwritten: %d', [lStats.Overwritten]));
  WriteLn(Format('Skipped: %d', [lStats.Skipped]));
  WriteLn(Format('Failed: %d', [lStats.Failed]));

  Result := 0;
end;

function Run: Integer;
var
  lConfig     : TCommandLineConfig;
  lOutputText : String;
  lService    : TTranscriptService;
  lResult     : TTranscriptResult;
  lOutputDir  : string;
  lMetaOptions: TMetaOptions;
  lYtDlpExtraArgs: string;
begin
  Result := 1; // Default to error
  try
    TryAutoUpdateYtDlp;
    lConfig := ParseCommandLine;

    if lConfig.ShowHelp then
    begin
      WriteLn(RSUsage);
      Exit(0);
    end;

    if lConfig.URL.IsEmpty then
      raise EArgumentException.Create('YouTube URL is a required argument.');

    if lConfig.ChannelMode then
      Exit(RunChannelMode(lConfig));

    lYtDlpExtraArgs := BuildYtDlpAuthArguments(lConfig);
    gc(lService, TTranscriptService.Create);
    lResult := lService.FetchTranscript(lConfig.URL, lConfig.Language, lYtDlpExtraArgs);
    lOutputText := lResult.Transcript;
    lMetaOptions := lConfig.MetaOptions;
    if lConfig.IncludeMeta then
      lOutputText := BuildMetaSection(lResult.Meta, lConfig.Keywords, lMetaOptions) + lOutputText;

    lConfig.OutputTarget := BuildOutputFilePath(lConfig, lResult.Meta);
    if lConfig.OutputTarget.IsEmpty then
    begin
      WriteLn(lOutputText);
    end
    else
    begin
      lConfig.OutputTarget := EnsureUniqueFilePath(lConfig.OutputTarget);
      lOutputDir := ExtractFileDir(lConfig.OutputTarget);
      if not lOutputDir.IsEmpty then
        TDirectory.CreateDirectory(lOutputDir);
      TFile.WriteAllText(lConfig.OutputTarget, lOutputText, TEncoding.UTF8);
      WriteLn('Transcript saved to: ', lConfig.OutputTarget);
    end;

    Result := 0;
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
    (Tags <> '') or (Description <> '');
end;

{ TTranscriptService }

function TTranscriptService.CaptureYtDlpOutput(const aArguments: string; out aOutput, aError: string): Integer;
var
  lCmd: string;
  lStdOut: TStringBuilder;
  lStdErr: TStringBuilder;
begin
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
  lCommandArgs := '--dump-single-json --quiet --no-warnings --skip-download --no-playlist ';
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

    lDelayMs := CThrottleCooldownMs * lAttempt;
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

    lDelayMs := CThrottleCooldownMs * lAttempt;
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

    lFiles := TDirectory.GetFiles(lTempDir, '*.srt');
    if Length(lFiles) = 0 then
      raise EFileNotFoundException.Create('yt-dlp did not produce an SRT subtitle file. The requested language might not be available or may have a different code.');
    if Length(lFiles) > 1 then
      raise Exception.Create('yt-dlp produced multiple SRT files, which is unexpected.');

    lSrtFile := lFiles[0];
    try
      lSrtContent := TFile.ReadAllText(lSrtFile, TEncoding.UTF8);
    Except
      lSrtContent := TFile.ReadAllText(lSrtFile, TEncoding.default); // retry with non utf8 system encoding
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
