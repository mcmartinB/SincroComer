unit UFacturasComerVsX3;

interface

uses
  DB, DBTables;


//function ActualizarCobros( const AMaster, AX3: TQuery; var VLog: string  ) : integer;


implementation

uses
  SysUtils, UUtils, Variants;

var
  bFlag: Boolean = False;

procedure FacturasComer( const AQuery: TQuery );
begin
  with AQuery do
  begin
    SQL.Clear;
    SQL.Add(' select * ');
    SQL.Add(' from tfacturas_cab ');
    SQL.Add(' where 1 = 1 ');
    SQL.Add(' and fecha_factura_fc >= ''1/5/2015'' ');
  end;
end;


procedure SQLFacturasX3( const AQuery: TQuery );
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
    SQL.Add('SELECT ACCDAT_0,BPR_0,AMTNOT_0,AMTATI_0,CUR_0 FROM BONNYSA.SINVOICE ');
    SQL.Add('WHERE NUM_0= :factura ');
  end;
end;



function FacturasComerVsX3( const AMaster, AX3: TQuery; var VLog: string  ) : integer;
var
  bAux1, bAux2: boolean;
begin
  Result:= 0;
  VLog:= '';
  bAux1:= AMaster.RequestLive;
  AMaster.RequestLive:= False;
  bAux2:= AX3.RequestLive;
  AX3.RequestLive:= False;

  //Seleccionamos facturas
  try
    SQLFacturasX3( AX3 );


    //FacturasPendientesSQL( AMaster );
    AMaster.Open;
    while not AMaster.Eof do
    begin
      AX3.ParamByName('factura').AsString:= AMaster.FieldByName('cod_factura_fc').AsString;
      AX3.Open;
      //InsertarCobro( AMaster, AX3 );
      AX3.Close;
      AMaster.Next;
      Inc( Result );
    end;
    AMaster.Close;

    //FacturasSinCobroSQL( AMaster );
    AMaster.Open;
    while not AMaster.Eof do
    begin
      AX3.ParamByName('factura').AsString:= AMaster.FieldByName('cod_factura_fc').AsString;
      AX3.Open;
      //InsertarCobro( AMaster, AX3 );
      AX3.Close;
      AMaster.Next;
      Inc( Result );
    end;
    AMaster.Close;

  finally
    AMaster.Close;
    //qryAux.Close;
    AX3.Close;

    AMaster.RequestLive:= bAux1;
    AX3.RequestLive:= bAux2;

    //FreeAndNil( qryAux );
  end;
end;


end.
