SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[BI_EvaluacionSemanal] as  
--CREATE PROCEDURE dbo.BI_EvaluacionSemanal as;    
--ALTER PROCEDURE dbo.BI_EvaluacionSemanal as;  
                            
declare @fechaactual smalldatetime, @FechaIniMes smalldatetime, @FechaIniSem smalldatetime                                    
select @fechaactual = fechaconsolidacion from vcsfechaconsolidacion                                    
--set @fechaactual = '20251116'                                  
--SELECT @fechaactual as FechaActual                                
                                    
SELECT @FechaIniMes= DATEADD(month, DATEDIFF(month, 0, @fechaactual), 0)                                      
                                
-- Si hoy es domingo, entonces tomamos la semana pasada completa (lunes a domingo)                                
-- Si hoy NO es domingo, tomamos el lunes de esta semana                                
--IF DATENAME(WEEKDAY, @fechaactual) IN ('Monday','Tuesday')                                
IF DATENAME(WEEKDAY, @fechaactual) IN ('Sunday')                             
BEGIN                                
    -- Obtener lunes de la semana pasada son (6 días antes del domingo)                                
    SET @FechaIniSem = DATEADD(DAY, -6 - DATEPART(WEEKDAY, @fechaactual), @fechaactual)+1;                                
END                                
ELSE                                
BEGIN                                
    -- Obtener lunes de esta semana (asumiendo semana inicia en lunes)                                
    SET @FechaIniSem = DATEADD(DAY, 1 - DATEPART(WEEKDAY, @fechaactual), @fechaactual)+1;                                
END;  
                                    
---SALIDAS EN LA SEMANA DE PROMOTORES DE MAS DE 3 MESES  
select e.CodOficina, o.NomOficina, COUNT(distinct(Paterno + ' ' + Materno + ' ' + Nombres)) Salidas                   
into #SALIDAS                                    
from tCsempleados e                                    
LEFT OUTER JOIN tcloficinas o with(nolock) on o.codoficina=e.CodOficina                                    
where e.Salida>= @fechainiMEs and e.Salida<=@fechaactual and e.CodPuesto = '66'                                    
AND  DATEDIFF(DAY, e.Ingreso, GETDATE()) >= 90 --ANTIGUEDAD MAYOR A 3 MESES                                    
and Paterno + ' ' + Materno + ' ' + Nombres not in (select PROMOTOR from FNMGCONSOLIDADO.DBO.TCACARTAPROMOTOR3APP where FECHACONSULTA = @fechaactual)                                    
group by e.CodOficina, o.NomOficina                                    
---------------------------------------------                                    
                                    
--RENOVACIONES                                    
                                    
select codpromotor, count(codprestamo) LIQ                                    
,sum(case when Estado = 'Renovado' and dateadd(day,day(cancelacion)*-1+1,cancelacion) = dateadd(day,day(nuevodesembolso)*-1+1,nuevodesembolso) then 1 else 0 end) RENOV                                    
,sum(Monto) MontoLIQ                                    
,sum(case when Estado = 'Renovado' and dateadd(day,day(cancelacion)*-1+1,cancelacion) = dateadd(day,day(nuevodesembolso)*-1+1,nuevodesembolso) then NuevoMonto else 0 end) MontoRENOV                                    
into #Renov                                    
from tCsACaLIQUI_RR                                     
where cancelacion >= @fechaIniMes and cancelacion <= @fechaactual                                    
and atrasomaximo <= 7 and codprestamo not in ('004-170-06-00-07877')                                    
group by codpromotor                                    
                                    
select sucursal, count(codprestamo) LIQ                                    
,sum(case when Estado = 'Renovado' and dateadd(day,day(cancelacion)*-1+1,cancelacion) = dateadd(day,day(nuevodesembolso)*-1+1,nuevodesembolso) then 1 else 0 end) RENOV                       
,sum(Monto) MontoLIQ                            
,sum(case when Estado = 'Renovado' and dateadd(day,day(cancelacion)*-1+1,cancelacion) = dateadd(day,day(nuevodesembolso)*-1+1,nuevodesembolso) then NuevoMonto else 0 end) MontoRENOV                                    
into #RenovSuc                                    
from tCsACaLIQUI_RR                           
where cancelacion >= @fechaIniMes and cancelacion <= @fechaactual                                    
and atrasomaximo <= 7 and codprestamo not in ('004-170-06-00-07877')                                    
group by sucursal                           
                
