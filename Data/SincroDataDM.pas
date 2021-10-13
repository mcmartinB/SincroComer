unit SincroDataDM;

interface

uses
  SysUtils, Classes, DB, DBTables, StdCtrls, ComCtrls, Forms, IdMessage,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient,
  IdMessageClient, IdSMTP, ExtCtrls, Windows, Messages, Graphics, SvcMgr,
  Controls, IdExplicitTLSClientServerBase, IdSMTPBase ;


type
  TDSincroData = class(TDataModule)
    dbBAGChanita: TDatabase;
    qryCentral: TQuery;
    qryAlmacen: TQuery;
    dbBAG: TDatabase;
    dbSAT: TDatabase;
    dbSATLlanos: TDatabase;
    dbSATTenerife: TDatabase;
    IdSMTP: TIdSMTP;
    IdMessage: TIdMessage;
    dbBAGP4H: TDatabase;
    dbBAGTenerife: TDatabase;
    dbBAGSevilla: TDatabase;
    dbRF: TDatabase;
    dbX3: TDatabase;
    qryX3: TQuery;
    dbMaster: TDatabase;
  private
    { Private declarations }
    procedure EnviarMsg( const ADataBase, ASubject, AMsg: string );
    procedure EnviarMeMsg( const ADataBase, ASubject, AMsg: string );
    procedure EnviarResumen( const ASubject, AMsg: string );
    procedure PutDireccionMail( const ADataBase: string );
    //procedure PutDireccionCopia;

    procedure ComprobarAlbaranesValoradosSAT( var AMsg: string );
    procedure ComprobarAlbaranesValoradosBAG( var AMsg: string );
    procedure AlbaranesValorados( const ADB: TDatabase; const ADataBaseName: string; var AMsg: string );

    procedure ComprobarAlbaranesVentaSAT( var AMsg: string );
    procedure ComprobarAlbaranesVentaBAG( var AMsg: string );
    procedure AlbaranesVenta( const ADB: TDatabase; const ADataBaseName: string; var AMsg: string );

    procedure TraerRfAlmacenesSAT;
    procedure TraerRfAlmacenesBAG;
    procedure RfAlmacenes( const AEmpresa: string; const ADB: TDatabase );

  public
    { Public declarations }

    (*
    function  ExisteTabla( const ATabName: string ): boolean;
    procedure BorrarSiExisteTabla( const ATabName: string );
    *)

    procedure ComprobarAlbaranesVenta;
    procedure ComprobarAlbaranesValorados;
    procedure TraerRfAlmacenes;
    procedure ActualizarCobros;
    procedure FacturasComerVsX3;
end;

procedure ComprobarAlbaranesVenta;
//procedure ComprobarAlbaranesValorados;
procedure TraerRfAlmacenes;
procedure ActualizarCobros;
procedure FacturasComerVsX3;

var
  DSincroData: TDSincroData;

implementation

uses
  dialogs, variants, UUtilsBD, UTraerRF, UComprobarAlbaranes, UUtils,
  UActualizarCobros, UFacturasComerVsX3, UAlbaranesValorados;

{$R *.dfm}



procedure ComprobarAlbaranesVenta;
begin
  UUtils.AddLog( 'ComprobarAlbaranesVenta' );
  Application.CreateForm(TDSincroData, DSincroData);
  try
    DSincroData.ComprobarAlbaranesVenta;
  finally
    FreeAndNil(DSincroData);
  end;
end;

procedure TraerRfAlmacenes;
begin
  UUtils.AddLog( 'TraerRfAlmacenes' );
  Application.CreateForm(TDSincroData, DSincroData);
  try
    DSincroData.TraerRfAlmacenes;
  finally
    FreeAndNil(DSincroData);
  end;
end;


procedure ActualizarCobros;
begin
  UUtils.AddLog( 'ActualizarCobros' );
  Application.CreateForm(TDSincroData, DSincroData);
  try
    DSincroData.ActualizarCobros;
  finally
    FreeAndNil(DSincroData);
  end;
end;

