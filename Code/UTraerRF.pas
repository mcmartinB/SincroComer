unit UTraerRF;

interface

uses
  DB, DBTables, SysUtils;

function TraerRf( const AEmpresa: string; const ABD: Integer; const AFuente, ADestino: TQuery; var VLog: string ) : integer;
function TraerRfPB( const AEmpresa: string; const ABD: Integer; const AFuente, ADestino: TQuery; var VLog: string ) : integer;
function TraerRfPCC( const AEmpresa: string; const ABD: Integer; const AFuente, ADestino: TQuery; var VLog: string ) : integer;
function TraerRfPCD( const AEmpresa: string; const ABD: Integer; const AFuente, ADestino: TQuery; var VLog: string  ) : integer;

implementation

function CopiarRegistro(  const AFuente, ADestino: TDataSet ): boolean;
var
  i: integer;
  campo: TField;
begin
  i:= 0;
  while i < ADestino.Fields.Count do
  begin
    campo:= AFuente.FindField(ADestino.Fields[i].FieldName);
    if campo <> nil then
    begin
      ADestino.Fields[i].Value:= campo.Value;
    end;
    inc( i );
  end;
  try
    ADestino.Post;
    result:= true;
  except
    on E: Exception do
    begin
      result:= False;
      ADestino.Cancel;
    end;
  end;
end;

function TraerRf( const AEmpresa: string; const ABD: Integer; const AFuente, ADestino: TQuery; var VLog: string ) : integer;
var
  sAux: string;
begin
  Result:= TraerRfPB( AEmpresa, ABD, AFuente, ADestino, sAux );
  VLog:= sAux;
  Result:= Result + TraerRfPCC( AEmpresa, ABD, AFuente, ADestino, sAux );
  VLog:= VLog + #13 + #10 + sAux;
  TraerRfPCD( AEmpresa, ABD, AFuente, ADestino, sAux );
  VLog:= VLog + #13 + #10 + sAux;
end;


function TraerRfPB( const AEmpresa: string; const ABD: Integer; const AFuente, ADestino: TQuery; var VLog: string  ) : integer;
var
  sAux: string;
  campo: TField;
begin
  Result:= 0;
  VLog:= '';
  ADestino.SQL.Clear;
  ADestino.SQL.Add('delete from rf_palet_pb where cod_empresa_pb = :empresa and cod_bd_pb = :idbd ');
  ADestino.ParamByName('empresa').AsString:= AEmpresa;
  ADestino.ParamByName('idbd').AsInteger:= ABD;
  ADestino.RequestLive:= True;
  ADestino.ExecSQL;

  ADestino.SQL.Clear;
  ADestino.SQL.Add('select * from rf_palet_pb ');
  ADestino.RequestLive:= True;
  ADestino.Open;

  AFuente.SQL.Clear;
  AFuente.SQL.Add('select * from rf_palet_pb where fecha_alta >= today - 365 and status <> ''B'' ');
  AFuente.RequestLive:= False;
  AFuente.Open;

  while not AFuente.Eof do
  begin

    ADestino.Insert;
    ADestino.FieldByName('cod_empresa_pb').AsString:= AEmpresa;
    ADestino.FieldByName('cod_bd_pb').AsInteger:= ABD;
    campo:= AFuente.FindField('sscc');
    sAux:= '';
    if campo <> nil then
      sAux:= campo.AsString;
    if not CopiarRegistro( AFuente, ADestino ) then
    begin
      VLog:= '= ERROR AL INSERTAR [' + AEmpresa + ':' + IntToStr(ABD) + '] ---> ' + sAux + #13 + #10;
    end
    else
    begin
      Inc( Result );
    end;
    AFuente.Next;
  end;
  AFuente.Close;
  ADestino.Close;

  if VLog = '' then
  begin
    VLog:= 'Recepcion de la RF Palets PB OK ';
  end
  else
  begin
    VLog:= 'ERRORES en la recepcion de la RF Palets PB ' + #13 + #10 + VLog;
  end;
end;

function TraerRfPCC( const AEmpresa: string; const ABD: Integer; const AFuente, ADestino: TQuery; var VLog: string  ) : integer;
var
  sAux: string;
  campo: TField;
