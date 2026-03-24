SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create PROCEDURE [dbo].[pvINTFNombreVr13] @fecha smalldatetime AS

--declare @fecha smalldatetime  --comentar
--set @fecha='20151130'		--comentar

declare @primerdia smalldatetime
select @primerdia=primerdia from tclperiodo where ultimodia=@fecha

truncate table tCsBuroxTblReInomVr13

insert into tCsBuroxTblReInomVr13
/***************  vINTFNombreCartera  ******************/
SELECT --top 50
'Cartera' AS Tipo, dbo.tCsCarteraDet.Fecha, dbo.tCsCarteraDet.CodPrestamo, dbo.tCsCarteraDet.CodUsuario, 
Case when ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'') = '' Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)),'') Else  ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'')  End AS Paterno, 
Case when ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'') = '' Then 'NO PROPORCIONADO' Else ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)),'')  End As Materno,  

/* --Se comento este bloque a peticion de Christofer para no enviar apellido adicional 02-08-2016
case when tCsCartera.FechaDesembolso>='20130101' then ''
else
  Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
end
AS Adicional
*/
'' as Adicional
, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre2)), '') 
+ ' ' + ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre3)), '') AS Nombre2,
dbo.fduFechaATexto(dbo.tCsPadronClientes.FechaNacimiento, 'DDMMAAAA') AS Nacimiento, RFC.UsRFC, '' AS Prefijo, '' AS Sufijo, 
dbo.tClPaises.INTF AS Nacionalidad, dbo.tUsClTipoPropiedad.INTF AS Residencia
,CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir
,dbo.tUsClEstadoCivil.INTF AS EstadoCivil, dbo.tUsClSexo.INTF AS Sexo, '' AS CedulaProfesional
, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE
, CASE tCsPadronClientes.coddociden WHEN 'CURP' THEN tCsPadronClientes.DI ELSE '' END AS CURP--'' AS ImpuestoOtroPais
, '' AS ClaveOtroPais, tCsPadronClientes.UsNDependientes AS NumeroDependientes, '' AS EdadesDependientes, 
'' AS DefuncionFecha, '' AS DefuncionIndicador
FROM (SELECT CodUsuario, CASE c WHEN 10 THEN usrfc ELSE usrfcbd END AS UsRFC
      FROM 
            (SELECT     CodUsuario, CASE WHEN (isnumeric(SUBSTRING(UsRFC, 1, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 2, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 3, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 4, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 5, 1))) 
            = 1 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 6, 1))) 
            = 1 THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 7, 2) >= '01' AND SUBSTRING(UsRFC, 7, 2) 
            <= '12' THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 9, 2) >= '01' AND SUBSTRING(UsRFC, 9, 2) 
            <= '31' THEN 1 ELSE 0 END + CASE WHEN len(rtrim(ltrim(usrfc))) = 13 THEN 1 ELSE 0 END + 
            CASE WHEN (SUBSTRING(UsRFC,5, 6) = dbo.fduFechaATexto(FechaNacimiento, 'AAMMDD')) THEN 1 ELSE 0 END AS C
            , UsRFC, UsRFCBD, UsRFCVal
            FROM tCsPadronClientes with(nolock)
            )
            Datos) RFC 
            INNER JOIN dbo.tCsPadronClientes with(nolock) ON RFC.CodUsuario COLLATE Modern_Spanish_CI_AI = dbo.tCsPadronClientes.CodUsuario 
	and dbo.tCsPadronClientes.codentidadtipo<>'JUR'
            LEFT OUTER JOIN dbo.tUsClTipoPropiedad with(nolock) ON ISNULL(dbo.tCsPadronClientes.TipoPropiedadDirFam, dbo.tCsPadronClientes.TipoPropiedadDirNeg) = dbo.tUsClTipoPropiedad.CodTipoPro 
            LEFT OUTER JOIN dbo.tUsClSexo with(nolock) ON dbo.tCsPadronClientes.Sexo = dbo.tUsClSexo.Sexo 
            LEFT OUTER JOIN dbo.tUsClEstadoCivil with(nolock) ON dbo.tCsPadronClientes.CodEstadoCivil = dbo.tUsClEstadoCivil.CodEstadoCivil 
            LEFT OUTER JOIN dbo.tClPaises with(nolock) ON dbo.tCsPadronClientes.CodPais = dbo.tClPaises.CodPais 
            --RIGHT OUTER JOIN dbo.tINTFPeriodo 
            INNER JOIN dbo.tCsCarteraDet with(nolock) --ON dbo.tCsCarteraDet.Fecha=dbo.tINTFPeriodo.Corte
            ON dbo.tCsPadronClientes.CodUsuario = dbo.tCsCarteraDet.CodUsuario
            inner join tcscartera with(nolock) on tcscartera.codprestamo = dbo.tCsCarteraDet.codprestamo
            and tcscartera.fecha=tCsCarteraDet.fecha
