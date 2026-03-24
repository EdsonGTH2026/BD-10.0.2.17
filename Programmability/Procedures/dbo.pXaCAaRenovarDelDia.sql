SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCAaRenovarDelDia]
as
set nocount on
declare @fecha smalldatetime
--set @fecha='20190618'
select @fecha=fechaconsolidacion+1 from vcsfechaconsolidacion

declare @fecini smalldatetime
declare @fecfin smalldatetime

set @fecini='20180101'
set @fecfin=@fecha

create table #dias(codprestamo varchar(25),nrodiasatraso int)
create table #ptmos (codprestamo varchar(25))

insert into #ptmos
select codprestamo
from [10.0.2.14].finmas.dbo.tcaprestamos
where estado='CANCELADO' and fechaproceso=@fecha and fechaultpago=@fecha
and codprestamo not in(select codprestamo from tCsACaLIQUI_RR with(nolock))

insert into #dias
select codprestamo,max(nrodiasatraso) nrodiasatraso
from tcscartera with(nolock)
where codprestamo in (select codprestamo from #ptmos)
--and codoficina='308' and codusuario='BCM980505FTR06'
group by codprestamo

insert into tCsACaLIQUI_RR
select z.nombre region,o.codoficina,o.nomoficina sucursal,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador
,p.codusuario,cl.nombrecompleto cliente
,p.codprestamo,p.secuenciacliente,p.monto,p.desembolso fechadesembolso,ca.fechavencimiento,@fecha cancelacion,d.nrodiasatraso atrasomaximo
,case when cr.nuevodesembolso is not null then
	case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then 'Renovado' else 'Reactivado' end
 else 
	'Sin Renovar'
 end Estado
,cr.nuevomonto,cr.nuevodesembolso,cr.codprestamo codprestamonuevo,cl.telefonomovil
,datepart(week,@fecha) semana
,e.codusuario codpromotor
,p.tiporeprog
from tcspadroncarteradet p with(nolock)
left outer join tCsPadronCarteraSecuen s with(nolock) on s.codprestamo=p.codprestamo
left outer join(
       select x.codprestamo,x.codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso,secuenciacliente,y.secuenciaproductivo
       ,y.secuenciaconsumo
       from tcspadroncarteradet x
       left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo
       where x.desembolso>=@fecini and x.desembolso<=@fecha
) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
	   and cr.secuenciacliente=p.secuenciacliente+1
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on o.zona=z.zona
inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
inner join tcspadronclientes co with(nolock) on co.codusuario=p.ultimoasesor
left outer join tcscartera ca with(nolock) on ca.fecha=p.fechacorte and ca.codprestamo=p.codprestamo
left outer join #dias d on d.codprestamo=p.codprestamo
left outer join tcsempleadosfecha e on e.codusuario=p.ultimoasesor and e.fecha=@fecfin-1-->huerfano
where p.codprestamo in(select codprestamo from #ptmos)

drop table #ptmos
drop table #dias


--select * from tcsempleados where codusuario='PHR1304941'
--select * from tCsACaLIQUI_RR where cancelacion='20190618'
GO