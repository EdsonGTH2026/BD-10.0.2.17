SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE procedure [dbo].[pCsAComerSegCarteraMotos] @fecha smalldatetime, @codoficina varchar(300)
as

--declare @fecha smalldatetime
--set @fecha='20150630'

SELECT ca.Fecha, ca.CodPrestamo, ca.CodSolicitud, ca.CodOficina, tClOficinas.NomOficina, tClZona.Nombre AS Region
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
,ds.DescDestino,pro.nombre proveedor,un.descripcion unidad
FROM tCsCartera ca with(nolock) 
INNER JOIN tCaProducto with(nolock) ON tCaProducto.CodProducto = ca.CodProducto 
INNER JOIN tCaClTecnologia with(nolock) ON tCaClTecnologia.Tecnologia = tCaProducto.Tecnologia 
INNER JOIN tClOficinas with(nolock) ON ca.CodOficina = tClOficinas.CodOficina 
INNER JOIN tCsPadronClientes asesor with(nolock) ON ca.CodAsesor = asesor.codusuario
LEFT OUTER JOIN tCsCarteraGrupos with(nolock) ON ca.CodOficina = tCsCarteraGrupos.CodOficina AND ca.CodGrupo = tCsCarteraGrupos.CodGrupo 
INNER JOIN tClZona with(nolock) ON tClOficinas.Zona = tClZona.Zona
inner join tCsCarteradet cd with(nolock) on cd.fecha=ca.fecha and cd.codprestamo=ca.codprestamo
left outer join tCsPadronCarteraDestinoDet de with(nolock) on de.codprestamo=cd.codprestamo and de.codusuario=cd.codusuario
INNER JOIN tCsPadronClientes with(nolock) ON cd.CodUsuario = tCsPadronClientes.CodUsuario 
inner join tCaProdPerTipoCredito tc with(nolock) on tc.CodTipoCredito=tCaProducto.tipotecnocred
left outer join tClUbigeo u with(nolock) on u.codubigeo=isnull(tCsPadronClientes.codubigeodirfampri,tCsPadronClientes.codubigeodirnegpri)
left outer join (select codmunicipio,codestado,descubigeo municipio from tClUbigeo muni where codubigeotipo='MUNI') m on m.codmunicipio=u.codmunicipio and m.codestado=u.codestado
left outer join tCaClDestino ds with(nolock) on ds.coddestino=isnull(de.coddestino,ca.coddestino)
left outer join tCaClDProveedor pro with(nolock) on pro.codproveedor=de.codproveedor
left outer join tCaClDUnidad un with(nolock) on un.codunidad=de.codunidad
WHERE (ca.Fecha = @fecha) and (ca.codproducto in (163,302) or ca.codprestamo='024-156-06-00-00364')

GO