where dbo.tCsCarteraDet.Fecha=@fecha
and tCsCarteraDet.codprestamo not in (select codprestamo from tCsBuroDepuLey)--='018-158-06-04-00037'
--and tCsCarteraDet.codprestamo not in (select codprestamo from [10.0.2.14].[Finmas].[dbo].[tCaCtasLiqPago])
and tCsCarteraDet.codprestamo not in (select codprestamo from tCaCtasLiqPago with(nolock))
--WHERE (dbo.tINTFPeriodo.Activo = 1)
--and tCsCartera.codoficina<100
and tCsCartera.codoficina not in ('230','231') --03/08/2016

union

/***************  vINTFNombreAvales  ******************/
SELECT  -- top 50  
'Aval' AS Tipo, tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCarteraDet.CodUsuario,  
Case when ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'') = '' Then  ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)),'') Else  ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'')  End AS Paterno, 
Case when ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'') = '' Then  'NO PROPORCIONADO' Else ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)),'')  End As Materno, 
--Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
case when tCsCarteraDet.FechaDesembolso>='20130101' then ''
else
  Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
end
AS Adicional
, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre2)), '') 
+ ' ' + ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre3)), '') AS Nombre2, dbo.fduFechaATexto(dbo.tCsPadronClientes.FechaNacimiento, 
'DDMMAAAA') AS Nacimiento, RFC.UsRFC, '' AS Prefijo, '' AS Sufijo, dbo.tClPaises.INTF AS Nacionalidad, dbo.tUsClTipoPropiedad.INTF AS Residencia, 
CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir, dbo.tUsClEstadoCivil.INTF AS EstadoCivil, dbo.tUsClSexo.INTF AS Sexo, 
'' AS CedulaProfesional, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE
, CASE tCsPadronClientes.coddociden WHEN 'CURP' THEN tCsPadronClientes.DI ELSE '' END AS CURP--'' AS ImpuestoOtroPais
, '' AS ClaveOtroPais, 
dbo.tCsPadronClientes.UsNDependientes AS NumeroDependientes, '' AS EdadesDependientes, '' AS DefuncionFecha, '' AS DefuncionIndicador
FROM (SELECT CodUsuario, CASE c WHEN 10 THEN usrfc ELSE usrfcbd END AS UsRFC
      FROM 
            (SELECT     CodUsuario, CASE WHEN (isnumeric(SUBSTRING(UsRFC, 1, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 2, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 3, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 4, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 5, 1))) 
            = 1 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 6, 1))) 
            = 1 THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 7, 2) >= '01' AND SUBSTRING(UsRFC, 7, 2) 
            <= '12' THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 9, 2) >= '01' AND SUBSTRING(UsRFC, 9, 2) 
            <= '31' THEN 1 ELSE 0 END + CASE WHEN len(rtrim(ltrim(usrfc))) = 13 THEN 1 ELSE 0 END + CASE WHEN (SUBSTRING(UsRFC, 
            5, 6) = dbo.fduFechaATexto(FechaNacimiento, 'AAMMDD')) THEN 1 ELSE 0 END AS C, UsRFC, UsRFCBD, UsRFCVal
            FROM tCsPadronClientes with(nolock)) 
            Datos) RFC 
            INNER JOIN dbo.tCsPadronClientes with(nolock) ON RFC.CodUsuario COLLATE Modern_Spanish_CI_AI = dbo.tCsPadronClientes.CodUsuario 
            LEFT OUTER JOIN dbo.tUsClTipoPropiedad with(nolock) ON ISNULL(dbo.tCsPadronClientes.TipoPropiedadDirFam, dbo.tCsPadronClientes.TipoPropiedadDirNeg) = dbo.tUsClTipoPropiedad.CodTipoPro 
            LEFT OUTER JOIN dbo.tUsClSexo with(nolock) ON dbo.tCsPadronClientes.Sexo = dbo.tUsClSexo.Sexo 
            LEFT OUTER JOIN dbo.tUsClEstadoCivil with(nolock) ON dbo.tCsPadronClientes.CodEstadoCivil = dbo.tUsClEstadoCivil.CodEstadoCivil 
            LEFT OUTER JOIN dbo.tClPaises with(nolock) ON dbo.tCsPadronClientes.CodPais = dbo.tClPaises.CodPais 
            --RIGHT OUTER JOIN dbo.tINTFPeriodo 
            INNER JOIN
                      (SELECT tCsCartera.Fecha, tCsMesGarantias.Codigo AS CodPrestamo, tCsPadronClientes.CodUsuario
                      , tCsMesGarantias.EstGarantia,tCsCartera.FechaDesembolso
                       FROM tCsMesGarantias with(nolock) 
                       INNER JOIN tCsClientes with(nolock) ON tCsMesGarantias.DocPropiedad = tCsClientes.CodOrigen 
                       INNER JOIN tCsPadronClientes with(nolock) ON tCsClientes.CodUsuario = tCsPadronClientes.CodOriginal 
                       INNER JOIN tCsCartera with(nolock) 
                       --ON dbo.fduFechaATexto(tCsMesGarantias.Fecha,'AAAAMM')=dbo.fduFechaATexto(tCsCartera.Fecha,'AAAAMM') -->18seg
                       ON tCsMesGarantias.Fecha=tCsCartera.Fecha-->0seg
                       AND tCsMesGarantias.Codigo = tCsCartera.CodPrestamo
                       --WHERE (tCsCartera.NroDiasAtraso >= 90) and tCsCartera.Fecha='20121231' -->264
                       /*que ocurre si el siguiente mes ya no tiene 90 dias de atraso, que ocurre con los avales???? es ahi donde se descontinua 
                         y genera desactualizadas.
                       */
                       WHERE tCsCartera.Fecha=@fecha 
--and tcscartera.codoficina<100 -->1703 
                       and (tCsCartera.nrodiasacumulado > 0)
--		and tCsCartera.codprestamo='018-158-06-04-00037'
and tCsCartera.codoficina not in ('230','231')  --03/08/2016
                       ) tCsCarteraDet --ON dbo.tINTFPeriodo.Corte = tCsCarteraDet.Fecha 
                       ON  dbo.tCsPadronClientes.CodUsuario = tCsCarteraDet.CodUsuario
