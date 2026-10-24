unit YTTrans.ChannelIndex;

interface

uses
  System.SysUtils,
  YTTrans.Throttle;

type
  EChannelIndexError = class(Exception);

  TChannelIndexVideo = record
    VideoId: string;
    Url: string;
    PublishedAt: string;
    PublishedUnix: Int64;
  end;

  TChannelIndexData = record
    SourceUrl: string;
    ChannelId: string;
    ChannelName: string;
    LastFullScanUtc: TDateTime;
    LastIncrementalScanUtc: TDateTime;
    Videos: TArray<TChannelIndexVideo>;
  end;

  TChannelDiscoveryMode = (cdmFresh, cdmFailed, cdmThrottled, cdmAll);
  TChannelDiscoveryAction = (cdaUseIndex, cdaFetchRss, cdaFullListing);
  TChannelRssOutcome = (croSuccess, croWarning, croThrottled);
  TChannelRssFetch = reference to procedure(const aUrl: string;
    out aStatusCode: Integer; out aBody, aError: string);

  TChannelIndexStore = class
  private
    FFileName: string;
    FBackupFileName: string;
    class function Normalize(const aData: TChannelIndexData): TChannelIndexData; static;
    class function Parse(const aText: string; out aData: TChannelIndexData): Boolean; static;
    class function Serialize(const aData: TChannelIndexData): string; static;
    function LoadFile(const aFileName: string; out aData: TChannelIndexData): Boolean;
  public
    constructor Create(const aChannelDirectory: string);
    function Load(out aData: TChannelIndexData): Boolean;
    procedure Save(const aData: TChannelIndexData);
    property FileName: string read FFileName;
    property BackupFileName: string read FBackupFileName;
  end;

function SelectChannelDiscoveryAction(const aMode: TChannelDiscoveryMode;
  const aHasValidIndex: Boolean; const aLastFullScanUtc,
  aNowUtc: TDateTime): TChannelDiscoveryAction;
function RefreshChannelIndexFromRss(const aStore: TChannelIndexStore;
  const aCurrent: TChannelIndexData;
  const aThrottleController: TThrottleController;
  const aFetch: TChannelRssFetch; const aThrottleCheckpoint: TProc;
  const aNowUtc: TDateTime; out aUpdated: TChannelIndexData;
  out aError: string): TChannelRssOutcome;
procedure ReconcileFullChannelIndex(const aStore: TChannelIndexStore;
  const aCurrent: TChannelIndexData; const aHasCurrent: Boolean;
  const aDiscovered: TChannelIndexData; const aNowUtc: TDateTime;
  out aUpdated: TChannelIndexData);
function TryReconcileFullChannelIndex(const aStore: TChannelIndexStore;
  const aCurrent: TChannelIndexData; const aHasCurrent: Boolean;
  const aDiscovered: TChannelIndexData; const aNowUtc: TDateTime;
  out aUpdated: TChannelIndexData; out aError: string): Boolean;

implementation

uses
  Winapi.Windows,
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.IOUtils,
  System.JSON,
  System.StrUtils,
  Xml.XMLDoc,
  Xml.XMLIntf;

const
  CChannelIndexSchema = 1;
  CChannelIndexFileName = '.yttrans-channel-index.json';
  CFullReconciliationDays = 30;

function ValidVideoId(const aValue: string): Boolean; forward;

function ValidChannelId(const aValue: string): Boolean;
var
  I: Integer;
begin
  Result := StartsText('UC', aValue) and (Length(aValue) > 2);
  if not Result then
    Exit;
  for I := 1 to Length(aValue) do
    if not CharInSet(aValue[I],
      ['a'..'z', 'A'..'Z', '0'..'9', '_', '-']) then
      Exit(False);
end;

function SelectChannelDiscoveryAction(const aMode: TChannelDiscoveryMode;
  const aHasValidIndex: Boolean; const aLastFullScanUtc,
  aNowUtc: TDateTime): TChannelDiscoveryAction;
begin
  if aMode = cdmAll then
    Exit(cdaFullListing);
  if not aHasValidIndex then
    Exit(cdaFullListing);
  if aMode in [cdmFailed, cdmThrottled] then
    Exit(cdaUseIndex);
  if (aLastFullScanUtc <= 0) or
     (aNowUtc >= IncDay(aLastFullScanUtc, CFullReconciliationDays)) then
    Exit(cdaFullListing);
  Result := cdaFetchRss;
