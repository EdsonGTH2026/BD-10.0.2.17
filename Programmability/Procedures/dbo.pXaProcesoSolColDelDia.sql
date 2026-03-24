SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pXaProcesoSolColDelDia
CREATE procedure [dbo].[pXaProcesoSolColDelDia]
as
create table #pro (proceso varchar(10),codigo varchar(25),codoficina varchar(5),monto money)
insert into #pro (proceso,codigo,codoficina,monto)
exec [10.0.2.14].finmas.dbo.pXaProcesoSolColDelDia

declare @ca table (sec int identity(1,1), region varchar(100), sucursal varchar(200), sol_nro int, sol_monto money, cre_nro int, cre_monto money, nro int)
insert into @ca (region,sucursal,sol_nro,sol_monto,cre_nro,cre_monto,nro)
select region,sucursal,sum(sol_nro) sol_nro, sum(sol_monto) sol_monto,sum(cre_nro) cre_nro,sum(cre_monto) cre_monto,sum(nro) nro
from (
	select a.*,b.nro
	from (
		select 0 i,'' region,'Total' sucursal
		,count(case when proceso='solicitud' then codigo else null end) sol_nro
		,sum(case when proceso='solicitud' then monto else 0 end) sol_monto
		,count(case when proceso='credito' then codigo else null end) cre_nro
		,sum(case when proceso='credito' then monto else 0 end) cre_monto
		from #pro c with(nolock)
		inner join tcloficinas o with(nolock) on c.codoficina=o.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona
	) a cross join 
	(select count(codusuario) nro
		from tcsempleados e  with(nolock) inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
		where estado=1 and codpuesto=66
		) b

	union
	select a.*,isnull(e.nro,0) nro
	from (
		select 1 i,z.nombre region,o.nomoficina sucursal
		,count(case when proceso='solicitud' then codigo else null end) sol_nro
		,sum(case when proceso='solicitud' then monto else 0 end) sol_monto
		,count(case when proceso='credito' then codigo else null end) cre_nro
		,sum(case when proceso='credito' then monto else 0 end) cre_monto
		from #pro c with(nolock)
		inner join tcloficinas o with(nolock) on c.codoficina=o.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona	
		group by z.nombre,o.nomoficina
	) a
	left outer join (
		select o.nomoficina sucursal, count(codusuario) nro
		from tcsempleados e  with(nolock) inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
		where estado=1 and codpuesto=66
		group by o.nomoficina
	) e on e.sucursal=a.sucursal

	union
	select distinct 1 i,z.nombre region, o.nomoficina,0 sol_nro,0 sol_monto,0 cre_nro,0 cre_monto, 0 nro
	from tcloficinas o with(nolock)
	inner join tclzona z with(nolock) on z.zona=o.zona
	where o.tipo<>'Cerrada'
	and o.codoficina not in(99,98,97)

	union
	select a.*,e.nro
	from (
		select 99 i,z.nombre region,'Total' sucursal
		,count(case when proceso='solicitud' then codigo else null end) sol_nro
		,sum(case when proceso='solicitud' then monto else 0 end) sol_monto
		,count(case when proceso='credito' then codigo else null end) cre_nro
		,sum(case when proceso='credito' then monto else 0 end) cre_monto
		from #pro c with(nolock)
		inner join tcloficinas o with(nolock) on c.codoficina=o.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona	
		group by z.nombre	
	) a
	inner join (
		select z.nombre sucursal,count(codusuario) nro
		from tcsempleados e  with(nolock) inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
		inner join tclzona z with(nolock) on z.zona=o.zona	
		where estado=1 and codpuesto=66
		group by z.nombre
	) e on e.sucursal=a.region

) a
group by region,sucursal,i
order by region,i

select c.sec,c.region,c.sucursal,c.sol_nro,c.sol_monto,c.cre_nro,c.cre_monto,case when c.nro=0 then isnull(e.nro,0) else c.nro end nro
,case when c.region='' then 3 else (case when c.sucursal='Total' then 2 else c.sec%2 end) end par 
from @ca c
left outer join (
			select o.nomoficina sucursal, count(codusuario) nro
		from tcsempleados e  with(nolock) inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
		where estado=1 and codpuesto=66
		group by o.nomoficina
) e on c.sucursal=e.sucursal
order by sec

drop table #pro
GO