unit MainFormUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    SourceMmo: TMemo;
    MarkerMmo: TMemo;
    ParseBtn: TMenuItem;
    ThesaurusMmo: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    procedure ParseBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TMarker =  array[0..11] of String;
const
  //MarkerDef : TMarker = ('Длина записи','asd');
  MarkerPos:     TMarker = ('0-4', '5', '6-9', '10', '11', '12-16', '17', '18,19', '20', '21', '22', '23');
  MarkerFullDef: TMarker =
  (
  'длина записи (позиции 0-4) - количество символов в записи, включая маркер и разделитель записи, выражается десятичным числом, выравниваемым вправо и дополняемым слева до пяти символов нулями; ',
  'статус записи  (позиция 5) - один символ, который должен быть определен в нормативно-технических документах по применению данной структуры записи, например, "новая" или "изменяющая" запись;',
  'коды применения (позиции 6-9) - коды, которые могут быть определены в нормативно-технических документах по применению данной структуры;',
  'длина индикатора (позиция 10) - десятичная цифра, определяющая количество символов индикатора. Если индикатор не используется, длина индикатора принимает значение равное нулю;',
  'длина идентификатора (позиция 11) - десятичная цифра, определяющая количество символов идентификатора. Первым или единственным символом идентификатора должен быть ASCII-код 1Fh. Если идентификатор не используется, длина идентификатора принимает значение '+'равное нулю;',
  'базовый адрес данных  (позиции 12-16) - десятичное число, выравниваемое вправо и дополняемое до пяти символов нулями, указывающее общую длину в символах маркера записи и справочника, включая разделитель поля в конце справочника;',
  'набор кодов  (позиции 17) - символ, определяющий набор кодов и используемый для представления данных в записи, включая маркер записи, справочник, метки, индикаторы, идентификаторы, разделители и поля данных. Значения данного символа должны быть определен'+'ы в документах по применению данной структуры записи;',
  'зарезервировано (позиции 18, 19) - определяются пользователем;',
  'позиция 20 - десятичная цифра, указывающая длину в символах компонента "длина поля данных" каждой статьи справочника;',
  'позиция 21 - десятичная цифра, указывающая длину в символах компонента "позиция начального символа" каждой статьи справочника;',
  'позиция 22 - десятичная цифра, указывающая длину в символах компонента "часть, определяемая при применении" (ЧОП) каждой статьи справочника;',
  'позиция 23 - зарезервирована.'
  );

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

function ClearCLRFText(Text:string):string;
begin
  Result:=stringreplace(Text,#13,'',[rfreplaceall]);
  Result:=stringreplace(Result,#10,'',[rfreplaceall]);
end;

function ParseMarker(marker:string):TMarker;
begin
  if length(marker) <> 24 then
    Raise Exception.Create('Маркер должен состоять из 24 символов ['+inttostr(length(marker))+'].');
  result[0]  := copy(marker,1,5);
  result[1]  := copy(marker,6,1);
  result[2]  := copy(marker,7,4);
  result[3]  := copy(marker,11,1);
  result[4]  := copy(marker,12,1);
  result[5]  := copy(marker,13,5);
  result[6]  := copy(marker,18,1);
  result[7]  := copy(marker,19,2);
  result[8]  := copy(marker,21,1);
  result[9]  := copy(marker,22,1);
  result[10] := copy(marker,23,1);
  result[11] := copy(marker,24,1);
end;

procedure TMainForm.ParseBtnClick(Sender: TObject);
  function MakeDefString(MarkerPos:String; MarkerPart:string; MarkerFullDef:string):string;
  begin
    result := format('[%s]'#9'[%d]'#9#39'%s'#39#9'%s',[MarkerPos, length(MarkerPart), MarkerPart , MarkerFullDef]);
  end;
var
  s:                    string;
  Marker:               TMarker;
  i:                    integer;
  ThesaurusLen:         integer;
  Thesaurus:            string;
  DataFieldLength:      Integer;
  FirstCharPosLength:   Integer;
  UsePartLength:        Integer;
  TermLength:           Integer;
begin
  s := SourceMmo.Text;
  Marker := ParseMarker(copy(s,1,24));
  MarkerMmo.Lines.Add('Позиции'#9'Длина'#9'Текст'#9'Описание');
  for i:=0 to 11 do
  begin
    MarkerMmo.Lines.Add(MakeDefString(MarkerPos[i] ,Marker[i], markerFullDef[i]));
  end;
  ThesaurusLen := strtoint(marker[5])+5;
  Thesaurus := copy(s,25,ThesaurusLen);
  Thesaurus := ClearCLRFText(Thesaurus);

//  узнать у преподавателя - переводы строк лишние или нет?
//  если нет, то считать ли оба символа (/r/n) или как один?
  //ThesaurusMmo.Text  := Thesaurus;
  DataFieldLength    := StrToInt(Marker[8]);
  FirstCharPosLength := StrToInt(Marker[9]);
  UsePartLength      := StrToInt(Marker[10]);
  TermLength         := 3 + DataFieldLength + FirstCharPosLength + UsePartLength;
  i := 1;
  while I<ThesaurusLen do
  begin
    ThesaurusMmo.Lines.Add(Copy(Thesaurus,i,TermLength));
    i:=i+TermLength;
  end;
end;



procedure TMainForm.Button1Click(Sender: TObject);
var s:string;
begin
  s:=SourceMmo.Text;
  s:=stringreplace(s,#13,'',[rfreplaceall]);
  s:=stringreplace(s,#10,'',[rfreplaceall]);
  showmessage(s[475]);
  //memo1.Commatext;
end;

end.

