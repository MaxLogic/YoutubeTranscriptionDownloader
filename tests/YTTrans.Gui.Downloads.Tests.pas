unit YTTrans.Gui.Downloads.Tests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TYTTransGuiDownloadsTests = class
  public
    // YTD-039
    [Test] procedure DisplayTextCoversEveryStatus;
    [Test] procedure NormalizeUrlInputTrimsAndUnquotes;
    [Test] procedure BuildYtTransArgumentsQuotesAndEscapes;
    [Test] procedure FailureOutputJoinsOrFallsBack;
    [Test] procedure IndexOfUrlIsCaseSensitive;
    [Test] procedure SessionFolderGuardAcceptsOnlyOwnTempChild;
    [Test] procedure DeleteSessionFolderRemovesOwnFolder;
    [Test] procedure DeleteSessionFolderNeverFollowsJunctions;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.Generics.Collections,
  Winapi.Windows, YTTrans.Gui.Downloads, YTTrans.ProcessRunner;

procedure CreateJunction(const aLink, aTarget: string);
var
  lCmd, lOut, lErr: string;
  lExitCode: Integer;
begin
  SetLength(lCmd, MAX_PATH);
  SetLength(lCmd, GetSystemDirectory(PChar(lCmd), MAX_PATH));
  lExitCode := RunConsoleProcess(IncludeTrailingPathDelimiter(lCmd) + 'cmd.exe',
    Format('/d /c mklink /J "%s" "%s"', [aLink, aTarget]), lOut, lErr);
  Assert.AreEqual(0, lExitCode, 'mklink /J: ' + lOut + lErr);
end;

function NewItem(const aUrl: string; aStatus: TDownloadStatus;
  const aTitle: string = ''): TDownloadItem;
begin
  Result := TDownloadItem.Create;
  Result.Url := aUrl;
  Result.Status := aStatus;
  Result.Title := aTitle;
end;

procedure TYTTransGuiDownloadsTests.DisplayTextCoversEveryStatus;
const
  CUrl = 'https://www.youtube.com/watch?v=jNQXAC9IVRw';
var
  lItem: TDownloadItem;
begin
  lItem := NewItem(CUrl, dsQueued, 'Me at the zoo');
  try
    Assert.AreEqual('[queued] ' + CUrl, DownloadDisplayText(lItem));
    lItem.Status := dsDownloading;
    Assert.AreEqual('[downloading] ' + CUrl, DownloadDisplayText(lItem));
    lItem.Status := dsDone;
    Assert.AreEqual('[done] Me at the zoo', DownloadDisplayText(lItem));
    lItem.Title := '';
    Assert.AreEqual('[done] ' + CUrl, DownloadDisplayText(lItem));
    lItem.Status := dsFailed;
    lItem.Title := 'ignored';
    Assert.AreEqual('[failed] ' + CUrl, DownloadDisplayText(lItem));
  finally
    lItem.Free;
  end;
end;

