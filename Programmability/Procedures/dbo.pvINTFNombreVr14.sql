SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pvINTFNombreVr14 '20200531'
CREATE PROCEDURE [dbo].[pvINTFNombreVr14] @fecha smalldatetime 
AS
set nocount on
--declare @fecha smalldatetime  --comentar
--set @fecha='20200531'		--comentar

declare @primerdia smalldatetime
select @primerdia=primerdia from tclperiodo with(nolock) where ultimodia=@fecha

truncate table tCsBuroxTblReInomVr14 --descomentar

insert into tCsBuroxTblReInomVr14 --descomentar
/***************  vINTFNombreCartera  ******************/
SELECT 'Cartera' AS Tipo, d.Fecha, d.CodPrestamo, d.CodUsuario
, (Case 
      when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') like '%XX%' Then ISNULL(RTRIM(LTRIM(cl.Materno)),'')   --2018/06/04
      when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then ISNULL(RTRIM(LTRIM(cl.Materno)),'') 
      Else  ISNULL(RTRIM(LTRIM(cl.Paterno)),'')  
 End) AS Paterno
, (Case 
     when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') like '%XX%' Then 'NO PROPORCIONADO'  --2018/06/04
     when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then 'NO PROPORCIONADO' 
     Else ISNULL(RTRIM(LTRIM(cl.Materno)),'')  
 End) As Materno
