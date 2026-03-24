SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----drop procedure pCsCAALIQUI_RR '20181007'
CREATE procedure [dbo].[pCsCAALIQUI_RR] @fecha smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20201005'

declare @fecini smalldatetime
declare @fecfin smalldatetime

--set @fecini=dbo.fdufechaaperiodo(dateadd(month,-3,@fecha))+'01'
--set @fecini=cast(year(@fecha) as char(4))+'0101'
set @fecini='20170101'
set @fecfin=@fecha

create table #dias(codprestamo varchar(25),nrodiasatraso int)
create table #ptmos (codprestamo varchar(25))

insert into #ptmos
select codprestamo from tcspadroncarteradet p with(nolock) 
--where p.cancelacion>=dbo.fdufechaaperiodo(dateadd(month,-3,@fecha))+'01' and p.cancelacion<=@fecha
where p.cancelacion>=@fecini and p.cancelacion<=@fecfin
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
and p.codoficina not in('97','230','231')--='308'--
--and p.codoficina='4'
--and p.codusuario='BCM980505FTR06'

insert into #dias 
select codprestamo,max(nrodiasatraso) nrodiasatraso
from tcscartera with(nolock)
where codprestamo in (select codprestamo from #ptmos)
--and codoficina='308' and codusuario='BCM980505FTR06'
group by codprestamo

truncate table tCsACaLIQUI_RR
--drop table tCsACaLIQUI_RR
insert into tCsACaLIQUI_RR
select z.nombre region,o.codoficina,o.nomoficina sucursal,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador
,p.codusuario,cl.nombrecompleto cliente
,p.codprestamo,p.secuenciacliente,p.monto,p.desembolso fechadesembolso,ca.fechavencimiento,p.cancelacion,d.nrodiasatraso atrasomaximo
,case when cr.nuevodesembolso is not null then
	case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then 'Renovado' else 'Reactivado' end
 else 
	'Sin Renovar'
 end Estado
,cr.nuevomonto,cr.nuevodesembolso,cr.codprestamo codprestamonuevo,cl.telefonomovil
,datepart(week,p.cancelacion) semana
,case when (e.codusuario is null or e.codpuesto<>66) then null else e.codusuario end codpromotor
,p.tiporeprog
--into tCsACaLIQUI_RR
from tcspadroncarteradet p with(nolock)
left outer join tCsPadronCarteraSecuen s with(nolock) on s.codprestamo=p.codprestamo
left outer join(
       select x.codprestamo,x.codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso,secuenciacliente,y.secuenciaproductivo
       ,y.secuenciaconsumo
       from tcspadroncarteradet x
       left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo
       where x.desembolso>=@fecini and x.desembolso<=@fecha--'20180927'--
) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
       --and (case when cr.codproducto='370' then cr.secuenciaconsumo else cr.secuenciaproductivo end)
       --       =(case when p.codproducto='370' then s.secuenciaconsumo+1 else s.secuenciaproductivo+1 end)
	   and cr.secuenciacliente=p.secuenciacliente+1
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on o.zona=z.zona
inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
inner join tcspadronclientes co with(nolock) on co.codusuario=p.ultimoasesor
left outer join tcscartera ca with(nolock) on ca.fecha=p.fechacorte and ca.codprestamo=p.codprestamo
left outer join #dias d on d.codprestamo=p.codprestamo
left outer join tcsempleadosfecha e on e.codusuario=p.ultimoasesor and e.fecha=@fecfin-->huerfano
where p.cancelacion>=@fecini and p.cancelacion<=@fecfin
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
and p.codoficina not in('97','230','231')--='308' --
--and p.codusuario='BCM980505FTR06'

select s.codsolicitud,s.codusuario,s.fechadesembolso,s.montoaprobado
into #panel
from [10.0.2.14].finmas.dbo.tcasolicitud s
inner join [10.0.2.14].finmas.dbo.tcasolicitudproce p on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina
where p.estado not in(9,10,11,70,71,211,311)

update #panel
set codusuario=p.codusuario
from tcspadronclientes p with(nolock)
inner join #panel x on x.codusuario=p.codorigen

--select p.*,l.*
update tCsACaLIQUI_RR
set estado='En proceso',nuevomonto=p.montoaprobado,nuevodesembolso=p.fechadesembolso,codprestamonuevo=p.codsolicitud
from #panel p
inner join tCsACaLIQUI_RR l on l.codusuario=p.codusuario
where estado='Sin Renovar'

delete from tCsACaLIQUI_RR
where codoficina>=100 and codoficina<300
and estado<>'En proceso'

drop table #ptmos
drop table #dias
--drop table #panel

--select * from tCsACaLIQUI_RR
GO