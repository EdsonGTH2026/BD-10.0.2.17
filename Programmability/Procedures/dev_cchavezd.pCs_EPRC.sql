SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*CALCULO DEL EPRC A LA FECHA DE CORTE --2022*/

CREATE procedure [dev_cchavezd].[pCs_EPRC] @fecha smalldatetime      
as     
set nocount on  

--declare @fecha smalldatetime
--set @fecha='20220310'

declare @fecini smalldatetime
set @fecini =cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime) -- inicio de mes

declare @fecante smalldatetime
set @fecante= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1  --fecha de termino del mes anterior

---SALDO EPRC --- ptmos LIQUIDADOS
declare @eprLiqui table(fecha smalldatetime,EPRliquidado money)
insert into @eprLiqui
select @fecha fecha,isnull(sum(r.eprc_total),0) EPRliquidado
from tcspadroncarteradet c with(nolock)
inner join tCsCarteraReserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.Cancelacion-1
where Cancelacion>= @fecini --> ptmos liquidados 
and Cancelacion <= @fecha 


---SALDO EPRC ---- ptmos CASTIGADOS
declare @eprCastigado table (fecha smalldatetime,EPRcastigo money)
insert into @eprCastigado
select @fecha id,isnull(sum(r.eprc_total),0) EPRcastigo
from tcspadroncarteradet c with(nolock)
inner join tCsCarteraReserva r with (nolock) on c.codprestamo=r.codprestamo and r.fecha=c.PaseCastigado-1
where PaseCastigado>=@fecini -->ptmos castigados en el periodo evaluado
and PaseCastigado<=@fecha 

---EPRC al dia de consulta y al inicio del mes---
declare @eprc table (fecha smalldatetime,fech smalldatetime,eprc money)
insert into @eprc
select @fecha fecha,r.fecha fech,sum(r.eprc_total) eprc
from tCsCarteraReserva r with (nolock)
inner join tcscartera c with(nolock) on c.codprestamo=r.codprestamo and r.fecha=c.fecha
where r.fecha = @fecha --- FECHA DE CONSULTA
or r.fecha=@fecante -- fecha fin de mes anterior
group by r.fecha


select @fecha fecha
,sum(case when p.fech=@fecha then eprc else 0 end) saldoEPRCFin
,sum(case when p.fech=@fecante then eprc else 0 end) saldoEPRCIni
,(EPRcastigo)EPRCcastigo 
,(EPRliquidado)EPRCliquidado
,sum(case when p.fech=@fecha then eprc else 0 end)-sum(case when p.fech=@fecante then eprc else 0 end)
+EPRcastigo+EPRliquidado GastoEPRC
from @eprLiqui l
left outer join @eprCastigado c on l.fecha=c.fecha
left outer join @eprc p on p.fecha=l.fecha
group by EPRcastigo,EPRliquidado
GO