WHERE (tCsCarteraDet.EstGarantia NOT IN ('INACTIVO'))
and tCsCarteraDet.codprestamo not in (select codprestamo from tCsBuroDepuLey)--='018-158-06-04-00037'
--and tCsCarteraDet.codprestamo not in (select codprestamo from [10.0.2.14].[Finmas].[dbo].[tCaCtasLiqPago])
and tCsCarteraDet.codprestamo not in (select codprestamo from tCaCtasLiqPago with(nolock))
--and (dbo.tINTFPeriodo.Activo = 1)
--255 con >=90
--1647 todos

union

/***************  vINTFNombreCancelados  ******************/
SELECT   -- top 50
tCsCarteraDet.Tipo 	--'Cancelados' AS Tipo
, tCsCarteraDet.Fecha, tCsCarteraDet.CodPrestamo, tCsCarteraDet.CodUsuario, 
Case when ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'') = '' Then  ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)),'') Else  ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'')  End AS Paterno, 
Case when ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)),'') = '' Then  'NO PROPORCIONADO' Else ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)),'')  End As Materno,  
--Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
case when tCsCarteraDet.FechaDesembolso>='20130101' then ''
else
  Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
end
AS Adicional
, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre2)), '') 
+ ' ' + ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre3)), '') AS Nombre2, 
dbo.fduFechaATexto(dbo.tCsPadronClientes.FechaNacimiento, 'DDMMAAAA') AS Nacimiento, RFC.UsRFC, '' AS Prefijo, '' AS Sufijo, 
dbo.tClPaises.INTF AS Nacionalidad, dbo.tUsClTipoPropiedad.INTF AS Residencia, CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir, 
dbo.tUsClEstadoCivil.INTF AS EstadoCivil, dbo.tUsClSexo.INTF AS Sexo, '' AS CedulaProfesional, CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE
, CASE tCsPadronClientes.coddociden WHEN 'CURP' THEN tCsPadronClientes.DI ELSE '' END AS CURP--'' AS ImpuestoOtroPais
, '' AS ClaveOtroPais, dbo.tCsPadronClientes.UsNDependientes AS NumeroDependientes, '' AS EdadesDependientes, 
'' AS DefuncionFecha, '' AS DefuncionIndicador
FROM (SELECT     CodUsuario, CASE c WHEN 10 THEN usrfc ELSE usrfcbd END AS UsRFC
      FROM 
            (SELECT     CodUsuario, CASE WHEN (isnumeric(SUBSTRING(UsRFC, 1, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 2, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 3, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 4, 1))) 
            = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 5, 1))) 
            = 1 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 6, 1))) 
            = 1 THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 7, 2) >= '01' AND SUBSTRING(UsRFC, 7, 2) 
            <= '12' THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 9, 2) >= '01' AND SUBSTRING(UsRFC, 9, 2) 
            <= '31' THEN 1 ELSE 0 END + CASE WHEN len(rtrim(ltrim(usrfc))) = 13 THEN 1 ELSE 0 END + CASE WHEN (SUBSTRING(UsRFC, 
            5, 6) = dbo.fduFechaATexto(FechaNacimiento, 'AAMMDD')) THEN 1 ELSE 0 END AS C, UsRFC, UsRFCBD, UsRFCVal
            FROM tCsPadronClientes with(nolock)) 
            Datos) RFC 
            INNER JOIN dbo.tCsPadronClientes with(nolock) ON RFC.CodUsuario COLLATE Modern_Spanish_CI_AI = dbo.tCsPadronClientes.CodUsuario 
	and dbo.tCsPadronClientes.codentidadtipo<>'JUR'	
            LEFT OUTER JOIN dbo.tUsClTipoPropiedad with(nolock) ON ISNULL(dbo.tCsPadronClientes.TipoPropiedadDirFam, dbo.tCsPadronClientes.TipoPropiedadDirNeg) = dbo.tUsClTipoPropiedad.CodTipoPro 
            LEFT OUTER JOIN dbo.tUsClSexo with(nolock) ON dbo.tCsPadronClientes.Sexo = dbo.tUsClSexo.Sexo 
            LEFT OUTER JOIN dbo.tUsClEstadoCivil with(nolock) ON dbo.tCsPadronClientes.CodEstadoCivil = dbo.tUsClEstadoCivil.CodEstadoCivil 
            LEFT OUTER JOIN dbo.tClPaises with(nolock) ON dbo.tCsPadronClientes.CodPais = dbo.tClPaises.CodPais 
            --RIGHT OUTER JOIN dbo.tINTFPeriodo 
            INNER JOIN
                  (
                   /*titulares*/
                   SELECT     CAST(dbo.fduFechaATexto(DATEADD([Month], 1, CAST(dbo.fduFechaATexto(Cancelacion, 'AAAAMM') + '01' AS SmallDateTime)), 'AAAAMM') 
                   + '01' AS SmallDateTime) - 1 AS Fecha, Cancelacion, CodPrestamo, CodUsuario,tCsPadronCarteraDet.desembolso FechaDesembolso, 'CanceladosT' tipo
					,tCsPadronCarteraDet.codoficina
                   FROM tCsPadronCarteraDet with(nolock)
                   WHERE (EstadoCalculado = 'CANCELADO')
                   and tCsPadronCarteraDet.cancelacion>=@primerdia  and tCsPadronCarteraDet.cancelacion<=@fecha
--		               and codprestamo='018-158-06-04-00037'
		               union
		               /*avales*/
		               SELECT @fecha fecha, tCspadronCarteradet.cancelacion,tCsMesGarantias.Codigo AS CodPrestamo
		               , tCsPadronClientes.CodUsuario,tCsPadronCarteraDet.desembolso FechaDesembolso, 'CanceladosA' tipo
					,tCsPadronCarteraDet.codoficina
                    FROM tCsMesGarantias with(nolock)
                    INNER JOIN tCsClientes with(nolock) ON tCsMesGarantias.DocPropiedad = tCsClientes.CodOrigen 
                    INNER JOIN tCsPadronClientes with(nolock) ON tCsClientes.CodUsuario = tCsPadronClientes.CodOriginal 
                    INNER JOIN tCspadronCarteradet with(nolock) 
                    ON tCsMesGarantias.Fechsalida=tCspadronCarteradet.cancelacion
                    AND tCsMesGarantias.Codigo = tCspadronCarteradet.CodPrestamo
                    WHERE tCspadronCarteradet.cancelacion>=@primerdia and tCspadronCarteradet.cancelacion<=@fecha
--                    and tCspadronCarteradet.codprestamo='018-158-06-04-00037'
		               /*codeudores*/
                    union
                    select @fecha fecha, tCspadronCarteradet.cancelacion,tCspadronCarteradet.CodPrestamo
                    ,tCsPrestamoCodeudor.codusuario,tCsPadronCarteraDet.desembolso FechaDesembolso, 'CanceladosC' tipo
					,tCsPadronCarteraDet.codoficina
                    from tCspadronCarteradet with(nolock) inner join 
                    tCsPrestamoCodeudor with(nolock) on tCsPrestamoCodeudor.CodPrestamo = tCspadronCarteradet.CodPrestamo
                    --tCsPadronClientes.CodUsuario = dbo.tCsPrestamoCodeudor.CodUsuario 
                    WHERE tCspadronCarteradet.cancelacion>=@primerdia and tCspadronCarteradet.cancelacion<=@fecha
--                    and tCspadronCarteradet.codprestamo='018-158-06-04-00037'
		              
	      ) tCsCarteraDet --ON dbo.tINTFPeriodo.Corte = tCsCarteraDet.Fecha 
                   ON dbo.tCsPadronClientes.CodUsuario = tCsCarteraDet.CodUsuario
