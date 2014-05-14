unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, Math, Vcl.Buttons, Vcl.ExtCtrls, Excel_TLB,
  Xml.xmldom, Xml.XMLIntf, Xml.Win.msxmldom, Xml.XMLDoc;

{$REGION 'TForm1'}

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    SourceMmo: TMemo;
    MarkerMmo: TMemo;
    ParseBtn: TMenuItem;
    Label2: TLabel;
    LoadStructBtn: TMenuItem;
    BitBtn1: TBitBtn;
    Panel1: TPanel;
    Label1: TLabel;
    ReferenceList: TListBox;
    Panel2: TPanel;
    ReferenceMemo: TMemo;
    Memo1: TMemo;
    SaveToFile1: TMenuItem;
    procedure ParseBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ReferenceListClick(Sender: TObject);
    procedure LoadStructBtnClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure SaveToFile1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
{$ENDREGION}
{$REGION 'MEKOF Definitions'}

type
  TMekofMarker = array [0 .. 11] of String;

type
  TMekofTermDef = class(TObject)
  public
    TagLength: integer;
    FieldLength: integer;
    FirstSymbolPosLength: integer;
    ChopLength: integer;
    Parent: TObject; // TMekofFieldList
    Function GetTermLength(): integer;
    Property TermLength: integer Read GetTermLength;
    Constructor Create(Parent: TObject; TagLength: integer;
      FieldLength: integer; FirstSymbolPos: integer; Chop: integer); Overload;
    Constructor Create(Parent: TObject; TagLength: string; FieldLength: string;
      FirstSymbolPos: string; Chop: string); Overload;
  end;

type
  TMekofFieldDef = class(TObject)
  public
    Tag: string;
    Length: integer;
    StartPos: integer;
    Chop: string;
    Parent: TObject; // TMekofField
    function GetNaim(): string;
    property Naim: string read GetNaim;
    function GetSource: string;
    Constructor Create(Parent: TObject; Def: string; DefAlloc: TMekofTermDef);
  end;

type
  TMekofField = class(TObject)
  private
    Source: string;
    function GetIndicator(): string;
    function GetIdentificator(): TStringList;
    function GetValues(): TStringList;
  public
    Description: TMekofFieldDef;
    Parent: TObject; // TMekofFieldList
    property Identificator: TStringList Read GetIdentificator;
    // property Value: string read Source;
    property Values: TStringList Read GetValues;
    property Indicator: string Read GetIndicator;
    Constructor Create(Parent: TObject; Description: TMekofFieldDef;
      Value: string);
  end;

type
  TMekofFieldList = Class(TObject)
  private
    function GetLength(): integer;
  public
    Fields: array of TMekofField;
    TermDefinition: TMekofTermDef;
    Parent: TObject; // TMekofRecord
    property Length: integer read GetLength;
    Constructor Create(Parent: TObject; Reference: string; TagLength: string;
      FieldLength: string; FirstSymbolPos: string; Chop: string;
      DataText: String);
  end;

type
  TMekofRecord = class(TObject)
  private
    SourceText: string;
  public
    Marker: TMekofMarker;
    Fields: TMekofFieldList;
    Titles: TXMLDocument;
    // Reference: TMekofReference;
    Constructor Create(SourceText: string);
  end;
{$ENDREGION}
{$REGION 'Const'}

