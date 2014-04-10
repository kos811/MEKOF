unit ReportFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, MainFormUnit,
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc, Vcl.Grids;

type
  TReportForm = class(TForm)
    MainMenu1: TMainMenu;
    SaveToFile1: TMenuItem;
    Memo1: TMemo;
    SaveDialog1: TSaveDialog;
    WordWrap1: TMenuItem;
    XMLDocument1: TXMLDocument;
    XML1: TMenuItem;
    StringGrid1: TStringGrid;
    procedure SaveToFile1Click(Sender: TObject);
    procedure WordWrap1Click(Sender: TObject);
  private
    { Private declarations }
    Rec: TMekofRecord;
  public
    Procedure ShowRep(aRec: TMekofRecord);
    { Public declarations }
  end;

var
  ReportForm: TReportForm;

implementation

{$R *.dfm}

function GetNaim(Code: integer): string;
begin
  case Code of
    001:
      result := 'Идентификатор подзаписи';
    002:
      result := 'Указатель подзаписей';
    004:
      result := 'Обозначение внешней базы данных';
    005:
      result := 'Обозначение заимствованной записи 010 - ISBN';
    011:
      result := 'ISSN';
    100:
      result := 'Системные данные';
    101:
      result := 'Язык документа';
    102:
      result := 'Физическая форма документа';
    200:
      result := 'Заглавие и сведения об авторстве';
    201:
      result := 'Параллельное заглавие';
    206:
      result := 'Нумерация и дата сериального издания';
    210:
      result := 'Выходные данные';
    600:
      result := 'УДК';
    610:
      result := 'МКИ';
    620:
      result := 'Рубрикатор';
    630:
      result := 'Тезаурус';
    640:
      result := 'Ключевое слово';
    650:
      result := 'Текст документа';
    660:
      result := 'Реферат (аннотация)';
    670:
      result := 'Предметная рубрика';
    700:
      result := 'Лицо с первичной интеллектуальной ответственностью';
    905:
      result := 'Хранение документаэж';
  end;

end;

Procedure TReportForm.ShowRep(aRec: TMekofRecord);
  function MakeDefString(MarkerPos: String; MarkerPart: string;
    MarkerFullDef: string): string;
  begin
    result := format('[%s]'#9'[%d]'#9#39'%s'#39#9'%s',
      [MarkerPos, Length(MarkerPart), MarkerPart, MarkerFullDef]);
  end;
  function GetTerm(D: string; i: integer; Naim: string; Tag: string;
    Chop: string; indicator: string; identificator: string; FSP: string;
    FieldLen: string; val: string): string;
  begin
    // d - Delimeter
    result := format('%d' + D + '%s' + D + '%s' + D + '%s' + D + '%s' + D + '%s'
      + D + '%s' + D + '%s' + D + '%s', [i, Naim, Tag, Chop, indicator,
      identificator, FSP, FieldLen, val]);
  end;

var
  RootNode: Xml.XMLIntf.IXMLNode;
  FieldNode: Xml.XMLIntf.IXMLNode;
  ValNode: Xml.XMLIntf.IXMLNode;
  Temp: string;
  i, j, l: integer;
  Naim: string;
  delim: string;
