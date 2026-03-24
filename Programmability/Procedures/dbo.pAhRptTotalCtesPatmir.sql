SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SP_HELPTEXT pAhRptTotalCtesPatmir                  
--DROP PROC pAhRptTotalCtesPatmir                  
--EXEC pAhRptTotalCtesPatmir '2012-10-01','2012-10-31'    
CREATE PROCEDURE [dbo].[pAhRptTotalCtesPatmir] (@FecIni SMALLDATETIME, @FecFin SMALLDATETIME)                  
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
       Sucursal         varchar(25) )    
    
--drop table #clientes    
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
    
--DATOS CLIENTES AHORRO Y CRÉDITOS    
--drop table #cteubigeo    
SELECT DISTINCT c.codorigen, cl.Sucursal,u.codubigeo, c.codusuario,    
 --fechanacimiento    
 cast(year(Fechanacimiento)as char(4)) +'/'+ replicate('0',2-len(cast(month(Fechanacimiento)as varchar(2)))) + cast(month(Fechanacimiento) as varchar(2)) +'/'+ replicate('0',2-len(cast(day(Fechanacimiento)as varchar(2)))) + cast(day(Fechanacimiento) as varchar(2)) Fecha_nacimiento,    
 case when paterno is null then materno when paterno='' then materno else paterno end paterno,--isnull(paterno,materno) paterno,    
 case when paterno is null then '' when paterno='' then '' else materno end materno,--isnull(paterno,'') materno,    
 nombre1,isnull(nombre2,'') nombre2,'0' tipopersona,    
 --,fechaingreso    
 cast(year(fechaingreso)as char(4)) +'/'+ replicate('0',2-len(cast(month(fechaingreso)as varchar(2)))) + cast(month(fechaingreso) as varchar(2)) +'/'+ replicate('0',2-len(cast(day(fechaingreso)as varchar(2)))) + cast(day(fechaingreso) as varchar(2)) Fecha_inscripcion,    
 case when sexo=0 then 'M' else 'F' end sexo, isnull(direcciondirfampri,direcciondirnegpri) direccion,    
 isnull(numextfam,numextneg) numero, u.descubigeo colonia, isnull(c.codpostalfam,c.codpostalneg) codpostal,    
 c.LocPatmir  as Clave_Localidad,     
 cl.codoficina, cl.saldocta,    
 case when d.elegible is not null then case when d.elegible = 0 then 'NO' else 'SI' end else '' end as ZonaPatmir    
 INTO #cteubigeo    
 FROM tcspadronclientes c with(nolock)     
 LEFT OUTER JOIN tclubigeo     u with(nolock) ON u.codubigeo=isnull(codubigeodirfampri,codubigeodirnegpri)    
 LEFT OUTER JOIN tclUbigeoDGRV d with(nolock) ON c.LocPatmir = d.Localidad_Id    
INNER JOIN (Select codusuario, codoficina, Sucursal, sum(saldocta) saldocta From #clientes Group By codusuario, codoficina, Sucursal) cl ON cl.codusuario=c.codusuario    
WHERE c.codusuario in (Select codusuario From #clientes)     
  AND c.CodTPersona='01'     
--drop table #cteubigeo    
    
--SELECT * FROM #cteubigeo WHERE Clave_Localidad = '' OR Clave_Localidad IS NULL    
    
    
--select * from #cteubigeo    
SELECT DISTINCT c.CodOficina, c.Sucursal,     
       (Select distinct count(*) From #cteubigeo c2 Where c.CodOficina = c2.CodOficina) TotalClientes,    
       (Select distinct count(*) From #cteubigeo c2 Where c.CodOficina = c2.CodOficina And c2.ZonaPatmir = 'SI') TotalCtesPatmir,    
       (Select distinct count(*) From #cteubigeo c2 Where c.CodOficina = c2.CodOficina And c2.ZonaPatmir = 'NO') TotalCtesNoPatmir,    
       (Select distinct count(*) From #cteubigeo c2 Where c.CodOficina = c2.CodOficina And (c2.ZonaPatmir IS NULL OR c2.ZonaPatmir = '')) TotalCtesSinLocPatmir,    
       @FecIni FechaInicial, @FecFin FechaFinal    
  FROM #cteubigeo c    
 ORDER BY c.CodOficina--c.NomOficina    
    
  DROP TABLE #clientes    
  DROP TABLE #cteubigeo    
    
    
GO