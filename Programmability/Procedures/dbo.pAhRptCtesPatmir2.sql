SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SP_HELPTEXT pAhRptCtesPatmir2                  
--DROP PROC pAhRptCtesPatmir2                  
--EXEC pAhRptCtesPatmir2 '01-10-2012','31-10-2012'    
CREATE PROCEDURE [dbo].[pAhRptCtesPatmir2] (@FecIni SMALLDATETIME, @FecFin SMALLDATETIME)                  
    AS         
/*    
DECLARE @FecIniX CHAR(10)    
DECLARE @FecFinX CHAR(10)    
    set @FecIniX ='01-10-2012'    
    set @FecFinX ='31-10-2012'    
--*/    
/*    
DECLARE @FecIni SMALLDATETIME    
DECLARE @FecFin SMALLDATETIME    
DECLARE @FechaInicial CHAR(10)  
DECLARE @FechaFinal   CHAR(10)  
    
SELECT @FecIni = @FecIniX    
SELECT @FecFin = @FecFinX    
*/
--SELECT @FechaInicial = right(rtrim(@FecIniX),2)+'/'+left(right(rtrim(@FecIniX),4),2)+'/'+left(rtrim(@FecIniX),4)  
--SELECT @FechaFinal   = right(rtrim(@FecFinX),2)+'/'+left(right(rtrim(@FecFinX),4),2)+'/'+left(rtrim(@FecFinX),4)  
--SELECT @FechaInicial = right(rtrim(@FecIniX),2)+'/'+left(right(rtrim(@FecIniX),4),2)+'/'+left(rtrim(@FecIniX),4)  
--SELECT @FechaFinal   = right(rtrim(@FecFinX),2)+'/'+left(right(rtrim(@FecFinX),4),2)+'/'+left(rtrim(@FecFinX),4)  
    
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
       Sucursal     varchar(25)  )    
    
INSERT INTO #clientes    
SELECT pa.codusuario,pa.codcuenta,pa.fraccioncta,pa.renovado,pa.codoficina,ah.saldocuenta,pa.monapertura,    
       case ah.idestadocta when 'CB' then ah.montobloqueado when 'CP' then ah.saldocuenta else 0 end Garantia,    
       ah.FechaVencimiento, o.NomOficina    
  FROM tCsPadronAhorros pa    
 INNER JOIN tcsahorros ah with(nolock) ON ah.fecha=pa.fechacorte AND ah.codcuenta=pa.codcuenta AND ah.FraccionCta=pa.FraccionCta AND ah.renovado=pa.renovado    
 INNER JOIN tcloficinas o with(nolock) ON pa.codoficina=o.codoficina    
 WHERE pa.fecapertura>=@fecini     
   AND pa.fecapertura<=@fecfin    
   AND pa.estadocalculado <> 'CC'     
   AND pa.codusuario NOT IN (select distinct codusuario from tcspadronahorros with(nolock) where fecapertura<@fecini)     
    
delete #clientes where codusuario in (select distinct codusuario from tcspadroncarteradet with(nolock) where desembolso<@fecini)    
delete #clientes where codusuario in (select codusuario from tcstransacciondiaria with(nolock) where extornado=0 and codsistema='TC' and fecha<@fecini)    
    
--DATOS CLIENTES AHORRO Y CRÉDITOS    
SELECT DISTINCT c.codorigen, cl.Sucursal, u.codubigeo, cl.codusuario,    
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
  
--select distinct * from #cteubigeo where Clave_Localidad is null or Clave_Localidad = ''  
    
--select * from #cteubigeo    
SELECT DISTINCT CodOficina, Sucursal, CodUsuario, Paterno+' '+Materno+' '+Nombre1+' '+Nombre2 as Nombre,    
       Fecha_Inscripcion, Sexo, replace(Direccion+ ' '+Numero,'_','') Dirección, Colonia, replace(CodPostal,'_','') CodPostal,    
       CodUbigeo, ISNULL(Clave_Localidad,'') LocalidadDGRV, ZonaPatmir, @FecIni FechaInicial, @FecFin FechaFinal    
  FROM #cteubigeo    
 ORDER BY Sucursal    
    
  DROP TABLE #clientes    
  DROP TABLE #cteubigeo    
    
    
    
  
GO