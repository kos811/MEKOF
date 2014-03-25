unit ReportFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Menus, MainFormUnit;

type
  TReportForm = class(TForm)
    MainMenu1: TMainMenu;
    SaveToFile1: TMenuItem;
    Memo1: TMemo;
    SaveDialog1: TSaveDialog;
    WordWrap1: TMenuItem;
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

Procedure TReportForm.ShowRep(aRec: TMekofRecord);
  function MakeDefString(MarkerPos: String; MarkerPart: string;
    MarkerFullDef: string): string;
  begin
    Result := format('[%s]'#9'[%d]'#9#39'%s'#39#9'%s',
      [MarkerPos, Length(MarkerPart), MarkerPart, MarkerFullDef]);
  end;
  function GetTerm(i: integer; Naim: string; Tag: string; Chop: string;
    indicator: string; identificator: string; FSP: string; FieldLen: string;
    val: string): string;
  begin
    Result := format('%d'#9'%s'#9'%s'#9'%s'#9'%s'#9'%s'#9#9'%s'#9'%s'#9'%s',
      [i, Naim, Tag, Chop, indicator, identificator, FSP, FieldLen, val]);
  end;

var
  Temp: string;
  i, j: integer;
  Naim: string;
  delim:string;
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
  Temp := '№ п/п' + #9 + 'Наименование' + #9 + 'Метка' + #9 + 'ЧОП' + #9 +
    'Индикатор' + #9 + 'Идентификатор' + #9 + 'Адрес' + #9 + 'Длина' + #9 +
    'Значение';
  Memo1.Lines.Add(Temp);
  for i := 0 to Rec.Fields.Length - 1 do
    with Rec.Fields.Fields[i].Description do
      begin
        Naim := '-'#9;
        Temp := Rec.Fields.Fields[i].Value;
        delim :=#13#10#9#9#9#9#9#9#9#9#9#9#9;
        Temp := StringReplace(Temp, '+', delim+'+', [rfReplaceAll]);
        delete(temp,pos(delim,temp),System.Length(delim));
        { for j := 0 to Rec.Fields.Fields[i].Values.Count - 1 do
          Memo1.Lines.Add(GetTerm(i + 1, Naim, Tag, Chop,
          Rec.Fields.Fields[i].indicator, Rec.Fields.Fields[i].identificator,
          inttostr(StartPos), inttostr(Length),
          Rec.Fields.Fields[i].Values[j])); }
        Memo1.Lines.Add(GetTerm(i + 1, Naim, Tag, Chop,
          Rec.Fields.Fields[i].indicator, Rec.Fields.Fields[i].identificator + #9,
          inttostr(StartPos), inttostr(Length), temp));
      end;
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