-- REN & LIQ < 30                
                
select codpromotor, count(codprestamo) LIQ                                    
,sum(case when Estado = 'Renovado' and dateadd(day,day(cancelacion)*-1+1,cancelacion) = dateadd(day,day(nuevodesembolso)*-1+1,nuevodesembolso) then 1 else 0 end) RENOV                                    
,sum(Monto) MontoLIQ                                    
,sum(case when Estado = 'Renovado' and dateadd(day,day(cancelacion)*-1+1,cancelacion) = dateadd(day,day(nuevodesembolso)*-1+1,nuevodesembolso) then NuevoMonto else 0 end) MontoRENOV                                    
into #Renov30                                   
from tCsACaLIQUI_RR                                     
where cancelacion >= @fechaIniMes and cancelacion <= @fechaactual                                    
and atrasomaximo <= 30 and codprestamo not in ('004-170-06-00-07877')                                    
group by codpromotor                                    
                                    
select sucursal, count(codprestamo) LIQ                                    
,sum(case when Estado = 'Renovado' and dateadd(day,day(cancelacion)*-1+1,cancelacion) = dateadd(day,day(nuevodesembolso)*-1+1,nuevodesembolso) then 1 else 0 end) RENOV                                    
,sum(Monto) MontoLIQ                                    
,sum(case when Estado = 'Renovado' and dateadd(day,day(cancelacion)*-1+1,cancelacion) = dateadd(day,day(nuevodesembolso)*-1+1,nuevodesembolso) then NuevoMonto else 0 end) MontoRENOV                                    
into #RenovSuc30                                    
from tCsACaLIQUI_RR                                     
where cancelacion >= @fechaIniMes and cancelacion <= @fechaactual                                    
and atrasomaximo <= 30 and codprestamo not in ('004-170-06-00-07877')                                    
group by sucursal                                                 
                                    
select '3-4-5' codprestamo, '20240101' Fecha                                    
into #Castigados                                    
                                    
select 'NA' sucursal, 'jkdshfs' codasesor, 5 nroCreditos, 10 SCCastigado                                    
into #SCCastigado                                    
                                   
--------------------------------------------------                                    
                                    
--COLOCACION                                    
                                    
select   
 j.NomOficina sucursal                                      
,p.monto MontoColocado                                      
,p.codprestamo Ptmos                                  
,p.Desembolso                                  
,case when c.codprestamo in (select codprestamo   
                             from FNMGConsolidado.dbo.tCaDesembAutoRenovacion   
                             where FechaDesembolso >= @fechainimes and FechaDesembolso <= @fechaactual) then 'Anticipado WA'                                      
      when p.TipoReprog = 'RENOV' then 'Anticipado'                                       
      when p.SecuenciaCliente =1 then 'Nuevo'                                      
      when DATEDIFF(MM,t.cancelacion,p.desembolso) >= 1 then 'Reactivado'                                       
   when t.cancelacion is null and p.SecuenciaCliente > 1 then 'Reactivado'                                      
      else t.estado end tipoCredito                                    
,c.codasesor  
,p.secuenciacliente Ciclo                                    
into #CreditosColocados                                    
from tcspadroncarteradet p with (nolock)                                      
inner join tcscartera c with (nolock) on c.CodPrestamo = p.CodPrestamo and c.Fecha =p.Desembolso                                      
inner join tcloficinas j with(nolock) on j.codoficina=p.codoficina                                      
left outer join tCsACaLIQUI_RR t on t.codprestamonuevo = p.CodPrestamo                                      
where p.desembolso>= @FechaIniMes and p.desembolso <= @fechaactual                                     
and p.codoficina not in('97','231','230','98','999')                                    
                                    