procedure TYTTransGuiDownloadsTests.NormalizeUrlInputTrimsAndUnquotes;
begin
  Assert.AreEqual('https://x/y', NormalizeUrlInput('  https://x/y '#9));
  Assert.AreEqual('https://x/y', NormalizeUrlInput(' " https://x/y " '));
  Assert.AreEqual('"a"', NormalizeUrlInput('""a""'), 'only one pair is stripped');
  Assert.AreEqual('', NormalizeUrlInput('   '));
  Assert.AreEqual('', NormalizeUrlInput('""'));
  Assert.AreEqual('"', NormalizeUrlInput('"'));
end;

procedure TYTTransGuiDownloadsTests.BuildYtTransArgumentsQuotesAndEscapes;
begin
  Assert.AreEqual('"https://www.youtube.com/watch?v=abc" -o "C:\T\yttransgui-1\1.md" -meta',
    BuildYtTransArguments('https://www.youtube.com/watch?v=abc',
    'C:\T\yttransgui-1\1.md'));
  Assert.AreEqual('"https://x/?q=%22a%22" -o "f.md" -meta',
    BuildYtTransArguments('https://x/?q="a"', 'f.md'));
end;

procedure TYTTransGuiDownloadsTests.FailureOutputJoinsOrFallsBack;
begin
  Assert.AreEqual('yttrans exited with code 3 without output.',
    FailureOutput(3, ' '#13#10, ''));
  Assert.AreEqual('Error: boom', FailureOutput(1, 'Error: boom'#13#10, ''));
  Assert.AreEqual('warn', FailureOutput(1, '', #13#10'warn'#13#10));
  Assert.AreEqual('Error: boom' + sLineBreak + 'warn',
    FailureOutput(1, 'Error: boom'#13#10, 'warn'#13#10));
end;

procedure TYTTransGuiDownloadsTests.IndexOfUrlIsCaseSensitive;
var
  lItems: TObjectList<TDownloadItem>;
begin
  lItems := TObjectList<TDownloadItem>.Create(True);
  try
    lItems.Add(NewItem('https://youtu.be/abcDEF', dsDone));
    lItems.Add(NewItem('https://youtu.be/ABCdef', dsFailed));
    Assert.AreEqual(0, IndexOfUrl(lItems, 'https://youtu.be/abcDEF'));
    Assert.AreEqual(1, IndexOfUrl(lItems, 'https://youtu.be/ABCdef'));
    Assert.AreEqual(-1, IndexOfUrl(lItems, 'https://youtu.be/abcdef'));
  finally
    lItems.Free;
  end;
end;

procedure TYTTransGuiDownloadsTests.SessionFolderGuardAcceptsOnlyOwnTempChild;
const
  CTemp = 'C:\Users\u\AppData\Local\Temp\';
begin
  Assert.IsTrue(IsSessionFolder(CTemp + 'yttransgui-1234', CTemp));
  Assert.IsTrue(IsSessionFolder(CTemp + 'yttransgui-1234\', ExcludeTrailingPathDelimiter(CTemp)));
  Assert.IsFalse(IsSessionFolder(CTemp + 'yttransgui-', CTemp), 'bare prefix');
  Assert.IsFalse(IsSessionFolder(CTemp + 'other-1234', CTemp), 'foreign name');
  Assert.IsFalse(IsSessionFolder(CTemp + 'x\yttransgui-1234', CTemp), 'nested');
  Assert.IsFalse(IsSessionFolder(CTemp, CTemp), 'the temp folder itself');
  Assert.IsFalse(IsSessionFolder('D:\yttransgui-1234', CTemp), 'other parent');
  Assert.IsFalse(IsSessionFolder(CTemp + 'yttransgui-1234', ''), 'no temp path');
end;

procedure TYTTransGuiDownloadsTests.DeleteSessionFolderRemovesOwnFolder;
var
  lDir, lForeign: string;
begin
  lDir := TPath.Combine(TPath.GetTempPath, CSessionFolderPrefix +
    TGUID.NewGuid.ToString);
  lForeign := TPath.Combine(TPath.GetTempPath, 'yttrans-guard-' +
    TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(lDir);
  TDirectory.CreateDirectory(lForeign);
  try
    TFile.WriteAllText(TPath.Combine(lDir, '1.md'), 'x');
    DeleteSessionFolder(lDir);
    DeleteSessionFolder(lForeign);
    Assert.IsFalse(TDirectory.Exists(lDir), 'session folder must be removed');
    Assert.IsTrue(TDirectory.Exists(lForeign), 'foreign folder must stay');
  finally
    if TDirectory.Exists(lDir) then
      TDirectory.Delete(lDir, True);
    TDirectory.Delete(lForeign, True);
  end;
end;

procedure TYTTransGuiDownloadsTests.DeleteSessionFolderNeverFollowsJunctions;
var
  lRoot, lTarget, lDir, lLinkedDir: string;
begin
  // the victim folder lives outside the temp-root naming guard
  lRoot := TPath.Combine(TPath.GetTempPath, 'yttrans-junction-' +
    TGUID.NewGuid.ToString);
  lTarget := TPath.Combine(lRoot, 'target');
  lDir := TPath.Combine(TPath.GetTempPath, CSessionFolderPrefix +
    TGUID.NewGuid.ToString);
  lLinkedDir := TPath.Combine(TPath.GetTempPath, CSessionFolderPrefix +
    TGUID.NewGuid.ToString);
  TDirectory.CreateDirectory(lTarget);
  TFile.WriteAllText(TPath.Combine(lTarget, 'keep.txt'), 'x');
  TDirectory.CreateDirectory(lDir);
  try
    TFile.WriteAllText(TPath.Combine(lDir, '1.md'), 'x');
    CreateJunction(TPath.Combine(lDir, 'link'), lTarget);
    CreateJunction(lLinkedDir, lTarget);

    DeleteSessionFolder(lDir);
    DeleteSessionFolder(lLinkedDir);

    Assert.IsTrue(TFile.Exists(TPath.Combine(lTarget, 'keep.txt')),
      'a junction target was emptied');
    Assert.IsFalse(TFile.Exists(TPath.Combine(lDir, '1.md')),
      'plain files of the session folder are deleted');
    Assert.IsTrue(TDirectory.Exists(lDir),
      'a folder holding a junction stays');
    Assert.IsTrue(TDirectory.Exists(lLinkedDir), 'a linked folder is refused');
  finally
    // RemoveDirectory removes a junction itself, never its target
    RemoveDirectory(PChar(TPath.Combine(lDir, 'link')));
    RemoveDirectory(PChar(lLinkedDir));
    RemoveDirectory(PChar(lDir));
    TFile.Delete(TPath.Combine(lTarget, 'keep.txt'));
    RemoveDirectory(PChar(lTarget));
    RemoveDirectory(PChar(lRoot));
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TYTTransGuiDownloadsTests);

end.
