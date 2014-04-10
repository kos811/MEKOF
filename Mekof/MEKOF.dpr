program MEKOF;

uses
  Forms,
  MainFormUnit in 'MainFormUnit.pas' {MainForm},
  ReportFormUnit in 'ReportFormUnit.pas' {ReportForm},
  Vcl.Themes,
  Vcl.Styles,
  Excel_TLB in 'C:\Users\KMT.SFT2000\Documents\RAD Studio\12.0\Imports\Excel_TLB.pas';

{$R *.RES}

begin
  Application.Initialize;
  TStyleManager.TrySetStyle('Light');
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TReportForm, ReportForm);
  Application.Run;
end.
