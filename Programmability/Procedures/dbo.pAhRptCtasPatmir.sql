SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SP_HELPTEXT pAhRptCtasPatmir                  
--DROP PROC pAhRptCtasPatmir                  
--EXEC pAhRptCtasPatmir '2012-10-01','2012-10-31'    
CREATE PROCEDURE [dbo].[pAhRptCtasPatmir] (@FecIni SMALLDATETIME, @FecFin SMALLDATETIME)                  
    AS         
--DECLARE @FecIni SMALLDATETIME, @FecFin SMALLDATETIME    
 --SELECT @FecIni ='20121001', @FecFin = '20121031'

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
   
--select * from tcsahorros
--select * from tCsPadronAhorros where codusuario = 'AGA1011721'
delete #clientes where codusuario in (select distinct codusuario from tcspadroncarteradet with(nolock) where desembolso<@fecini)    
delete #clientes where codusuario in (select codusuario from tcstransacciondiaria with(nolock) where extornado=0 and codsistema='TC' and fecha<@fecini)    
    
SELECT c.CodUsuario, p.LocPatmir, case when d.elegible is null then '' else case when d.elegible = '0' then 'NO' else 'SI' end end Patmir    
  INTO #LocPatmir    
  FROM tcspadronclientes p with(nolock)     
 INNER JOIN #clientes c on c.CodUsuario = p.CodUsuario    
  LEFT OUTER JOIN tclUbigeoDGRV d with(nolock) ON p.LocPatmir = d.Localidad_Id    
    
SELECT DISTINCT CodOficina, NomOficina Sucursal, c.CodUsuario, CodCuenta, FraccionCta, Renovado,     
       SaldoCta, MonApertura, Garantia, isnull(FechaVencimiento,'') FechaVencimiento,    
       right(left(CodCuenta,5),1) AS Tipo,    
       CASE WHEN right(left(CodCuenta,5),1) = '1' THEN 'A LA VISTA' ELSE 'DPF' END AS DescTipo,    
       CASE WHEN MonApertura >= 500 THEN 'SI' ELSE 'NO' END AS AperturadoMayor500,    
       CASE WHEN SaldoCta    >= 500 THEN 'SI' ELSE 'NO' END AS SaldoCtaMayor500,    
       LocPatmir, Patmir, @FecIni FechaInicial, @FecFin FechaFinal     
  FROM #clientes c    
 INNER JOIN #LocPatmir l on c.CodUsuario = l.CodUsuario    
 ORDER BY NomOficina, c.CodUsuario    
  
  drop table #clientes    
  drop table #LocPatmir    
    
  
GO