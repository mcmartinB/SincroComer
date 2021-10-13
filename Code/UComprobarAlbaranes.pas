unit UComprobarAlbaranes;

interface

uses
  DB, DBTables;


function ComprobarRecepccionAlbaranesVenta( const AFuente, ADestino: TQuery; var VLog: string; const ATable: string = ''  ) : integer;


implementation

uses
  SysUtils, UUtils;


function ComprobarRecepccionAlbaranesVenta( const AFuente, ADestino: TQuery; var VLog: string; const ATable: string = ''  ) : integer;
var
  i, iRegistros: Integer;
begin
  UUtils.AddLog( 'ComprobarRecepccionAlbaranesVenta' );

  Result:= 0;
  VLog:= 'ALBARANES PENDIENTES DE ENVIAR DEL ' + FormatDateTime( 'dd/mm/yy', Now-31)  + ' AL ' +
//  VLog:= 'ALBARANES PENDIENTES DE ENVIAR DEL ' + FormatDateTime( 'dd/mm/yy', Now-185)  + ' AL ' +
                                                 FormatDateTime( 'dd/mm/yy', Now-1)  + '.' + #13 + #10;

  ADestino.SQL.Clear;
  ADestino.SQL.Add('select cliente_sal_sc cliente, empresa_sc empresa, centro_salida_sc centro, fecha_Sc fecha, n_albaran_Sc albaran, ');
  ADestino.SQL.Add('       sum(cajas_sl) cajas, sum(kilos_sl) kilos ');
  ADestino.SQL.Add('from frf_salidas_c ');
  ADestino.SQL.Add('     join frf_salidas_l on empresa_sc = empresa_sl and centro_salida_sc = centro_salida_sc ');
  ADestino.SQL.Add('                        and fecha_sc = fecha_sl and n_albaran_sc = n_albaran_sl ');
  ADestino.SQL.Add('where empresa_sc =  :empresa ');
  ADestino.SQL.Add('and centro_salida_sc = :centro ');
  ADestino.SQL.Add('and fecha_sc = :fecha ');
  ADestino.SQL.Add('and n_albaran_sc = :albaran ');
  ADestino.SQL.Add('group by cliente, empresa, centro, fecha, albaran ');

  AFuente.SQL.Clear;
  AFuente.SQL.Add('select count(*) registros');
  AFuente.SQL.Add('from frf_salidas_c ');
//  AFuente.SQL.Add('where fecha_sc between today - 31 and today - 1 ');
  AFuente.SQL.Add('where fecha_sc between today - 186 and today - 1 ');
  AFuente.RequestLive:= False;
  AFuente.Open;
  iRegistros:= AFuente.FieldByName('registros').AsInteger;
  AFuente.Close;

  AFuente.SQL.Clear;
  AFuente.SQL.Add('select cliente_sal_sc cliente, empresa_sc empresa, centro_salida_sc centro, fecha_Sc fecha, n_albaran_Sc albaran, ');
  AFuente.SQL.Add('       sum(cajas_sl) cajas, sum(kilos_sl) kilos ');
  AFuente.SQL.Add('from frf_salidas_c ');
  AFuente.SQL.Add('     join frf_salidas_l on empresa_sc = empresa_sl and centro_salida_sc = centro_salida_sc ');
  AFuente.SQL.Add('                        and fecha_sc = fecha_sl and n_albaran_sc = n_albaran_sl ');

//  AFuente.SQL.Add('where fecha_sc between today - 31 and today - 1 ');
  AFuente.SQL.Add('where fecha_sc between today - 186 and today - 1 ');
  AFuente.SQL.Add('group by empresa, centro, cliente, fecha, albaran ');
  AFuente.SQL.Add('order by empresa, centro, cliente, fecha, albaran ');
  AFuente.RequestLive:= False;
  AFuente.Open;

  for i:= 1 to iRegistros do
  begin
    ADestino.ParamByName('empresa').AsString:= AFuente.fieldByName('empresa').AsString;
    ADestino.ParamByName('centro').AsString:= AFuente.fieldByName('centro').AsString;
    ADestino.ParamByName('fecha').AsString:= AFuente.fieldByName('fecha').AsString;
    ADestino.ParamByName('albaran').AsString:= AFuente.fieldByName('albaran').AsString;
    try
      UUtils.AddLog( 'in' );
      ADestino.RequestLive:= False;
      ADestino.Open;
      UUtils.AddLog( 'out' );
    except
      on e:Exception do
      begin
        UUtils.AddLog( e.Message );
        Break;
      end;
    end;


    if ADestino.IsEmpty then
    begin
      Inc(Result);
      VLog:= VLog +  '  -->>  ' +
                                AFuente.fieldByName('empresa').AsString + ' - ' + AFuente.fieldByName('centro').AsString + ' - ' +
                                AFuente.fieldByName('cliente').AsString + ' - ' +
                                AFuente.fieldByName('fecha').AsString + ' - ' + AFuente.fieldByName('albaran').AsString + #13 + #10;
    end;
    ADestino.Close;

    UUtils.AddLog( inttostr( i ) + '/' + inttostr( iRegistros ) + ' -> ' +
                   AFuente.fieldByName('empresa').AsString + ' - ' +  AFuente.fieldByName('centro').AsString + ' - ' +
                   AFuente.fieldByName('albaran').AsString  + ' - ' + AFuente.fieldByName('fecha').AsString  );
    if i < iRegistros then
    try
      AFuente.Next;
    except
      on e:Exception do
      begin
        UUtils.AddLog( e.Message );
        Break;
      end;
    end;
  end;

  if Result = 0 then
  begin
      VLog:= VLog +  '  -->>  NO HAY ALBARANES PENDIENTES.' +  #13 + #10;
  end;

  AFuente.Close;
  ADestino.Close;
end;

end.
