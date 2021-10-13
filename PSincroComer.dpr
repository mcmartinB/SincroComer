program PSincroComer;

uses
  Forms,
  SincroMainF in 'SincroMainF.pas' {FSincroMain},
  SincroDataDM in 'Data\SincroDataDM.pas' {DSincroData: TDataModule},
  UUtilsBD in 'Code\UUtilsBD.pas',
  UTraerRF in 'Code\UTraerRF.pas',
  UComprobarAlbaranes in 'Code\UComprobarAlbaranes.pas',
  UUtils in 'Code\UUtils.pas',
  UFacturasComerVsX3 in 'Code\UFacturasComerVsX3.pas',
  UActualizarCobros in 'Code\UActualizarCobros.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFSincroMain, FSincroMain);
  Application.Run;
end.