--WHERE     (dbo.tINTFPeriodo.Activo = 1)
--where tCsCarteraDet.Fecha='20121231' 
/* realizarlo con la fecha calculada del texto es un error, demora mucho, con la fecha de cancelacion 0seg
*/
--where tCsCarteraDet.cancelacion>=@primerdia  and tCsCarteraDet.cancelacion<=@fecha
--2442
where tCsCarteraDet.codoficina not in ('230','231') 

union

/***************  vINTFNombreCodeudores  ******************/
SELECT   -- top 50
'Codeudor' AS Tipo, dbo.tCsCarteraDet.Fecha, dbo.tCsCarteraDet.CodPrestamo, dbo.tCsPrestamoCodeudor.CodUsuario, 
CASE WHEN ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)), '') = '' THEN ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)), '') 
ELSE ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)), '') END AS Paterno, CASE WHEN ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Paterno)), '') 
= '' THEN 'NO PROPORCIONADO' ELSE ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Materno)), '') END AS Materno, 
--CASE tCsPadronClientes.Sexo WHEN 0 THEN ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') WHEN 1 THEN '' END 
case when tCsCartera.FechaDesembolso>='20130101' then ''
else
  Case tCsPadronClientes.Sexo When 0 Then ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.ApeEsposo)), '') When 1 Then '' End