procedure FacturasComerVsX3;
begin
  UUtils.AddLog( 'ActualizarCobros' );
  Application.CreateForm(TDSincroData, DSincroData);
  try
    DSincroData.FacturasComerVsX3;
  finally
    FreeAndNil(DSincroData);
  end;
end;

(*
function TDAlmacenes.ExisteTabla( const ATabName: string ): boolean;
begin
  with QCentral do
  begin
    SQL.Clear;
    SQL.Add('select * from systables where tabname = :tabname ');
    ParamByName('tabname').AsString:= ATabName;
    Open;
    result:= not IsEmpty;
    Close;
  end;
end;

procedure TDAlmacenes.BorrarSiExisteTabla( const ATabName: string );
begin
  If ExisteTabla(ATabName) then
  begin
    with QCentral do
    begin
      SQL.Clear;
      SQL.Add('drop table ' +  ATabName );
      ExecSQL;
    end;
  end;
end;
*)

procedure TDSincroData.PutDireccionMail( const ADataBase: string );
begin
  UUtils.AddLog( 'TDSincroData.PutDireccionMail' );

  IdMessage.Recipients.Clear;

  if ADataBase = 'dbSATLlanos' then
  begin
    //080 - centro cuatro a chanita
    IdMessage.Recipients.Add.Address := 'administrativos.llanos@satbonnysa.com';
    IdMessage.Recipients.Add.Address := 'veronica.ras@bonnysa.es';
    IdMessage.Recipients.Add.Address := 'mcmartin@bonnysa.es';
  end
  else
  if ( ADataBase = 'dbSATTenerife' ) or ( ADataBase = 'dbBAGTenerife' ) then
  begin
    //IdMessage.Recipients.Add.Address := 'franciscoechandi@bonnysa.es';
    IdMessage.Recipients.Add.Address := 'palomahernandez@bonnysa.es';
    IdMessage.Recipients.Add.Address := 'patriciaperez@bonnysa.es';
    IdMessage.Recipients.Add.Address := 'mcmartin@bonnysa.es';
  end
  else
  if ( ADataBase = 'dbBAGChanita' )  then
  begin
    //F17 - centro 2 los llanos
    IdMessage.Recipients.Add.Address := 'almacen.alc@masetdeseva.com';
    IdMessage.Recipients.Add.Address := 'mcmartin@bonnysa.es';
    //IdMessage.Recipients.Add.Address := 'administrativos.llanos@satbonnysa.com';
  end
  else
  if ( ADataBase = 'dbBAGP4H' )  then
  begin
    IdMessage.Recipients.Add.Address := 'mjoserivera@bonnysa.es';
    IdMessage.Recipients.Add.Address := 'mcmartin@bonnysa.es';
  end;
//  else
//  if ( ADataBase = 'dbBAGSevilla' )  then
//  begin
//    IdMessage.Recipients.Add.Address := 'yahaira@frigodocks.es';
//    IdMessage.Recipients.Add.Address := 'laura@frigodocks.es';
//  end;

(*
  while direcciones <> '' do
  begin
    if pos(';', direcciones) > 0 then
    begin
      IdMessage.Recipients.Add.Address := Trim(Copy(direcciones, 0, (pos(';', direcciones) - 1)));
      aux := pos(';', direcciones) + 1;
      direcciones := Copy(direcciones, aux, Length(direcciones));
    end
    else
    begin
      IdMessage.Recipients.Add.Address := trim(Copy(direcciones, 0, Length(direcciones)));
      direcciones := '';
    end;
  end;
*)
end;

(*
procedure TDSincroData.PutDireccionCopia;
begin
  UUtils.AddLog( 'TDSincroData.PutDireccionCopia' );

  IdMessage.CCList.Clear;
  IdMessage.CCList.Add.Address:= 'rosanagonzalez@bonnysa.es';
  //IdMessage.CCList.Add.Address:= 'vanessalucas@bonnysa.es';
  IdMessage.CCList.Add.Address:= 'pepebrotons@bonnysa.es';
end;
*)

