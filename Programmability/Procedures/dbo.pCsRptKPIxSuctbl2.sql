SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRptKPIxSuctbl2] @fecha smalldatetime, @codoficina varchar(5)
as   
set nocount on 

--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01' ---- fecha de inicio de mes


--declare @codoficina varchar(5)  
--set @codoficina = '309'

---BAJAS EN EL PERIODO ---
select e.codoficina,o.nomoficina nomoficina
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
and o.codoficina=@codoficina
group by  o.nomoficina, e.codoficina


if(select count(*) from #base with(nolock))<=0 
begin
	insert into #base values(@codoficina,'sucursal',0,0,0,0,0,0)
    select * from #base with(nolock)
end
else 
begin
	select * from #base with(nolock)
end


--select count(*) from #base with(nolock)

drop table #base
GO