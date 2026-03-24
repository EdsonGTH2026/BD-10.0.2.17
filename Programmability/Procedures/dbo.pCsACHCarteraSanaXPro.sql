SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsACHCarteraSanaXPro
create procedure [dbo].[pCsACHCarteraSanaXPro] @fecha      SMALLDATETIME ,            
                 @codoficina VARCHAR(300)
as

IF  EXISTS (SELECT * FROM tCsRptCHCarteraSanaXPro) --dbo.sysobjects WHERE id = OBJECT_ID(N'[tCsRptBonoCartera]'))-- AND type = 'D')            
BEGIN            
     DROP TABLE tCsRptCHCarteraSanaXPro
END

select z.nombre region,o.nomoficina sucursal,c.codasesor,cl.nombrecompleto,e.codpuesto,e.codempleado,e.ingreso
,count(distinct c.codprestamo) nroprestamos,count(distinct d.codusuario) nroclientes
,sum(d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido) saldocarterasana
,sum(case when c.codproducto not in('164','156','116','115') then d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido else 0 end) individual
,sum(case when c.codproducto in('156') then d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido else 0 end) solidaria
,sum(case when c.codproducto in('164') then d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido else 0 end) grupal
into tCsRptCHCarteraSanaXPro
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join (SELECT codusuario,codpuesto,codempleado,codoficinanom,ingreso FROM tCsEmpleados with(nolock) where estado=1 and codpuesto in (66,67) and codusuario<>'') e
on e.codusuario=c.codasesor
inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
inner join tclzona z with(nolock) on z.zona=o.zona
where c.fecha=@fecha and c.cartera='ACTIVA'
and c.nrodiasatraso=0
group by z.nombre,o.nomoficina,c.codasesor,cl.nombrecompleto,e.codpuesto,e.codempleado,e.ingreso
GO