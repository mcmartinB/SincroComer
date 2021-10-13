unit UUtils;

interface

var
  bLog: Boolean = False;

procedure AddLog( const AString: string );

implementation

uses
  Classes, SysUtils;

procedure AddLog( const AString: string );
var
  fichero : TStringList;
const
  rutaFichero = 'C:\temp\log_servicio_sincro_comer.txt';
begin
  if bLog then
  begin
    fichero := TStringList.Create;
    try
      if FileExists(rutaFichero) then
        fichero.LoadFromFile(rutaFichero);
      fichero.Add(DateTimeToStr(Now) + ' ' + AString);
      fichero.SaveToFile(rutaFichero);
    finally
      FreeAndNil( fichero );
    end;
  end;
end;

end.