,  '' as Adicional
/* --Se comento este bloque a peticion de Christofer para no enviar apellido adicional 02-08-2016
case when tCsCartera.FechaDesembolso>='20130101' then ''
else
  Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
end
AS Adicional
*/
, ISNULL(RTRIM(LTRIM(cl.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(cl.Nombre2)), '') 
+ ' ' + ISNULL(RTRIM(LTRIM(cl.Nombre3)), '') AS Nombre2
,dbo.fduFechaATexto(cl.FechaNacimiento, 'DDMMAAAA') AS Nacimiento
--RFC.UsRFC, 
--tCsPadronClientes.Nombre1 , tCsPadronClientes.Nombre2 ,tCsPadronClientes.Paterno, tCsPadronClientes.Materno, 
--tCsPadronClientes.FechaNacimiento,
--finamigoexterno_191115.dbo.f_Calcula_RFC(tCsPadronClientes.Nombre1 + ' ' +isnull(tCsPadronClientes.Nombre2,'') ,tCsPadronClientes.Paterno, tCsPadronClientes.Materno, tCsPadronClientes.FechaNacimiento) as rfc2, --se cambio por la linea de abajo

--tCsPadronClientes.UsRFCBD, --OSC, en algunos casos el RFC venia vacio,por lo que se cambio por la linea de abajo
,(case when len(cl.UsRFCBD) > 0 then cl.UsRFCBD
else finamigoexterno_191115.dbo.f_Calcula_RFC(cl.Nombre1 + ' ' +isnull(cl.Nombre2,'') ,cl.Paterno, cl.Materno, cl.FechaNacimiento)
end) as UsRFCBD
,'' AS Prefijo, '' AS Sufijo
, dbo.tClPaises.INTF AS Nacionalidad, dbo.tUsClTipoPropiedad.INTF AS Residencia
,CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir
,dbo.tUsClEstadoCivil.INTF AS EstadoCivil, dbo.tUsClSexo.INTF AS Sexo, '' AS CedulaProfesional
, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE
, CASE cl.coddociden WHEN 'CURP' THEN cl.DI ELSE '' END AS CURP--'' AS ImpuestoOtroPais
, '' AS ClaveOtroPais, cl.UsNDependientes AS NumeroDependientes, '' AS EdadesDependientes, 
'' AS DefuncionFecha, '' AS DefuncionIndicador
FROM tcscartera c with(nolock)
INNER JOIN tCsCarteraDet d with(nolock) on c.codprestamo=d.codprestamo and c.fecha=d.fecha
INNER JOIN tCsPadronClientes cl with(nolock) ON cl.CodUsuario=d.CodUsuario
LEFT OUTER JOIN tUsClTipoPropiedad with(nolock) ON ISNULL(cl.TipoPropiedadDirFam, cl.TipoPropiedadDirNeg)=tUsClTipoPropiedad.CodTipoPro 
LEFT OUTER JOIN tUsClSexo with(nolock) ON cl.Sexo = tUsClSexo.Sexo 
LEFT OUTER JOIN tUsClEstadoCivil with(nolock) ON cl.CodEstadoCivil = tUsClEstadoCivil.CodEstadoCivil 
LEFT OUTER JOIN tClPaises with(nolock) ON cl.CodPais = tClPaises.CodPais 
where c.Fecha=@fecha
and c.codprestamo not in (select codprestamo from tCsBuroDepuLey with(nolock))--='018-158-06-04-00037'
and c.codprestamo not in (select codprestamo from tCaCtasLiqPago with(nolock))
and c.codoficina not in ('230','231')
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
union

/***************  vINTFNombreAvales  ******************/
SELECT 'Aval' AS Tipo, c.Fecha, c.CodPrestamo, gd.CodUsuario
,Case when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then  ISNULL(RTRIM(LTRIM(cl.Materno)),'') Else  ISNULL(RTRIM(LTRIM(cl.Paterno)),'')  End AS Paterno
,Case when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then  'NO PROPORCIONADO' Else ISNULL(RTRIM(LTRIM(cl.Materno)),'')  End As Materno, '' AS Adicional
/* --Se comento este bloque a peticion de Christofer para no enviar apellido adicional 02-08-2016
case when tCsCarteraDet.FechaDesembolso>='20130101' then ''
else
  Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
end
AS Adicional
*/
, ISNULL(RTRIM(LTRIM(cl.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(cl.Nombre2)), '') 
+ ' ' + ISNULL(RTRIM(LTRIM(cl.Nombre3)), '') AS Nombre2, dbo.fduFechaATexto(cl.FechaNacimiento, 'DDMMAAAA') AS Nacimiento
--RFC.UsRFC, 
--finamigoexterno_191115.dbo.f_Calcula_RFC(tCsPadronClientes.Nombre1 + ' ' +isnull(tCsPadronClientes.Nombre2,'') ,tCsPadronClientes.Paterno, tCsPadronClientes.Materno, tCsPadronClientes.FechaNacimiento) as rfc2, -- cambio por la linea de abajo
,cl.UsRFCBD
,'' AS Prefijo, '' AS Sufijo, tClPaises.INTF AS Nacionalidad, tUsClTipoPropiedad.INTF AS Residencia
,CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir
,tUsClEstadoCivil.INTF AS EstadoCivil,tUsClSexo.INTF AS Sexo
,'' AS CedulaProfesional, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE
,CASE cl.coddociden WHEN 'CURP' THEN cl.DI ELSE '' END AS CURP--'' AS ImpuestoOtroPais
,'' AS ClaveOtroPais
,cl.UsNDependientes AS NumeroDependientes
,'' AS EdadesDependientes, '' AS DefuncionFecha, '' AS DefuncionIndicador
FROM tCsCartera c with(nolock)
INNER JOIN (		
		SELECT g.Codigo AS CodPrestamo, x.CodUsuario
		FROM tCsdiaGarantias g with(nolock) 
        INNER JOIN tCsPadronClientes x with(nolock) ON g.docpropiedad=x.CodOriginal 
        WHERE g.Fecha=@fecha --'20200531'--
		and g.tipogarantia='IPN' and g.estado in('ACTIVO','MODIFICADO')
) gd on gd.codprestamo=c.codprestamo
INNER JOIN tCsPadronClientes cl with(nolock) on cl.codusuario=gd.codusuario
LEFT OUTER JOIN tUsClTipoPropiedad with(nolock) ON ISNULL(cl.TipoPropiedadDirFam, cl.TipoPropiedadDirNeg) = tUsClTipoPropiedad.CodTipoPro 
LEFT OUTER JOIN tUsClSexo with(nolock) ON cl.Sexo=tUsClSexo.Sexo 
LEFT OUTER JOIN tUsClEstadoCivil with(nolock) ON cl.CodEstadoCivil=tUsClEstadoCivil.CodEstadoCivil 
LEFT OUTER JOIN tClPaises with(nolock) ON cl.CodPais=tClPaises.CodPais 
WHERE c.Fecha=@fecha
and c.codprestamo not in (select codprestamo from tCsBuroDepuLey with(nolock))
and c.codprestamo not in (select codprestamo from tCaCtasLiqPago with(nolock))
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and c.codoficina not in ('230','231')
union

/***************  vINTFNombreCancelados  ******************/
SELECT d.Tipo 	--'Cancelados' AS Tipo
,@fecha Fecha, d.CodPrestamo, d.CodUsuario
,Case when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then  ISNULL(RTRIM(LTRIM(cl.Materno)),'') Else  ISNULL(RTRIM(LTRIM(cl.Paterno)),'')  End AS Paterno
,Case when ISNULL(RTRIM(LTRIM(cl.Paterno)),'') = '' Then  'NO PROPORCIONADO' Else ISNULL(RTRIM(LTRIM(cl.Materno)),'')  End As Materno
/* --Se comento este bloque a peticion de Christofer para no enviar apellido adicional 02-08-2016
case when tCsCarteraDet.FechaDesembolso>='20130101' then ''
else
  Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
end
AS Adicional
*/
,'' AS Adicional
, ISNULL(RTRIM(LTRIM(cl.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(cl.Nombre2)), '') 
+ ' ' + ISNULL(RTRIM(LTRIM(cl.Nombre3)), '') AS Nombre2, 
dbo.fduFechaATexto(cl.FechaNacimiento, 'DDMMAAAA') AS Nacimiento
--RFC.UsRFC, 
--finamigoexterno_191115.dbo.f_Calcula_RFC(tCsPadronClientes.Nombre1 + ' ' +isnull(tCsPadronClientes.Nombre2,'') ,tCsPadronClientes.Paterno, tCsPadronClientes.Materno, tCsPadronClientes.FechaNacimiento) as rfc2, --se cambio por la linea de abajo
,cl.UsRFCBD
,'' AS Prefijo, '' AS Sufijo
,tClPaises.INTF AS Nacionalidad, tUsClTipoPropiedad.INTF AS Residencia, CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir
,isnull(tUsClEstadoCivil.INTF,'S') AS EstadoCivil, tUsClSexo.INTF AS Sexo, '' AS CedulaProfesional, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE
,CASE cl.coddociden WHEN 'CURP' THEN cl.DI ELSE '' END AS CURP--'' AS ImpuestoOtroPais
,'' AS ClaveOtroPais, isnull(cl.UsNDependientes,0) AS NumeroDependientes, '' AS EdadesDependientes
,'' AS DefuncionFecha, '' AS DefuncionIndicador
FROM (
	/*titulares*/
	SELECT Cancelacion, CodPrestamo, CodUsuario,'CanceladosT' tipo,codoficina
	FROM tCsPadronCarteraDet with(nolock)
	WHERE EstadoCalculado='CANCELADO' and cancelacion>=@primerdia and cancelacion<=@fecha
	union
	/*avales*/
	SELECT p.cancelacion,g.Codigo AS CodPrestamo, x.CodUsuario,'CanceladosA' tipo,p.codoficina
	FROM tCsdiaGarantias g with(nolock)
	INNER JOIN tCsPadronClientes x with(nolock) ON g.docpropiedad=x.CodOriginal
	INNER JOIN tCspadronCarteradet p with(nolock) on p.codprestamo=g.codigo and p.cancelacion>=@primerdia and p.cancelacion<=@fecha
	WHERE g.fecha=@fecha and g.tipogarantia='IPN' and g.estado in('ACTIVO','MODIFICADO')
) d 
INNER JOIN tCsPadronClientes cl with(nolock) ON cl.codusuario=d.codusuario--RFC.CodUsuario COLLATE Modern_Spanish_CI_AI = dbo.tCsPadronClientes.CodUsuario and dbo.tCsPadronClientes.codentidadtipo<>'JUR'	
LEFT OUTER JOIN tUsClTipoPropiedad with(nolock) ON ISNULL(cl.TipoPropiedadDirFam,cl.TipoPropiedadDirNeg)=tUsClTipoPropiedad.CodTipoPro 
LEFT OUTER JOIN tUsClSexo with(nolock) ON cl.Sexo=tUsClSexo.Sexo
LEFT OUTER JOIN tUsClEstadoCivil with(nolock) ON cl.CodEstadoCivil=tUsClEstadoCivil.CodEstadoCivil 
LEFT OUTER JOIN tClPaises with(nolock) ON cl.CodPais=tClPaises.CodPais 
where d.codoficina not in ('230','231') 
and d.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
and d.codprestamo not in (select codprestamo from tCsBuroDepuLey with(nolock))--='018-158-06-04-00037'
and d.codprestamo not in (select codprestamo from tCaCtasLiqPago with(nolock))
GO