const
  // MarkerDef : TMarker = ('����� ������','asd');
  MarkerPos: TMekofMarker = ('0-4', '5', '6-9', '10', '11', '12-16', '17',
    '18,19', '20', '21', '22', '23');
  MarkerFullDef: TMekofMarker =
    ('����� ������ (������� 0-4) - ���������� �������� � ������, ������� ������ � ����������� ������, ���������� ���������� ������, ������������� ������ � ����������� ����� �� ���� �������� ������; ',
    '������ ������  (������� 5) - ���� ������, ������� ������ ���� ��������� � ����������-����������� ���������� �� ���������� ������ ��������� ������, ��������, "�����" ��� "����������" ������;',
    '���� ���������� (������� 6-9) - ����, ������� ����� ���� ���������� � ����������-����������� ���������� �� ���������� ������ ���������;',
    '����� ���������� (������� 10) - ���������� �����, ������������ ���������� �������� ����������. ���� ��������� �� ������������, ����� ���������� ��������� �������� ������ ����;',
    '����� �������������� (������� 11) - ���������� �����, ������������ ���������� �������� ��������������. ������ ��� ������������ �������� �������������� ������ ���� ASCII-��� 1Fh. ���� ������������� �� ������������, ����� �������������� ��������� �������� '
    + '������ ����;',
    '������� ����� ������  (������� 12-16) - ���������� �����, ������������� ������ � ����������� �� ���� �������� ������, ����������� ����� ����� � �������� ������� ������ � �����������, ������� ����������� ���� � ����� �����������;',
    '����� �����  (������� 17) - ������, ������������ ����� ����� � ������������ ��� ������������� ������ � ������, ������� ������ ������, ����������, �����, ����������, ��������������, ����������� � ���� ������. �������� ������� ������� ������ ���� ���������'
    + '� � ���������� �� ���������� ������ ��������� ������;',
    '��������������� (������� 18, 19) - ������������ �������������;',
    '������� 20 - ���������� �����, ����������� ����� � �������� ���������� "����� ���� ������" ������ ������ �����������;',
    '������� 21 - ���������� �����, ����������� ����� � �������� ���������� "������� ���������� �������" ������ ������ �����������;',
    '������� 22 - ���������� �����, ����������� ����� � �������� ���������� "�����, ������������ ��� ����������" (���) ������ ������ �����������;',
    '������� 23 - ���������������.');
  ReferenceDef: array [0 .. 3] of string = ('�����',
    '����� ���� ������  - ������������: 1) ����� ����������� �������� (������� ��������� � ����������� ����) � ���� ������, ���������������� ������ ������, ��� 2) �����, ������������, ��� ������ ������ ����������� ��������� � ���� ������, ����� ����� �����'
    + '����� ��������� ���������� ���������� ���������� ����� (n), ������� ����� ����������� � ���������� "����� ���� ������" ������ �����������. � ����� ������ ���� ������ ��������������� ��� ����������� �� ��������� ������, ����� ������ �� �������, �� ��������'
    + '��� ���������, ����� n. ������ ����� ����� ���� ������ �����������, ���������� "�����", � "�����, ������������ ��� ����������" ���� ������, � ����� "������� ���������� �������" ��� �����, � ������� ��������� ��� ������ �����������. ������� �������� ����� '
    + '���� ������ ��������, ��� ������ ������ ���������� � ��� ����� ���� ������, ������� �� �������� ���������, � �� ����� ����� n; ��� 3) ����������� �������� (������� ����������� ����) � ��������� ����� ���� ������, ���������� � �.2. � �������, ���������'
    + ' � ��. 2 � 3, ��� ������ �����������, ����������� � ������ ������ � ���� �� ���� ������, ������ ��������� ���� �� ������ � ��� �� ������������������, ��� � ���� ����� ���� ������;',
    '������� ���������� ������� - ���������� �����, ������������ ������� ������� ������� ���� ������, ����������������� �������������� ������, ������������ �������� ������ ������ (������� ���������� ������� ������� ���� ������, ���������� ��������������� �� ��'
    + '������������, ����� ����); ',
    '�����, ������������ ��� ���������� (���) - ������������� ��� ������������� �������������� ����������, ����������� � ���� ������, ����������������� ���� ������� �����������. ');

{$ENDREGION}

var
  MainForm: TMainForm;
  Rec: TMekofRecord;

implementation

uses ReportFormUnit;

{$R *.DFM}
{$REGION 'NoClass Methods'}

function AddLeftZeros(int: integer; len: integer): string;
var
  s: string;
begin
  s := inttostr(int);
  while System.Length(s) < len do
    s := '0' + s;
  Result := s;
