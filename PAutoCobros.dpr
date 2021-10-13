program PAutoCobros;

uses
  Forms,
  SysUtils,
  SincroMainF in 'SincroMainF.pas' {FSincroMain},
  SincroDataDM in 'Data\SincroDataDM.pas' {DSincroData: TDataModule},
  UUtilsBD in 'Code\UUtilsBD.pas',
  UTraerRF in 'Code\UTraerRF.pas',
  UComprobarAlbaranes in 'Code\UComprobarAlbaranes.pas',
  UUtils in 'Code\UUtils.pas',
  UActualizarCobros in 'Code\UActualizarCobros.pas',
  UFacturasComerVsX3 in 'Code\UFacturasComerVsX3.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDSincroData, DSincroData);
  try
    DSincroData.ActualizarCobros;
  finally
    FreeAndNil(DSincroData);
  end
end.