end
AS Adicional, 
ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre1)), '') AS Nombre1, ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre2)), '') 
+ ' ' + ISNULL(RTRIM(LTRIM(dbo.tCsPadronClientes.Nombre3)), '') AS Nombre2, dbo.fduFechaATexto(dbo.tCsPadronClientes.FechaNacimiento, 'DDMMAAAA') 
AS Nacimiento, RFC.UsRFC, '' AS Prefijo, '' AS Sufijo, dbo.tClPaises.INTF AS Nacionalidad, dbo.tUsClTipoPropiedad.INTF AS Residencia, 
CASE coddociden WHEN 'vcb' THEN DI END AS LicenciaConducir, dbo.tUsClEstadoCivil.INTF AS EstadoCivil, dbo.tUsClSexo.INTF AS Sexo, '' AS CedulaProfesional, 
CASE coddociden WHEN 'CE' THEN '' ELSE '' END AS IFE
, CASE tCsPadronClientes.coddociden WHEN 'CURP' THEN tCsPadronClientes.DI ELSE '' END AS CURP--'' AS ImpuestoOtroPais
, '' AS ClaveOtroPais, 
dbo.tCsPadronClientes.UsNDependientes AS NumeroDependientes, '' AS EdadesDependientes, '' AS DefuncionFecha, '' AS DefuncionIndicador
FROM dbo.tClPaises with(nolock) RIGHT OUTER JOIN
                   (SELECT     CodUsuario, CASE c WHEN 10 THEN usrfc ELSE usrfcbd END AS UsRFC
                    FROM 
                          (SELECT     CodUsuario, CASE WHEN (isnumeric(SUBSTRING(UsRFC, 1, 1))) = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 2, 
                           1))) = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 3, 1))) 
                           = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 4, 1))) 
                           = 0 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 5, 1))) 
                           = 1 THEN 1 ELSE 0 END + CASE WHEN (isnumeric(SUBSTRING(UsRFC, 6, 1))) = 1 THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 7, 
                           2) >= '01' AND SUBSTRING(UsRFC, 7, 2) <= '12' THEN 1 ELSE 0 END + CASE WHEN SUBSTRING(UsRFC, 9, 2) >= '01' AND 
                           SUBSTRING(UsRFC, 9, 2) <= '31' THEN 1 ELSE 0 END + CASE WHEN len(rtrim(ltrim(usrfc))) 
                           = 13 THEN 1 ELSE 0 END + CASE WHEN (SUBSTRING(UsRFC, 5, 6) = dbo.fduFechaATexto(FechaNacimiento, 'AAMMDD')) 
                           THEN 1 ELSE 0 END AS C, UsRFC, UsRFCBD, UsRFCVal
                           FROM tCsPadronClientes with(nolock)) 
                           Datos) RFC 
                   INNER JOIN dbo.tCsPadronClientes with(nolock) ON RFC.CodUsuario COLLATE Modern_Spanish_CI_AI = dbo.tCsPadronClientes.CodUsuario 
                   INNER JOIN dbo.tCsPrestamoCodeudor with(nolock) 
                   --INNER JOIN dbo.tINTFPeriodo 
                   INNER JOIN dbo.tCsCarteraDet with(nolock) --ON dbo.tINTFPeriodo.Corte = dbo.tCsCarteraDet.Fecha 
                   ON dbo.tCsPrestamoCodeudor.CodPrestamo = dbo.tCsCarteraDet.CodPrestamo 
                   ON dbo.tCsPadronClientes.CodUsuario = dbo.tCsPrestamoCodeudor.CodUsuario 
                   LEFT OUTER JOIN dbo.tUsClTipoPropiedad with(nolock) 
                   ON ISNULL(dbo.tCsPadronClientes.TipoPropiedadDirFam, dbo.tCsPadronClientes.TipoPropiedadDirNeg) = dbo.tUsClTipoPropiedad.CodTipoPro 
                   LEFT OUTER JOIN dbo.tUsClSexo with(nolock) ON dbo.tCsPadronClientes.Sexo = dbo.tUsClSexo.Sexo 
                   LEFT OUTER JOIN dbo.tUsClEstadoCivil with(nolock) ON dbo.tCsPadronClientes.CodEstadoCivil = dbo.tUsClEstadoCivil.CodEstadoCivil 
                   ON dbo.tClPaises.CodPais = dbo.tCsPadronClientes.CodPais
                   inner join tcscartera with(nolock) on tcscartera.codprestamo = dbo.tCsCarteraDet.codprestamo
                   and tcscartera.fecha=tCsCarteraDet.fecha
--WHERE (dbo.tINTFPeriodo.Activo = 1)
where dbo.tCsCarteraDet.Fecha=@fecha
and tCsCarteraDet.codprestamo not in (select codprestamo from tCsBuroDepuLey)--='018-158-06-04-00037'
--and tCsCarteraDet.codprestamo not in (select codprestamo from [10.0.2.14].[Finmas].[dbo].[tCaCtasLiqPago])
and tCsCarteraDet.codprestamo not in (select codprestamo from tCaCtasLiqPago)
--and tCsCarteraDet.codprestamo='018-158-06-04-00037'
--6394
--and tcscartera.codoficina<100
and tCsCartera.codoficina not in ('230','231');  --03/08/2016


--por ultimo borra todos los de tipo ALTA 5, 6, 7 ,8, 9
delete from tCsBuroxTblReInomVr13 
where CodPrestamo in (select codprestamo from finamigoconsolidado..tCspadroncarteradet where CodGrupo in ( 'alta5', 'alta6', 'alta7', 'alta8', 'alta9'))





GO