select sucursal , codasesor                                  
,sum(case when tipoCredito = 'Anticipado WA' then 1 else 0 end) AnticipadoWA                                    
,sum(case when tipoCredito = 'Anticipado' then 1 else 0 end) Anticipado                                    
,sum(case when tipoCredito = 'Nuevo' then 1 else 0 end) Nuevo                                    
,sum(case when tipoCredito = 'Reactivado' then 1 else 0 end) Reactivado                                    
,sum(case when tipoCredito = 'Renovado' then 1 else 0 end) Renovado                                    
,sum(case when tipoCredito = 'Anticipado WA' then MontoColocado else 0 end) MontoWA                                    
,sum(case when (tipoCredito = 'Anticipado' or tipoCredito = 'Anticipado WA') and Ciclo >= 4 then 1 else 0 end) Ant2mas                                    
into #Colocacion                                    
from #CreditosColocados                                    
group by sucursal, codasesor                                                 
        
        
-------------CAMPAÑA CREDITO 20, 40+ SEMANAL -----------------------------------        
SELECT         
    sucursal,        
    codasesor,        
    -- Créditos < 20k        
    SUM(CASE WHEN MontoColocado < 20000 THEN 1 ELSE 0 END) AS CreditosMenor20,        
    -- Créditos >= 20k y < 40k        
    SUM(CASE WHEN MontoColocado >= 20000 AND MontoColocado < 40000 THEN 1 ELSE 0 END) AS CreditosMayorIgual20,        
    -- Créditos >= 40k        
    SUM(CASE WHEN MontoColocado >= 40000 THEN 1 ELSE 0 END) AS CreditosMayorIgual40,        
        
    -- Total normal (sin ponderar)        
    COUNT(*) AS TotalCreditosSemana,        
        
    -- ⭐ TOTAL AJUSTADO SEGÚN CAMPAÑA ⭐        
    SUM(        
        CASE         
            WHEN MontoColocado >= 40000 THEN 3      -- vale 3 créditos        
            WHEN MontoColocado >= 20000 AND MontoColocado < 40000 THEN 2  -- vale 2 créditos        
            ELSE 1                                   -- (<20k) vale 1 crédito        
        END        
    ) AS TotalCreditosCampaña        
        
INTO #CreditosCampaña        
FROM #CreditosColocados        
WHERE TipoCredito = 'Nuevo'        
  AND Ciclo = 1        
  AND Desembolso >= @FechaIniSem        
  AND Desembolso <= @FechaActual        
GROUP BY sucursal, codasesor;        
--------------------------------------------------------------                                   
                                  
select sucursal, codasesor,                                  
       sum(case when tipoCredito = 'Nuevo' then 1 else 0 end) NuevoColUltSem,                       
       sum(case when tipoCredito = 'Reactivado' then 1 else 0 end) ReactivadoColUltSem                  
into #ColUltSem                                  
from #CreditosColocados                                  
WHERE desembolso>= @FechaIniSem and Desembolso <= @fechaactual                                     
group by sucursal, codasesor;                                  
                   
                             
                                
----------------------------------------------                                    
                                    
--Buckets Cartera                                    
                                    
select c.Codasesor                                    
,sum(case when c.nrodiasatraso = 0 then c.SaldoCapital else 0 end) SC0                                    
,sum(case when c.nrodiasatraso >= 1 and c.nrodiasatraso < 8 then c.SaldoCapital else 0 end) SC17                                    
,sum(case when c.nrodiasatraso >= 8 and c.nrodiasatraso < 16 then c.SaldoCapital else 0 end) SC815                                    
,sum(case when c.nrodiasatraso >= 16 and c.nrodiasatraso < 22 then c.SaldoCapital else 0 end) SC1621                                    
,sum(case when c.nrodiasatraso >= 22 and c.nrodiasatraso <= 30 then c.SaldoCapital else 0 end) SC2230                                    
,sum(case when c.nrodiasatraso <= 120 then c.SaldoCapital else 0 end) SC0120                                    
,sum(case when c.nrodiasatraso = 0 then 1 else 0 end) PTMOS0                                  
,sum(case when c.nrodiasatraso >= 1 and c.nrodiasatraso < 8 then 1 else 0 end) PTMOS17                 
,sum(case when c.nrodiasatraso >= 8 and c.nrodiasatraso < 16 then 1 else 0 end) PTMOS815                                    
,sum(case when c.nrodiasatraso >= 16 and c.nrodiasatraso < 22 then 1 else 0 end) PTMOS1621                                    
,sum(case when c.nrodiasatraso >= 22 and c.nrodiasatraso <= 30 then 1 else 0 end) PTMOS2230                          
,sum(case when c.nrodiasatraso <= 120 then 1 else 0 end) PTMOS0120                        
,sum(case when c.nrodiasatraso >= 31 then 1 else 0 end) PTMOS31                                    
into #Buckets                                    
from tCsCartera c                                    
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina                                          
where c.codoficina not in('97','98','231','230','999')                                           
and c.fecha = @fechaactual                                        
and c.cartera='ACTIVA'                                          
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))                                                                  
group by c.Codasesor           
                                    