procedure TDSincroData.EnviarMsg( const ADataBase, ASubject, AMsg: string );
begin

  UUtils.AddLog( 'TDSincroData.EnviarMsg' );

  IdSMTP.Host:= 'smtp.bonnysa.es';
  IdSMTP.Username:= 'mcmartin@bonnysa.es';
  IdSMTP.Password:= 'Mm457913';
//  IdSMTP.Password:= 'Pb123456';
  IdSMTP.Port:= 25;  // IdSMTP.Port:= 257;
  try
    try
      Screen.Cursor := crHourGlass;
      IdSMTP.Connect;
      IdMessage.From.Name := 'Control Gestión Comercial';
      IdMessage.From.Address := 'mcmartin@bonnysa.es';
      IdMessage.ReplyTo.EMailAddresses:= 'mcmartin@bonnysa.es';

      IdMessage.Recipients.Clear;


      IdMessage.Recipients.Add.Address:= 'mcmartin@bonnysa.es';
      PutDireccionMail( ADataBase );


      //PutDireccionCopia;
      //IdMessage.BccList.Clear;
      //IdMessage.BccList.Add.Address:= 'pepebrotons@bonnysa.es';

      IdMessage.Subject := ASubject;
      IdMessage.Body.Clear;
      IdMessage.Body.Add( AMsg );
      IdSMTP.Send(IdMessage);
      Screen.Cursor := crArrow;
    finally
      IdSMTP.Disconnect;
    end;
  except
    //Ignramos el error si no podemos enviar el correo
    //por lo meos el programa sigue ejecutandos
  end;
end;

procedure TDSincroData.EnviarResumen( const ASubject, AMsg: string );
begin
  UUtils.AddLog( 'TDSincroData.EnviarMsg' );

  IdSMTP.Host:= 'smtp.bonnysa.es';
  IdSMTP.Username:= 'mcmartin@bonnysa.es';
  IdSMTP.Password:= 'Mm457913';
  IdSMTP.Port:= 25;  // IdSMTP.Port:= 257;
  try
    try
      Screen.Cursor := crHourGlass;
      IdSMTP.Connect;
      IdMessage.From.Name := 'Control Gestión Comercial';
      IdMessage.From.Address := 'mcmartin@bonnysa.es';
      IdMessage.ReplyTo.EMailAddresses:= 'mcmartin@bonnysa.es';


      IdMessage.Recipients.Clear;
      IdMessage.Recipients.Add.Address:= 'rosanagonzalez@bonnysa.es';
      IdMessage.Recipients.Add.Address:= 'vanessalucas@bonnysa.es';
      IdMessage.Recipients.Add.Address:= 'mcmartin@bonnysa.es';
      IdMessage.BccList.Clear;
      IdMessage.BccList.Add.Address:= 'mcmartin@bonnysa.es';

      IdMessage.Subject := ASubject;
      IdMessage.Body.Clear;
      IdMessage.Body.Add( AMsg );
      IdSMTP.Send(IdMessage);
      Screen.Cursor := crArrow;
    finally
      IdSMTP.Disconnect;
    end;
  except
    //Ignramos el error si no podemos enviar el correo
    //por lo meos el programa sigue ejecutandos
  end;
end;

procedure TDSincroData.EnviarMeMsg( const ADataBase, ASubject, AMsg: string );
begin
  UUtils.AddLog( 'TDSincroData.EnviarMeMsg' );

  IdSMTP.Host:= 'smtp.bonnysa.es';
  IdSMTP.Username:= 'mcmartin@bonnysa.es';
  IdSMTP.Password:= 'Mm457913';
  IdSMTP.Port:= 25;  // IdSMTP.Port:= 257;
  try
    try
      Screen.Cursor := crHourGlass;
      IdSMTP.Connect;
      IdMessage.From.Name := 'Control Gestión Comercial';
      IdMessage.From.Address := 'mcmartin@bonnysa.es';
      IdMessage.ReplyTo.EMailAddresses:= 'mcmartin@bonnysa.es';

      IdMessage.Recipients.Clear;
      IdMessage.Recipients.Add.Address := 'mcmartin@bonnysa.es';

      IdMessage.Subject := ASubject;
      IdMessage.Body.Clear;
      IdMessage.Body.Add( AMsg );
      IdSMTP.Send(IdMessage);
      Screen.Cursor := crArrow;
    finally
      IdSMTP.Disconnect;
    end;
  except
    //Ignramos el error si no podemos enviar el correo
    //por lo meos el programa sigue ejecutandos
  end;
