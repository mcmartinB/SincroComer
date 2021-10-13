unit SincroMainF;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, DBTables, StdCtrls, ComCtrls, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdMessageClient, IdSMTP, IdMessage, Grids,
  DBGrids;

type
  TFSincroMain = class(TForm)
    btnAlbaranes: TButton;
    btnClose: TButton;
    dbgrd1: TDBGrid;
    dbgrd2: TDBGrid;
    ds1: TDataSource;
    ds2: TDataSource;
    btnTraerRF: TButton;
    btnCobros: TButton;
    btnFacturasX3: TButton;
    procedure btnAlbaranesClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnTraerRFClick(Sender: TObject);
    procedure btnCobrosClick(Sender: TObject);
    procedure btnFacturasX3Click(Sender: TObject);
  private
    { Private declarations }
    ADestino: TDataSet;

  public
    { Public declarations }
  end;

var
  FSincroMain: TFSincroMain;

implementation

uses SincroDataDM, DateUtils;

{$R *.dfm}

procedure TFSincroMain.FormCreate(Sender: TObject);
begin
  //DSincroData:= TDSincroData.Create( self );
  //dtpFecha.DateTime:= IncYear( Now, -1 );
end;

procedure TFSincroMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //FreeAndNil( DSincroData );
end;

procedure TFSincroMain.btnAlbaranesClick(Sender: TObject);
var
  sMsg: string;
  dIni, dGlobal: TDateTime;
begin
   SincroDataDM.ComprobarAlbaranesVenta;
end;

procedure TFSincroMain.btnTraerRFClick(Sender: TObject);
begin
  SincroDataDM.TraerRfAlmacenes;
end;

procedure TFSincroMain.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFSincroMain.btnCobrosClick(Sender: TObject);
begin
  SincroDataDM.ActualizarCobros;
end;

procedure TFSincroMain.btnFacturasX3Click(Sender: TObject);
begin
  SincroDataDM.FacturasComerVsX3;
end;

end.
