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
  public
    function FetchTranscript(const aUrl, aLanguage: string): TTranscriptResult;
  end;

function ParseCommandLine: TCommandLineConfig;
function Run: Integer;


implementation

uses
  System.IOUtils, System.IniFiles, System.JSON, System.StrUtils, System.DateUtils, autoFree, MaxLogic.ioUtils;

resourcestring
  RSUsage =
    'YouTrans v1.0' + sLineBreak +
    'Usage: youtrans <URL> -l <lang> [options]' + sLineBreak +
    'Downloads a transcript for a YouTube video using yt-dlp.' + sLineBreak +
    sLineBreak +
    'Arguments:' + sLineBreak +
    '  <URL>                   The full URL of the YouTube video.' + sLineBreak +
    sLineBreak +
    'Options:' + sLineBreak +
    '  -l, --lang <lang_code>  Language code for subtitles (e.g., "en", "pl"). default is "en".' + sLineBreak +
    '  -o, --output <path>     Output file path. If it is a directory path, title is used as .md file name.' + sLineBreak +
    '  -p, --prefix <text>     Prefix text for auto-generated file names.' + sLineBreak +
    '  -meta, --meta            Prepend YouTube metadata before the transcript output.' + sLineBreak +
    '  -keywords <list>         Comma-separated keywords added to metadata. Implies -meta.' + sLineBreak +
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
  CMetaSection = 'meta';

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

function Run: Integer;
var
  lConfig     : TCommandLineConfig;
  lOutputText : String;
  lService    : TTranscriptService;
  lResult     : TTranscriptResult;
  lOutputDir  : string;
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

    gc(lService, TTranscriptService.Create);
    lResult := lService.FetchTranscript(lConfig.URL, lConfig.Language);
    lOutputText := lResult.Transcript;
    if lConfig.IncludeMeta then
      lOutputText := BuildMetaSection(lResult.Meta, lConfig.Keywords, lConfig.MetaOptions) + lOutputText;

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
begin
  Result := Default(TCommandLineConfig);
  LoadDefaultOptions(Result);

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
   Result.Language := 'en'; // default
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
    (Duration <> '') or (ViewCount <> '') or (LikeCount <> '') or (CommentCount <> '') or
    (Tags <> '') or (Description <> '');
end;

{ TTranscriptService }

function TTranscriptService.FetchTranscript(const aUrl, aLanguage: string): TTranscriptResult;
var
  lTempDir: string;
  lYtDlpPath: string;
  lParams: TStringBuilder;
  lFiles: TArray<string>;
  lMetaFiles: TArray<string>;
  lSrtFile: string;
  lSrtContent: string;
  lMetaContent: string;
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
    // Use -P for path instead of -o to avoid filename templating issues
    lParams.AppendFormat('-P "%s" ', [lTempDir]);
    lParams.AppendFormat('-o "%s" ', ['transcript']);
    lParams.AppendFormat('"%s"', [aUrl]);

    MaxLogic.ioutils.ExecuteFile(lYtDlpPath, lParams.ToString, '', True, true);

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