end;

procedure TDSincroData.ComprobarAlbaranesVenta;
var
  sAux, sMsg: string;
begin
  UUtils.AddLog( 'TDSincroData.ComprobarAlbaranesVenta' );

  ComprobarAlbaranesVentaSAT( sMsg );
  ComprobarAlbaranesVentaBAG( sAux );
  sMsg:= sMsg + #13 + #10 + sAux;
  EnviarResumen( 'ALBARANES PENDIENTES DE ENVIO DEL ' + FormatDateTime( 'dd/mm/yy', Now-30)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , sMsg );
//  EnviarResumen( 'ALBARANES PENDIENTES DE ENVIO DEL ' + FormatDateTime( 'dd/mm/yy', Now-185)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , sMsg );
end;


procedure TDSincroData.ComprobarAlbaranesVentaSAT( var AMsg: string );
var
  sAux: string;
begin
  UUtils.AddLog( 'TDSincroData.ComprobarAlbaranesVentaSAT' );


  try
    //Abrir BD Central
    dbSAT.Connected:= True;
    qryCentral.DatabaseName:= dbSAT.DatabaseName;
  except
    ShowMessage('Probemas al conectar con la BD de RF en la central ');
    Exit;
  end;

  try
    AlbaranesVenta( dbSATTenerife, 'SAT TENERIFE', sAux );
    AMsg:= '* SAT Tenerife' + #13 + #10 + sAux;
    AlbaranesVenta( dbSATLlanos, 'SAT PENINSULA', sAux );
    AMsg:= AMsg + #13 + #10 + '* SAT Península' + #13 + #10 + sAux;
  finally
    dbSAT.Connected:= False;
  end;
end;

procedure TDSincroData.ComprobarAlbaranesVentaBAG( var AMsg: string );
var
  sAux: string;
begin
  UUtils.AddLog( 'TDSincroData.ComprobarAlbaranesVentaBAG' );

  try
    //Abrir BD Central
    dbBAG.Connected:= True;
    qryCentral.DatabaseName:= dbBAG.DatabaseName;
  except
    ShowMessage('Probemas al conectar con la BD de RF en la central ');
    Exit;
  end;

  try
    AlbaranesVenta( dbBAGChanita, 'BAG CHANITA', sAux );
    AMsg:= '* BAG Chanita' + #13 + #10 + sAux;
    AlbaranesVenta( dbBAGP4H, 'BAG P4H', sAux );
    AMsg:= AMsg + #13 + #10 + '* BAG P4H' + #13 + #10 + sAux;
    AlbaranesVenta( dbBAGTenerife, 'BAG TENERIFE', sAux );
    AMsg:= AMsg + #13 + #10 + '* BAG Tenerife' + #13 + #10 + sAux;
    //AlbaranesVenta( 'BAG', dbBAGSevilla );
  finally
    dbBAG.Connected:= False;
  end;
end;


procedure TDSincroData.AlbaranesVenta( const ADB: TDatabase; const ADataBaseName: string; var AMsg: string );
begin
  UUtils.AddLog( 'TDSincroData.AlbaranesVenta' );

  try
    //Abrir BD Almacen
    ADB.Connected:= True;
    qryAlmacen.DatabaseName:= ADB.DatabaseName;
  except
    ADB.Connected:= False;
    ShowMessage('Probemas al conectar con la BD de RF en el almacen de Chanita Alicante ');
    Exit;
  end;

  try
    AMsg:= '';
    if ComprobarRecepccionAlbaranesVenta( qryAlmacen, qryCentral, AMsg ) > 0 then
      EnviarMsg( qryAlmacen.DatabaseName, ADataBaseName + ' ALBARANES PENDIENTES DE ENVIO DEL ' + FormatDateTime( 'dd/mm/yy', Now-30)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , AMsg )
