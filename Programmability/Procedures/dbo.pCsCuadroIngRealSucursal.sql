SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsCuadroIngRealSucursal '20180831'
CREATE procedure [dbo].[pCsCuadroIngRealSucursal] @fecfin datetime
as
--declare @fecfin datetime
--set @fecfin='20180831'
declare @fecini datetime
set @fecini= dbo.fdufechaaperiodo(@fecfin)+'01'

select distinct t.codigocuenta codprestamo,t.fecha fecha
into #pag
from tcstransacciondiaria t
where t.fecha>=@fecini and t.fecha<=@fecfin
and t.codsistema='CA' and t.tipotransacnivel3 in(104,105) and t.extornado=0
and t.codoficina<>'97'

--71,410
select p.*
,c.estado
,c.nrodiasatraso
into #cre
from #pag p
left outer join tcscartera c on p.codprestamo=c.codprestamo and p.fecha=c.fecha-1
--select * from #cre
select 
case when codoficinacuenta='150' then codoficinacuenta
		when codoficinacuenta='131' then '37'
		else 
		(case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end) 
	end codoficina
,o.nomoficina sucursal
,sum(montocapitaltran) capital
,sum(montointerestran) interes
--,sum(montoinpetran+montocargos) moratorios
--,sum(MontoOtrosTran) seguros
,sum(case when c.nrodiasatraso=0 then montocapitaltran else 0 end) capital_puntual
,sum(case when c.estado='VIGENTE' then montocapitaltran else 0 end) capital_vigente
,sum(case when c.estado='VENCIDO' then montocapitaltran else 0 end) capital_vencido
,sum(case when c.estado='CASTIGADO' then montocapitaltran else 0 end) capital_castigado
,sum(case when c.nrodiasatraso is null then montocapitaltran else 0 end) capital_adelantado

,sum(case when c.nrodiasatraso=0 then montointerestran else 0 end) interes_puntual
,sum(case when c.estado='VIGENTE' then montointerestran else 0 end) interes_vigente
,sum(case when c.estado='VENCIDO' then montointerestran else 0 end) interes_vencido
,sum(case when c.estado='CASTIGADO' then montointerestran else 0 end) interes_castigado
,sum(case when c.nrodiasatraso is null then montointerestran else 0 end) interes_adelantado

--select t.fecha,t.codigocuenta,t.montointerestran,c.*
from tcstransacciondiaria t with(nolock)
left outer join #cre c on c.codprestamo=t.codigocuenta and c.fecha=t.fecha
inner join tcloficinas o with(nolock) on o.codoficina=(case when codoficinacuenta='150' then codoficinacuenta
			when codoficinacuenta='131' then '37'
			else 
			(case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end) 
		end)
where t.fecha>=@fecini and t.fecha<=@fecfin
and t.codsistema='CA' and t.tipotransacnivel3 in(104,105) and t.extornado=0
and t.codoficina<>'97'
--and t.codigocuenta not in(select codprestamo from #tca)
--and t.codigocuenta in(
----'003-170-06-00-00929',
--'003-170-06-00-00973'
--)
group by 
	case when codoficinacuenta='150' then codoficinacuenta
			when codoficinacuenta='131' then '37'
			else 
			(case when (cast(codoficinacuenta as int)<100 or cast(codoficinacuenta as int)>300) then codoficinacuenta else cast((cast(codoficinacuenta as int)+200) as varchar(4)) end) 
		end
,o.nomoficina


drop table #pag
drop table #cre
GO

GRANT EXECUTE ON [dbo].[pCsCuadroIngRealSucursal] TO [marista]
GO