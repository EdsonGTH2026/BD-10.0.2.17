SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAComerSegCaDestino] @fecha smalldatetime, @coddestino varchar(300)
as

SELECT ca.Fecha, ca.CodPrestamo
, ca.CodSolicitud, ca.CodOficina, tClOficinas.NomOficina, tClZona.Nombre AS Region
,ca.CodProducto, tCaProducto.NombreProdCorto, tCaClTecnologia.veridico NombreTec
,ca.CodAsesor, asesor.nombrecompleto asesor, cd.CodUsuario
,tCsPadronClientes.NombreCompleto, ca.CodGrupo, tCsCarteraGrupos.NombreGrupo, ca.Estado, ca.SecuenciaSolicitud
,ca.NroDiasAtraso, ca.NroCuotas, ca.NroCuotasPagadas, ca.NroCuotasPorPagar, ca.FechaDesembolso
,ca.FechaVencimiento, cd.MontoDesembolso,ca.tiporeprog
, case when tCaProducto.codproducto='123' then 'VIVIENDA' else tc.Descripcion end tipo
,cd.saldocapital,cd.saldocapital-cd.capitalvencido capitalvigente,cd.capitalatrasado,cd.capitalvencido
,cd.interesvigente,cd.interesvencido,cd.interesctaorden
,cd.moratoriovigente,cd.moratoriovencido,cd.moratorioctaorden
,cd.otroscargos,cd.impuestos,cd.cargomora
,case when isnull(tCsPadronClientes.codpostalfam,'')='' then tCsPadronClientes.codpostalneg else tCsPadronClientes.codpostalfam end codpostal
,case when isnull(tCsPadronClientes.telefonodirfampri,'')='' then tCsPadronClientes.telefonodirnegpri else tCsPadronClientes.telefonodirfampri end telefono
,m.municipio
,u.descubigeo localidad
FROM tCsCartera ca with(nolock) 
INNER JOIN tCaProducto with(nolock) ON tCaProducto.CodProducto = ca.CodProducto 
INNER JOIN tCaClTecnologia with(nolock) ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia 
INNER JOIN tClOficinas with(nolock) ON ca.CodOficina = tClOficinas.CodOficina 
INNER JOIN tCsPadronClientes asesor with(nolock) ON ca.CodAsesor = asesor.codusuario
LEFT OUTER JOIN tCsCarteraGrupos with(nolock) ON ca.CodOficina = tCsCarteraGrupos.CodOficina AND ca.CodGrupo = tCsCarteraGrupos.CodGrupo 
INNER JOIN tClZona with(nolock) ON tClOficinas.Zona = tClZona.Zona
inner join tCsCarteradet cd with(nolock) on cd.fecha=ca.fecha and cd.codprestamo=ca.codprestamo
INNER JOIN tCsPadronClientes with(nolock) ON cd.CodUsuario = tCsPadronClientes.CodUsuario 
inner join tCaProdPerTipoCredito tc with(nolock) on tc.CodTipoCredito=tCaProducto.tipotecnocred
left outer join tClUbigeo u with(nolock) on u.codubigeo=isnull(tCsPadronClientes.codubigeodirfampri,tCsPadronClientes.codubigeodirnegpri)
left outer join (select codmunicipio,codestado,descubigeo municipio from tClUbigeo muni
where codubigeotipo='MUNI') m on m.codmunicipio=u.codmunicipio and m.codestado=u.codestado
inner join tcacldestino d on d.coddestino=ca.coddestino
WHERE (ca.Fecha = @fecha) 
and d.padredestino in (select codigo from dbo.fduTablaValores(@coddestino))
GO