//      EnviarMsg( qryAlmacen.DatabaseName, ADataBaseName + ' ALBARANES PENDIENTES DE ENVIO DEL ' + FormatDateTime( 'dd/mm/yy', Now-185)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , AMsg )
    else
      EnviarMsg( qryAlmacen.DatabaseName, ADataBaseName + ' NO HAY ALBARANES PENDIENTES DEL ' + FormatDateTime( 'dd/mm/yy', Now-30)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , AMsg );
//      EnviarMsg( qryAlmacen.DatabaseName, ADataBaseName + ' ALBARANES PENDIENTES DE ENVIO DEL ' + FormatDateTime( 'dd/mm/yy', Now-185)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , AMsg )
  finally
    ADB.Connected:= False;
  end;
end;

procedure TDSincroData.TraerRfAlmacenes;
begin
  UUtils.AddLog( 'TDSincroData.TraerRfAlmacenes' );

  //TraerRfAlmacenesSAT;
  TraerRfAlmacenesBAG;
end;

procedure TDSincroData.TraerRfAlmacenesSAT;
begin
  UUtils.AddLog( 'TDSincroData.TraerRfAlmacenesSAT' );

  try
    //Abrir BD Central
    dbRF.Connected:= True;
    qryCentral.DatabaseName:= dbRF.DatabaseName;
  except
    ShowMessage('Probemas al conectar con la BD de RF en la central ');
    Exit;
  end;

  try
    RfAlmacenes( 'SAT', dbSATLlanos );
    RfAlmacenes( 'SAT', dbSATTenerife );
  finally
    dbSAT.Connected:= False;
  end;
end;


procedure TDSincroData.TraerRfAlmacenesBAG;
begin
  UUtils.AddLog( 'TDSincroData.TraerRfAlmacenesBAG' );

  try
    //Abrir BD Central
    dbRF.Connected:= True;
    qryCentral.DatabaseName:= dbRF.DatabaseName;
  except
    ShowMessage('Probemas al conectar con la BD de RF en la central ');
    Exit;
  end;

  try
    RfAlmacenes( 'BAG', dbBAGChanita );
    RfAlmacenes( 'BAG', dbBAGP4H );
    RfAlmacenes( 'BAG', dbBAGTenerife );
    //RfAlmacenes( 'BAG', dbBAGSevilla );
  finally
    dbBAG.Connected:= False;
  end;
end;


function GetDBid( const ADatabaseName: string ): integer;
begin
  UUtils.AddLog( 'GetDBid' );

  if ( ADatabaseName = 'dbBAG' ) or ( ADatabaseName = 'dbSAT' ) then
    result:= 0
  else
  if ADatabaseName = 'dbSATLlanos' then
    Result:= 1
  else
  if ADatabaseName = 'dbBAGChanita' then
    Result:= 3
  else
  if ADatabaseName = 'dbBAGP4H' then
    Result:= 4
  else
  if ADatabaseName = 'dbBAGSevilla' then
    Result:= 5
  else
  if ( ADatabaseName = 'dbSATTenerife' ) or ( ADatabaseName = 'dbBAGTenerife' )  then
    Result:= 6
  else
    Result:= -1;
end;


procedure TDSincroData.RfAlmacenes( const AEmpresa: string; const ADB: TDatabase );
var
  VMsg: string;
  dIni, dFin: TDateTime;
  iResult: Integer;
