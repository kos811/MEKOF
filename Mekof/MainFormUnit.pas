unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, Math;

{$REGION 'TForm1'}

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    SourceMmo: TMemo;
    MarkerMmo: TMemo;
    ParseBtn: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    ReferenceList: TListBox;
    ReferenceMemo: TMemo;
    LoadStructBtn: TMenuItem;
    procedure ParseBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ReferenceListClick(Sender: TObject);
    procedure LoadStructBtnClick(Sender: TObject);
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
    Function GetTermLength(): integer;
    Property TermLength: integer Read GetTermLength;
    Constructor Create(TagLength: integer; FieldLength: integer;
      FirstSymbolPos: integer; Chop: integer); Overload;
    Constructor Create(TagLength: string; FieldLength: string;
      FirstSymbolPos: string; Chop: string); Overload;
  end;

type
  TMekofField = class(TObject)
    Description: string;
    Value: string;
    Constructor Create(Description: string; Value: string);
  end;

type
  TMekofFieldList = array of TMekofField;

Type
  TMekofReference = class(TObject)
  private                       
    function  GetLength(): Integer;
  public
    TermDef: TMekofTermDef;
    FieldDefs: TMekofFieldList;
    Constructor Create(Text: string; TermDef: TMekofTermDef);  
    property Length : integer read GetLength; 
  end;

type
  TMekofRecord = class(TObject)  
  private
    SourceText: string; 
  public
    Marker: TMekofMarker;
    Fields: TMekofFieldList;
    Reference: TMekofReference;
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
{$ENDREGION}

var
  MainForm: TMainForm;
  Rec: TMekofRecord;

implementation

{$R *.DFM}
{$REGION 'NoClass Methods'}

