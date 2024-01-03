object frmSample: TfrmSample
  Left = 0
  Top = 0
  Caption = 'Sample'
  ClientHeight = 291
  ClientWidth = 765
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 15
  object lbSubscribe1: TLabel
    Left = 176
    Top = 8
    Width = 64
    Height = 15
    Caption = 'Subscriber 1'
  end
  object lbSubscribe2: TLabel
    Left = 376
    Top = 8
    Width = 64
    Height = 15
    Caption = 'Subscriber 2'
  end
  object lbSubscribe3: TLabel
    Left = 576
    Top = 8
    Width = 64
    Height = 15
    Caption = 'Subscriber 3'
  end
  object lbPublisher: TLabel
    Left = 8
    Top = 8
    Width = 49
    Height = 15
    Caption = 'Publisher'
  end
  object lbTotalPushed: TLabel
    Left = 8
    Top = 186
    Width = 102
    Height = 15
    Caption = 'Total pushed items:'
  end
  object lbTotalPopped: TLabel
    Left = 8
    Top = 207
    Width = 104
    Height = 15
    Caption = 'Total popped items:'
  end
  object lbQueueSize: TLabel
    Left = 8
    Top = 228
    Width = 61
    Height = 15
    Caption = 'Queue Size:'
  end
  object btnSubscribe1: TButton
    Left = 176
    Top = 220
    Width = 185
    Height = 25
    Caption = 'Subscribe 1'
    TabOrder = 0
    OnClick = btnSubscribe1Click
  end
  object btnSubscribe2: TButton
    Left = 376
    Top = 220
    Width = 185
    Height = 25
    Caption = 'Subscribe 2'
    TabOrder = 1
    OnClick = btnSubscribe2Click
  end
  object mmSubscribe1: TMemo
    Left = 176
    Top = 29
    Width = 185
    Height = 185
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 2
  end
  object mmSubscribe2: TMemo
    Left = 376
    Top = 29
    Width = 185
    Height = 185
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object mmSubscribe3: TMemo
    Left = 581
    Top = 29
    Width = 185
    Height = 185
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -9
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 4
  end
  object btnSubscribe3: TButton
    Left = 584
    Top = 220
    Width = 177
    Height = 25
    Caption = 'Subscribe 3'
    TabOrder = 5
    OnClick = btnSubscribe3Click
  end
  object edtPublisher: TEdit
    Left = 8
    Top = 29
    Width = 153
    Height = 23
    TabOrder = 6
  end
  object btnPublish: TButton
    Left = 8
    Top = 64
    Width = 153
    Height = 25
    Caption = 'Publish data'
    TabOrder = 7
    OnClick = btnPublishClick
  end
  object cbAutoPublish: TCheckBox
    Left = 8
    Top = 112
    Width = 113
    Height = 17
    Caption = 'Spam messages'
    TabOrder = 8
    OnClick = cbAutoPublishClick
  end
  object cbStatistics: TCheckBox
    Left = 8
    Top = 147
    Width = 97
    Height = 17
    Caption = 'Enable statistics'
    TabOrder = 9
    OnClick = cbStatisticsClick
  end
  object btnUnsubscribe1: TButton
    Left = 176
    Top = 251
    Width = 185
    Height = 25
    Caption = 'Unsubscribe 1'
    TabOrder = 10
    OnClick = btnUnsubscribe1Click
  end
  object btnUnsubscribe2: TButton
    Left = 376
    Top = 251
    Width = 185
    Height = 25
    Caption = 'Unsubscribe 2'
    TabOrder = 11
    OnClick = btnUnsubscribe2Click
  end
  object btnUnsubscribe3: TButton
    Left = 584
    Top = 251
    Width = 177
    Height = 25
    Caption = 'Unsubscribe 3'
    TabOrder = 12
    OnClick = btnUnsubscribe3Click
  end
end
