SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* TABLA 13.TENDENCIA SALDO PROMEDIO   */

CREATE Procedure [dbo].[pCsCaReporteDiarioT13]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

select fecha,rango
,case when categoria='vencido90' then '3.VENCIDO 90+'
    when categoria='vigente0a30' then '1.VIGENTE 0-30'  
    when categoria='atraso31a89' then '2.ATRASADO 31-89'  ELSE '' 
end categoria
,saldoCtera,ptmosCtera,promSaldo_Ctera,imor31
into #base
from FNMGConsolidado.dbo.tCaPromedioSaldo
where fecha=@fecha
union
select fecha,rango,'TOTAL' categoria,sum(saldoCtera),sum(ptmosCtera),sum(promSaldo_Ctera),imor31
from FNMGConsolidado.dbo.tCaPromedioSaldo
where fecha=@fecha
Group by fecha,rango,imor31



select fecha,rango,imor31,categoria,'Saldo Capital' detalle,saldoCtera valor
from #base
union
select fecha,rango,imor31,categoria,'Ptmos' detalle,ptmosCtera valor
from #base
union
select fecha,rango,imor31,categoria,'Saldo Promedio'detalle,promSaldo_Ctera valor
from #base

drop table #base
GO