select                         
    o.nomoficina sucursal,                                    
    sum(case when c.nrodiasatraso = 0 then c.SaldoCapital else 0 end) SC0,                                    
    sum(case when c.nrodiasatraso >= 1  and c.nrodiasatraso < 8  then c.SaldoCapital else 0 end) SC17,                                    
    sum(case when c.nrodiasatraso >= 8  and c.nrodiasatraso < 16 then c.SaldoCapital else 0 end) SC815,                                    
    sum(case when c.nrodiasatraso >= 16 and c.nrodiasatraso < 22 then c.SaldoCapital else 0 end) SC1621,                                    
    sum(case when c.nrodiasatraso >= 22 and c.nrodiasatraso <= 30 then c.SaldoCapital else 0 end) SC2230,                                    
    sum(case when c.nrodiasatraso <= 120 then c.SaldoCapital else 0 end) SC0120,                                    
                        
    sum(case when c.nrodiasatraso = 0 then 1 else 0 end) PTMOS0,                                    
    sum(case when c.nrodiasatraso >= 1  and c.nrodiasatraso < 8  then 1 else 0 end) PTMOS17,                                    
    sum(case when c.nrodiasatraso >= 8  and c.nrodiasatraso < 16 then 1 else 0 end) PTMOS815,                                    
    sum(case when c.nrodiasatraso >= 16 and c.nrodiasatraso < 22 then 1 else 0 end) PTMOS1621,                                    
    sum(case when c.nrodiasatraso >= 22 and c.nrodiasatraso <= 30 then 1 else 0 end) PTMOS2230,                   
    sum(case when c.nrodiasatraso <= 120 then 1 else 0 end) PTMOS0120,                         
    sum(case when c.nrodiasatraso >= 31 then 1 else 0 end) PTMOS31                        
                                   
into #BucketsSucursales                                    
from tCsCartera c                                    
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina                                          
where c.codoficina not in('97','98','231','230','999')                                           
and c.fecha = @fechaactual                                        
and c.cartera='ACTIVA'                                          
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))                                                                      
group by o.nomoficina                                    
                                    
------------                                    
                                    
select    
 a.FECHACONSULTA  
,a.CODASESOR  
,a.REGION  
,a.SUCURSAL  
,a.PROMOTOR                                     
,e.Celular                                    
,a.FECHA_INGRESO                                    
,a.CA_VTGE0A30_FIN CARTERAVIGACTUAL                                    
,a.MONTO_ASIG                                      
,a.MONTO_QUITAS                               
,a.PTMOS_ASIG                              
,a.PTMOS_QUITAS                              
,a.CA_VTGE0A30_INI CARTERAVIGINICIAL                       
,a.CART_VENCIDA_INI CARTERAVENINICIAL                                    
,a.CART_VENCIDA_FIN + a.SALDO_CASTIGADO CARTERAVENFINAL                                    
,a.CA_VTGE0A30_FIN +a.CART_VENCIDA_FIN + a.SALDO_CASTIGADO CarteraTotal                                    
,a.Cartera07                                    
,a.MONTO_NUEVOS                              
,a.MONTO_RENOV                                    
,a.MONTO_REACTIVACIONES                                    
,a.MOTO_COLOCACION_TOTAL MONTO_COLOCACION_TOTAL                                    
,a.PTMOS_VGTE_FIN                                    
,a.PTMOS_VGTE_INI                                    
,a.PROGRAMADO_S                                    
,a.MONTO_COBRADO                                                                     
into #CarteraProm                                    
from FNMGCONSOLIDADO.DBO.TCACARTAPROMOTOR3APP a                          
left outer join FNMGCONSOLIDADO.DBO.TCACARTAPROMOTOR3APP i on i.CODASESOR = a.CODASESOR and i.FECHACONSULTA = @FechaIniMes                                                                    
left outer join tCsempleados e on e.CodUsuario=a.CODASESOR                                    
where a.FechaConsulta = @fechaactual                                    
and a.SUCURSAL not in  ('UMAN','Lagos de Moreno')                                                                     
                                    
                                    
select distinct    
 a.FECHACONSULTA  
