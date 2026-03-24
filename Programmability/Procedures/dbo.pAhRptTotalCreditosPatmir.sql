SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SP_HELPTEXT pAhRptTotalCreditosPatmir                    
--DROP PROC pAhRptTotalCreditosPatmir                    
--EXEC pAhRptTotalCreditosPatmir '2012-11-01','2012-11-30'      
CREATE PROCEDURE [dbo].[pAhRptTotalCreditosPatmir] (@FecIni SMALLDATETIME, @FecFin SMALLDATETIME)                    
    AS           
      
CREATE TABLE #clientes       
     ( codusuario   varchar(15),      
       codcuenta    varchar(25),      
       FraccionCta  varchar(25),      
       Renovado     tinyint,      
       codoficina   varchar(4),      
       saldocta     decimal(16,2),      
       monapertura  decimal(16,2),      
       garantia     decimal(16,2),      
       FechaVencimiento DATETIME ,      
       NomOficina   VARCHAR(25)  )      
      
INSERT INTO #clientes      
SELECT ah.codusuario,ah.codcuenta,ah.fraccioncta,ah.renovado,ah.codoficina,ah.saldocuenta,pa.monapertura,    
       case ah.idestadocta when 'CB' then ah.montobloqueado when 'CP' then ah.saldocuenta else 0 end Garantia,    
       ah.FechaVencimiento, o.nomoficina    
  FROM tcsahorros ah with(nolock) 
 INNER JOIN tCsPadronAhorros pa with(nolock) ON ah.fecha=pa.fechacorte AND ah.codcuenta=pa.codcuenta AND ah.FraccionCta=pa.FraccionCta AND ah.renovado=pa.renovado       
 INNER JOIN tcloficinas o with(nolock) ON o.codoficina=pa.codoficina    
 WHERE ah.FechaApertura>=@fecini     
   AND ah.FechaApertura<=@fecfin    
   AND ah.idEstadoCta <> 'CC'  
   AND ah.codoficina  <> '98'   
   AND ah.codusuario NOT IN (select distinct codusuario from tcspadronahorros with(nolock) where fecapertura<@fecini)     
      
delete #clientes where codusuario in (select distinct codusuario from tcspadroncarteradet with(nolock) where desembolso<@fecini)      
delete #clientes where codusuario in (select codusuario from tcstransacciondiaria with(nolock) where extornado=0 and codsistema='TC' and fecha<@fecini)      
      
SELECT c.codoficina, c.nomoficina Sucursal,cd.codusuario, cd.codprestamo,      
 cast(year(ca.FechaDesembolso)as char(4)) +'/'+ replicate('0',2-len(cast(month(ca.FechaDesembolso)as varchar(2)))) + cast(month(ca.FechaDesembolso) as varchar(2))       
 +'/'+ replicate('0',2-len(cast(day(ca.FechaDesembolso)as varchar(2)))) + cast(day(ca.FechaDesembolso) as varchar(2)) Fechaapertura,      
 case when ca.fechavencimiento is null then '' else       
 cast(year(ca.Fechavencimiento)as char(4)) +'/'+ replicate('0',2-len(cast(month(ca.Fechavencimiento)as varchar(2)))) + cast(month(ca.Fechavencimiento) as varchar(2))       
 +'/'+ replicate('0',2-len(cast(day(ca.Fechavencimiento)as varchar(2)))) + cast(day(ca.Fechavencimiento) as varchar(2)) end Fechavencimiento,      
 cd.fecha FechaCierre, cd.saldocapital saldocuenta, case when cd.saldocapital >= 500 then 'SI' else 'NO' end SaldoMayor500,      
        cl.LocPatmir, case when d.elegible is null then '' else case when d.elegible = '0' then 'NO' else 'SI' end end Patmir      
   INTO #clientesT      
   FROM tcscarteradet cd with(nolock)       
  INNER JOIN #clientes c on c.codusuario=cd.codusuario       
  INNER JOIN tcscartera ca with(nolock) on ca.codprestamo=cd.codprestamo and ca.fecha=cd.fecha      
  INNER JOIN tcspadronclientes cl with(nolock) on cl.codusuario=ca.codusuario      
   LEFT OUTER JOIN tclUbigeoDGRV d with(nolock) ON cl.LocPatmir = d.Localidad_Id      
  WHERE cd.fecha = @fecfin      
  ORDER BY c.nomoficina, c.codusuario      
        
--RESUMEN      
SELECT DISTINCT c.codoficina, c.Sucursal,       
       SUM(c.saldocuenta)   AS SaldoCuentas,      
       COUNT(c.codprestamo) AS NumCreditos,      
       (Select COUNT(*)       
          From #clientesT c2      
         Where c.codoficina  = c2.codoficina      
           And c2.saldocuenta>='500') AS CtasSaldoCierreMayor500,      
       (Select COUNT(*)       
          From #clientesT c2      
         Where c.codoficina  = c2.codoficina      
           And c2.saldocuenta>='500' and Patmir = 'SI') AS CredPatmirMay500,      
       (Select COUNT(*)       
          From #clientesT c2      
         Where c.codoficina  = c2.codoficina) AS TotalCtes,      
       (Select COUNT(*)       
          From #clientesT c2      
         Where c.codoficina  = c2.codoficina      
           And Patmir = 'SI') AS TotalCtesLocPatmir,      
       (Select COUNT(*)       
          From #clientesT c2      
         Where c.codoficina  = c2.codoficina      
           And Patmir <> 'SI') AS TotalCtesNoPatmir,      
       @FecIni FechaInicial, @FecFin FechaFinal      
  FROM #clientesT c      
 GROUP BY c.codoficina, c.Sucursal      
 ORDER BY c.Sucursal      
      
  drop table #clientes      
  drop table #clientesT 
GO