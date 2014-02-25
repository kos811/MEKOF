program MEKOF;

uses
  Forms,
  MainFormUnit in 'MainFormUnit.pas' {MainForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