begin
  UUtils.AddLog( 'TDSincroData.RfAlmacenes' );

  try
    //Abrir BD Almacen
    ADB.Connected:= True;
    qryAlmacen.DatabaseName:= ADB.DatabaseName;
  except
    ADB.Connected:= False;
    ShowMessage('Probemas al conectar con la BD de RF en el almacen de Chanita Alicante ');
    Exit;
  end;

  try
    VMsg:= '';
    dIni:= Now;
    iResult:= TraerRf( AEmpresa, GetDBid( ADB.DatabaseName ) , qryAlmacen, qryCentral, VMsg );
    dFin:= Now;

    VMsg:= '********************************************************' + #13 + #10 + VMsg;
    VMsg:= 'TIEMPO:' + FormatDateTime( 'hh:nn:ss', dFin - dIni) + #13 + #10 + VMsg;
    VMsg:= FormatDateTime( 'dd/mm/yy hh:nn:ss', dFin ) + ' -> FIN' + #13 + #10 + VMsg;
    VMsg:= FormatDateTime( 'dd/mm/yy hh:nn:ss', dIni ) +  ' -> INICIO' + #13 + #10 + VMsg;



    if iResult < 0 then
    begin
      EnviarMeMsg( qryAlmacen.DatabaseName, 'RF EN PRUEBAS '+ AEmpresa + '[' + ADB.DatabaseName + '] (' + FormatDateTime( 'dd/mm/yy hh:mm', Now)  + '): ERROR', VMsg )
    end
    else
    begin
      EnviarMeMsg( qryAlmacen.DatabaseName, 'RF EN PRUEBAS '+ AEmpresa + '[' +  ADB.DatabaseName + '] (' + FormatDateTime( 'dd/mm/yy hh:mm', Now)  + '): OK', VMsg );
    end;
  finally
    ADB.Connected:= False;
  end;
end;

procedure TDSincroData.ActualizarCobros;
var
  VMsg: string;
  iResult: Integer;
  dIni, dFin: TDateTime;
begin
  UUtils.AddLog( 'TDSincroData.ActualizarCobros' );
  try
    //Abrir BD Almacen
    dbX3.Connected:= True;
    qryX3.DatabaseName:= dbX3.DatabaseName;
  except
    dbX3.Connected:= False;
    ShowMessage('Probemas al conectar con la BD de X3 en la central ');
    Exit;
  end;

  try
    //Abrir BD Central
    dbMaster.Connected:= True;
    qryCentral.DatabaseName:= dbMaster.DatabaseName;
  except
    ShowMessage('Probemas al conectar con la BD Master en la central ');
    Exit;
  end;

  try
    VMsg:= '';
    dIni:= Now;
    iResult:= UActualizarCobros.ActualizarCobros( qryCentral, qryX3, VMsg );
    dFin:= Now;

    VMsg:= '********************************************************' + #13 + #10 + VMsg;
    VMsg:= 'TIEMPO:' + FormatDateTime( 'hh:nn:ss', dFin - dIni) + #13 + #10 + VMsg;
    VMsg:= FormatDateTime( 'dd/mm/yy hh:nn:ss', dFin ) + ' -> FIN' + #13 + #10 + VMsg;
    VMsg:= FormatDateTime( 'dd/mm/yy hh:nn:ss', dIni ) +  ' -> INICIO' + #13 + #10 + VMsg;
    EnviarMeMsg( qryCentral.DatabaseName, 'EN PRUEBAS SAT (' + FormatDateTime( 'dd/mm/yy hh:mm', Now)  + '): Cobros actualizados -> ' + IntToStr( iResult ), VMsg );
  finally
    dbSAT.Connected:= False;
    dbX3.Connected:= False;
  end;
end;

procedure TDSincroData.FacturasComerVsX3;
var
  VMsg: string;
  iResult: Integer;
  dIni, dFin: TDateTime;
begin
  UUtils.AddLog( 'TDSincroData.FacturasComerVsX3' );
  try
    //Abrir BD Almacen
    dbX3.Connected:= True;
    qryX3.DatabaseName:= dbX3.DatabaseName;
  except
    dbX3.Connected:= False;
    ShowMessage('Probemas al conectar con la BD de X3 en la central ');
    Exit;
  end;

  try
    //Abrir BD Central
    dbMaster.Connected:= True;
    qryCentral.DatabaseName:= dbMaster.DatabaseName;
  except
    ShowMessage('Probemas al conectar con la BD Master en la central ');
    Exit;
  end;

  try
    VMsg:= '';
    dIni:= Now;
    //iResult:= UFacturasComerVsX3.FacturasComerVsX3( qryCentral, qryX3, VMsg );
    dFin:= Now;

    VMsg:= '********************************************************' + #13 + #10 + VMsg;
    VMsg:= 'TIEMPO:' + FormatDateTime( 'hh:nn:ss', dFin - dIni) + #13 + #10 + VMsg;
    VMsg:= FormatDateTime( 'dd/mm/yy hh:nn:ss', dFin ) + ' -> FIN' + #13 + #10 + VMsg;
    VMsg:= FormatDateTime( 'dd/mm/yy hh:nn:ss', dIni ) +  ' -> INICIO' + #13 + #10 + VMsg;
    EnviarMeMsg( qryCentral.DatabaseName, 'EN PRUEBAS SAT (' + FormatDateTime( 'dd/mm/yy hh:mm', Now)  + '): Cobros actualizados -> ' + IntToStr( iResult ), VMsg );
  finally
    dbSAT.Connected:= False;
    dbX3.Connected:= False;
  end;
