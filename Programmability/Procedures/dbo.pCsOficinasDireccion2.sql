SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsOficinasDireccion2]
	@Codoficina	Varchar(4)
AS

--declare	@Codoficina	Varchar(4)
--set @Codoficina	='98'

Set @CodOficina = Ltrim(Rtrim(@CodOficina))

Select CodOficina = Cast(CodOficina as Int), O, Direccion, DescOficina  from ( 
SELECT  O = 1, CodOficina, Tipo,  
replace(replace(tClOficinas.Direccion, '#','Número '),'No.', 'Numero') as Direccion
,tClOficinas.FechaApertura
--,FechaCierre = IsNull(tClOficinas.FechaCierre, dbo.fduFechaatexto(@Fecha, 'AAAAMMDD'))
,DescOficina FROM tClOficinas with(nolock) INNER JOIN tClUbigeo with(nolock) ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN tCPLugar with(nolock) ON 
tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND tClUbigeo.CodEstado = 
tCPLugar.CodEstado INNER JOIN tCPClMunicipio with(nolock) ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = 
tCPClMunicipio.CodEstado INNER JOIN tCPClEstado with(nolock) ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado 
UNION 
SELECT O = 2, CodOficina, 
Tipo, Case When Ltrim(Rtrim(tCPClTipoLugar.TipoLugar)) <> 'Pueblo' Then Ltrim(Rtrim(tCPClTipoLugar.TipoLugar)) + ' ' Else ''
End + Case When CharIndex('CENTRO', Upper(Ltrim(rtrim(tCPLugar.Lugar))), 1) <> 0 And Upper(Ltrim(rtrim(Substring(tCPLugar.Lugar , 
1, CharIndex('CENTRO', Upper(Ltrim(rtrim(tCPLugar.Lugar))), 1) - 1)))) = upper(Ltrim(rtrim(tCPClMunicipio.Municipio))) Then 
Ltrim(rtrim(Substring(tCPLugar.Lugar , CharIndex('CENTRO', Upper(Ltrim(rtrim(tCPLugar.Lugar))), 1) , 1000))) Else tCPLugar.Lugar 
end AS Expr1, tClOficinas.FechaApertura
--, FechaCierre = IsNull(tClOficinas.FechaCierre, dbo.fduFechaatexto(@Fecha, 'AAAAMMDD'))
, DescOficina 
FROM tClOficinas with(nolock) INNER JOIN tClUbigeo with(nolock) ON tClOficinas.CodUbiGeo = 
tClUbigeo.CodUbiGeo INNER JOIN tCPLugar with(nolock) ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio 
AND tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN tCPClMunicipio with(nolock) ON tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND 
tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN tCPClEstado with(nolock) ON tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN 
tCPClTipoLugar with(nolock) ON tCPLugar.CodTipoLugar = tCPClTipoLugar.CodTipoLugar 
UNION 
SELECT  O = 3, CodOficina, Tipo, 
replace( Case When 
tCPClEstado.CodEstado = '09' Then 'Delegación ' Else 'Municipio '  end + tCPClMunicipio.Municipio + ', ' + Case When 
tCPClEstado.CodEstado = '09' Then '' Else 'Estado '  end + tCPClEstado.Estado 
,'Distrito Federal','Ciudad de México')
AS Expr1, tClOficinas.FechaApertura
--, FechaCierre = IsNull(tClOficinas.FechaCierre, dbo.fduFechaatexto(@Fecha, 'AAAAMMDD'))
, DescOficina 
FROM tClOficinas with(nolock)
INNER JOIN tClUbigeo with(nolock) ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN tCPLugar with(nolock) ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND 
tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN tCPClMunicipio with(nolock) ON 
tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN tCPClEstado with(nolock) ON 
tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN tCPClTipoLugar with(nolock) ON tCPLugar.CodTipoLugar = tCPClTipoLugar.CodTipoLugar 
UNION 
SELECT O = 4, CodOficina, Tipo, 'C.P. ' + CodPostal AS Expr1, tClOficinas.FechaApertura
--, FechaCierre = IsNull(tClOficinas.FechaCierre, dbo.fduFechaatexto(@Fecha, 'AAAAMMDD') )
, DescOficina FROM tClOficinas with(nolock) INNER JOIN 
tClUbigeo with(nolock) ON tClOficinas.CodUbiGeo = tClUbigeo.CodUbiGeo INNER JOIN tCPLugar with(nolock) ON tClUbigeo.IdLugar = tCPLugar.IdLugar AND 
tClUbigeo.CodMunicipio = tCPLugar.CodMunicipio AND tClUbigeo.CodEstado = tCPLugar.CodEstado INNER JOIN tCPClMunicipio with(nolock) ON 
tCPLugar.CodMunicipio = tCPClMunicipio.CodMunicipio AND tCPLugar.CodEstado = tCPClMunicipio.CodEstado INNER JOIN tCPClEstado with(nolock) ON 
tCPClMunicipio.CodEstado = tCPClEstado.CodEstado INNER JOIN tCPClTipoLugar with(nolock) ON tCPLugar.CodTipoLugar = tCPClTipoLugar.CodTipoLugar) 
Datos 
Where CodOficina = @CodOficina
Order By Cast(CodOficina as int), o

--Print @Cadena
--Exec (@Cadena)
GO