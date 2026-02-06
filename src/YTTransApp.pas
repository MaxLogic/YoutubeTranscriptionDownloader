unit YTTransApp;

interface

uses
  System.SysUtils, System.Classes;

type
  TCommandLineConfig = record
    URL        : String;
    OutputFile : String;     // Empty = write to STDOUT
    Language   : String;     // e.g. 'en', 'pl'
    ShowHelp   : Boolean;
    IncludeMeta: Boolean;
  end;

  TTranscriptMetadata = record
    Url    : String;
    Title  : String;
    Channel: String;
    Created: String;
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
  System.IOUtils, System.JSON, System.StrUtils, System.DateUtils, autoFree, MaxLogic.ioUtils;

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
    '  -o, --output <file>     Path of output text file (overwritten). Prints to console if omitted.' + sLineBreak +
    '  -meta, --meta            Prepend YouTube metadata before the transcript output.' + sLineBreak +
    '  -h, --help              Show this help and exit.' + sLineBreak;

  RSError = 'Error: %s';

function BuildMetaSection(const aMeta: TTranscriptMetadata): string;
var
  lBuilder: TStringBuilder;
begin
  Result := '';
  if not aMeta.HasData then
    Exit;

  lBuilder := TStringBuilder.Create;
  try
    if aMeta.Url <> '' then
      lBuilder.AppendLine('url: ' + aMeta.Url);

    if aMeta.Title <> '' then
      lBuilder.AppendLine('title: ' + aMeta.Title);

    if aMeta.Channel <> '' then
      lBuilder.AppendLine('channel: ' + aMeta.Channel);

    if aMeta.Created <> '' then
      lBuilder.AppendLine('created: ' + aMeta.Created);

    lBuilder.AppendLine;
    Result := lBuilder.ToString;
  finally
    lBuilder.Free;
  end;
end;

function Run: Integer;
var
  lConfig     : TCommandLineConfig;
  lOutputText : String;
  lService    : TTranscriptService;
  lResult     : TTranscriptResult;
begin
  Result := 1; // Default to error
  try
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
    if lConfig.IncludeMeta and lResult.Meta.HasData then
      lOutputText := BuildMetaSection(lResult.Meta) + lOutputText;

    if lConfig.OutputFile.IsEmpty then
    begin
      WriteLn(lOutputText);
    end
    else
    begin
      TFile.WriteAllText(lConfig.OutputFile, lOutputText, TEncoding.UTF8);
      WriteLn('Transcript saved to: ', lConfig.OutputFile);
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
      Result.OutputFile := TPath.GetFullPath(ParamStr(x));
    end
    else if (lArg = '-l') or (lArg = '--lang') then
    begin
      if (x + 1) > ParamCount then
        raise EArgumentException.CreateFmt('Missing value for option %s', [lArg]);
      Inc(x);
      Result.Language := ParamStr(x).ToLower;
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

    if lJson.TryGetValue<string>('title', lTemp) then
      Result.Title := lTemp;

    if not lJson.TryGetValue<string>('channel', lTemp) then
      lJson.TryGetValue<string>('uploader', lTemp);
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
  Result := (Url <> '') or (Title <> '') or (Channel <> '') or (Created <> '');
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
  lYtDlpPath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'yt-dlp.exe');
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
