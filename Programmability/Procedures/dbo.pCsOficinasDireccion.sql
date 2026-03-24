SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsOficinasDireccion]
@Tipo 		Varchar(50),
@Fecha		SmallDateTime,
@Codoficina	Varchar(4) = ''
AS

Declare @Cadena Varchar(8000)

Set @CodOficina = Ltrim(Rtrim(@CodOficina))

Set @Cadena = 'Select CodOficina = Cast(CodOficina as Int), O, Direccion, DescOficina  from ( '
Set @Cadena = @Cadena + 'SELECT  O = 1, CodOficina, Tipo,  '
Set @Cadena = @Cadena + 'replace(replace(tClOficinas.Direccion, ''#'',''Número ''),''No.'', ''Numero'') as Direccion, '
Set @Cadena = @Cadena + 'tClOficinas.FechaApertura, FechaCierre = IsNull(tClOficinas.FechaCierre, ''' + dbo.fduFechaatexto(@Fecha, 'AAAAMMDD') + '''), '
Set @Cadena = @Cadena + 'DescOficina FROM tClOficinas INNER JOIN tClUbigeo ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN tCPLugar ON '
Set @Cadena = @Cadena + 'tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND tClUbigeo.CodEstado = '
Set @Cadena = @Cadena + 'tCPLugar.CodEstado INNER JOIN tCPClMunicipio ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = '
Set @Cadena = @Cadena + 'tCPClMunicipio.CodEstado INNER JOIN tCPClEstado ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado '
Set @Cadena = @Cadena + 'UNION '
Set @Cadena = @Cadena + 'SELECT O = 2, CodOficina, '
Set @Cadena = @Cadena + 'Tipo, Case When Ltrim(Rtrim(tCPClTipoLugar.TipoLugar)) <> ''Pueblo'' Then Ltrim(Rtrim(tCPClTipoLugar.TipoLugar)) + '' '' Else '''' '
Set @Cadena = @Cadena + 'End + Case When CharIndex(''CENTRO'', Upper(Ltrim(rtrim(tCPLugar.Lugar))), 1) <> 0 And Upper(Ltrim(rtrim(Substring(tCPLugar.Lugar , '
Set @Cadena = @Cadena + '1, CharIndex(''CENTRO'', Upper(Ltrim(rtrim(tCPLugar.Lugar))), 1) - 1)))) = upper(Ltrim(rtrim(tCPClMunicipio.Municipio))) Then '
Set @Cadena = @Cadena + 'Ltrim(rtrim(Substring(tCPLugar.Lugar , CharIndex(''CENTRO'', Upper(Ltrim(rtrim(tCPLugar.Lugar))), 1) , 1000))) Else tCPLugar.Lugar '
Set @Cadena = @Cadena + 'end AS Expr1, tClOficinas.FechaApertura, FechaCierre = IsNull(tClOficinas.FechaCierre, '''
Set @Cadena = @Cadena + dbo.fduFechaatexto(@Fecha, 'AAAAMMDD') + '''), DescOficina FROM tClOficinas INNER JOIN tClUbigeo ON tClOficinas.CodUbiGeo = '
Set @Cadena = @Cadena + 'tClUbigeo.CodUbiGeo INNER JOIN tCPLugar ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio '
Set @Cadena = @Cadena + 'AND tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN tCPClMunicipio ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND '
Set @Cadena = @Cadena + 'tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN tCPClEstado ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN '
Set @Cadena = @Cadena + 'tCPClTipoLugar ON tCPLugar.CodTipoLugar = tCPClTipoLugar.CodTipoLugar '
Set @Cadena = @Cadena + 'UNION '
Set @Cadena = @Cadena + 'SELECT  O = 3, CodOficina, Tipo, '
Set @Cadena = @Cadena + 'replace( Case When '
Set @Cadena = @Cadena + 'tCPClEstado.CodEstado = ''09'' Then ''Delegación '' Else ''Municipio ''  end + tCPClMunicipio.Municipio + '', '' + Case When '
Set @Cadena = @Cadena + 'tCPClEstado.CodEstado = ''09'' Then '''' Else ''Estado ''  end + tCPClEstado.Estado '
Set @Cadena = @Cadena + ',''Distrito Federal'',''Ciudad de México'')'
Set @Cadena = @Cadena + 'AS Expr1, tClOficinas.FechaApertura, '
Set @Cadena = @Cadena + 'FechaCierre = IsNull(tClOficinas.FechaCierre, ''' + dbo.fduFechaatexto(@Fecha, 'AAAAMMDD') + '''), DescOficina '
Set @Cadena = @Cadena + 'FROM tClOficinas '
Set @Cadena = @Cadena + 'INNER JOIN tClUbigeo ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN tCPLugar ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND '
Set @Cadena = @Cadena + 'tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN tCPClMunicipio ON '
Set @Cadena = @Cadena + 'tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN tCPClEstado ON '
Set @Cadena = @Cadena + 'tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN tCPClTipoLugar ON tCPLugar.CodTipoLugar = tCPClTipoLugar.CodTipoLugar '
Set @Cadena = @Cadena + 'UNION '
Set @Cadena = @Cadena + 'SELECT O = 4, CodOficina, Tipo, ''C.P. '' + CodPostal AS Expr1, tClOficinas.FechaApertura, FechaCierre = '
Set @Cadena = @Cadena + 'IsNull(tClOficinas.FechaCierre, ''' + dbo.fduFechaatexto(@Fecha, 'AAAAMMDD') + '''), DescOficina FROM tClOficinas INNER JOIN '
Set @Cadena = @Cadena + 'tClUbigeo ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN tCPLugar ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND '
Set @Cadena = @Cadena + 'tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN tCPClMunicipio ON '
Set @Cadena = @Cadena + 'tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN tCPClEstado ON '
Set @Cadena = @Cadena + 'tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN tCPClTipoLugar ON tCPLugar.CodTipoLugar = tCPClTipoLugar.CodTipoLugar) '
Set @Cadena = @Cadena + 'Datos Where Tipo = ''' +  @Tipo + ''' And FechaApertura <= ''' + dbo.fduFechaatexto(@Fecha, 'AAAAMMDD') + ''' And '
Set @Cadena = @Cadena + 'FechaCierre >= ''' + dbo.fduFechaatexto(@Fecha, 'AAAAMMDD') + ''' '+ Case When @CodOficina <> '' Then 'And CodOficina = '''+ @CodOficina +'''' Else '' End +' Order By Cast(CodOficina as int), o'

Print @Cadena
Exec (@Cadena)

GO