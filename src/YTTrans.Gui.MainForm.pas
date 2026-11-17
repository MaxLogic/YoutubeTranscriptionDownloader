unit YTTrans.Gui.MainForm;

// yttransgui main window (YTD-039): submits single-video URLs to yttrans.exe
// and shows the downloaded transcripts. Orchestration only; see
// YTTrans.Gui.Downloads for the worker and helpers.

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ExtCtrls,
  YTTrans.Gui.Downloads;

type
  TMainForm = class(TForm)
    PanelTop: TPanel;
    LabelUrl: TStaticText;
    ButtonDownload: TButton;
    EditUrl: TEdit;
    PanelItems: TPanel;
    ListBoxItems: TListBox;
    LabelItems: TStaticText;
    PanelTranscript: TPanel;
    LabelTranscript: TStaticText;
    SplitterMain: TSplitter;
    MemoTranscript: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ButtonDownloadClick(Sender: TObject);
    procedure ListBoxItemsClick(Sender: TObject);
    procedure ListBoxItemsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure MemoTranscriptKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FItems: TObjectList<TDownloadItem>;
    FRemovedItems: TObjectList<TDownloadItem>;
    FNextItemId: Integer;
    FThreads: TList<TDownloadThread>; // started and not yet finished
    FSessionDir, FExePath: string;
    FJob: THandle;
    FRunning: Integer;
    FFirstDone, FClosing: Boolean;
    procedure StartQueued;
    procedure StartItem(aIndex: Integer);
    procedure DownloadFinished(Sender: TObject);
    procedure RefreshItem(aIndex: Integer);
    procedure ShowItem(aIndex: Integer);
  public
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  System.IOUtils, System.Diagnostics, YTTrans.FrontMatter;

const
  // two parallel children at most; each child paces only itself
  CMaxParallel = 2;
  CCloseWaitMs = 10000;
  // the memo does not word-wrap; long yttrans error lines are broken here
  CFailureWrapWidth = 100;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FItems := TObjectList<TDownloadItem>.Create(True);
  FRemovedItems := TObjectList<TDownloadItem>.Create(True);
  FThreads := TList<TDownloadThread>.Create;
  FExePath := TPath.Combine(ExtractFilePath(ParamStr(0)), 'yttrans.exe');
  FSessionDir := TPath.Combine(TPath.GetTempPath, CSessionFolderPrefix +
    TGUID.NewGuid.ToString.Replace('{', '').Replace('}', ''));
  TDirectory.CreateDirectory(FSessionDir);
  // children (and their yt-dlp/JS grandchildren) die with this handle
  FJob := CreateKillOnCloseJob;
end;

destructor TMainForm.Destroy;
begin
  FThreads.Free;
  FItems.Free;
  FRemovedItems.Free;
  inherited;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  lWatch: TStopwatch;
  lThread: TDownloadThread;
begin
  FClosing := True;
  if FJob <> 0 then
    TerminateJobObject(FJob, 1);
  lWatch := TStopwatch.StartNew;
  while (FRunning > 0) and (lWatch.ElapsedMilliseconds < CCloseWaitMs) do
  begin
    CheckSynchronize(50);
    // a child assigned to the job after the first call must die as well
    if FJob <> 0 then
      TerminateJobObject(FJob, 1);
  end;
  // a thread still running past the deadline must not call into this form
  for lThread in FThreads do
    lThread.OnTerminate := nil;
  FThreads.Clear;
  if FJob <> 0 then
  begin
    CloseHandle(FJob);
    FJob := 0;
  end;
  DeleteSessionFolder(FSessionDir);
end;

procedure TMainForm.ButtonDownloadClick(Sender: TObject);
var
  lUrl: string;
  lIndex: Integer;
  lItem: TDownloadItem;
begin
  lUrl := NormalizeUrlInput(EditUrl.Text);
  if lUrl = '' then
    Exit;
  lIndex := IndexOfUrl(FItems, lUrl);
  if lIndex >= 0 then
  begin
    lItem := FItems[lIndex];
    if lItem.Status = dsFailed then
    begin
      if FileExists(lItem.TranscriptPath) then
        System.SysUtils.DeleteFile(lItem.TranscriptPath);
      lItem.Status := dsQueued;
      lItem.Output := '';
      RefreshItem(lIndex);
    end;
  end
  else
  begin
    lItem := TDownloadItem.Create;
    lItem.Url := lUrl;
    Inc(FNextItemId);
    lItem.TranscriptPath := TPath.Combine(FSessionDir,
      IntToStr(FNextItemId) + '.md');
    lItem.Status := dsQueued;
    lIndex := FItems.Add(lItem);
    ListBoxItems.Items.Add(DownloadDisplayText(lItem));
  end;
  EditUrl.Clear;
  EditUrl.SetFocus;
  ListBoxItems.ItemIndex := lIndex;
  ShowItem(lIndex);
  StartQueued;
end;