begin
  Rec := aRec;
  Temp := '';

  Memo1.Clear;
  Memo1.Lines.Add('Позиции'#9'Длина'#9'Текст'#9'Описание');
  for i := 0 to 11 do
  begin
    Memo1.Lines.Add(MakeDefString(MarkerPos[i], Rec.Marker[i],
      MarkerFullDef[i]));
  end;
  Memo1.Lines.Add(#13#10#9'СПРАВОЧНИК:');
  Memo1.Lines.Add('Текст'#9'Описание');
  Memo1.Lines.Add(inttostr(Rec.Fields.TermDefinition.TagLength) + #9 +
    ReferenceDef[0]);
  Memo1.Lines.Add(inttostr(Rec.Fields.TermDefinition.FieldLength) + #9 +
    ReferenceDef[1]);
  Memo1.Lines.Add(inttostr(Rec.Fields.TermDefinition.FirstSymbolPosLength) + #9
    + ReferenceDef[2]);
  Memo1.Lines.Add(inttostr(Rec.Fields.TermDefinition.ChopLength) + #9 +
    ReferenceDef[3]);
  Memo1.Lines.Add(#13#13#9'Статьи справочника:');
  for i := 0 to Rec.Fields.Length - 1 do
    Memo1.Lines.Add(Rec.Fields.Fields[i].Description.GetSource);
  StringGrid1.FixedCols := 0;
  StringGrid1.ColCount := 9;
  StringGrid1.RowCount := 2;
  StringGrid1.Fixedrows := 1;
  StringGrid1.ColWidths[8] := 500;

  StringGrid1.Cells[0, 0] := '№ п/п';
  StringGrid1.Cells[1, 0] := 'Наименование';
  StringGrid1.Cells[2, 0] := 'Метка';
  StringGrid1.Cells[3, 0] := 'ЧОП';
  StringGrid1.Cells[4, 0] := 'Индикатор';
  StringGrid1.Cells[5, 0] := 'Идентификатор';
  StringGrid1.Cells[6, 0] := 'Адрес';
  StringGrid1.Cells[7, 0] := 'Длина';
  StringGrid1.Cells[8, 0] := 'Значение';

  i := 0;
  delim := #9;
  Memo1.Lines.Add('№ п/п' + delim + 'Наименование Эл-та' + delim + 'Метка' +
    delim + 'ЧОП' + delim + 'Индикатор' + delim + 'Идентификатор' + delim +
    'Адрес' + delim + 'Длина' + delim + 'Значение');
  for i := 0 to Rec.Fields.Length - 1 do
    with Rec.Fields.Fields[i] do
    begin
      for j := 0 to Rec.Fields.Fields[i].Values.Count - 1 do
      begin
        if i > 0 then
          StringGrid1.RowCount := StringGrid1.RowCount + 1;
        l := StringGrid1.RowCount - 1;
        Temp := Rec.Fields.Fields[i].Values[j];
        if j < 1 then
        begin
          StringGrid1.Cells[0, l] := inttostr(i + 1);
          StringGrid1.Cells[1, l] := Description.Naim;
          StringGrid1.Cells[2, l] := Description.Tag;
          StringGrid1.Cells[3, l] := Description.Chop;
          StringGrid1.Cells[4, l] := indicator;
          Memo1.Lines.Add(GetTerm(#9'|', i + 1, Description.Naim,
            Description.Tag, Description.Chop, indicator, identificator[j],
            inttostr(Description.StartPos), inttostr(Description.Length),
            Rec.Fields.Fields[i].Values[j]));
        end
        else
          Memo1.Lines.Add(GetTerm(#9'|', i + 1, '', '', '', '',
            identificator[j], inttostr(Description.StartPos),
            inttostr(Description.Length), Rec.Fields.Fields[i].Values[j]));
        StringGrid1.Cells[5, l] := identificator[j];
        StringGrid1.Cells[6, l] := inttostr(Description.StartPos);
        StringGrid1.Cells[7, l] := inttostr(Description.Length);
        StringGrid1.Cells[8, l] := Rec.Fields.Fields[i].Values[j];

      end;
    end;
  //StringGrid1.
  XMLDocument1.Active := true;
  RootNode := XMLDocument1.AddChild('Record');
  for i := 0 to Rec.Fields.Length - 1 do
    for j := 0 to Rec.Fields.Fields[i].Values.Count - 1 do
    begin
      FieldNode := RootNode.AddChild('Field');
      FieldNode.Attributes['Tag'] := Rec.Fields.Fields[i].Description.Tag;
      FieldNode.Attributes['Name'] := Rec.Fields.Fields[i].Description.Naim;
      with Rec.Fields.Fields[i].Description do
      begin
        ValNode := FieldNode.AddChild('SubField');
        ValNode.Text := Rec.Fields.Fields[i].Values[j]
      end;
    end;

  Memo1.Text := Memo1.Text + XMLDocument1.Xml.Text;
  XMLDocument1.SaveToFile('LastXML.xml');
  self.Show();
end;

procedure TReportForm.WordWrap1Click(Sender: TObject);
begin
  Memo1.WordWrap := not Memo1.WordWrap;
  WordWrap1.Caption := 'WordWrap [' + BoolToStr(Memo1.WordWrap) + ']';
  if Memo1.WordWrap then
    Memo1.ScrollBars := TScrollStyle.ssVertical
  else
    Memo1.ScrollBars := TScrollStyle.ssBoth;

end;

procedure TReportForm.SaveToFile1Click(Sender: TObject);
var
  s: string;
  fl: TextFile;
begin
  if SaveDialog1.Execute() then
  begin
    s := Memo1.Text;
    AssignFile(fl, SaveDialog1.FileName);
    Rewrite(fl);
    Write(fl, s);
    CloseFile(fl);
  end;

end;

end.
