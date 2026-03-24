SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
  /*TENDENCIA DE SALDO CAPITAL IMOR 30 Y 90 */  
  
CREATE procedure [dbo].[pCsRepTendenciaSaldoT3]  @fecha smalldatetime,@meses int  
as   
set nocount on  
  
--declare @fecha smalldatetime  ---LA FECHA DE CORTE  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
--declare @meses int  
--set @meses= 2--mostrar el # de meses ingresado  


  
select    
fecfin  
,region, sucursal  
,SUM(capitalInicialFA) capitalIni  
,sum(case when estadoinicial in ('VIGENTE 0-30') then capitalInicialFA else 0 end) VIGENTE0a30Ini   
,sum(case when estadoinicial='ATRASADO 31-89' then capitalInicialFA else 0 end) ATRASADO31a89Ini   
,sum(case when estadoinicial='VENCIDO 90+' then capitalInicialFA else 0 end) VENCIDO90Ini   
,SUM(capitalFinFA) capitalFin  
,sum(case when estadoFinal in('VIGENTE 0-30')  then capitalFinFA else 0 end) VIGENTE0a30Fin   
,sum(case when estadoFinal='ATRASADO 31-89' then capitalFinFA else 0 end )ATRASADO31a89Fin   
,sum(case when estadoFinal='VENCIDO 90+' then capitalFinFA else 0 end) VENCIDO90Fin   
into #base  
FROM fnmgConsolidado.dbo.tCACubos1 with (nolock)  
where fecfin  in(select ultimodia from tclperiodo where ultimodia>=dateadd(month,-@meses,@fecha) and ultimodia<=@fecha  
union select @fecha)  
and region not in('Zona Cerradas','Zona Corporativo','Pro exito')  
GROUP BY fecfin  
,region,sucursal  

select  fecfin,region,sucursal
,sum(ATRASADO31a89Ini)+sum(VENCIDO90Ini)  cub30mInicial
,sum(ATRASADO31a89fin)+sum(VENCIDO90fin) cub30mfinal
,sum(VENCIDO90Ini)cub90mInicial
,sum(VENCIDO90fin)cub90mfinal
, sum(VIGENTE0a30Ini)+sum(ATRASADO31a89Ini)+sum(VENCIDO90Ini) saldoInicial
,sum(VIGENTE0a30fin)+sum(ATRASADO31a89fin)+sum(VENCIDO90fin) saldofinal
into #imor
from #base with(nolock)  
group by fecfin,region,sucursal  
  
select fecfin
,(sum(cub30mInicial)/sum(saldoInicial))*100 imor30Ini
,(sum(cub30mfinal)/sum(saldofinal))*100 imor30Fin
,(sum(cub90mInicial)/sum(saldoInicial))*100 imor90Ini
,(sum(cub90mfinal)/sum(saldofinal))*100  imor90Fin
from #imor
group by fecfin
  
 drop table #imor 
drop table #base
GO