procedure TMainForm.ListBoxItemsClick(Sender: TObject);
begin
  ShowItem(ListBoxItems.ItemIndex);
end;

procedure TMainForm.ListBoxItemsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  lIndex: Integer;
  lItem: TDownloadItem;
begin
  if (Key <> VK_DELETE) or (Shift <> []) then
    Exit;
  Key := 0;
  lIndex := ListBoxItems.ItemIndex;
  if (lIndex < 0) or (lIndex >= FItems.Count) then
    Exit;
  lItem := FItems[lIndex];
  // A running thread retains this item until its completion callback.
  if lItem.Status = dsDownloading then
    FRemovedItems.Add(FItems.Extract(lItem))
  else
    FItems.Delete(lIndex);
  ListBoxItems.Items.Delete(lIndex);
  if lIndex >= FItems.Count then
    lIndex := FItems.Count - 1;
  ListBoxItems.ItemIndex := lIndex;
  ShowItem(lIndex);
end;

procedure TMainForm.MemoTranscriptKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Ord('A')) and (Shift = [ssCtrl]) then
  begin
    MemoTranscript.SelectAll;
    Key := 0;
  end;
end;

procedure TMainForm.StartQueued;
var
  lLimit, i: Integer;
begin
  if FClosing then
    Exit;
  // until the first child has finished, run one at a time so a due yt-dlp
  // self-update and its settings.ini write happen in one process only
  if FFirstDone then
    lLimit := CMaxParallel
  else
    lLimit := 1;
  for i := 0 to FItems.Count - 1 do
  begin
    if FRunning >= lLimit then
      Break;
    if FItems[i].Status = dsQueued then
      StartItem(i);
  end;
end;

procedure TMainForm.StartItem(aIndex: Integer);
var
  lItem: TDownloadItem;
  lThread: TDownloadThread;
begin
  lItem := FItems[aIndex];
  lThread := TDownloadThread.Create;
  lThread.ExePath := FExePath;
  lThread.Arguments := BuildYtTransArguments(lItem.Url, lItem.TranscriptPath);
  lThread.Job := FJob;
  lThread.Item := lItem;
  lThread.OnTerminate := DownloadFinished;
  lItem.Status := dsDownloading;
  FThreads.Add(lThread);
  Inc(FRunning);
  RefreshItem(aIndex);
  lThread.Start;
end;

procedure TMainForm.DownloadFinished(Sender: TObject);
var
  lThread: TDownloadThread;
  lItem: TDownloadItem;
  lIndex: Integer;
begin
  lThread := Sender as TDownloadThread;
  FThreads.Remove(lThread);
  Dec(FRunning);
  lItem := lThread.Item;
  if FRemovedItems.Contains(lItem) then
  begin
    FRemovedItems.Remove(lItem);
    FFirstDone := True;
    StartQueued;
    Exit;
  end;
  if FClosing then
    Exit;
  lItem := lThread.Item;
  if lThread.StartError <> '' then
  begin
    lItem.Status := dsFailed;
    lItem.Output := lThread.StartError;
  end
  else if (lThread.ExitCode = 0) and FileExists(lItem.TranscriptPath) then
  begin
    lItem.Status := dsDone;
    try
      lItem.Title := Trim(ReadFrontMatterValue(lItem.TranscriptPath, 'title'));
    except
      lItem.Title := ''; // the display falls back to the URL
    end;
  end
  else
  begin
    lItem.Status := dsFailed;
    lItem.Output := FailureOutput(lThread.ExitCode, lThread.StdOut,
      lThread.StdErr);
  end;
  lIndex := FItems.IndexOf(lItem);
  if lIndex >= 0 then
    RefreshItem(lIndex);
  FFirstDone := True;
  StartQueued;
end;

procedure TMainForm.RefreshItem(aIndex: Integer);
begin
  ListBoxItems.Items[aIndex] := DownloadDisplayText(FItems[aIndex]);
  if ListBoxItems.ItemIndex = aIndex then
    ShowItem(aIndex);
end;

procedure TMainForm.ShowItem(aIndex: Integer);
var
  lItem: TDownloadItem;
begin
  if (aIndex < 0) or (aIndex >= FItems.Count) then
  begin
    MemoTranscript.Clear;
    Exit;
  end;
  lItem := FItems[aIndex];
  case lItem.Status of
    dsQueued: MemoTranscript.Text := 'Queued: ' + lItem.Url;
    dsDownloading: MemoTranscript.Text := 'Downloading: ' + lItem.Url;
    dsDone:
      try
        MemoTranscript.Lines.LoadFromFile(lItem.TranscriptPath, TEncoding.UTF8);
      except
        on E: Exception do
          MemoTranscript.Text := E.Message;
      end;
  else
    MemoTranscript.Text := 'Failed: ' + lItem.Url + sLineBreak + sLineBreak +
      WrapText(lItem.Output, sLineBreak, [' ', #9], CFailureWrapWidth);
  end;
end;

end.
