SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--sucursal, promotor, núm. de préstamo, fecha de otorgamiento, monto, tipo de producto, días en mora, tasa, plazo, periodicidad,deuda,estado
--16,070
--15,347
--pCsACarteraMesa '20191127'
--drop procedure pCsACarteraMesa
CREATE procedure [dbo].[pCsACarteraMesa] @fecha smalldatetime
as
set nocount on

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'

IF  EXISTS (select 1 from dbo.sysobjects WHERE id = OBJECT_ID(N'[tCsRptCAMesa]')) -- -- AND type = 'D')             --SELECT * FROM tCsRptCAMesa
BEGIN            
     DROP TABLE tCsRptCAMesa
END   

select z.nombre region,p.codoficina nrosucursal,o.nomoficina sucursal,cl.nombrecompleto cliente,pr.nombrecompleto promotor1,pr2.nombrecompleto promotor2
,p.codprestamo 'numprestamo',c.codsolicitud,p.desembolso 'fechaotorgamiento',p.monto,c.fechavencimiento
,po.nombreprod,c.nrodiasatraso,c.tasaintcorriente, datediff(month,fechadesembolso,fechavencimiento) 'plazo',c.modalidadplazo 'periocidad'
,case when p.estadocalculado='CANCELADO' then 0 else
d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden
+d.impuestos+d.cargomora+d.otroscargos end deuda,p.estadocalculado
,p.secuenciacliente
,case when p.estadocalculado='CANCELADO' then 0 else d.saldocapital end saldocapital
,case when p.estadocalculado='CANCELADO' then 0 else d.interesvigente end interesvigente
,case when p.estadocalculado='CANCELADO' then 0 else d.interesvencido end interesvencido
,case when p.estadocalculado='CANCELADO' then 0 else d.interesctaorden end interesctaorden
,case when p.estadocalculado='CANCELADO' then 0 else d.moratoriovigente end moratoriovigente
,case when p.estadocalculado='CANCELADO' then 0 else d.moratoriovencido end moratoriovencido
,case when p.estadocalculado='CANCELADO' then 0 else d.moratorioctaorden end moratorioctaorden
,case when p.estadocalculado='CANCELADO' then 0 else d.impuestos end impuestos
,case when p.estadocalculado='CANCELADO' then 0 else d.cargomora end cargomora
,case when p.estadocalculado='CANCELADO' then 0 else d.otroscargos end otroscargos
into tCsRptCAMesa
from tcspadroncarteradet p with(nolock)
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
left outer join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
left outer join tcspadronclientes pr with(nolock) on pr.codusuario=p.primerasesor
left outer join tcspadronclientes pr2 with(nolock) on pr2.codusuario=p.ultimoasesor
inner join tcaproducto po with(nolock) on po.codproducto=p.codproducto
inner join tcscarteradet d with(nolock) on p.fechacorte=d.fecha and p.codprestamo=d.codprestamo and p.codusuario=d.codusuario
inner join tcscartera c with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tclzona z with(nolock) on z.zona=o.zona
where p.desembolso>=@fecini and cast(p.codoficina as int)<>97
GO