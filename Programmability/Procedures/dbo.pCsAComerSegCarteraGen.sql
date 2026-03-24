SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAComerSegCarteraGen] @fecha smalldatetime,@codoficina as varchar(4)
as

create table #tca(
	codprestamo varchar(25),
	prestamoid varchar(25),
	codserviciop varchar(25)
)
insert into #tca (codprestamo,prestamoid,codserviciop)
select codprestamo,codanterior,codserviciop from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100

--declare @fecha smalldatetime
--set @fecha='20161210'


IF  EXISTS (select * from dbo.sysobjects WHERE id = OBJECT_ID(N'[tCsRptAComerSegCartera]')) --SELECT * FROM tCsRptAComerSegCartera---- AND type = 'D')            
BEGIN            
     DROP TABLE tCsRptAComerSegCartera
END    

SELECT ca.Fecha, ca.CodPrestamo, ca.CodSolicitud, ca.CodOficina, tClOficinas.NomOficina, tClZona.Nombre AS Region
,ca.CodProducto, tCaProducto.NombreProdCorto, tCaClTecnologia.veridico NombreTec
,ca.CodAsesor, asesor.nombrecompleto asesor,pripro.nombrecompleto primerpromotor 
, cd.CodUsuario
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
,u.descubigeo localidad,ca.tasaintcorriente
,case when ca.Estado not in ('VENCIDO','CASTIGADO') then
    case when ca.NroDiasAtraso=0 then 
          '0 días'
          when ca.NroDiasAtraso>0 and ca.NroDiasAtraso<8 then
          '1 a 7 días'
          when ca.NroDiasAtraso>=8 and ca.NroDiasAtraso<16 then
          '8 a 15 días'
          when ca.NroDiasAtraso>=16 and ca.NroDiasAtraso<31 then
          '16 a 30 días'
          when ca.NroDiasAtraso>=31 and ca.NroDiasAtraso<61 then
          '31 a 60 días'
          when ca.NroDiasAtraso>=61 and ca.NroDiasAtraso<90 then
          '61 a 89 días'
          else
          null 
          end
   else 
    'Mayor a 90 días'
   end RangoDias
,case when clq.codprestamo is null then '' else 'Crédito Cedido' end Venta
into tCsRptAComerSegCartera
FROM tCsCartera ca with(nolock) 
--INNER JOIN tCaProducto with(nolock) ON tCaProducto.CodProducto = ca.CodProducto 
left outer join tcspadroncarteraotroprod op on op.codprestamo=ca.codprestamo
inner join tcaproducto on tcaproducto.codproducto=isnull(op.codproducto,ca.codproducto)
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
left outer join [10.0.2.14].[Finmas].[dbo].[tCaCtasLiqPago] clq on clq.codprestamo=ca.codprestamo
left outer join tcspadroncarteradet pd with(nolock) on pd.codprestamo=cd.codprestamo and pd.codusuario=cd.codusuario
left outer JOIN tCsPadronClientes pripro with(nolock) ON pripro.codusuario=pd.primerasesor 
WHERE (ca.Fecha = @fecha) and ca.codoficina<>97 and ca.cartera='ACTIVA' 
--AND (ca.CodOficina IN (select codigo from dbo.fduTablaValores(@codoficina)))
and ca.codprestamo not in (select codprestamo from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100 and estado='ANULADO')
and ca.codprestamo not in (select codprestamo from #tca where codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9'))

drop table #tca

GO