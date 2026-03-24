SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptRegSolicitudesPromotor] @codoficina varchar(100)
as

--declare @codoficina varchar(4)
--set @codoficina='37'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

Declare @Fecha SmallDateTime
Select @Fecha=FechaConsolidacion From vCsFechaConsolidacion
--set @Fecha='20190914'

Declare @Fecini SmallDateTime
set @Fecini=dateadd(day,(-1)*day(@Fecha),@Fecha)+1

create table #liqreno(codsolicitud varchar(25) not null,codoficina varchar(4),desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)
insert into #liqreno
select p.codsolicitud,p.codoficina,p.fechadesembolso,p.codusuario,max(a.cancelacion) cancelacion
from tCaASolicitudes p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.fechadesembolso
where p.codoficina in(select codigo from @sucursales)
group by p.codsolicitud,p.codoficina,p.fechadesembolso,p.codusuario
having max(a.cancelacion) is not null

select promotor
,sum(nro) total
,sum(case when tipo='Nuevo' then nro else 0 end) nuevo
,sum(case when tipo='Renovacion' then nro else 0 end) Renovacion
,sum(case when tipo='Reactivacion' then nro else 0 end) Reactivacion
,sum(T_App) T_App
,(sum(T_App)/sum(cast(nro as money)))*100 T_App_por
,sum(T_Finmas) T_Finmas
,(sum(T_Finmas)/sum(cast(nro as money)))*100 T_Finmas_por
from (
	select promotor,tipo,count(codsolicitud) nro
	,count(T_App) T_App
	,count(T_Finmas) T_Finmas
	from (
		select s.codsolicitud--,l.*
		,case when s.tiporegistro='APP' then s.codsolicitud else null end T_App
		,case when s.tiporegistro='FINMAS' then s.codsolicitud else null end T_Finmas
		--,case when s.fechasolicitud=@fecha then s.codsolicitud else null end RegDia
		, case when l.cancelacion is null then 'Nuevo' 
			   when l.cancelacion >= '20190901' and l.cancelacion<='20190930' then 'Renovacion' 
			   when l.cancelacion < '20190901'then 'Reactivacion' else '?' end Tipo
		, o.nomoficina sucursal 
		, z.Nombre region
		,case when e.codpuesto<>66 then 'HUERFANO'
		else
		case when e.codusuario is null then 'HUERFANO' else s.promotor end
		end Promotor
		from tCaASolicitudes s
		left outer join #liqreno l with(nolock) on l.codsolicitud=s.codsolicitud and l.codoficina=s.codoficina
		inner join tClOficinas o with(nolock) on o.codoficina=s.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona
		left outer join tCsEmpleadosFecha e with(nolock) on e.codusuario=s.codpromotor and fecha=@fecha
		where s.codoficina in(select codigo from @sucursales)
	) a
	group by promotor,tipo
) b
group by promotor

drop table #liqreno
GO