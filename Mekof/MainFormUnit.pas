unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, Math, Vcl.Buttons;

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
    Memo1: TMemo;
    BitBtn1: TBitBtn;
    SaveDialog1: TSaveDialog;
    procedure ParseBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ReferenceListClick(Sender: TObject);
    procedure LoadStructBtnClick(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
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
  TMekofFieldDef = class(TObject)
  public
    Tag:string;
    Length:Integer;
    StartPos:integer;
    CHOP:string;
    function GetSource:string;
    Constructor Create(Def:string;DefAlloc:TMekofTermDef);
  end;

type
  TMekofField = class(TObject)
  public
    Description: TMekofFieldDef;
    Value: string;
    Constructor Create(Description: TMekofFieldDef; Value: string);
  end;

type
  TMekofFieldList = Class(TObject)
  private
    function  GetLength(): Integer;
  public
    Fields:array of TMekofField;
    TermDefinition:TMekofTermDef;
    property Length : integer read GetLength;
    Constructor Create(Reference:string;TermDef:TMekofTermDef;DataText:String);
  end;

type
  TMekofRecord = class(TObject)
  private
    SourceText: string;
  public
    Marker: TMekofMarker;
    Fields: TMekofFieldList;
//    Reference: TMekofReference;
    Constructor Create(SourceText: string);
  end;
{$ENDREGION}
{$REGION 'Const'}

const
  // MarkerDef : TMarker = ('Длина записи','asd');
  MarkerPos: TMekofMarker = ('0-4', '5', '6-9', '10', '11', '12-16', '17',
    '18,19', '20', '21', '22', '23');
  MarkerFullDef: TMekofMarker =
    ('длина записи (позиции 0-4) - количество символов в записи, включая маркер и разделитель записи, выражается десятичным числом, выравниваемым вправо и дополняемым слева до пяти символов нулями; ',
    'статус записи  (позиция 5) - один символ, который должен быть определен в нормативно-технических документах по применению данной структуры записи, например, "новая" или "изменяющая" запись;',
    'коды применения (позиции 6-9) - коды, которые могут быть определены в нормативно-технических документах по применению данной структуры;',
    'длина индикатора (позиция 10) - десятичная цифра, определяющая количество символов индикатора. Если индикатор не используется, длина индикатора принимает значение равное нулю;',
    'длина идентификатора (позиция 11) - десятичная цифра, определяющая количество символов идентификатора. Первым или единственным символом идентификатора должен быть ASCII-код 1Fh. Если идентификатор не используется, длина идентификатора принимает значение '
    + 'равное нулю;',
    'базовый адрес данных  (позиции 12-16) - десятичное число, выравниваемое вправо и дополняемое до пяти символов нулями, указывающее общую длину в символах маркера записи и справочника, включая разделитель поля в конце справочника;',
    'набор кодов  (позиции 17) - символ, определяющий набор кодов и используемый для представления данных в записи, включая маркер записи, справочник, метки, индикаторы, идентификаторы, разделители и поля данных. Значения данного символа должны быть определен'
    + 'ы в документах по применению данной структуры записи;',
    'зарезервировано (позиции 18, 19) - определяются пользователем;',
    'позиция 20 - десятичная цифра, указывающая длину в символах компонента "длина поля данных" каждой статьи справочника;',
    'позиция 21 - десятичная цифра, указывающая длину в символах компонента "позиция начального символа" каждой статьи справочника;',
    'позиция 22 - десятичная цифра, указывающая длину в символах компонента "часть, определяемая при применении" (ЧОП) каждой статьи справочника;',
    'позиция 23 - зарезервирована.');
   ReferenceDef: array [0..3] of string = ('Метка',
    'длина поля данных  - определяется: 1) общим количеством символов (включая индикатор и разделитель поля) в поле данных, идентифицируемом данной меткой, или 2) нулем, обозначающим, что данная статья справочника относится к полю данных, общая длина котор'
    + 'орого превышает наибольшее допустимое десятичное число (n), которое может содержаться в компоненте "длина поля данных" статьи справочника. В таком случае поле данных рассматривается как разделенное на несколько частей, длина каждой из которых, за исключен'
    + 'ием последней, равна n. Каждая часть имеет свою статью справочника, содержащую "метку", и "часть, определяемую при применении" поля данных, а также "позицию начального символа" той части, к которой относится эта статья справочника. Нулевое значение длины '
    + 'поля данных означает, что данная статья адресуется к той части поля данных, которая не является последней, а ее длина равна n; или 3) количеством символов (включая разделитель поля) в последней части поля данных, описанного в п.2. В случаях, описанных'
    + ' в пп. 2 и 3, все статьи справочника, относящиеся к частям одного и того же поля данных, должны следовать друг за другом в той же последовательности, что и сами части поля данных;',
    'позиция начального символа - десятичное число, определяющее позицию первого символа поля данных, идентифицируемого предшествующей меткой, относительно базового адреса данных (позиция начального символа первого поля данных, следующего непосредственно за сп'
    + 'справочником, равна нулю); ',
    'часть, определяемая при применении (ЧОП) - предназначена для представления дополнительной информации, относящейся к полю данных, идентифицируемому этой статьей справочника. ');

{$ENDREGION}

var
  MainForm: TMainForm;
  Rec: TMekofRecord;

implementation

{$R *.DFM}
{$REGION 'NoClass Methods'}

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

function ReferenceRep(len:integer;text:string;capt:string):string;
begin
  result:= format('%d'#9'%s'#9'%s',[len,text,capt]);
end;

function ThesaurusRep(Length: integer; Text: string;
  Desription: string): string;
begin
  Result := format('[%d]:'#9'%s'#9'%s', [Length, Text, Desription])
end;

function ParseMarker(Marker: string): TMekofMarker;
begin
  if Length(Marker) <> 24 then
    Raise Exception.Create('Маркер должен состоять из 24 символов [' +
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

Constructor TMekofField.Create(Description: TMekofFieldDef; Value: string);
begin
  self.Description := Description;
  self.Value := Value;
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
  i := strtoint(Marker[5]);
  RefText := copy(SourceText, 25, i-25);
  DataText := copy(SourceText,strtoint(Marker[5])+1,strtoint(Marker[0])-strtoint(Marker[5]));
  self.Fields := TMekofFieldList.Create(RefText,
    TMekofTermDef.Create('3', Marker[8], Marker[9], Marker[10]),DataText);
end;

Constructor TMekofFieldList.Create(Reference:string;TermDef:TMekofTermDef;DataText:String);
var
  i: integer;
  TermCount: integer;
  Temp: string;
  MekofFieldDef : TMekofFieldDef;
begin
  TermDefinition := TermDef;
  TermCount := Ceil(Reference.Length / TermDef.TermLength);
  SetLength(self.Fields, TermCount);
  for i := 0 to TermCount - 1 do
    begin
      Temp := copy(Reference, TermDef.TermLength * i + 1, TermDef.TermLength);
      MekofFieldDef := TMekofFieldDef.Create(Temp,TermDefinition);
      Temp := copy(DataText, MekofFieldDef.StartPos + 1, MekofFieldDef.Length-1);
      self.Fields[i] := TMekofField.Create(MekofFieldDef, Temp);
    end;
end;

function TMekofFieldList.GetLength(): Integer;
begin
  result := System.Length(Fields);
end;

function TMekofFieldDef.GetSource:string;
function MakeLen(int:integer; len:integer):string;
var s:string;
begin
  while System.Length(s)<len do
  s:='0'+s;
  result:=s;
end;
begin
  result:=Tag + MakeLen(Length,)+inttostr(StartPos)+CHOP
end;

Constructor TMekofFieldDef.Create(Def:string;DefAlloc:TMekofTermDef);
var
i:integer;
begin
  i:=1;
  self.Tag := copy(Def,i,DefAlloc.TagLength);
  i:= i+DefAlloc.TagLength;
  Self.Length:= strtoint(copy(Def,i,DefAlloc.FieldLength));
  i:= i+DefAlloc.FieldLength;
  Self.StartPos:=strtoint(copy(Def,i,DefAlloc.FirstSymbolPosLength));
  i:= i+DefAlloc.FirstSymbolPosLength;
  Self.CHOP:=copy(Def,i,DefAlloc.ChopLength);
end;

{$ENDREGION}
{$REGION 'TForm1 Methods'}

function GetNaim(key:string):string;
begin
end;

procedure TMainForm.LoadStructBtnClick(Sender: TObject);
function GetTerm(i:integer;Naim:string;Tag:string;FieldLen:string;FSP:string;CHOP:string;val:string):string;
begin
  result:=format('%d'#9'%s'#9'%s'#9'%s'#9'%s'#9'%s'#9'%s',[i,Naim,Tag,FieldLen,FSP,CHOP,val]);
end;
var
  Temp: string;
  i: integer;
  naim:string;
begin
  Temp := '';
  for i := 0 to SourceMmo.Lines.Count do
    Temp := Temp + SourceMmo.Lines[i];
  Rec := TMekofRecord.Create(Temp);


  memo1.Clear;
  MarkerMmo.Lines.Add('Позиции'#9'Длина'#9'Текст'#9'Описание');
  for i := 0 to 11 do
  begin
    Memo1.Lines.Add(MakeDefString(MarkerPos[i], rec.Marker[i],
    MarkerFullDef[i]));
  end;
  memo1.Lines.Add(#13#10#9'СПРАВОЧНИК:');
  memo1.Lines.Add('Текст'#9'Описание');
  memo1.Lines.Add(inttostr(rec.Fields.TermDefinition.TagLength)+#9+ReferenceDef[0]);
  memo1.Lines.Add(inttostr(rec.Fields.TermDefinition.FieldLength)+#9+ReferenceDef[1]);
  memo1.Lines.Add(inttostr(rec.Fields.TermDefinition.FirstSymbolPosLength)+#9+ReferenceDef[2]);
  memo1.Lines.Add(inttostr(rec.Fields.TermDefinition.ChopLength)+#9+ReferenceDef[3]);
  memo1.Lines.Add('№пп'#9'Наименование'#9'Метка'#9'ЧОП'#9'ПНС'#9'ДПД'#9'Значение');
  ReferenceList.Clear;
  for I := 0 to rec.Fields.Length - 1 do
  begin
  with rec.Fields.Fields[i].Description do
    memo1.Lines.Add(GetTerm(i+1,naim,Tag,CHOP,inttostr(StartPos),inttostr(Length),rec.Fields.Fields[i].Value));
    ReferenceList.Items.Add(rec.Fields.Fields[i].Description.GetSource);
  end;

//  memo1.Lines.Add(#13#10#9'ПОЛЯ:');
//  memo1.Lines.Add('№пп'#9'Значение');
//  for I := 0 to rec.Fields.Length - 1 do
//  begin
//    memo1.Lines.Add(inttostr(i+1)+#9+rec.Fields.Fields[i].Value);
//  end;
end;

procedure TMainForm.ParseBtnClick(Sender: TObject);

var
  s: string;
  Marker: TMekofMarker;
  i: integer;
  ReferenceLen: integer;
  Reference: string;
  TermLength: integer;
  DataFieldLength:integer;
  FirstCharPosLength:integer;
  UsePartLength   :integer;
begin
   s := SourceMmo.Text;
     Marker := ParseMarker(copy(s, 1, 24));
    MarkerMmo.Lines.Add('Позиции'#9'Длина'#9'Текст'#9'Описание');
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
  fl:textfile;
  s:string;
begin
if  SaveDialog1.Execute() then
begin
  s := memo1.Text;
  AssignFile(fl,SaveDialog1.FileName);
  Rewrite(fl);
  Write(fl,s);
  CloseFile(fl);
end;

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
   ReferenceMemo.Clear();
    article := ReferenceList.Items[ReferenceList.ItemIndex];
    ind := 1;
    ReferenceMemo.Lines.Add('Длина'#9'Параметр'#9'Описание');
    ReferenceMemo.Lines.Add(ReferenceRep(3, copy(article, 1, 3), ReferenceDef[0]));
    ind := ind + 3;

    ReferenceMemo.Lines.Add(ReferenceRep(rec.Fields.TermDefinition.FieldLength, copy(article, ind,
    rec.Fields.TermDefinition.FieldLength),
ReferenceDef[1])
    );
    ind := ind + rec.Fields.TermDefinition.FieldLength;
    ReferenceMemo.Lines.Add(ReferenceRep(rec.Fields.TermDefinition.FirstSymbolPosLength, copy(article, ind,
    rec.Fields.TermDefinition.FirstSymbolPosLength),
    ReferenceDef[2]));
    ind := ind + rec.Fields.TermDefinition.FirstSymbolPosLength;
    ReferenceMemo.Lines.Add(ReferenceRep(rec.Fields.TermDefinition.ChopLength, copy(article, ind,
    rec.Fields.TermDefinition.ChopLength),
    ReferenceDef[3])
    );
end;
{$ENDREGION}

end.
