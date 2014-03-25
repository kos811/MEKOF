program MEKOF;

uses
  Forms,
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  ReportFormUnit in 'ReportFormUnit.pas' {ReportForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TReportForm, ReportForm);
  Application.Run;
end.
