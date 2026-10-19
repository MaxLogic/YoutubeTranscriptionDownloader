unit YTTrans.FrontMatter;

// Reads YAML front matter values of transcript files. Kept free of other
// project units so the GUI can use it without linking YTTransApp.

interface

// A top-level front matter value, unquoted. Also reads files written before
// values were quoted, whose raw text follows the first `:`.
function ReadFrontMatterValue(const aFilePath, aKey: string): string;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, System.StrUtils;

// The value of a double-quoted scalar. Anything else, including a legacy
// value that merely starts with a quote (`"Hi" #shorts`), is returned as is.
function UnquoteYamlScalar(const aValue: string): string;
var
  lBuilder: TStringBuilder;
  lIndex, lCode: Integer;
begin
  if (Length(aValue) < 2) or (aValue[1] <> '"') then
    Exit(aValue);
  lBuilder := TStringBuilder.Create;
  try
    lIndex := 2;
    while lIndex <= Length(aValue) do
    begin
      case aValue[lIndex] of
        '"':
          if lIndex = Length(aValue) then
            Exit(lBuilder.ToString)
          else
            Exit(aValue);
        '\':
          begin
            Inc(lIndex);
            if lIndex > Length(aValue) then
              Exit(aValue);
            case aValue[lIndex] of
              'n': lBuilder.Append(#10);
              't': lBuilder.Append(#9);
              'r': lBuilder.Append(#13);
              '0': lBuilder.Append(#0);
              'u':
                begin
                  if not TryStrToInt('$' + Copy(aValue, lIndex + 1, 4), lCode) then
                    Exit(aValue);
                  lBuilder.Append(Char(lCode));
                  Inc(lIndex, 4);
                end;
            else
              lBuilder.Append(aValue[lIndex]); // \" \\ \/ and the like
            end;
          end;
      else
        lBuilder.Append(aValue[lIndex]);
      end;
      Inc(lIndex);
    end;
    Result := aValue; // no closing quote
  finally
    lBuilder.Free;
  end;
end;

// The `|-` block that starts at aLines[aStart], without its indentation and
// trailing empty lines, joined with LF.
function ReadYamlBlockLines(const aLines: TStrings; const aStart: Integer): string;
var
  lBlock: TStringList;
  lLine: string;
begin
  lBlock := TStringList.Create;
  try
    for var lIndex := aStart to aLines.Count - 1 do
    begin
      lLine := aLines[lIndex];
      if Trim(lLine) = '' then
        lBlock.Add('')
      else if StartsStr('  ', lLine) then
        lBlock.Add(Copy(lLine, 3, MaxInt))
      else
        Break;
    end;
    while (lBlock.Count > 0) and (lBlock[lBlock.Count - 1] = '') do
      lBlock.Delete(lBlock.Count - 1);
    Result := string.Join(#10, lBlock.ToStringArray);
  finally
    lBlock.Free;
  end;
end;

function ReadFrontMatterValue(const aFilePath, aKey: string): string;
var
  lText: string;
  lLines: TStringList;
  lLine: string;
  lValue: string;
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
      lLine := TrimRight(lLines[lIndex]);
      if lLine = '---' then
        Break;
      // Indented lines belong to a block value, not to a key.
      if (lLine = '') or CharInSet(lLine[1], [' ', #9]) then
        Continue;
      lPos := Pos(':', lLine);
      if lPos <= 1 then
        Continue;
      if SameText(Trim(Copy(lLine, 1, lPos - 1)), aKey) then
      begin
        lValue := Trim(Copy(lLine, lPos + 1, MaxInt));
        if MatchStr(lValue, ['|-', '|2-']) then
          Exit(ReadYamlBlockLines(lLines, lIndex + 1));
        Exit(UnquoteYamlScalar(lValue));
      end;
    end;
  finally
    lLines.Free;
  end;
end;

end.