,a.REGION   
,a.SUCURSAL  
,'Gerente' GERENTE  
,@fechainiMes FECHA_INGRESO                                    
,a.CA_VTGE0A30_FIN CARTERAVIGACTUAL                                    
,0 MONTO_ASIG                                    
,0 MONTO_QUITAS                              
,0 PTMOS_ASIG                               
,0 PTMOS_QUITAS                               
,a.CA_VTGE0A30_INI CARTERAVIGINICIAL                                    
,a.CART_VENCIDA_INI CARTERAVENINICIAL                                    
,a.CART_VENCIDA_FIN + a.SALDO_CASTIGADO CARTERAVENFINAL                                    
,a.CA_VTGE0A30_FIN +a.CART_VENCIDA_FIN + a.SALDO_CASTIGADO CarteraTotal                                    
,a.Cartera07                                    
,a.MONTO_NUEVOS                                    
,a.MONTO_RENOV                                    
,a.MONTO_REACTIVACIONES                                    
,a.MOTO_COLOCACION_TOTAL MONTO_COLOCACION_TOTAL                                    
,a.PTMOS_VGTE_FIN                                    
,a.PTMOS_VGTE_INI                                    
,a.PROGRAMADO_S                                    
,a.MONTO_COBRADO                                                                   
into #CarteraSuc                                    
from FNMGConsolidado.dbo.tCaCartaGerente3APP a                                     
left outer join FNMGConsolidado.dbo.tCaCartaGerente3APP i on i.SUCURSAL = a.SUCURSAL and i.FECHACONSULTA = @FechaIniMes                                                                     
where a.FechaConsulta = @fechaactual                                                                    
and a.SUCURSAL not in  ('UMAN','Lagos de Moreno')                                    
                                    
SELECT DISTINCT                                    
'Promotor' Tipo                                    
,cp.FECHACONSULTA, cp.REGION                                    
,cp.SUCURSAL SUCURSAL                                    
,cp.PROMOTOR                                    
,cp.Celular                                    
,cp.FECHA_INGRESO                                    
,cp.CARTERAVIGACTUAL                                    
,cp.MONTO_ASIG                                    
,cp.MONTO_QUITAS                                
,cp.PTMOS_QUITAS                               
,cp.PTMOS_ASIG                               
,cp.CARTERAVIGINICIAL                                    
,cp.CARTERAVENINICIAL                              
,cp.CARTERAVENFINAL                                    
,isnull(b.SC0120,0) CarteraTotal                                    
,cp.Cartera07                                    
,cp.MONTO_NUEVOS                                    
,cp.MONTO_RENOV                                    
,cp.MONTO_REACTIVACIONES                                    
,cp.MONTO_COLOCACION_TOTAL                                    
,isnull(r.LIQ,0) LIQ                                    
,isnull(r.RENOV,0) RENOV                    
,isnull(rr.LIQ,0) LIQ30                                   
,isnull(rr.RENOV,0) RENOV30                   
,cp.PTMOS_VGTE_FIN                                    
,cp.PTMOS_VGTE_INI                                    
,cp.PROGRAMADO_S                                    
,cp.MONTO_COBRADO                                    
,isnull(c.SCCastigado,0) SCCastigado                                    
,isnull(col.Anticipado,0) Anticipado                                    
,isnull(col.AnticipadoWA,0) AnticipadoWA                                    
,isnull(col.MontoWA,0) MontoWA                                    
,isnull(col.Nuevo,0) Nuevo                                    
,isnull(col.Reactivado,0) Reactivado                                    
,isnull(col.Renovado,0) Renovado                                    
,isnull(colUlt.NuevoColUltSem,0) NuevoColUltSem                  
,isnull(colReacUlt.ReactivadoColUltSem,0) ReactivadoColUltSem           
,isnull(credCampaña.TotalCreditosCampaña,0) TotalCreditosCampaña        
,case when cp.REGION in ('Costa Chica','Costa Grande','Centro','Estado') then 'Centro'                                    
      when cp.REGION in ('Sur tizimin','Sur progreso') then 'Sur'                                    
      when cp.REGION in ('Tabasco - Chiapas','Veracruz Norte','Veracruz Sur') then 'Veracruz'                                    
      when cp.REGION in ('Bajio Norte','Bajio Occidente','Jalisco') then 'Bajio'                                    
      else cp.REGION end Division               
