SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptLiqReacPeriodoSucTodo] @codoficina varchar(2000)
as
set nocount on

--declare @codoficina varchar(500)
--set @codoficina='37'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

declare @fecfin smalldatetime
select @fecfin=fechaconsolidacion from vcsfechaconsolidacion

select dbo.fdufechaaperiodo(cancelacion) periodo
,count(codprestamo) nro
,sum(monto) monto
,count(case when estado='Renovado' then codprestamonuevo else null end) reno_nro
,sum(case when estado='Renovado' then nuevomonto else 0 end) reno_mnto

,count(case when estado='Reactivado' then codprestamonuevo else null end) Reac_nro
,sum(case when estado='Reactivado' then nuevomonto else 0 end) Reac_mnto

,count(case when estado='Sin Renovar' then codprestamo else null end) Pend_nro
,sum(case when estado='Sin Renovar' then monto else 0 end) Pend_mnto

--select *
from tCsACaLIQUI_RR
where codoficina in(select codigo from @sucursales)--codoficina=@codoficina 
--and atrasomaximo<=30
and dbo.fdufechaaperiodo(cancelacion)<>dbo.fdufechaaperiodo(@fecfin)
group by dbo.fdufechaaperiodo(cancelacion)
order by dbo.fdufechaaperiodo(cancelacion)

GO