SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dev_cchavezd].[pCs_gastoEPRC] @fecha smalldatetime      
as     
set nocount on  

--declare @fecha smalldatetime
--set @fecha='20220209'

declare @fecini smalldatetime
set @fecini =cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)--'20220201' -- inicio de mes

declare @fecante smalldatetime
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  -- '20220131'--fecha de termino del mes anterior

---EPRC - liquidados----- LIQUIDADOS
select codprestamo, PaseCastigado, Cancelacion
into #ptmosLiqui
from tcspadroncarteradet with(nolock)
where Cancelacion>= @fecini---'20220201' 
and Cancelacion <= @fecha--'20220209'  

select @fecha id,isnull(sum(r.eprc_total),0) EPRcancelacion
into #eprLiqui
from tcspadroncarteradet c with(nolock)
inner join tCsCarteraReserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.Cancelacion-1
where c.codprestamo in(select codprestamo from #ptmosLiqui)

---EPRC - Castigados ---
select codprestamo, PaseCastigado, Cancelacion
into #ptmosCastigados
from tcspadroncarteradet with(nolock)
where PaseCastigado>=@fecini--'20220201' 
and PaseCastigado<=@fecha-- '20220209' -- CASTIGADOS

select @fecha id,isnull(sum(r.eprc_total),0) EPRcastigo
into #eprCastiga
from tcspadroncarteradet c with(nolock)
inner join tCsCarteraReserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.PaseCastigado-1
where c.codprestamo in(select codprestamo from #ptmosCastigados)
---EPRC---
select @fecha id,r.fecha fecha,sum(r.eprc_total) eprc
into #p
from tCsCarteraReserva r with (nolock)
inner join tcscartera c with(nolock) on c.codprestamo=r.codprestamo and r.fecha=c.fecha
where r.fecha = @fecha--'20220209' --- FECHA DE CONSULTA
or r.fecha=@fecante--'20220131' -- fecha fin de mes anterior
group by r.fecha


create table #EPR (fechacorte smalldatetime,saldoini money,saldoFin money ,liqui money, castigado money)
--insert into #EPR 

select @fecha fecha
,sum(case when fecha=@fecha then eprc else 0 end) saldoFin
,sum(case when fecha=@fecante then eprc else 0 end) saldoIni
,(EPRcastigo)EPRcastigo 
,(EPRcancelacion)EPRcancelacion
from #eprLiqui l
left outer join #eprCastiga c on l.id=c.id
left outer join #p p on p.id=l.id
group by EPRcastigo,EPRcancelacion
--select * from #EPR



drop table  #eprLiqui
drop table #eprCastiga
drop table #EPR
drop table #p
drop table #ptmosLiqui
drop table #ptmosCastigados
GO