,0 Salidas                                    
,0 seismas                                    
,0 seismenos                  
,0 Ingresos                                    
,isnull(b.SC0,0) SC0                                    
,isnull(b.SC17,0) SC17                                    
,isnull(b.SC815,0) SC815                                    
,isnull(b.SC1621,0) SC1621                                    
,isnull(b.SC2230,0) SC2230                                    
,isnull(b.SC0120,0) SC0120                                    
,isnull(b.PTMOS0,0) PTMOS0                                    
,isnull(b.PTMOS17,0) PTMOS17                                    
,isnull(b.PTMOS815,0) PTMOS815                                    
,isnull(b.PTMOS1621,0) PTMOS1621                                    
,isnull(b.PTMOS2230,0) PTMOS2230                                    
,isnull(b.PTMOS0120,0) PTMOS0120                         
,isnull(b.PTMOS31,0) PTMOS31                         
,isnull(col.Ant2mas,0) Ant2mas              
,CASE           
    WHEN cp.CARTERAVIGINICIAL <= 300000 THEN 'Amatista'          
    WHEN cp.CARTERAVIGINICIAL > 300000 AND cp.CARTERAVIGINICIAL <= 1000000 THEN 'Esmeralda'          
    WHEN cp.CARTERAVIGINICIAL > 1000000 AND cp.CARTERAVIGINICIAL <= 2000000 THEN 'Zafiro'          
    WHEN cp.CARTERAVIGINICIAL > 2000000 THEN 'Diamante'          
    ELSE 'NA'          
END AS Nivel          
into #Promotores                                    
from #CarteraProm cp                              
left outer join #Renov r on r.codpromotor = cp.CODASESOR                
left outer join #Renov30 rr on rr.codpromotor = cp.CODASESOR                
left outer join #SCCastigado c on c.CodAsesor = cp.CODASESOR                                    
left outer join #Colocacion col on col.CodAsesor = cp.CODASESOR                                    
left outer join #ColUltSem colUlt on colUlt.CodAsesor = cp.CODASESOR                         
left outer join #ColUltSem colReacUlt on colReacUlt.CodAsesor = cp.CODASESOR              
left outer join #CreditosCampaña credCampaña on credCampaña.CodAsesor = cp.CODASESOR                
left outer join #Buckets b on b.CodAsesor = cp.CODASESOR           
                                    
select DISTINCT                              
'Sucursal' Tipo                                    
,cp.FECHACONSULTA                                    
,cp.REGION                                    
,cp.SUCURSAL                                    
,cp.GERENTE                                    
,'NA' Celular                                    
,cp.FECHA_INGRESO                                    
,cp.CARTERAVIGACTUAL                                    
,cp.MONTO_ASIG                             
,cp.MONTO_QUITAS                                  
,cp.PTMOS_QUITAS                               
,cp.PTMOS_ASIG                               
,cp.CARTERAVIGINICIAL                                    
,cp.CARTERAVENINICIAL                                    
,cp.CARTERAVENFINAL                                    
,isnull(b.SC0120,0) CarteraTotal                              
,cp.Cartera07                                    
,cp.MONTO_NUEVOS                                    
,cp.MONTO_RENOV                                    
,cp.MONTO_REACTIVACIONES                                    
,cp.MONTO_COLOCACION_TOTAL                                    
,isnull(r.LIQ,0) LIQ                                    
,isnull(r.RENOV,0) RENOV                
,isnull(rr.LIQ,0) LIQ30                                   
,isnull(rr.RENOV,0) RENOV30                  
,cp.PTMOS_VGTE_FIN                                    
,cp.PTMOS_VGTE_INI                  
,cp.PROGRAMADO_S                                    
,cp.MONTO_COBRADO                                    
,isnull(sc.SCCastigado,0) SCCastigado                                    
,isnull(col.Anticipado,0) Anticipado                                    
,isnull(col.AnticipadoWA,0) AnticipadoWA                                    
,isnull(col.MontoWA,0) MontoWA                                    
,isnull(col.Nuevo,0) Nuevo                                    
,isnull(col.Reactivado,0) Reactivado                                    
,isnull(col.Renovado,0) Renovado                                    
,isnull(colUlt.NuevoColUltSem,0) NuevoColUltSem                   
,isnull(colReacUlt.ReactivadoColUltSem,0) ReactivadoColUltSem              
,isnull(credCampaña.TotalCreditosCampaña,0) TotalCreditosCampaña        
,case when cp.REGION in ('Costa Chica','Costa Grande','Centro','Estado') then 'Centro'                                    
      when cp.REGION in ('Sur tizimin','Sur progreso') then 'Sur'                                    
      when cp.REGION in ('Tabasco - Chiapas','Veracruz Norte','Veracruz Sur') then 'Veracruz'                                    
      when cp.REGION in ('Bajio Norte','Bajio Occidente','Jalisco') then 'Bajio'                                    
      else cp.REGION end Division                                    