end;

function MakeDefString(MarkerPos: String; MarkerPart: string;
  MarkerFullDef: string): string;
begin
  Result := format('[%s]'#9'[%d]'#9#39'%s'#39#9'%s',
    [MarkerPos, Length(MarkerPart), MarkerPart, MarkerFullDef]);
end;

function ClearCLRFText(Text: string): string;
begin
  Result := stringreplace(Text, #13, '', [rfreplaceall]);
  Result := stringreplace(Result, #10, '', [rfreplaceall]);
end;

function ReferenceRep(len: integer; Text: string; capt: string): string;
begin

  Result := format('%d'#9'%s'#9'%s', [len, Text, capt]);
end;

function ThesaurusRep(Length: integer; Text: string;
  Desription: string): string;
begin
  Result := format('[%d]:'#9'%s'#9'%s', [Length, Text, Desription])
end;

function ParseMarker(Marker: string): TMekofMarker;
begin
  if Length(Marker) <> 24 then
    Raise Exception.Create('������ ������ �������� �� 24 �������� [' +
      inttostr(Length(Marker)) + '].');
  Result[0] := copy(Marker, 1, 5);
  Result[1] := copy(Marker, 6, 1);
  Result[2] := copy(Marker, 7, 4);
  Result[3] := copy(Marker, 11, 1);
  Result[4] := copy(Marker, 12, 1);
  Result[5] := copy(Marker, 13, 5);
  Result[6] := copy(Marker, 18, 1);
  Result[7] := copy(Marker, 19, 2);
  Result[8] := copy(Marker, 21, 1);
  Result[9] := copy(Marker, 22, 1);
  Result[10] := copy(Marker, 23, 1);
  Result[11] := copy(Marker, 24, 1);
end;

{$ENDREGION}
{$REGION 'Mekof methods'}
{$REGION 'TMekofTermDef'}

Constructor TMekofTermDef.Create(Parent: TObject; TagLength: integer;
  FieldLength: integer; FirstSymbolPos: integer; Chop: integer);
begin
  self.Parent := Parent;
  self.TagLength := TagLength;
  self.FieldLength := FieldLength;
  self.FirstSymbolPosLength := FirstSymbolPos;
  self.ChopLength := Chop;
end;

Function TMekofTermDef.GetTermLength(): integer;
begin
  Result := TagLength + FieldLength + FirstSymbolPosLength + ChopLength;
end;

Constructor TMekofTermDef.Create(Parent: TObject; TagLength: string;
  FieldLength: string; FirstSymbolPos: string; Chop: string);
begin
  self.Parent := Parent;
  self.TagLength := strtoint(TagLength);
  self.FieldLength := strtoint(FieldLength);
  self.FirstSymbolPosLength := strtoint(FirstSymbolPos);
  self.ChopLength := strtoint(Chop);
end;
{$ENDREGION}

Constructor TMekofField.Create(Parent: TObject; Description: TMekofFieldDef;
  Value: string);
begin
  self.Description := Description;
  self.Source := Value;
  self.Parent := Parent;
end;

function TMekofField.GetIndicator(): string;
begin
  Result := self.Source[1];
  if Description.Tag = '001' then
    Result := ''
    // if self.Source[1] <> '+' then
    // Result := copy(self.Source, 1, strtoint(Rec.Marker[10]))

end;

function TMekofField.GetIdentificator(): TStringList;
var
  temp: string;
  val: string;
  p, p2: integer;
begin
  Result := TStringList.Create();
  temp := Source;
  while pos('+', temp) > 0 do
  begin
    p := pos('+', temp);
    delete(temp, 1, p);
    val := temp[1];
    Result.Add(val);
  end;
  if Description.Tag = '001' then
    Result.Add('')
    // Result := '___'
end;

function TMekofField.GetValues(): TStringList;
var
  temp: string;
  val: string;
  p, p2: integer;
  id: char;
begin
  Result := TStringList.Create();
  temp := Source;
  while pos('+', temp) > 0 do
  begin
    p := pos('+', temp);
    id := temp[p + 1];
    delete(temp, 1, p);
    p := pos('+', temp);
    if p = 0 then
      p := Length(temp) + 1;
    val := copy(temp, 2, p - 2);
    Result.Values[id] := val;
  end;
  if self.Description.Tag = '001' then
    Result.Add(Source);
end;

Constructor TMekofRecord.Create(SourceText: string);
var
  temp: string;
  RefText: string;
  DataText: string;
  Fld: string;
  i: integer;
  ReferenceLen: integer;
  TermLength: integer;
  DataFieldLength: integer;
  FirstCharPosLength: integer;
  UsePartLength: integer;
  TermCount: integer;
begin
  self.Marker := ParseMarker(copy(SourceText, 1, 24));
  i := strtoint(Marker[5]);
  RefText := copy(SourceText, 25, i - 25);
  DataText := copy(SourceText, strtoint(Marker[5]) + 1,
    strtoint(Marker[0]) - strtoint(Marker[5]));
  self.Fields := TMekofFieldList.Create(self, RefText, '3', Marker[8],
    Marker[9], Marker[10], DataText);
  Titles := TXMLDocument.Create(nil);
  if not FileExists('IdScheme.xml') then
    ShowMessage('File not found! ("IdScheme.xml")')
  else
    Titles.LoadFromFile('IdScheme.xml');
end;

Constructor TMekofFieldList.Create(Parent: TObject; Reference: string;
  TagLength: string; FieldLength: string; FirstSymbolPos: string; Chop: string;
  DataText: String);
var
  i: integer;
  TermCount: integer;
  temp: string;
  MekofFieldDef: TMekofFieldDef;
begin
  self.Parent := Parent;
  TermDefinition := TMekofTermDef.Create(self, TagLength, FieldLength,
    FirstSymbolPos, Chop);
  TermCount := Ceil(Reference.Length / TermDefinition.TermLength);
  SetLength(self.Fields, TermCount);
  for i := 0 to TermCount - 1 do
  begin
    temp := copy(Reference, TermDefinition.TermLength * i + 1,
      TermDefinition.TermLength);
    MekofFieldDef := TMekofFieldDef.Create(self, temp, TermDefinition);
    temp := copy(DataText, MekofFieldDef.StartPos + 1,
      MekofFieldDef.Length - 1);
    self.Fields[i] := TMekofField.Create(self, MekofFieldDef, temp);
  end;
end;

function TMekofFieldList.GetLength(): integer;
begin
  Result := System.Length(Fields);
end;

function TMekofFieldDef.GetNaim(): string;
begin
  //Result:=TmekofRecord(TMekofFieldList(TMekofField(Parent).Parent).Parent).Titles.DocumentElement.ChildNodes.Nodes[tag].NodeName;
  case strtoint(Tag) of
    001:
      Result := '������������� ���������';
    002:
      Result := '��������� ����������';
    004:
      Result := '����������� ������� ���� ������';
    005:
      Result := '����������� �������������� ������ 010 - ISBN';
    011:
      Result := 'ISSN';
    100:
      Result := '��������� ������';
    101:
      Result := '���� ���������';
    102:
      Result := '���������� ����� ���������';
    200:
      Result := '�������� � �������� �� ���������';
    201:
      Result := '������������ ��������';
    206:
      Result := '��������� � ���� ����������� �������';
    210:
      Result := '�������� ������';
    600:
      Result := '���';
    610:
      Result := '���';
    620:
      Result := '����������';
    630:
      Result := '��������';
    640:
      Result := '�������� �����';
    650:
      Result := '����� ���������';
    660:
      Result := '������� (���������)';
    670:
      Result := '���������� �������';
    700:
      Result := '���� � ��������� ���������������� ����������������';
    905:
      Result := '�������� ���������';
  else
    Result := '';
  end;

end;

function TMekofFieldDef.GetSource: string;

var
  len, PNS: string;
begin
  len := AddLeftZeros(Length, Rec.Fields.TermDefinition.FieldLength);
  PNS := AddLeftZeros(StartPos, Rec.Fields.TermDefinition.FirstSymbolPosLength);
  Result := Tag + ' ' + len + ' ' + PNS + ' ' + Chop;
end;

Constructor TMekofFieldDef.Create(Parent: TObject; Def: string;
  DefAlloc: TMekofTermDef
  );
var
  i: integer;
begin
  self.Parent := Parent;
  i := 1;
  self.Tag := copy(Def, i, DefAlloc.TagLength);
  i := i + DefAlloc.TagLength;
  self.Length := strtoint(copy(Def, i, DefAlloc.FieldLength));
  i := i + DefAlloc.FieldLength;
  self.StartPos := strtoint(copy(Def, i, DefAlloc.FirstSymbolPosLength));
  i := i + DefAlloc.FirstSymbolPosLength;
  self.Chop := copy(Def, i, DefAlloc.ChopLength);
end;

{$ENDREGION}
{$REGION 'TForm1 Methods'}

procedure TMainForm.LoadStructBtnClick(Sender: TObject);
  function GetTerm(i: integer; Naim: string; Tag: string; Chop: string;
    Indicator: string; Identificator: string; FSP: string; FieldLen: string;
    val: string): string;
  begin
    Result := format('%d'#9'%s'#9'%s'#9'%s'#9'%s'#9'%s'#9'%s'#9'%s'#9'%s',
      [i, Naim, Tag, Chop, Indicator, Identificator, FSP, FieldLen, val]);
  end;

var
  temp: string;
  i, j: integer;
  Naim: string;
begin
  temp := '';
  for i := 0 to SourceMmo.Lines.Count do
    temp := temp + SourceMmo.Lines[i];
  Rec := TMekofRecord.Create(temp);

  Memo1.Clear;
  MarkerMmo.Lines.Add('�������'#9'�����'#9'�����'#9'��������');
  for i := 0 to 11 do
  begin
    MarkerMmo.Lines.Add(MakeDefString(MarkerPos[i], Rec.Marker[i],
      MarkerFullDef[i]));
  end;
  Memo1.Lines.Add(#13#10#9'����������:');
  Memo1.Lines.Add('�����'#9'��������');
  Memo1.Lines.Add(inttostr(Rec.Fields.TermDefinition.TagLength) + #9 +
    ReferenceDef[0]);
  Memo1.Lines.Add(inttostr(Rec.Fields.TermDefinition.FieldLength) + #9 +
    ReferenceDef[1]);
  Memo1.Lines.Add(inttostr(Rec.Fields.TermDefinition.FirstSymbolPosLength) + #9
    + ReferenceDef[2]);
  Memo1.Lines.Add(inttostr(Rec.Fields.TermDefinition.ChopLength) + #9 +
    ReferenceDef[3]);
  temp := '� �/�' + #9 + '������������ ��-��' + #9 + '�����' + #9 + '���' + #9 +
    '���������' + #9 + '�������������' + #9 + '�����' + #9 + '�����' + #9 +
    '��������';
  Memo1.Lines.Add(temp);

  // ('���'#9'������������'#9'�����'#9'���'#9'���'#9'���'#9'��������');
  ReferenceList.Clear;
  for i := 0 to Rec.Fields.Length - 1 do
  begin
    ReferenceList.Items.Add(Rec.Fields.Fields[i].Description.GetSource());
    with Rec.Fields.Fields[i].Description do
    begin
      for j := 0 to Rec.Fields.Fields[i].Values.Count - 1 do
      begin
        Memo1.Lines.Add(GetTerm(i + 1, Naim, Tag, Chop,
          Rec.Fields.Fields[i].Indicator, Rec.Fields.Fields[i].Identificator[j],
          inttostr(StartPos), inttostr(Length),
          Rec.Fields.Fields[i].Values[j]));
      end;
    end;
  end;

  // memo1.Lines.Add(#13#10#9'����:');
  // memo1.Lines.Add('���'#9'��������');
  // for I := 0 to rec.Fields.Length - 1 do
  // begin
  // memo1.Lines.Add(inttostr(i+1)+#9+rec.Fields.Fields[i].Value);
  // end;
end;

procedure TMainForm.ParseBtnClick(Sender: TObject);

var
  s: string;
  Marker: TMekofMarker;
  i: integer;
  ReferenceLen: integer;
  Reference: string;
  TermLength: integer;
  DataFieldLength: integer;
  FirstCharPosLength: integer;
  UsePartLength: integer;
begin
  s := SourceMmo.Text;
  Marker := ParseMarker(copy(s, 1, 24));
  MarkerMmo.Lines.Add('�������'#9'�����'#9'�����'#9'��������');
  for i := 0 to 11 do
  begin
    MarkerMmo.Lines.Add(MakeDefString(MarkerPos[i], Marker[i],
      MarkerFullDef[i]));
  end;
  ReferenceLen := strtoint(Marker[5]) + 5;
  Reference := copy(s, 25, ReferenceLen);
  Reference := ClearCLRFText(Reference);

  DataFieldLength := strtoint(Marker[8]);
  FirstCharPosLength := strtoint(Marker[9]);
  UsePartLength := strtoint(Marker[10]);
  TermLength := 3 + DataFieldLength + FirstCharPosLength + UsePartLength;
  ReferenceList.Clear();
  i := 1;
  while i < ReferenceLen do
  begin
    ReferenceList.Items.Add(copy(Reference, i, TermLength));
    i := i + TermLength;
  end;
end;

procedure TMainForm.BitBtn1Click(Sender: TObject);
var
  fl: textfile;
  s: string;
begin

end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  s: string;
begin
  s := SourceMmo.Text;
  s := stringreplace(s, #13, '', [rfreplaceall]);
  s := stringreplace(s, #10, '', [rfreplaceall]);
  ShowMessage(s[475]);
  // memo1.Commatext;
end;

procedure TMainForm.ReferenceListClick(Sender: TObject);
var
  ind: integer;
  article: string;
  tmp: string;
begin
  ReferenceMemo.Clear();
  article := stringreplace(ReferenceList.Items[ReferenceList.ItemIndex], ' ',
    '', [rfreplaceall]);
  ind := 1;
  ReferenceMemo.Lines.Add('�����'#9'��������'#9'��������');
  tmp := copy(article, 1, 3);
  ReferenceMemo.Lines.Add(ReferenceRep(3, tmp, ReferenceDef[0]));
  ind := ind + 3;

  tmp := copy(article, ind, Rec.Fields.TermDefinition.FieldLength);
  ReferenceMemo.Lines.Add(ReferenceRep(Rec.Fields.TermDefinition.FieldLength,
    tmp, ReferenceDef[1]));
  ind := ind + Rec.Fields.TermDefinition.FieldLength;
  tmp := copy(article, ind, Rec.Fields.TermDefinition.FirstSymbolPosLength);
  ReferenceMemo.Lines.Add
    (ReferenceRep(Rec.Fields.TermDefinition.FirstSymbolPosLength, tmp,
    ReferenceDef[2]));
  ind := ind + Rec.Fields.TermDefinition.FirstSymbolPosLength;
  tmp := copy(article, ind, Rec.Fields.TermDefinition.ChopLength);
  ReferenceMemo.Lines.Add(ReferenceRep(Rec.Fields.TermDefinition.ChopLength,
    tmp, ReferenceDef[3]));
end;

procedure TMainForm.SaveToFile1Click(Sender: TObject);
var
  temp: string;
  i: integer;
  RepForm: TReportForm;
begin
  if Rec = nil then
  begin
    for i := 0 to SourceMmo.Lines.Count do
      temp := temp + SourceMmo.Lines[i];
    Rec := TMekofRecord.Create(temp);
  end;
  RepForm := TReportForm.Create(self);
  RepForm.showRep(Rec);
end;

{$ENDREGION}

end.
