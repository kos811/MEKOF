object ReportForm: TReportForm
  Left = 0
  Top = 0
  Caption = 'ReportForm'
  ClientHeight = 562
  ClientWidth = 812
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 812
    Height = 562
    Align = alClient
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object MainMenu1: TMainMenu
    Left = 200
    Top = 64
    object SaveToFile1: TMenuItem
      Caption = 'SaveToFile'
      OnClick = SaveToFile1Click
    end
    object WordWrap1: TMenuItem
      Caption = 'WordWrap'
      OnClick = WordWrap1Click
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 784
    Top = 534
  end
end
