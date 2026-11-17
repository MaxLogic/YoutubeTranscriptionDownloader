object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'yttrans - YouTube transcripts'
  ClientHeight = 521
  ClientWidth = 884
  Color = clBtnFace
  Constraints.MinHeight = 300
  Constraints.MinWidth = 600
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  ActiveControl = EditUrl
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object SplitterMain: TSplitter
    Left = 320
    Top = 40
    Width = 5
    Height = 481
    MinSize = 150
    ResizeStyle = rsUpdate
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 884
    Height = 40
    Align = alTop
    BevelOuter = bvNone
    Padding.Left = 8
    Padding.Top = 8
    Padding.Right = 8
    Padding.Bottom = 8
    ShowCaption = False
    TabOrder = 0
    object ButtonDownload: TButton
      AlignWithMargins = True
      Left = 780
      Top = 8
      Width = 96
      Height = 24
      Margins.Left = 8
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alRight
      Caption = '&Download'
      Default = True
      TabOrder = 1
      OnClick = ButtonDownloadClick
    end
    object EditUrl: TEdit
      Left = 38
      Top = 8
      Width = 734
      Height = 24
      Align = alClient
      TabOrder = 0
      TextHint = 'Paste a YouTube video URL and press Enter'
    end
    object LabelUrl: TStaticText
      AlignWithMargins = True
      Left = 8
      Top = 11
      Width = 28
      Height = 21
      Margins.Left = 0
      Margins.Top = 3
      Margins.Right = 6
      Margins.Bottom = 0
      Align = alLeft
      AutoSize = False
      Caption = '&URL:'
      FocusControl = EditUrl
      TabStop = False
    end
  end
  object PanelItems: TPanel
    Left = 0
    Top = 40
    Width = 320
    Height = 481
    Align = alLeft
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 1
    object ListBoxItems: TListBox
      Left = 0
      Top = 23
      Width = 320
      Height = 458
      Align = alClient
      IntegralHeight = False
      ItemHeight = 15
      TabOrder = 0
      OnClick = ListBoxItemsClick
      OnKeyDown = ListBoxItemsKeyDown
    end
    object LabelItems: TStaticText
      AlignWithMargins = True
      Left = 8
      Top = 3
      Width = 304
      Height = 17
      Margins.Left = 8
      Margins.Right = 8
      Align = alTop
      AutoSize = False
      Caption = '&List of downloads'
      FocusControl = ListBoxItems
      TabStop = False
    end
  end
  object PanelTranscript: TPanel
    Left = 325
    Top = 40
    Width = 559
    Height = 481
    Align = alClient
    BevelOuter = bvNone
    ShowCaption = False
    TabOrder = 2
    object MemoTranscript: TMemo
      Left = 0
      Top = 23
      Width = 559
      Height = 458
      Align = alClient
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
      OnKeyDown = MemoTranscriptKeyDown
    end
    object LabelTranscript: TStaticText
      AlignWithMargins = True
      Left = 8
      Top = 3
      Width = 543
      Height = 17
      Margins.Left = 8
      Margins.Right = 8
      Align = alTop
      AutoSize = False
      Caption = '&Memo transcript'
      FocusControl = MemoTranscript
      TabStop = False
    end
  end
end
