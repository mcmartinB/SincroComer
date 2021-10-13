program ServiceSincroComer;

uses
  SvcMgr,
  SincroMainService in 'SincroMainService.pas' {SSincroMain: TService},
  SincroDataDM in 'Data\SincroDataDM.pas' {DSincroData: TDataModule},
  UAlbaranesValorados in 'Code\UAlbaranesValorados.pas',
  UTraerRF in 'Code\UTraerRF.pas',
  UUtilsBD in 'Code\UUtilsBD.pas',
  UUtils in 'Code\UUtils.pas',
  UActualizarCobros in 'Code\UActualizarCobros.pas',
  UFacturasComerVsX3 in 'Code\UFacturasComerVsX3.pas',
  UComprobarAlbaranes in 'Code\UComprobarAlbaranes.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TSSincroMain, SSincroMain);
  Application.Run;
end.