,isnull(sa.Salidas,0) Salidas                                    
,isnull(p.seismas,0) seismas                                    
,isnull(p.seismenos,0) seismenos                                    
,isnull(p.Ingresos,0) Ingresos                                    
,isnull(b.SC0,0) SC0                                    
,isnull(b.SC17,0) SC17                                    
,isnull(b.SC815,0) SC815                                    
,isnull(b.SC1621,0) SC1621                              
,isnull(b.SC2230,0) SC2230                                    
,isnull(b.SC0120,0) SC0120                                    
,isnull(b.PTMOS0,0) PTMOS0                                    
,isnull(b.PTMOS17,0) PTMOS17                                    
,isnull(b.PTMOS815,0) PTMOS815                                    
,isnull(b.PTMOS1621,0) PTMOS1621                                    
,isnull(b.PTMOS2230,0) PTMOS2230                          
,isnull(b.PTMOS0120,0) PTMOS0120                        
,isnull(b.PTMOS31,0) PTMOS31                                    
,isnull(col.Ant2mas,0) Ant2mas          
,'NA' Nivel          
into #Sucursales                                    
from #CarteraSuc cp                                    
left outer join (select NomOficina, sum(Salidas) Salidas from #SALIDAS group by NomOficina) sa on sa.NomOficina = cp.SUCURSAL                                    
left outer join (select sucursal, sum(LIQ) LIQ, sum(RENOV) RENOV from #RenovSuc group by sucursal) r on r.sucursal = cp.SUCURSAL                
left outer join (select sucursal, sum(LIQ) LIQ, sum(RENOV) RENOV from #RenovSuc30 group by sucursal) rr on rr.sucursal = cp.SUCURSAL                
left outer join (select sucursal, SUM(SCCastigado) SCCastigado from #SCCastigado group by sucursal ) sc on sc.sucursal = cp.SUCURSAL                                     
left outer join #BucketsSucursales b on b.sucursal = cp.SUCURSAL                                    
left outer join (select sucursal,sum(Renovado) Renovado,sum(Anticipado) Anticipado, sum(AnticipadoWA) AnticipadoWA, sum(MontoWA) MontoWA,sum(Nuevo) Nuevo, sum(Reactivado) Reactivado, sum(Ant2mas) Ant2mas from #Colocacion group by sucursal) col on col.sucursal = cp.SUCURSAL                                    
left outer join (select sucursal,sum(NuevoColUltSem) NuevoColUltSem from #ColUltSem group by sucursal) colUlt on colUlt.sucursal = cp.SUCURSAL                       
left outer join (select sucursal,sum(ReactivadoColUltSem) ReactivadoColUltSem from #ColUltSem group by sucursal) colReacUlt on colReacUlt.sucursal = cp.SUCURSAL          
left outer join (select sucursal,sum(TotalCreditosCampaña) TotalCreditosCampaña from #CreditosCampaña group by sucursal) credCampaña on credCampaña.sucursal = cp.SUCURSAL          
left outer join (                                    
select SUCURSAl                                    
,sum(case when datediff(month,FECHA_INGRESO,@fechaactual) >=6 then 1 else 0 end) 'seismas'                                    
,sum(case when datediff(month,FECHA_INGRESO,@fechaactual) < 6 then 1 else 0 end) 'seismenos'                                    
,sum(case when FECHA_INGRESO >= @FechaIniMes then 1 else 0 end) Ingresos                                    
from #Promotores                                                                 
group by SUCURSAL ) p on p.SUCURSAL = cp.SUCURSAL                                    
                       
select * from #Promotores   
  
Union all                                    
                                    
Select * from #Sucursales  
                                    
union all                                  
                     
select 'Region' Tipo                                    
,FECHACONSULTA                                    
,REGION                                    
,'NA' SUCURSAL                                    
,'Gerente' Gerente                                    
,'NA' Celular                                    
,@FechaIniMes Fecha_Ingreso                                    
,SUM(CARTERAVIGACTUAL) CARTERAVIGACTUAL                                    
,0 MONTO_ASIG                                    
,0 MONTO_QUITAS                                  
,0 PTMOS_ASIG                                    
,0 PTMOS_QUITAS                                
,SUM(CARTERAVIGINICIAL) CARTERAVIGINICIAL                                    
,sum(CARTERAVENINICIAL) CARTERAVENINICIAL                                    
,sum(CARTERAVENFINAL) CARTERAVENFINAL                                    
,sum(CarteraTotal) CarteraTotal                                    
,sum(Cartera07) Cartera07                                    
,sum(MONTO_NUEVOS) MONTO_NUEVOS                                    
,sum(MONTO_RENOV) MONTO_RENOV                                    
,sum(MONTO_REACTIVACIONES) MONTO_REACTIVACIONES                                    
,sum(MONTO_COLOCACION_TOTAL) MONTO_COLOCACION_TOTAL                                    
,sum(LIQ) LIQ                                    
,sum(RENOV) RENOV                  
,sum(LIQ30) LIQ30                                   
,sum(RENOV30) RENOV30                  
,sum(PTMOS_VGTE_FIN) PTMOS_VGTE_FIN                                    
,sum(PTMOS_VGTE_INI) PTMOS_VGTE_INI                                    
,sum(PROGRAMADO_S) PROGRAMADO_S               
,sum(MONTO_COBRADO) MONTO_COBRADO                                    
,sum(SCCastigado) SC_CASTIGADO                                    
,sum(Anticipado) Anticipado                                    
,sum(AnticipadoWA) AnticipadoWA                                    
,sum(MontoWA) MontoWA                                    
,sum(Nuevo) Nuevo                                    
,sum(Reactivado) Reactivado                                    
,sum(Renovado) Renovado                                  
,sum(NuevoColUltSem) NuevoColUltSem                          
,sum(ReactivadoColUltSem) ReactivadoColUltSem             
,sum(TotalCreditosCampaña) TotalCreditosCampaña        
,Division                                    
,sum(Salidas) Salidas                                    
,sum(seismas) seismas                                    
,sum(seismenos) seismenos                                    
,sum(Ingresos) Ingresos                                    
,sum(SC0) SC0                                    
,sum(SC17) SC17                                    
,sum(SC815) SC815                                    
,sum(SC1621) SC1621                          
,sum(SC2230) SC2230                                    
,sum(SC0120) SC0120                                    
,sum(PTMOS0) PTMOS0                                    
,sum(PTMOS17) PTMOS17                                    
,sum(PTMOS815) PTMOS815                                    
,sum(PTMOS1621) PTMOS1621                                    
,sum(PTMOS2230) PTMOS2230                          
,sum(PTMOS0120) PTMOS0120                         
,sum(PTMOS31) PTMOS31                                    
,sum(Ant2mas) Ant2mas               
,'NA' Nivel          
from #Sucursales                                    
where Sucursal not in ('AUTLAN',                                    
'Coatepec',                                    
'Emiliano Zapata',                                    
'PALENQUE',                                    
'Tecamac',                                    
'Tierra Blanca',                                    
'TIERRA COLORADA','CALKINI')                                    
group by FECHACONSULTA                                    
,REGION                                    
,Division                                    
                     
drop table #CarteraProm                                    
drop table #CarteraSuc                                    
drop table #Sucursales                                    
drop table #Promotores                                    
DROP TABLE #SALIDAS                                    
DROP TABLE #Renov                
DROP TABLE #Renov30          
DROP TABLE #RenovSuc30             
DROP TABLE #Castigados                                      
DROP TABLE #SCCastigado                                    
DROP TABLE #CreditosColocados                                    
DROP TABLE #Colocacion                                    
DROP TABLE #Buckets                                    
DROP TABLE #BucketsSucursales                                    
DROP TABLE #RenovSuc                                  
DROP TABLE #ColUltSem        
DROP TABLE #CreditosCampaña 
GO