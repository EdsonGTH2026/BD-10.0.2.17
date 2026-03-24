SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pXaProcesoSolColDelDiaxPro
CREATE procedure [dbo].[pXaProcesoSolColDelDiaxPro]
as
create table #pro (proceso varchar(10),codigo varchar(25),codoficina varchar(5),monto money, codasesor varchar(25))
insert into #pro (proceso,codigo,codoficina,monto,codasesor)
exec [10.0.2.14].finmas.dbo.pXaProcesoSolColDelDiaxPro

declare @ca table (sec int identity(1,1), region varchar(100), sucursal varchar(200),promotor varchar(200), sol_nro int, sol_monto money, cre_nro int, cre_monto money, nro int)
insert into @ca (region,sucursal,promotor,sol_nro,sol_monto,cre_nro,cre_monto)--,nro
select region,sucursal,promotor,sum(sol_nro) sol_nro, sum(sol_monto) sol_monto,sum(cre_nro) cre_nro,sum(cre_monto) cre_monto--,sum(nro) nro
from (
	select a.*--,b.nro
	from (
		select 0 i,'' region,'Total' sucursal,'' promotor
		,count(case when proceso='solicitud' then codigo else null end) sol_nro
		,sum(case when proceso='solicitud' then monto else 0 end) sol_monto
		,count(case when proceso='credito' then codigo else null end) cre_nro
		,sum(case when proceso='credito' then monto else 0 end) cre_monto
		from #pro c with(nolock)
		inner join tcloficinas o with(nolock) on c.codoficina=o.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona
	) a 
	--cross join 
	--(select count(codusuario) nro
	--	from tcsempleados e  with(nolock) inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
	--	where estado=1 and codpuesto=66
	--	) b

	union
	select a.*--,isnull(e.nro,0) nro
	from (
		select 1 i,z.nombre region,o.nomoficina sucursal,pr.nombrecompleto promotor
		,count(case when proceso='solicitud' then codigo else null end) sol_nro
		,sum(case when proceso='solicitud' then monto else 0 end) sol_monto
		,count(case when proceso='credito' then codigo else null end) cre_nro
		,sum(case when proceso='credito' then monto else 0 end) cre_monto
		from #pro c with(nolock)
		inner join tcloficinas o with(nolock) on c.codoficina=o.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona
		left outer join tcspadronclientes pr with(nolock) on pr.codorigen=c.codasesor
		group by z.nombre,o.nomoficina,pr.nombrecompleto
	) a
	--left outer join (
	--	select o.nomoficina sucursal, count(codusuario) nro
	--	from tcsempleados e  with(nolock) inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
	--	where estado=1 and codpuesto=66
	--	group by o.nomoficina
	--) e on e.sucursal=a.sucursal

	--union
	--select distinct 1 i,z.nombre region, o.nomoficina sucursal,'' promotor,0 sol_nro,0 sol_monto,0 cre_nro,0 cre_monto, 0 nro
	--from tcloficinas o with(nolock)
	--inner join tclzona z with(nolock) on z.zona=o.zona
	--where o.tipo<>'Cerrada'
	--and o.codoficina not in(99,98,97)

	union
	select a.*--,e.nro
	from (
		select 3 i,z.nombre region,'zTotal' sucursal,'' promotor
		,count(case when proceso='solicitud' then codigo else null end) sol_nro
		,sum(case when proceso='solicitud' then monto else 0 end) sol_monto
		,count(case when proceso='credito' then codigo else null end) cre_nro
		,sum(case when proceso='credito' then monto else 0 end) cre_monto
		from #pro c with(nolock)
		inner join tcloficinas o with(nolock) on c.codoficina=o.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona	
		group by z.nombre
	) a
	--inner join (
	--	select z.nombre sucursal,count(codusuario) nro
	--	from tcsempleados e  with(nolock) inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
	--	inner join tclzona z with(nolock) on z.zona=o.zona	
	--	where estado=1 and codpuesto=66
	--	group by z.nombre
	--) e on e.sucursal=a.region

	union
	select a.*--,e.nro
	from (
		select 2 i,z.nombre region,o.nomoficina sucursal,'Total' promotor
		,count(case when proceso='solicitud' then codigo else null end) sol_nro
		,sum(case when proceso='solicitud' then monto else 0 end) sol_monto
		,count(case when proceso='credito' then codigo else null end) cre_nro
		,sum(case when proceso='credito' then monto else 0 end) cre_monto
		from #pro c with(nolock)
		inner join tcloficinas o with(nolock) on c.codoficina=o.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona	
		group by z.nombre,o.nomoficina
	) a

) a
group by region,sucursal,i,promotor
order by region,sucursal,i

declare @tbl table (sec int, region varchar(100), sucursal varchar(200),promotor varchar(200), sol_nro int, sol_monto money, cre_nro int, cre_monto money)
insert into @tbl
select c.sec,c.region,c.sucursal,c.promotor,c.sol_nro,c.sol_monto,c.cre_nro,c.cre_monto
from @ca c
union
select distinct 5 i,z.nombre region, o.nomoficina sucursal,'' promotor,0 sol_nro,0 sol_monto,0 cre_nro,0 cre_monto
from tcloficinas o with(nolock)
inner join tclzona z with(nolock) on z.zona=o.zona	
where o.tipo<>'Cerrada'
and o.codoficina not in(99,98,97)
and o.nomoficina not in(select sucursal from @ca)
order by c.region,c.sucursal

--,case when c.nro=0 then isnull(e.nro,0) else c.nro end nro
--,case when c.region='' then 3 else (case when c.sucursal='Total' then 2 else c.sec%2 end) end par 

select c.*
,case when e.sucursal is null then 0 else e.nro end nro
from @tbl c
left outer join (
		select o.nomoficina sucursal, count(codusuario) nro
		from tcsempleados e  with(nolock) inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
		where estado=1 and codpuesto=66
		group by o.nomoficina
) e on c.sucursal=e.sucursal
union

select 0 sec,region,sucursal,promotor,0 sol_nro,0 sol_monto,0 cre_nro,0 cre_monto,1 nro
from (
	select o.nomoficina sucursal,z.nombre region,cl.nombrecompleto promotor
	from tcsempleados e  with(nolock) inner join tcloficinas o with(nolock) on o.codoficina=e.codoficinanom
	inner join tcspadronclientes cl with(nolock) on cl.codusuario=e.codusuario
	inner join tclzona z with(nolock) on z.zona=o.zona	
	where estado=1 and codpuesto=66
	group by o.nomoficina,z.nombre,cl.nombrecompleto
) a
where promotor not in(select promotor from @tbl)
order by c.region,c.sucursal,c.sec

--select 1
drop table #pro
GO

GRANT EXECUTE ON [dbo].[pXaProcesoSolColDelDiaxPro] TO [marista]
GO

GRANT EXECUTE ON [dbo].[pXaProcesoSolColDelDiaxPro] TO [ope_lvegav]
GO

GRANT EXECUTE ON [dbo].[pXaProcesoSolColDelDiaxPro] TO [ope_dalvarador]
GO