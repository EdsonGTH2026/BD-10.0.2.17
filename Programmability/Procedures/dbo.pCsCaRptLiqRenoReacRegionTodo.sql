SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptLiqRenoReacRegionTodo] @codoficina varchar(2000)
as
set nocount on

--declare @codoficina varchar(500)
--set @codoficina='37'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

declare @fecfin smalldatetime
declare @fecini smalldatetime

select @fecfin=fechaconsolidacion from vcsfechaconsolidacion
set @fecini=dbo.fdufechaaperiodo(@fecfin)+'01'

select z.nombre region
,count(codprestamo) nro
,sum(monto) monto
,count(case when estado='Renovado' then codprestamonuevo else null end) reno_nro
,sum(case when estado='Renovado' then nuevomonto else 0 end) reno_mnto

,count(case when estado='En proceso' then codprestamonuevo else null end) pane_nro
,sum(case when estado='En proceso' then nuevomonto else 0 end) pane_mnto

,count(case when estado='Sin Renovar' then codprestamo else null end) Pend_nro
,sum(case when estado='Sin Renovar' then monto else 0 end) Pend_mnto

,count(case when estado='Reactivado' then codprestamonuevo else null end) Reac_nro
,sum(case when estado='Reactivado' then nuevomonto else 0 end) Reac_mnto
--select *
from tCsACaLIQUI_RR l
inner join tcloficinas o with(nolock) on o.codoficina=l.codoficina
inner join tclzona z with(nolock) on z.zona=o.zona
where l.codoficina in(select codigo from @sucursales) --codoficina=@codoficina 
--and atrasomaximo<=30 --> TODO
and cancelacion>=@fecini and cancelacion<=@fecfin
group by z.nombre

GO