SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptKPIregionaltbl1] @fecha smalldatetime, @zona varchar(5)
as   
set nocount on 

--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes


--declare @zona varchar(5)  
--set @zona = 'z11'

---BAJAS EN EL PERIODO ---
select e.codoficina,o.nomoficina nomoficina,o.zona
,sum(case when (datediff(day,e.Ingreso, e.Salida)/30)>=0 and (datediff(day,e.Ingreso, e.Salida)/30)<3 then 1 else 0 end) mes0a3B
,sum(case when (datediff(day,e.Ingreso, e.Salida)/30)>=3 and (datediff(day,e.Ingreso, e.Salida)/30)<6 then 1 else 0 end) mes3a6B
,sum(case when (datediff(day,e.Ingreso, e.Salida)/30)>=6 and (datediff(day,e.Ingreso, e.Salida)/30)<9 then 1 else 0 end) mes6a9B
,sum(case when (datediff(day,e.Ingreso, e.Salida)/30)>=9 and (datediff(day,e.Ingreso, e.Salida)/30)<12 then 1 else 0 end) mes9a12B
,sum(case when (datediff(day,e.Ingreso, e.Salida)/30)>=12 then 1 else 0 end) mes12
,count(*)totSucursal
into #base
from tCsempleados e with (nolock)
left outer join tcloficinas o on o.codoficina=e.codoficina 
where salida >=@fecini and salida <=@fecha 
and e.CodPuesto ='66'
and o.zona=@zona
group by  o.zona, e.codoficina,o.nomoficina


select codoficina,nomoficina,zona 
into #office
from tcloficinas with(nolock)
where tipo<>'cerrada' and zona=@zona

select 	codoficina,nomoficina,zona
,sum(mes0a3B)mes0a3B,sum(mes3a6B)mes3a6B,sum(mes6a9B)mes6a9B,sum(mes9a12B)mes9a12B,sum(mes12)mes12,sum(totSucursal)totSucursal
from (
	select 1 x,
	codoficina,nomoficina,zona
	,mes0a3B,mes3a6B,mes6a9B,mes9a12B,mes12,totSucursal
	from #base
	union
    select 2 x,
	codoficina,nomoficina,zona,0 mes0a3B,0 mes3a6B,0 mes6a9B,0 mes9a12B,0 mes12,0 totSucursal
	from #office
	union
	select 3 x,
	'Total','Total',zona
    ,sum(mes0a3B)mes0a3B,sum(mes3a6B)mes3a6B,sum(mes6a9B)mes6a9B,sum(mes9a12B)mes9a12B,sum(mes12)mes12,sum(totSucursal)totSucursal
	from #base
	Group by zona
	)a
group by codoficina,nomoficina,zona


drop table #base
drop table #office
GO