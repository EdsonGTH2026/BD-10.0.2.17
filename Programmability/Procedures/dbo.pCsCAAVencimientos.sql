SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCAAVencimientos '20181009'
CREATE procedure [dbo].[pCsCAAVencimientos] @fecha smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20181009'

declare @fecini smalldatetime
declare @fecfin smalldatetime

set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
--set @fecfin=@fecha
select @fecfin=cast(year(@fecha) + (case when (month(@fecha)+1)=13 then 1 else 0 end) as char(4))+dbo.fdufechaatexto(ultimodia,'MMDD') 
											from tclperiodo where año=2017 and mes=case when (month(@fecha)+1)=13 then 1 else (month(@fecha)+1) end 

create table #dias(codprestamo varchar(25),nrodiasatraso int)
create table #ptmos (codprestamo varchar(25),cancelacion smalldatetime)

insert into #ptmos
select distinct p.codprestamo,p.cancelacion --from tcspadroncarteradet p with(nolock) 
from tcscartera ca with(nolock)
inner join tcspadroncarteradet p with(nolock) on p.codprestamo=ca.codprestamo and p.fechacorte=ca.fecha
--where p.cancelacion>=@fecini and p.cancelacion<=@fecfin
--and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
--and p.codoficina not in('97','230','231')
where ca.fechavencimiento>=@fecini and ca.fechavencimiento<=@fecfin
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
and p.codoficina not in('97','230','231')
and ca.cartera<>'CASTIGADA'
---and ca.codprestamo='004-170-06-05-00897'

insert into #dias 
select codprestamo,max(nrodiasatraso) nrodiasatraso
from tcscartera with(nolock)
where codprestamo in (select codprestamo from #ptmos)--='004-170-06-05-00897'-- 
group by codprestamo

declare @fecmin smalldatetime
select @fecmin=min(cancelacion) from #ptmos

select x.codprestamo,x.codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso,secuenciacliente,y.secuenciaproductivo,y.secuenciaconsumo
into #desembolsos
from tcspadroncarteradet x with(nolock)
left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo
where x.desembolso>=@fecmin--@fecini 
and x.desembolso<=@fecfin--'20180927'--

--select @fecmin '@fecmin'
 --drop table tCsACaVencimientos_RR
truncate table tCsACaVencimientos_RR
----select * from tCsACaVencimientos_RR
insert into tCsACaVencimientos_RR
select @fecha fecha,z.nombre region,o.codoficina,o.nomoficina sucursal,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else co.nombrecompleto end coordinador
--,cl.codusuario
,cl.nombrecompleto cliente
,p.codprestamo,p.secuenciacliente,p.monto,p.desembolso fechadesembolso,ca.fechavencimiento,p.cancelacion,d.nrodiasatraso atrasomaximo
,case when cr.nuevodesembolso is not null then
	case when dbo.fdufechaaperiodo(p.cancelacion)=dbo.fdufechaaperiodo(cr.nuevodesembolso) then 'Renovado' else 'Reactivado' end
 else 
	--'Sin Renovar'
	case when p.cancelacion is null then 'Credito Activo' else 'Sin Renovar' end
 end Estado
,cr.nuevomonto,cr.nuevodesembolso,cr.codprestamo codprestamonuevo
,de.saldocapital+de.interesvigente+de.interesvencido+de.interesctaorden+de.moratoriovigente+de.moratoriovencido+de.moratorioctaorden
+de.impuestos+de.cargomora+de.otroscargos Deuda
--into tCsACaVencimientos_RR
--select ca.* 
from tcscartera ca with(nolock)
inner join tcscarteradet de with(nolock) on de.codprestamo=ca.codprestamo and de.fecha=ca.fecha
inner join tcspadroncarteradet p with(nolock) on p.codprestamo=ca.codprestamo and p.fechacorte=ca.fecha
left outer join tCsPadronCarteraSecuen s with(nolock) on s.codprestamo=p.codprestamo
left outer join
--(
    --   select x.codprestamo,x.codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso,secuenciacliente,y.secuenciaproductivo
    --   ,y.secuenciaconsumo
    --   from tcspadroncarteradet x with(nolock)
    --   left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo
    --   where x.desembolso>=@fecmin--@fecini 
	   --and x.desembolso<=@fecfin--'20180927'--
--) 
#desembolsos cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
       and (case when cr.codproducto='370' then cr.secuenciaconsumo else cr.secuenciaproductivo end)
              =(case when p.codproducto='370' then s.secuenciaconsumo+1 else s.secuenciaproductivo+1 end)
inner join tcloficinas o with(nolock) on o.codoficina=p.codoficina
inner join tclzona z with(nolock) on o.zona=z.zona
inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
inner join tcspadronclientes co with(nolock) on co.codusuario=p.ultimoasesor
left outer join #dias d on d.codprestamo=p.codprestamo
left outer join tcsempleadosfecha e on e.codusuario=p.ultimoasesor and e.fecha=@fecha-->huerfano
where ca.fechavencimiento>=@fecini and ca.fechavencimiento<=@fecfin
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
and p.codoficina not in('97','230','231')
and ca.cartera<>'CASTIGADA'
--and ca.codprestamo='004-170-06-05-00897'

--select @fecini
--select @fecfin
--select x.codprestamo,x.codproducto,codusuario,monto nuevomonto,desembolso nuevodesembolso,secuenciacliente,y.secuenciaproductivo
--,y.secuenciaconsumo
--from tcspadroncarteradet x
--left outer join tCsPadronCarteraSecuen y with(nolock) on y.codprestamo=x.codprestamo
--where x.desembolso>=@fecmin and x.desembolso<=@fecfin--'20180927'--
--and x.codusuario='MLA2309891'

drop table #ptmos
drop table #dias
drop table #desembolsos
--9124
GO