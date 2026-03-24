SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*TENDENCIA DE SALDO CAPITAL-MISMO DIA */

  
CREATE procedure [dbo].[pCsRepTendenciaSaldoT4]  @fecha smalldatetime,@meses int  
as   
set nocount on  


--declare @fecha smalldatetime  ---LA FECHA DE CORTE  
--select @fecha='20220726'--fechaconsolidacion from vcsfechaconsolidacion 

--declare @meses int  
--set @meses=6      -- # de meses a mostrar 

declare @fechas table(fechas smalldatetime)
insert into @fechas values (@fecha)

declare @i int
set @i=1
while @i<=@meses
begin
	insert into @fechas values (DATEADD(month,-@i,@fecha))
	
	set @i=@i+1
end

--select * from @fechas

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
where fecfin  in(select FECHAS from @FECHAS)  
and region not in('Zona Cerradas','Zona Corporativo','Pro exito')  
GROUP BY fecfin  
,region,sucursal  

select  fecfin,region,sucursal,sum(VIGENTE0a30Ini) SaldoInicial,sum(VIGENTE0a30fin) SaldoFinal  
,sum(VIGENTE0a30fin-VIGENTE0a30Ini) variacion,'VIGENTE 0-30'categoria from #base with(nolock) group by fecfin,region,sucursal  
union  
select  fecfin,region,sucursal,sum(ATRASADO31a89Ini) SaldoInicial,sum(ATRASADO31a89fin) SaldoFinal  
,sum(ATRASADO31a89fin-ATRASADO31a89Ini) 
,'ATRASADO 31-89'categoria from #base with(nolock)  
group by fecfin,region,sucursal  
  union  
select  fecfin,region,sucursal,sum(VENCIDO90Ini) SaldoInicial,sum(VENCIDO90fin)  SaldoFinal  
,sum(VENCIDO90fin-VENCIDO90Ini)
,'VENCIDO 90+' categoria from #base with(nolock)  
group by fecfin,region,sucursal  
  
  
drop table #base
GO