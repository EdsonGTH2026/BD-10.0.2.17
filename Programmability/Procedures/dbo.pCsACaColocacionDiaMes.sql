SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure  [dbo].[pCsACaColocacionDiaMes] @fecfin smalldatetime
as
declare @fecini smalldatetime
--declare @fecfin smalldatetime
set @fecini='20170101'
--set @fecfin='20180829'

select dbo.fdufechaaperiodo(t.desembolso) periodo
,sum(monto) capital
,sum(case when day(t.desembolso)>=1 and day(t.desembolso)<=5 then monto else 0 end) rec_1a5
,(sum(case when day(t.desembolso)>=1 and day(t.desembolso)<=5 then monto else 0 end)/sum(monto))*100 por_1a5
,sum(case when day(t.desembolso)>=6 and day(t.desembolso)<=10 then monto else 0 end) rec_6a10
,(sum(case when day(t.desembolso)>=6 and day(t.desembolso)<=10 then monto else 0 end)/sum(monto))*100 por_6a10
,sum(case when day(t.desembolso)>=11 and day(t.desembolso)<=15 then monto else 0 end) rec_11a15
,(sum(case when day(t.desembolso)>=11 and day(t.desembolso)<=15 then monto else 0 end)/sum(monto))*100 por_11a15
,sum(case when day(t.desembolso)>=16 and day(t.desembolso)<=20 then monto else 0 end) rec_16a20
,(sum(case when day(t.desembolso)>=16 and day(t.desembolso)<=20 then monto else 0 end)/sum(monto))*100 por_16a20
,sum(case when day(t.desembolso)>=21 and day(t.desembolso)<=25 then monto else 0 end) rec_21a25
,(sum(case when day(t.desembolso)>=21 and day(t.desembolso)<=25 then monto else 0 end)/sum(monto))*100 por_21a25
,sum(case when day(t.desembolso)>=26 and day(t.desembolso)<=31 then monto else 0 end) rec_26a31
,(sum(case when day(t.desembolso)>=26 and day(t.desembolso)<=31 then monto else 0 end)/sum(monto))*100 por_26a31
from tcspadroncarteradet t with(nolock)
--inner join (select codprestamo, desembolso from tcspadroncarteradet with(nolock) group by codprestamo, desembolso) p on p.codprestamo=t.codigocuenta
where t.desembolso>=@fecini and t.desembolso<=@fecfin
group by dbo.fdufechaaperiodo(t.desembolso)
order by dbo.fdufechaaperiodo(t.desembolso)
--periodo	capital
--201801	32765841.54
--201802	28785121.59
--201803	30793552.01
--201805	32818913.15
--201804	32449479.27
--201806	31792374.79

GO

GRANT EXECUTE ON [dbo].[pCsACaColocacionDiaMes] TO [marista]
GO