unit UActualizarCobros;

interface

uses
  DB, DBTables;


function ActualizarCobros( const AMaster, AX3: TQuery; var VLog: string  ) : integer;


implementation

uses
  SysUtils, UUtils, Variants;

var
  bFlag: Boolean = False;
  qryAux: TQuery;

  (*
   CREATE TABLE tfacturas_pago (
    cod_factura_fp CHAR(15) NOT NULL,
    importe_factura_fp DECIMAL(10,2),
    importe_cobrado_fp DECIMAL(10,2),
    importe_pendiente_fp DECIMAL(10,2),
    fecha_factura_fp date,
    fecha_prevista_fp date,
    fecha_cobro_fp date,
    dias_retraso_fp integer
   )
  *)

procedure FacturasSinCobroSQL( const AQuery: TQuery );
begin
  with AQuery do
  begin
    SQL.Clear;
    SQL.Add(' select cod_factura_fc, fecha_factura_fc, prevision_cobro_fc, importe_total_fc ');
    SQL.Add(' from tfacturas_cab ');
    SQL.Add(' where 1 = 1 ');
    SQL.Add(' and not exists ');
    SQL.Add('     ( ');
    SQL.Add('       select * ');
    SQL.Add('       from tfacturas_pago ');
    SQL.Add('       where cod_factura_fc = cod_factura_fp ');
    SQL.Add('     ) ');
  end;


  with qryAux do
  begin
    SQL.Clear;
    SQL.Add(' insert into tfacturas_pago values ');
    SQL.Add('        (:codfactura, :importefactura, :importecobrado, :importependiente, :eurosfactura, :euroscobrado, :eurospendiente, :fechafactura,:FechaPrevista,:FechaCobro,:diasretraso) ');
  end;
end;

procedure FacturasPendientesSQL( const AQuery: TQuery );
begin
  with AQuery do
  begin
    SQL.Clear;
    SQL.Add(' select cod_factura_fc, fecha_factura_fc, prevision_cobro_fc, importe_total_fc ');
    SQL.Add(' from tfacturas_cab ');
    SQL.Add('      join tfacturas_pago on cod_factura_fc = cod_factura_fp ');
    SQL.Add(' where importe_pendiente_fp <> 0 ');
  end;

  with qryAux do
  begin
    SQL.Clear;
    SQL.Add(' update tfacturas_pago ');
    SQL.Add(' set importe_factura_fp = :importefactura, ');
    SQL.Add('     importe_cobrado_fp = :importecobrado, ');
    SQL.Add('     importe_pendiente_fp = :importependiente, ');
    SQL.Add('     euros_factura_fp = :eurosfactura, ');
    SQL.Add('     euros_cobrado_fp = :euroscobrado, ');
    SQL.Add('     euros_pendiente_fp = :eurospendiente, ');
    SQL.Add('     fecha_factura_fp = :fechafactura, ');
    SQL.Add('     fecha_prevista_fp = :FechaPrevista, ');
    SQL.Add('     fecha_cobro_fp = :FechaCobro, ');
    SQL.Add('     dias_retraso_fp = :diasretraso ');
    SQL.Add(' where cod_factura_fp = :codfactura ');
  end;
end;

procedure ImporteCobradoSQL( const AQuery: TQuery );
begin
  if not bFlag then
  begin
    with AQuery do
    begin
      SQL.Clear;
      SQL.Add(' USE v6; ');
      ExecSQL;
    end;
    bFlag:= True;
  end;

  with AQuery do
  begin
    SQL.Clear;
    SQL.Add(' SELECT ');
    SQL.Add('        CPY_0 AS [Sociedad], ');
    SQL.Add('        BPR_0 AS [Tercero], ');
    SQL.Add('        TYP_0 AS [Tipo], ');
    SQL.Add('        NUM_0 AS [CodFactura], ');
    SQL.Add('        AMTCUR_0 AS [Importe], ');
    SQL.Add('        PAYCUR_0 AS [Cobrado], ');
    SQL.Add('        AMTLOC_0 AS [eurosFactura], ');
    SQL.Add('        PAYLOC_0 AS [eurosCobrado],  ');
    SQL.Add('        PAYDAT_0 AS [FechaCobro], ');
    SQL.Add('        DUDDAT_0 AS [FechaPrevista] ');
    //SQL.Add('        DATEDIFF(day, DUDDAT_0, GETDATE()) AS [DiasRetrasoHoy], ');
    //SQL.Add('        DATEDIFF(day, DUDDAT_0, PAYDAT_0) AS [DiasRetrasoPago] ');
    SQL.Add(' FROM ');
    SQL.Add('      BONNYSA.GACCDUDATE ');
    SQL.Add(' WHERE  1 = 1 ');
    SQL.Add(' AND NUM_0 = :factura ');
  end;
