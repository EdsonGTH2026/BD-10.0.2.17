SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCHPlantillaEmpleados]
as

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tCsAPlantillaEmpleados]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].tCsAPlantillaEmpleados

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tCsAPlantillaResumen]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].tCsAPlantillaResumen

declare @fecha smalldatetime
declare @fecini smalldatetime
select @fecha=fechaconsolidacion from vCsFechaConsolidacion
set @fecini= dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'


select @fecha fecha,o.nomoficina sucursal,e.Paterno + ' '+ e.Materno +' '+e.Nombres Colaborador,p.descripcion puesto,e.ingreso,e.codpuesto
,cl.nombrecompleto nombrefinmas,e.codusuario,cl.codorigen
into tCsAPlantillaEmpleados
from tcsempleados e with(nolock)
inner join tcsclpuestos p with(nolock) on p.codigo=e.codpuesto
inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
left outer join tcspadronclientes cl with(nolock) on cl.codusuario=e.codusuario
where e.estado=1
and e.codoficinanom<>98
order by o.nomoficina,p.descripcion
--select * from tcsempleados

select @fecha fecha,o.nomoficina sucursal
,count(case when e.codpuesto=70 then paterno else null end) Lider
,count(case when e.codpuesto=20 then paterno else null end) Cajero
,count(case when e.codpuesto=66 then paterno else null end) Promotor
,count(case when e.codpuesto not in(66,20,70) then paterno else null end) Otro
,count(paterno) total
,count(case when ingreso>=@fecini and ingreso<=@fecha then 
	case when e.codpuesto=70 then paterno else null end
	else null end) IngLider
,count(case when ingreso>=@fecini and ingreso<=@fecha then 
	case when e.codpuesto=20 then paterno else null end
	else null end) IngCajero
,count(case when ingreso>=@fecini and ingreso<=@fecha then 
	case when e.codpuesto=66 then paterno else null end
	else null end) IngPromotor
into tCsAPlantillaResumen
from tcsempleados e with(nolock)
inner join tcsclpuestos p with(nolock) on p.codigo=e.codpuesto
inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
where e.estado=1
and e.codoficinanom<>98
group by o.nomoficina

--select codusuario,codoficinanom,codpuesto,codempleado
--from tcsempleados
--where estado=1
--and codoficinanom<>98
--and codusuario<>''

--select codusuario,codempleado,paterno,materno,nombres,p.descripcion puesto,o.nomoficina sucursal
--from tcsempleados e
--inner join tcsclpuestos p with(nolock) on p.codigo=e.codpuesto
--inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
--where e.estado=1
--and e.codoficinanom<>98
--and e.codusuario=''
GO