end;

function NodeHasName(const aNode: IXMLNode; const aName: string): Boolean;
begin
  Result := SameText(aNode.NodeName, aName) or
    EndsText(':' + aName, aNode.NodeName);
end;

function ChildText(const aParent: IXMLNode; const aName: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to aParent.ChildNodes.Count - 1 do
    if NodeHasName(aParent.ChildNodes[I], aName) then
      Exit(Trim(aParent.ChildNodes[I].Text));
end;

function ParseRssVideos(const aXml, aExpectedChannelId: string):
  TArray<TChannelIndexVideo>;
var
  lDocument: IXMLDocument;
  lFeed, lNode: IXMLNode;
  lVideos: TList<TChannelIndexVideo>;
  lVideo: TChannelIndexVideo;
  lPublishedUtc: TDateTime;
  lChannelId: string;
  I: Integer;
begin
  try
    lDocument := LoadXMLData(aXml);
  except
    on E: Exception do
      raise EChannelIndexError.Create('YouTube RSS returned malformed XML: ' +
        E.Message);
  end;
  lFeed := lDocument.DocumentElement;
  if not Assigned(lFeed) or not NodeHasName(lFeed, 'feed') then
    raise EChannelIndexError.Create('YouTube RSS has no feed element');
  lChannelId := ChildText(lFeed, 'channelId');
  // YouTube RSS may omit UC from the feed-level channel ID.
  if (lChannelId = '') or
     not (SameText(lChannelId, aExpectedChannelId) or
       (aExpectedChannelId.StartsWith('UC') and
        (lChannelId = Copy(aExpectedChannelId, 3, MaxInt)))) then
    raise EChannelIndexError.Create('YouTube RSS channel identity is missing or mismatched');

  lVideos := TList<TChannelIndexVideo>.Create;
  try
    for I := 0 to lFeed.ChildNodes.Count - 1 do
    begin
      lNode := lFeed.ChildNodes[I];
      if not NodeHasName(lNode, 'entry') then
        Continue;
      lVideo := Default(TChannelIndexVideo);
      lVideo.VideoId := ChildText(lNode, 'videoId');
      lVideo.PublishedAt := ChildText(lNode, 'published');
      if not ValidVideoId(lVideo.VideoId) then
        raise EChannelIndexError.Create('YouTube RSS entry has an invalid video ID');
      if (lVideo.PublishedAt = '') or
         not TryISO8601ToDate(lVideo.PublishedAt, lPublishedUtc, True) then
        raise EChannelIndexError.Create('YouTube RSS entry has an invalid publication timestamp');
      lVideo.PublishedAt := DateToISO8601(lPublishedUtc, True);
      lVideo.PublishedUnix := DateTimeToUnix(lPublishedUtc, True);
      lVideo.Url := 'https://www.youtube.com/watch?v=' + lVideo.VideoId;
      lVideos.Add(lVideo);
    end;
    Result := lVideos.ToArray;
  finally
    lVideos.Free;
  end;
end;

procedure MergeVideos(var aTarget: TChannelIndexData;
  const aHistorical: TArray<TChannelIndexVideo>);
var
  lCombined: TArray<TChannelIndexVideo>;
  lOffset, I: Integer;
begin
  lOffset := Length(aTarget.Videos);
  SetLength(lCombined, lOffset + Length(aHistorical));
  for I := 0 to lOffset - 1 do
    lCombined[I] := aTarget.Videos[I];
  for I := 0 to Length(aHistorical) - 1 do
    lCombined[lOffset + I] := aHistorical[I];
  aTarget.Videos := lCombined;
end;

function RefreshChannelIndexFromRss(const aStore: TChannelIndexStore;
  const aCurrent: TChannelIndexData;
  const aThrottleController: TThrottleController;
  const aFetch: TChannelRssFetch; const aThrottleCheckpoint: TProc;
  const aNowUtc: TDateTime; out aUpdated: TChannelIndexData;
  out aError: string): TChannelRssOutcome;
var
  lStatusCode, lExitCode: Integer;
  lBody, lFetchError, lCombined: string;
  lRssVideos: TArray<TChannelIndexVideo>;
begin
  if not Assigned(aThrottleController) then
    raise EArgumentNilException.Create('aThrottleController');
  if not Assigned(aFetch) then
    raise EArgumentNilException.Create('aFetch');

  aUpdated := aCurrent;
  aError := '';
  // RSS is listing work: it takes the short base gap, not a subtitle slot.
  aThrottleController.BeforeRequest(trcExtraction);
  lStatusCode := 0;
  lBody := '';
  lFetchError := '';
  aFetch('https://www.youtube.com/feeds/videos.xml?channel_id=' +
    aCurrent.ChannelId, lStatusCode, lBody, lFetchError);
  // "HTTP Error 429" is the rate-limit text the throttle classifier expects,
  // also when the server sends no status text.
  lCombined := Format('HTTP Error %d: %s', [lStatusCode, lFetchError]);
  if (lStatusCode < 200) or (lStatusCode >= 300) then
    lCombined := lCombined + ' ' + lBody;
  if (lStatusCode >= 200) and (lStatusCode < 300) and
     (Trim(lFetchError) = '') then
    lExitCode := 0
  else
    lExitCode := 1;
  aThrottleController.ReportResult(lExitCode, lCombined, trcExtraction);
  if (lStatusCode = 429) or
     TThrottleController.IsThrottleMessage(lCombined) then
  begin
    if Assigned(aThrottleCheckpoint) then
      aThrottleCheckpoint;
    aError := Trim(lFetchError);
    if aError = '' then
      aError := Format('YouTube RSS returned HTTP Error %d', [lStatusCode]);
    Exit(croThrottled);
  end;
  if lExitCode <> 0 then
  begin
    aError := Trim(lFetchError);
    if aError = '' then
      aError := Format('YouTube RSS returned HTTP %d', [lStatusCode]);
    Exit(croWarning);
  end;

  try
    lRssVideos := ParseRssVideos(lBody, aCurrent.ChannelId);
  except
    on E: EChannelIndexError do
    begin
      aError := E.Message;
      Exit(croWarning);
    end;
  end;
  aUpdated := aCurrent;
  aUpdated.Videos := lRssVideos;
  MergeVideos(aUpdated, aCurrent.Videos);
  aUpdated.LastIncrementalScanUtc := aNowUtc;
  aStore.Save(aUpdated);
  if not aStore.Load(aUpdated) then
    raise EChannelIndexError.Create(
      'Saved channel index could not be reloaded');
  Result := croSuccess;
end;

procedure ReconcileFullChannelIndex(const aStore: TChannelIndexStore;
  const aCurrent: TChannelIndexData; const aHasCurrent: Boolean;
  const aDiscovered: TChannelIndexData; const aNowUtc: TDateTime;
  out aUpdated: TChannelIndexData);
begin
  aUpdated := aDiscovered;
  if aHasCurrent then
  begin
    if not SameText(aCurrent.ChannelId, aDiscovered.ChannelId) then
      raise EChannelIndexError.Create(
        'Full discovery channel identity does not match the saved index');
    MergeVideos(aUpdated, aCurrent.Videos);
    aUpdated.LastIncrementalScanUtc := aCurrent.LastIncrementalScanUtc;
  end;
  aUpdated.LastFullScanUtc := aNowUtc;
  aStore.Save(aUpdated);
  if not aStore.Load(aUpdated) then
    raise EChannelIndexError.Create(
      'Reconciled channel index could not be reloaded');
end;

function TryReconcileFullChannelIndex(const aStore: TChannelIndexStore;
  const aCurrent: TChannelIndexData; const aHasCurrent: Boolean;
  const aDiscovered: TChannelIndexData; const aNowUtc: TDateTime;
  out aUpdated: TChannelIndexData; out aError: string): Boolean;
begin
  aError := '';
  try
    ReconcileFullChannelIndex(aStore, aCurrent, aHasCurrent, aDiscovered,
      aNowUtc, aUpdated);
    Result := True;
  except
    on E: EChannelIndexError do
    begin
      if not aHasCurrent then
        raise;
      aUpdated := aCurrent;
      aError := E.Message;
      Result := False;
    end;
  end;
end;

function IsVideoIdChar(const aChar: Char): Boolean;
begin
  Result := CharInSet(aChar, ['a'..'z', 'A'..'Z', '0'..'9', '_', '-']);
end;

function ValidVideoId(const aValue: string): Boolean;
var
  I: Integer;
begin
  Result := Length(aValue) = 11;
  if not Result then
    Exit;
  for I := 1 to Length(aValue) do
    if not IsVideoIdChar(aValue[I]) then
      Exit(False);
end;

function VideoIdFromUrl(const aUrl: string): string;
var
  lLower: string;
  lStart, lStop: Integer;
begin
  Result := '';
  lLower := LowerCase(Trim(aUrl));
  lStart := Pos('youtu.be/', lLower);
  if lStart > 0 then
    Inc(lStart, Length('youtu.be/'))
  else
  begin
    lStart := Pos('v=', lLower);
    if lStart > 0 then
      Inc(lStart, 2);
  end;
  if lStart <= 0 then
    Exit;
  lStop := lStart;
  while (lStop <= Length(aUrl)) and IsVideoIdChar(aUrl[lStop]) do
    Inc(lStop);
  Result := Copy(aUrl, lStart, lStop - lStart);
end;

function JsonText(const aObject: TJSONObject; const aName: string): string;
var
  lValue: TJSONValue;
begin
  Result := '';
  if aObject <> nil then
  begin
    lValue := aObject.Values[aName];
    if (lValue <> nil) and not (lValue is TJSONNull) then
      Result := lValue.Value;
  end;
end;

function ParseRequiredUtc(const aValue, aName: string): TDateTime;
begin
  if (Trim(aValue) = '') or not TryISO8601ToDate(aValue, Result, True) then
    raise EChannelIndexError.CreateFmt('Channel index %s is invalid', [aName]);
end;

function ParseOptionalUtc(const aValue, aName: string): TDateTime;
begin
  Result := 0;
  if Trim(aValue) = '' then
    Exit;
  if not TryISO8601ToDate(aValue, Result, True) then
    raise EChannelIndexError.CreateFmt('Channel index %s is invalid', [aName]);
end;

class function TChannelIndexStore.Normalize(
  const aData: TChannelIndexData): TChannelIndexData;
var
  lSeen: TDictionary<string, Boolean>;
  lVideos: TList<TChannelIndexVideo>;
  lVideo, lPrevious: TChannelIndexVideo;
  lVideoId: string;
  lPublishedUtc: TDateTime;
  I, J: Integer;
begin
  Result := aData;
  Result.SourceUrl := Trim(Result.SourceUrl);
  Result.ChannelId := Trim(Result.ChannelId);
  Result.ChannelName := Trim(Result.ChannelName);
  if Result.SourceUrl = '' then
    raise EChannelIndexError.Create('Channel index source_url is required');
  if not ValidChannelId(Result.ChannelId) then
    raise EChannelIndexError.Create('Channel index channel_id is invalid');
  if Result.ChannelName = '' then
    raise EChannelIndexError.Create('Channel index channel_name is required');
  if Result.LastFullScanUtc <= 0 then
    raise EChannelIndexError.Create('Channel index last_full_scan_utc is required');

  lSeen := TDictionary<string, Boolean>.Create;
  try
    lVideos := TList<TChannelIndexVideo>.Create;
    try
      for I := 0 to Length(Result.Videos) - 1 do
      begin
        lVideo := Result.Videos[I];
        lVideoId := Trim(lVideo.VideoId);
        if lVideoId = '' then
          lVideoId := VideoIdFromUrl(lVideo.Url);
        if not ValidVideoId(lVideoId) then
          raise EChannelIndexError.CreateFmt(
            'Channel index contains invalid video_id: %s', [lVideoId]);
        if lSeen.ContainsKey(lVideoId) then
          Continue;
        if lVideo.PublishedUnix < 0 then
          raise EChannelIndexError.Create(
            'Channel index published_unix cannot be negative');
        if lVideo.PublishedUnix > 0 then
          lVideo.PublishedAt := DateToISO8601(
            UnixToDateTime(lVideo.PublishedUnix, True), True)
        else if Trim(lVideo.PublishedAt) <> '' then
        begin
          lPublishedUtc := ParseOptionalUtc(lVideo.PublishedAt,
            'published_at');
          lVideo.PublishedAt := DateToISO8601(lPublishedUtc, True);
          lVideo.PublishedUnix := DateTimeToUnix(lPublishedUtc, True);
        end;
        lSeen.Add(lVideoId, True);
        lVideo.VideoId := lVideoId;
        lVideo.Url := 'https://www.youtube.com/watch?v=' + lVideoId;
        lVideos.Add(lVideo);
      end;

      for I := 1 to lVideos.Count - 1 do
      begin
        lVideo := lVideos[I];
        J := I - 1;
        while (J >= 0) and
          (lVideos[J].PublishedUnix < lVideo.PublishedUnix) do
        begin
          lPrevious := lVideos[J];
          lVideos[J + 1] := lPrevious;
          Dec(J);
        end;
        lVideos[J + 1] := lVideo;
      end;
      Result.Videos := lVideos.ToArray;
    finally
      lVideos.Free;
    end;
  finally
    lSeen.Free;
  end;
end;

class function TChannelIndexStore.Parse(const aText: string;
  out aData: TChannelIndexData): Boolean;
var
  lValue: TJSONValue;
  lRoot: TJSONObject;
  lArray: TJSONArray;
  lItem: TJSONObject;
  I: Integer;
begin
  Result := False;
  aData := Default(TChannelIndexData);
  try
    lValue := TJSONObject.ParseJSONValue(aText, False, True);
  except
    on E: EJSONParseException do
      Exit(False);
  end;
  if not (lValue is TJSONObject) then
  begin
    lValue.Free;
    Exit;
  end;
  lRoot := TJSONObject(lValue);
  try
    try
      if StrToIntDef(JsonText(lRoot, 'schema'), -1) <> CChannelIndexSchema then
        Exit;
      aData.SourceUrl := JsonText(lRoot, 'source_url');
      aData.ChannelId := JsonText(lRoot, 'channel_id');
      aData.ChannelName := JsonText(lRoot, 'channel_name');
      aData.LastFullScanUtc := ParseRequiredUtc(
        JsonText(lRoot, 'last_full_scan_utc'), 'last_full_scan_utc');
      aData.LastIncrementalScanUtc := ParseOptionalUtc(
        JsonText(lRoot, 'last_incremental_scan_utc'),
        'last_incremental_scan_utc');
      if not (lRoot.Values['videos'] is TJSONArray) then
        Exit;
      lArray := TJSONArray(lRoot.Values['videos']);
      SetLength(aData.Videos, lArray.Count);
      for I := 0 to lArray.Count - 1 do
      begin
        if not (lArray.Items[I] is TJSONObject) then
          Exit;
        lItem := TJSONObject(lArray.Items[I]);
        aData.Videos[I].VideoId := JsonText(lItem, 'video_id');
        aData.Videos[I].Url := JsonText(lItem, 'url');
        aData.Videos[I].PublishedAt := JsonText(lItem, 'published_at');
        if not TryStrToInt64(JsonText(lItem, 'published_unix'),
          aData.Videos[I].PublishedUnix) then
          Exit;
      end;
      aData := Normalize(aData);
      Result := True;
    except
      on E: EChannelIndexError do
        Result := False;
      on E: EJSONParseException do
        Result := False;
    end;
  finally
    lRoot.Free;
  end;
end;

class function TChannelIndexStore.Serialize(
  const aData: TChannelIndexData): string;
var
  lRoot, lItem: TJSONObject;
  lArray: TJSONArray;
  lVideo: TChannelIndexVideo;
begin
  lRoot := TJSONObject.Create;
  try
    lRoot.AddPair('schema', TJSONNumber.Create(CChannelIndexSchema));
    lRoot.AddPair('source_url', aData.SourceUrl);
    lRoot.AddPair('channel_id', aData.ChannelId);
    lRoot.AddPair('channel_name', aData.ChannelName);
    lRoot.AddPair('last_full_scan_utc', DateToISO8601(
      aData.LastFullScanUtc, True));
    if aData.LastIncrementalScanUtc > 0 then
      lRoot.AddPair('last_incremental_scan_utc', DateToISO8601(
        aData.LastIncrementalScanUtc, True))
    else
      lRoot.AddPair('last_incremental_scan_utc', '');
    lArray := TJSONArray.Create;
    try
      lRoot.AddPair('videos', lArray);
    except
      lArray.Free;
      raise;
    end;
    for lVideo in aData.Videos do
    begin
      lItem := TJSONObject.Create;
      try
        lItem.AddPair('video_id', lVideo.VideoId);
        lItem.AddPair('url', lVideo.Url);
        lItem.AddPair('published_at', lVideo.PublishedAt);
        lItem.AddPair('published_unix', TJSONNumber.Create(lVideo.PublishedUnix));
        lArray.AddElement(lItem);
      except
        lItem.Free;
        raise;
      end;
    end;
    Result := lRoot.Format(2);
  finally
    lRoot.Free;
  end;
end;

constructor TChannelIndexStore.Create(const aChannelDirectory: string);
var
  lDirectory: string;
begin
  inherited Create;
  lDirectory := TPath.GetFullPath(aChannelDirectory);
  FFileName := TPath.Combine(lDirectory, CChannelIndexFileName);
  FBackupFileName := FFileName + '.bak';
end;

function TChannelIndexStore.LoadFile(const aFileName: string;
  out aData: TChannelIndexData): Boolean;
var
  lText: string;
begin
  Result := False;
  if not TFile.Exists(aFileName) then
    Exit;
  try
    lText := TFile.ReadAllText(aFileName, TEncoding.UTF8);
    Result := Parse(lText, aData);
  except
    on E: EFileNotFoundException do
      Result := False;
    on E: EPathNotFoundException do
      Result := False;
    on E: EEncodingError do
      Result := False;
    on E: EOSError do
      Result := False;
  end;
end;

function TChannelIndexStore.Load(out aData: TChannelIndexData): Boolean;
begin
  Result := LoadFile(FFileName, aData);
  if not Result then
    Result := LoadFile(FBackupFileName, aData);
end;

procedure TChannelIndexStore.Save(const aData: TChannelIndexData);
var
  lNormalized, lValidated, lExisting: TChannelIndexData;
  lText, lTempFileName, lBackupTempFileName: string;
  lStream: TFileStream;
  lPrimaryIsValid: Boolean;
  lReplaced: Boolean;
begin
  lNormalized := Normalize(aData);
  lText := Serialize(lNormalized);
  if not Parse(lText, lValidated) then
    raise EChannelIndexError.Create('Serialized channel index failed validation');

  TDirectory.CreateDirectory(ExtractFileDir(FFileName));
  lTempFileName := FFileName + '.' + TPath.GetGUIDFileName + '.tmp';
  lBackupTempFileName := '';
  lReplaced := False;
  try
    TFile.WriteAllText(lTempFileName, lText, TEncoding.UTF8);
    lStream := TFileStream.Create(lTempFileName,
      fmOpenReadWrite or fmShareExclusive);
    try
      if not FlushFileBuffers(lStream.Handle) then
        RaiseLastOSError;
    finally
      lStream.Free;
    end;
    if not LoadFile(lTempFileName, lValidated) then
      raise EChannelIndexError.Create('Temporary channel index failed validation');

    lPrimaryIsValid := LoadFile(FFileName, lExisting);
    if lPrimaryIsValid then
    begin
      lBackupTempFileName := FBackupFileName + '.' +
        TPath.GetGUIDFileName + '.tmp';
      if not CopyFile(PChar(FFileName), PChar(lBackupTempFileName), False) then
        RaiseLastOSError;
      if not LoadFile(lBackupTempFileName, lExisting) then
        raise EChannelIndexError.Create(
          'Temporary channel index backup failed validation');
    end;
    if not MoveFileEx(PChar(lTempFileName), PChar(FFileName),
      MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then
      RaiseLastOSError;
    lReplaced := True;
    if (lBackupTempFileName <> '') and
       not MoveFileEx(PChar(lBackupTempFileName), PChar(FBackupFileName),
         MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then
      RaiseLastOSError;
  except
    on E: Exception do
      raise EChannelIndexError.CreateFmt(
        'Unable to save channel index; candidate preserved at %s: %s',
        [lTempFileName, E.Message]);
  end;
  if lReplaced and TFile.Exists(lTempFileName) then
    TFile.Delete(lTempFileName);
  if lReplaced and (lBackupTempFileName <> '') and
     TFile.Exists(lBackupTempFileName) then
    TFile.Delete(lBackupTempFileName);
end;

end.
