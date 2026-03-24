SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* TABLA 14.TENDENCIA SALDO PROMEDIO  PYME 30K+  */

CREATE Procedure [dbo].[pCsCaReporteDiarioT14]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

/*PYME 30K+ */
select fecha,rango
,case when categoria='vencido90' then '3.VENCIDO 90+'
    when categoria='vigente0a30' then '1.VIGENTE 0-30'  
    when categoria='atraso31a89' then '2.ATRASADO 31-89'  ELSE '' 
end categoria
,saldo170,ISNULL(nroPtmos170,0)nroPtmos170,promSaldo_170,imor31_170
into #base
from FNMGConsolidado.dbo.tCaPromedioSaldo
where fecha=@fecha and rango in('h.30mil+','i.40mil+','j.50mil+','k.75mil+','l.100mil+','m.150mil+')
union
select fecha,rango,'4.TOTAL' categoria,sum(saldo170),sum(ISNULL(nroPtmos170,0)),sum(promSaldo_170),imor31_170
from FNMGConsolidado.dbo.tCaPromedioSaldo
where fecha=@fecha and rango in('h.30mil+','i.40mil+','j.50mil+','k.75mil+','l.100mil+','m.150mil+')
Group by fecha,rango,imor31_170

select fecha,rango,imor31_170,categoria,'Saldo Capital' detalle,saldo170 valor
from #base
union
select fecha,rango,imor31_170,categoria,'Ptmos' detalle,nroPtmos170 valor
from #base
union
select fecha,rango,imor31_170,categoria,'Saldo Promedio'detalle,promSaldo_170 valor
from #base


drop table #base

GO