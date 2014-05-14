object ReportForm: TReportForm
  Left = 0
  Top = 0
  Caption = 'ReportForm'
  ClientHeight = 562
  ClientWidth = 929
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter2: TSplitter
    Left = 593
    Top = 0
    Width = 7
    Height = 562
    Align = alRight
    Beveled = True
    ResizeStyle = rsUpdate
    ExplicitLeft = 683
  end
  object TreeView1: TTreeView
    Left = 600
    Top = 0
    Width = 329
    Height = 562
    Align = alRight
    Indent = 19
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 593
    Height = 562
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 1
    object Splitter1: TSplitter
      Left = 1
      Top = 249
      Width = 591
      Height = 10
      Cursor = crVSplit
      Align = alTop
      Beveled = True
      ResizeStyle = rsUpdate
      ExplicitWidth = 689
    end
    object Memo1: TMemo
      Left = 1
      Top = 1
      Width = 591
      Height = 248
      Align = alTop
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
    object StringGrid1: TStringGrid
      Left = 1
      Top = 259
      Width = 591
      Height = 302
      Align = alClient
      FixedCols = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSizing, goColSizing, goEditing, goTabs]
      TabOrder = 1
    end
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
    object XML1: TMenuItem
      Caption = 'XML'
    end
    object ExportToExcel1: TMenuItem
      Caption = 'ExportToExcel'
      OnClick = ExportToExcel1Click
    end
  end
  object SaveDialog1: TSaveDialog
    Left = 784
    Top = 534
  end
  object XMLDocument1: TXMLDocument
    Left = 432
    Top = 88
    DOMVendorDesc = 'MSXML'
  end
end