end;

procedure TDSincroData.ComprobarAlbaranesValorados;
var
  sAux, sMsg: string;
begin
  UUtils.AddLog( 'TDSincroData.ComprobarAlbaranesValorados' );

  ComprobarAlbaranesValoradosSAT( sMsg );
  ComprobarAlbaranesValoradosBAG( sAux );
  sMsg:= sMsg + #13 + #10 + sAux;
  EnviarResumen( 'ALBARANES PENDIENTES DE VALORAR DEL ' + FormatDateTime( 'dd/mm/yy', Now-30)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , sMsg );
//  EnviarResumen( 'ALBARANES PENDIENTES DE ENVIO DEL ' + FormatDateTime( 'dd/mm/yy', Now-185)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , sMsg );
end;

procedure TDSincroData.ComprobarAlbaranesValoradosBAG(var AMsg: string);
begin

end;

procedure TDSincroData.ComprobarAlbaranesValoradosSAT( var AMsg: string );
var
  sAux: string;
begin
  UUtils.AddLog( 'TDSincroData.ComprobarAlbaranesValoradosSAT' );


  try
    //Abrir BD Central
    dbSAT.Connected:= True;
    qryCentral.DatabaseName:= dbSAT.DatabaseName;
  except
    ShowMessage('Problemas al conectar con la BD de la central ');
    Exit;
  end;

  try
    AlbaranesValorados( dbSAT, 'SAT', sAux );
    AMsg:= '* SAT' + #13 + #10 + sAux;
  finally
    dbSAT.Connected:= False;
  end;
end;

procedure TDSincroData.AlbaranesValorados(const ADB: TDatabase; const ADataBaseName: string; var AMsg: string);
var VLog: String;
begin
  UUtils.AddLog( 'TDSincroData.AlbaranesValorados' );

  try
    //Abrir BD Almacen
    ADB.Connected:= True;
    qryAlmacen.DatabaseName:= ADB.DatabaseName;
  except
    ADB.Connected:= False;
    ShowMessage('Probemas al conectar con la BD. ');
    Exit;
  end;

  try
    AMsg:= '';
    if ComprobarRecepcionAlbaranesValorados( qryAlmacen, qryCentral, VLog, AMsg ) > 0 then
      EnviarMsg( qryAlmacen.DatabaseName, ADataBaseName + ' ALBARANES PENDIENTES DE ENVIO DEL ' + FormatDateTime( 'dd/mm/yy', Now-30)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , AMsg )
//      EnviarMsg( qryAlmacen.DatabaseName, ADataBaseName + ' ALBARANES PENDIENTES DE ENVIO DEL ' + FormatDateTime( 'dd/mm/yy', Now-185)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , AMsg )
    else
      EnviarMsg( qryAlmacen.DatabaseName, ADataBaseName + ' NO HAY ALBARANES PENDIENTES DEL ' + FormatDateTime( 'dd/mm/yy', Now-30)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , AMsg );
//      EnviarMsg( qryAlmacen.DatabaseName, ADataBaseName + ' ALBARANES PENDIENTES DE ENVIO DEL ' + FormatDateTime( 'dd/mm/yy', Now-185)  + ' AL ' + FormatDateTime( 'dd/mm/yy', Now-1) , AMsg )
  finally
    ADB.Connected:= False;
  end;

end;

end.
