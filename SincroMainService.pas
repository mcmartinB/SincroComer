unit SincroMainService;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ExtCtrls;

type
  TSSincroMain = class(TService)
    tmrTemporizador: TTimer;
    procedure tmrTemporizadorTimer(Sender: TObject);
    procedure ServiceExecute(Sender: TService);
  private
    { Private declarations }
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  SSincroMain: TSSincroMain;

implementation

{$R *.DFM}

uses
  SincroDataDM, UUtils;

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  SSincroMain.Controller(CtrlCode);
end;

function TSSincroMain.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TSSincroMain.ServiceExecute(Sender: TService);
begin
  tmrTemporizador.Enabled := true;
  while not Terminated do
    ServiceThread.ProcessRequests(True);
  tmrTemporizador.Enabled := false;
end;

procedure TSSincroMain.tmrTemporizadorTimer(Sender: TObject);
begin
  tmrTemporizador.Enabled := False;

  if FormatDateTime('hh:nn', Now) = '12:00' then
  begin
    SincroDataDM.ComprobarAlbaranesVenta;
//    SincroDataDM.ComprobarAlbaranesValorados;
  end;

  (*
  UUtils.AddLog( 'Ejecutado servicio prueba' );
  if FormatDateTime('hh:nn', Now) = '14:44' then
    SincroDataDM.ComprobarAlbaranesVenta;
  if FormatDateTime('hh:nn', Now) = '12:00' then
    SincroDataDM.TraerRfAlmacenes;
  *)

  tmrTemporizador.Enabled := True;
end;

end.