function ClearCLRFText(Text: string): string;
begin
  Result := stringreplace(Text, #13, '', [rfreplaceall]);
  Result := stringreplace(Result, #10, '', [rfreplaceall]);
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

Constructor TMekofTermDef.Create(TagLength: integer; FieldLength: integer;
  FirstSymbolPos: integer; Chop: integer);
begin
  self.TagLength := TagLength;
  self.FieldLength := FieldLength;
  self.FirstSymbolPosLength := FirstSymbolPos;
  self.ChopLength := Chop;
end;

Function TMekofTermDef.GetTermLength(): integer;
begin
  Result := TagLength + FieldLength + FirstSymbolPosLength + ChopLength;
end;

Constructor TMekofTermDef.Create(TagLength: string; FieldLength: string;
  FirstSymbolPos: string; Chop: string);
begin
  self.TagLength := strtoint(TagLength);
  self.FieldLength := strtoint(FieldLength);
  self.FirstSymbolPosLength := strtoint(FirstSymbolPos);
  self.ChopLength := strtoint(Chop);
end;
{$ENDREGION}

Constructor TMekofField.Create(Description: string; Value: string);
begin
  self.Description := Description;
  self.Value := Value;
end;

Constructor TMekofReference.Create(Text: string; TermDef: TMekofTermDef);
var
  i: integer;
  TermCount: integer;
  Temp: string;
begin
  TermCount := Ceil(Text.Length / TermDef.TermLength);
  SetLength(self.FieldDefs, TermCount);
  for i := 0 to TermCount - 1 do
    begin
      Temp := copy(Text, TermDef.TermLength * i + 1, TermDef.TermLength);
      self.FieldDefs[i] := TMekofField.Create(Temp, '');
    end;
end;

Constructor TMekofRecord.Create(SourceText: string);
var
  Temp: string;
  RefText: string;
  DataText: string;
  Fld:string;
  i: integer;
  ReferenceLen: integer;
  TermLength: integer;
  DataFieldLength: integer;
  FirstCharPosLength: integer;
  UsePartLength: integer;
  TermCount: integer;
begin
  self.Marker := ParseMarker(copy(SourceText, 1, 24));
  i := strtoint(Marker[5]) + 5;
  RefText := copy(SourceText, 25, i);
  self.Reference := TMekofReference.Create(RefText,
    TMekofTermDef.Create('3', Marker[8], Marker[9], Marker[10]));
  DataText := copy(SourceText,strtoint(Marker[5])+1,strtoint(Marker[0])-strtoint(Marker[5]));
  setlength(  self.Fields,self.Reference.Length);
  for I := 0 to self.Reference.Length do
  begin
  self.Fields[i] := Copy(DataText,);
  end;
end;

function TMekofReference.GetLength(): Integer;
begin
  result := Length(self.FieldDefs);
end;

{$ENDREGION}
{$REGION 'TForm1 Methods'}

procedure TMainForm.LoadStructBtnClick(Sender: TObject);
var
  Temp: string;
  i: integer;
begin
  Temp := '';
  for i := 0 to SourceMmo.Lines.Count do
    Temp := Temp + SourceMmo.Lines[i];
  Rec := TMekofRecord.Create(Temp);
end;

procedure TMainForm.ParseBtnClick(Sender: TObject);
  function MakeDefString(MarkerPos: String; MarkerPart: string;
    MarkerFullDef: string): string;
  begin
    Result := format('[%s]'#9'[%d]'#9#39'%s'#39#9'%s',
      [MarkerPos, Length(MarkerPart), MarkerPart, MarkerFullDef]);
  end;

var
  s: string;
  Marker: TMekofMarker;
  i: integer;
  ReferenceLen: integer;
  Reference: string;
  TermLength: integer;
begin
  { s := SourceMmo.Text;
    // Marker := ParseMarker(copy(s, 1, 24));
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
    end; }
end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  s: string;
begin
  s := SourceMmo.Text;
  s := stringreplace(s, #13, '', [rfreplaceall]);
  s := stringreplace(s, #10, '', [rfreplaceall]);
  showmessage(s[475]);
  // memo1.Commatext;
end;

procedure TMainForm.ReferenceListClick(Sender: TObject);

var
  ind: integer;
  article: string;
begin
  { ReferenceMemo.Clear();
    article := ReferenceList.Items[ReferenceList.ItemIndex];
    ind := 1;
    ReferenceMemo.Lines.Add('�����'#9'��������'#9'��������');
    ReferenceMemo.Lines.Add(ReferenceRep(3, copy(article, 1, 3), '�����'));
    ind := ind + 3;
    ReferenceMemo.Lines.Add(ReferenceRep(DataFieldLength, copy(article, ind,
    DataFieldLength),
    '����� ���� ������  - ������������: 1) ����� ����������� �������� (������� ��������� � ����������� ����) � ���� ������, ���������������� ������ ������, ��� 2) �����, ������������, ��� ������ ������ ����������� ��������� � ���� ������, ����� ����� �����'
    + '����� ��������� ���������� ���������� ���������� ����� (n), ������� ����� ����������� � ���������� "����� ���� ������" ������ �����������. � ����� ������ ���� ������ ��������������� ��� ����������� �� ��������� ������, ����� ������ �� �������, �� ��������'
    + '��� ���������, ����� n. ������ ����� ����� ���� ������ �����������, ���������� "�����", � "�����, ������������ ��� ����������" ���� ������, � ����� "������� ���������� �������" ��� �����, � ������� ��������� ��� ������ �����������. ������� �������� ����� '
    + '���� ������ ��������, ��� ������ ������ ���������� � ��� ����� ���� ������, ������� �� �������� ���������, � �� ����� ����� n; ��� 3) ����������� �������� (������� ����������� ����) � ��������� ����� ���� ������, ���������� � �.2. � �������, ���������'
    + ' � ��. 2 � 3, ��� ������ �����������, ����������� � ������ ������ � ���� �� ���� ������, ������ ��������� ���� �� ������ � ��� �� ������������������, ��� � ���� ����� ���� ������;')
    );
    ind := ind + DataFieldLength;
    ReferenceMemo.Lines.Add(ReferenceRep(FirstCharPosLength, copy(article, ind,
    FirstCharPosLength),
    '������� ���������� ������� - ���������� �����, ������������ ������� ������� ������� ���� ������, ����������������� �������������� ������, ������������ �������� ������ ������ (������� ���������� ������� ������� ���� ������, ���������� ��������������� �� ��'
    + '������������, ����� ����); '));
    ind := ind + FirstCharPosLength;
    ReferenceMemo.Lines.Add(ReferenceRep(UsePartLength, copy(article, ind,
    UsePartLength),
    '�����, ������������ ��� ���������� (���) - ������������� ��� ������������� �������������� ����������, ����������� � ���� ������, ����������������� ���� ������� �����������. ')
    ); }
end;
{$ENDREGION}

end.