end;


procedure InsertarCobro( const AMaster, AX3: TQuery );
var
  fCorte: TDateTime;
begin
  qryAux.ParamByName('codfactura').AsString:= AMaster.FieldByName('cod_factura_fc').AsString;

  if AX3.FieldByName('Importe').AsFloat <> 0 then
    qryAux.ParamByName('importefactura').AsFloat:= AX3.FieldByName('Importe').AsFloat
  else
    qryAux.ParamByName('importefactura').AsFloat:= AMaster.FieldByName('importe_total_fc').AsFloat;

  qryAux.ParamByName('importecobrado').AsFloat:= AX3.FieldByName('Cobrado').AsFloat;
  qryAux.ParamByName('importependiente').AsFloat:= AX3.FieldByName('Importe').AsFloat - AX3.FieldByName('Cobrado').AsFloat;

  qryAux.ParamByName('eurosfactura').AsFloat:= AX3.FieldByName('eurosFactura').AsFloat;
  qryAux.ParamByName('euroscobrado').AsFloat:= AX3.FieldByName('eurosCobrado').AsFloat;
  qryAux.ParamByName('eurospendiente').AsFloat:= AX3.FieldByName('eurosFactura').AsFloat - AX3.FieldByName('eurosCobrado').AsFloat;

  qryAux.ParamByName('fechafactura').AsDateTime:= AMaster.FieldByName('fecha_factura_fc').AsDateTime;

  fCorte:= StrToDate('1/1/1990');
  //Fecha prevista
  if AX3.FieldByName('FechaPrevista').Value > fCorte then
  begin
    qryAux.ParamByName('FechaPrevista').AsDateTime:= AX3.FieldByName('FechaPrevista').AsDateTime;
  end
  else
  begin
    qryAux.ParamByName('FechaPrevista').AsDateTime:=  AMaster.FieldByName('prevision_cobro_fc').AsDateTime;
  end;

  //Fecha cobro
  if AX3.FieldByName('FechaCobro').Value > fCorte then
  begin
    qryAux.ParamByName('FechaCobro').AsDateTime:= AX3.FieldByName('FechaCobro').AsDateTime;
  end
  else
  begin
    if qryAux.ParamByName('importecobrado').AsFloat <> 0 then
      qryAux.ParamByName('FechaCobro').AsDateTime:= AMaster.FieldByName('prevision_cobro_fc').AsDateTime
    else
      qryAux.ParamByName('FechaCobro').AsDateTime:= fCorte;
  end;

  if qryAux.ParamByName('importependiente').AsFloat = 0 then
  begin
    qryAux.ParamByName('diasretraso').AsInteger:= Trunc( qryAux.ParamByName('FechaCobro').AsDateTime - qryAux.ParamByName('FechaPrevista').AsDateTime );
  end
  else
  begin
    qryAux.ParamByName('diasretraso').AsInteger:= Trunc( Now - qryAux.ParamByName('FechaPrevista').AsDateTime );
  end;
  qryAux.ExecSQL;
end;


function ActualizarCobros( const AMaster, AX3: TQuery; var VLog: string  ) : integer;
var
  bAux1, bAux2: boolean;
begin
  qryAux:= TQuery.Create( AMaster.Owner );
  qryAux.DatabaseName:= AMaster.DatabaseName;
  Result:= 0;
  VLog:= '';
  bAux1:= AMaster.RequestLive;
  AMaster.RequestLive:= False;
  bAux2:= AX3.RequestLive;
  AX3.RequestLive:= False;

  //Seleccionamos facturas
  try
    ImporteCobradoSQL( AX3 );


    FacturasPendientesSQL( AMaster );
    AMaster.Open;
    while not AMaster.Eof do
    begin
      AX3.ParamByName('factura').AsString:= AMaster.FieldByName('cod_factura_fc').AsString;
      AX3.Open;
      InsertarCobro( AMaster, AX3 );
      AX3.Close;
      AMaster.Next;
      Inc( Result );
    end;
    AMaster.Close;

    FacturasSinCobroSQL( AMaster );
    AMaster.Open;
    while not AMaster.Eof do
    begin
      AX3.ParamByName('factura').AsString:= AMaster.FieldByName('cod_factura_fc').AsString;
      AX3.Open;
      InsertarCobro( AMaster, AX3 );
      AX3.Close;
      AMaster.Next;
      Inc( Result );
    end;
    AMaster.Close;

  finally
    AMaster.Close;
    qryAux.Close;
    AX3.Close;

    AMaster.RequestLive:= bAux1;
    AX3.RequestLive:= bAux2;

    FreeAndNil( qryAux );
  end;
end;


end.
