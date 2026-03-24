SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/*TENDENCIA DE SALDO CAPITAL-MISMO DIA */

  
CREATE procedure [dbo].[pCsRepTendenciaSaldoT2]  @fecha smalldatetime,@meses int  
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
 
--select    
--fecfin  
--,region, sucursal  
--,sum(case when estadoinicial in ('VIGENTE 0-30') then capitalInicialFA else 0 end) VIGENTE0a30Ini   
--,sum(case when estadoinicial='ATRASADO 31-89' then capitalInicialFA else 0 end) ATRASADO31a89Ini   
--,sum(case when estadoinicial='VENCIDO 90+' then capitalInicialFA else 0 end) VENCIDO90Ini   
--,sum(case when estadoFinal in('VIGENTE 0-30')  then capitalFinFA else 0 end) VIGENTE0a30Fin   
--,sum(case when estadoFinal='ATRASADO 31-89' then capitalFinFA else 0 end )ATRASADO31a89Fin   
--,sum(case when estadoFinal='VENCIDO 90+' then capitalFinFA else 0 end) VENCIDO90Fin   
--into #base  
--FROM fnmgConsolidado.dbo.tCACubos1 with (nolock)  
--where fecfin  in(select fechas from @fechas)  
--and region not in('Zona Cerradas','Zona Corporativo','Pro exito')  
--GROUP BY fecfin  
--,region,sucursal  

select    
fecfin  
,z.nombre region, sucursal  
,sum(case when estadoinicial in ('VIGENTE 0-30') then capitalInicialFA else 0 end) VIGENTE0a30Ini   
,sum(case when estadoinicial='ATRASADO 31-89' then capitalInicialFA else 0 end) ATRASADO31a89Ini   
,sum(case when estadoinicial='VENCIDO 90+' then capitalInicialFA else 0 end) VENCIDO90Ini   
,sum(case when estadoFinal in('VIGENTE 0-30')  then capitalFinFA else 0 end) VIGENTE0a30Fin   
,sum(case when estadoFinal='ATRASADO 31-89' then capitalFinFA else 0 end )ATRASADO31a89Fin   
,sum(case when estadoFinal='VENCIDO 90+' then capitalFinFA else 0 end) VENCIDO90Fin   
into #base  
FROM fnmgConsolidado.dbo.tCACubos1 with (nolock) 
inner join tcloficinas o on o.nomoficina=sucursal and  tipo<>'Cerrada'
inner join tclzona z on z.zona=o.zona 
where fecfin  in(select fechas from @fechas)  
and region not in('Zona Cerradas','Zona Corporativo','Pro exito')  
GROUP BY fecfin  
,z.nombre,sucursal 


  /*SUCURSALES*/
select  fecfin,region,sucursal  
,sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini)SaldoInicial  
,sum(VIGENTE0a30Ini)VIGENTE0a30Ini
,sum(ATRASADO31a89Ini)ATRASADO31a89Ini
,sum(VENCIDO90Ini)VENCIDO90Ini
,case when sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini)=0 then 0
 else sum(ATRASADO31a89Ini+VENCIDO90Ini)/sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini)end *100 IMOR30Ini
,case when sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini) =0 then 0
 else sum(VENCIDO90Ini)/sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini) end *100  IMOR90Ini
,sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin) SaldoFinal  
,sum(VIGENTE0a30Fin)VIGENTE0a30Fin
,sum(ATRASADO31a89Fin)ATRASADO31a89Fin
,sum(VENCIDO90Fin)VENCIDO90Fin
,case when sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin)=0 then 0
 else sum(ATRASADO31a89Fin+VENCIDO90Fin)/sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin) end *100 IMOR30Fin
,case when sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin)=0 then 0
 else sum(VENCIDO90Fin)/sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin)  end *100 IMOR90Fin
,sum(VIGENTE0a30Fin-VIGENTE0a30Ini)varVigente
,sum(ATRASADO31a89Fin-ATRASADO31a89Ini) varAtrasado
,sum(VENCIDO90Fin-VENCIDO90Ini)varVencido
--,case when fecfin=@fecante then 1 else 0 end UltimoCorte
from #base
GROUP BY fecfin,region,sucursal  
/*REGIONES*/
union
select  fecfin, region,region sucursal  
,sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini)SaldoInicial  
,sum(VIGENTE0a30Ini)VIGENTE0a30Ini
,sum(ATRASADO31a89Ini)ATRASADO31a89Ini
,sum(VENCIDO90Ini)VENCIDO90Ini
,case when sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini)=0 then 0
 else sum(ATRASADO31a89Ini+VENCIDO90Ini)/sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini)end *100 IMOR30Ini
,case when sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini) =0 then 0
 else sum(VENCIDO90Ini)/sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini) end *100  IMOR90Ini
,sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin) SaldoFinal  
,sum(VIGENTE0a30Fin)VIGENTE0a30Fin
,sum(ATRASADO31a89Fin)ATRASADO31a89Fin
,sum(VENCIDO90Fin)VENCIDO90Fin
,case when sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin)=0 then 0
 else sum(ATRASADO31a89Fin+VENCIDO90Fin)/sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin) end *100 IMOR30Fin
,case when sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin)=0 then 0
 else sum(VENCIDO90Fin)/sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin)  end *100 IMOR90Fin
,sum(VIGENTE0a30Fin-VIGENTE0a30Ini)varVigente
,sum(ATRASADO31a89Fin-ATRASADO31a89Ini) varAtrasado
,sum(VENCIDO90Fin-VENCIDO90Ini)varVencido
--,case when fecfin=@fecante then 1 else 0 end UltimoCorte

from #base
GROUP BY fecfin,region 
/*GENERAL*/
union
select  fecfin,'NACIONAL' region,'NACIONAL'sucursal  
,sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini)SaldoInicial  
,sum(VIGENTE0a30Ini)VIGENTE0a30Ini
,sum(ATRASADO31a89Ini)ATRASADO31a89Ini
,sum(VENCIDO90Ini)VENCIDO90Ini
,case when sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini)=0 then 0
 else sum(ATRASADO31a89Ini+VENCIDO90Ini)/sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini)end *100 IMOR30Ini
,case when sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini) =0 then 0
 else sum(VENCIDO90Ini)/sum(VIGENTE0a30Ini + ATRASADO31a89Ini+ VENCIDO90Ini) end *100  IMOR90Ini
,sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin) SaldoFinal  
,sum(VIGENTE0a30Fin)VIGENTE0a30Fin
,sum(ATRASADO31a89Fin)ATRASADO31a89Fin
,sum(VENCIDO90Fin)VENCIDO90Fin
,case when sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin)=0 then 0
 else sum(ATRASADO31a89Fin+VENCIDO90Fin)/sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin) end *100 IMOR30Fin
,case when sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin)=0 then 0
 else sum(VENCIDO90Fin)/sum(VIGENTE0a30Fin+ATRASADO31a89Fin+VENCIDO90Fin)  end *100 IMOR90Fin
,sum(VIGENTE0a30Fin-VIGENTE0a30Ini)varVigente
,sum(ATRASADO31a89Fin-ATRASADO31a89Ini) varAtrasado
,sum(VENCIDO90Fin-VENCIDO90Ini)varVencido
--,case when fecfin=@fecante then 1 else 0 end UltimoCorte
from #base
GROUP BY fecfin
  
  
  
drop table #base
GO