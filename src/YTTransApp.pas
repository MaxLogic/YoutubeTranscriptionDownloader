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
  end;

  TTranscriptService = class
  private
    function ParseSrtContent(const aSrtContent: string): string;
  public
    function FetchTranscript(const aUrl, aLanguage: string): string;
  end;

function ParseCommandLine: TCommandLineConfig;
function Run: Integer;


implementation

uses
  System.IOUtils, System.StrUtils, autoFree, MaxLogic.ioUtils;

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
    '  -h, --help              Show this help and exit.' + sLineBreak;

  RSError = 'Error: %s';

function Run: Integer;
var
  lConfig     : TCommandLineConfig;
  lOutputText : String;
  lService    : TTranscriptService;
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
    lOutputText := lService.FetchTranscript(lConfig.URL, lConfig.Language);

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

{ TTranscriptService }

function TTranscriptService.FetchTranscript(const aUrl, aLanguage: string): string;
var
  lTempDir: string;
  lYtDlpPath: string;
  lParams: TStringBuilder;
  lFiles: TArray<string>;
  lSrtFile: string;
  lSrtContent: string;
begin
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

    Result := ParseSrtContent(lSrtContent);
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
