SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/* TABLA 16.TENDENCIA SALDO PROMEDIO PRODUCTIVO  */

CREATE Procedure [dbo].[pCsCaReporteDiarioT16]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

/*consumo*/
select fecha,rango
,case when categoria='vencido90' then '3.VENCIDO 90+'
    when categoria='vigente0a30' then '1.VIGENTE 0-30'  
    when categoria='atraso31a89' then '2.ATRASADO 31-89'  ELSE '' 
end categoria
,saldo370,nroPtmos370,promSaldo_370,imor31_370
into #base
from FNMGConsolidado.dbo.tCaPromedioSaldo
where fecha=@fecha
union
select fecha,rango,'4.TOTAL' categoria,sum(saldo370),sum(nroPtmos370),sum(promSaldo_370),imor31_370
from FNMGConsolidado.dbo.tCaPromedioSaldo
where fecha=@fecha
Group by fecha,rango,imor31_370

delete #base
where isnull(saldo370,0)=0 and   isnull(nroptmos370,0)=0 


select fecha,rango,imor31_370,categoria,'Saldo Capital' detalle,isnull(saldo370,0) valor
from #base
union
select fecha,rango,imor31_370,categoria,'Ptmos' detalle,isnull(nroPtmos370,0) valor
from #base
union
select fecha,rango,imor31_370,categoria,'Saldo Promedio'detalle,promSaldo_370 valor
from #base


drop table #base
GO