begin
  VLog:= '';
  ADestino.SQL.Clear;
  ADestino.SQL.Add('delete from rf_palet_pc_cab where cod_empresa_pcc = :empresa and cod_bd_pcc = :idbd ');
  ADestino.ParamByName('empresa').AsString:= AEmpresa;
  ADestino.ParamByName('idbd').AsInteger:= ABD;
  ADestino.RequestLive:= True;
  ADestino.ExecSQL;

  ADestino.SQL.Clear;
  ADestino.SQL.Add('select * from rf_palet_pc_cab ');
  ADestino.RequestLive:= True;
  ADestino.Open;

  AFuente.SQL.Clear;
  AFuente.SQL.Add('select * from rf_palet_pc_cab where date(fecha_alta_cab) > today - 365 and status_cab <> ''B'' ');
  AFuente.RequestLive:= False;
  AFuente.Open;

  Result:= 0;
  while not AFuente.Eof do
  begin

    ADestino.Insert;
    ADestino.FieldByName('cod_empresa_pcc').AsString:= AEmpresa;
    ADestino.FieldByName('cod_bd_pcc').AsInteger:= ABD;
    campo:= AFuente.FindField('ean128_cab');
    sAux:= '';
    if campo <> nil then
      sAux:= campo.AsString;
    if not CopiarRegistro( AFuente, ADestino ) then
    begin
      VLog:= '= ERROR AL INSERTAR [' + AEmpresa + ':' + IntToStr(ABD) + '] ---> ' + sAux + #13 + #10;
    end
    else
    begin
      Inc( Result );
    end;
    AFuente.Next;
  end;
  AFuente.Close;
  ADestino.Close;

  if VLog = '' then
  begin
    VLog:= 'Recepcion de la RF Palets PC Cab OK';
  end
  else
  begin
    VLog:= 'ERRORES en la recepcion de la RF  Palets PC Cab' + #13 + #10 + VLog;
  end;
end;

function TraerRfPCD( const AEmpresa: string; const ABD: Integer; const AFuente, ADestino: TQuery; var VLog: string  ) : integer;
var
  sAux: string;
  campo: TField;
begin
  VLog:= '';
  ADestino.SQL.Clear;
  ADestino.SQL.Add('delete from rf_palet_pc_det where cod_empresa_pcd = :empresa and cod_bd_pcd = :idbd ');
  ADestino.ParamByName('empresa').AsString:= AEmpresa;
  ADestino.ParamByName('idbd').AsInteger:= ABD;
  ADestino.RequestLive:= True;
  ADestino.ExecSQL;

  ADestino.SQL.Clear;
  ADestino.SQL.Add('select * from rf_palet_pc_det ');
  ADestino.RequestLive:= True;
  ADestino.Open;

  AFuente.SQL.Clear;
  AFuente.SQL.Add('select rf_palet_pc_det.*  ');
  AFuente.SQL.Add('from rf_palet_pc_cab ');
  AFuente.SQL.Add('     join rf_palet_pc_det on ean128_cab = ean128_det ');
  AFuente.SQL.Add('where date(rf_palet_pc_cab.fecha_alta_cab)> today - 365 and status_cab <> ''B'' ');
  AFuente.RequestLive:= False;
  AFuente.Open;

  Result:= 0;
  while not AFuente.Eof do
  begin

    ADestino.Insert;
    ADestino.FieldByName('cod_empresa_pcd').AsString:= AEmpresa;
    ADestino.FieldByName('cod_bd_pcd').AsInteger:= ABD;
    campo:= AFuente.FindField('ean128_det');
    sAux:= '';
    if campo <> nil then
      sAux:= campo.AsString;
    if not CopiarRegistro( AFuente, ADestino ) then
    begin
      VLog:= '= ERROR AL INSERTAR [' + AEmpresa + ':' + IntToStr(ABD) + '] ---> ' + sAux + #13 + #10;
    end
    else
    begin
      Inc( Result );
    end;
    AFuente.Next;
  end;
  AFuente.Close;
  ADestino.Close;

  if VLog = '' then
  begin
    VLog:= 'Recepcion de la RF Palets PC Det OK';
  end
  else
  begin
    VLog:= 'ERRORES en la recepcion de la RF  Palets PC Det' + #13 + #10 + VLog;
  end;
end;

end.
