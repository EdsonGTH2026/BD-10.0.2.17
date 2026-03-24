SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---SP para generar informacion para el reporte Operativo enviado a DG      
--se optimiza sp 2023.10.16 zccu  
   
CREATE Procedure [dbo].[pCsROCASaldoCiclosVGT]    
as          
set nocount on           
          
----declare @fecha smalldatetime  ---LA FECHA DE CORTE          
----select @fecha='20231014'--fechaconsolidacion from vcsfechaconsolidacion          
          
----/*Comparacion de cartera vigente por ciclos de 4 años*/               
----declare @m int          
----set @m= cast(month(@fecha) as int)+35 --mostrar registro de 2 años atras y los meses del año actual          
        
-----------VALIDAR --- TABLA TEMPORAL / SE BORRA TODA Y SE INSERTAN NUEVOS REGISTROS.-- ZCCU    
------DELETE FROM FNMGCONSOLIDADO.DBO.TmpROCASaldoCiclosVGT    
------INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCASaldoCiclosVGT    
     
----select @fecha fechaCorte,c.fecha fechaperiodo          
----,sum(cd.saldocapital) saldoCapital          
----,count(c.codprestamo) nroCreditos               
----,case           
---- when pd.secuenciacliente >= 11 then 'e.Ciclo 11+'          
---- when pd.secuenciacliente >= 4 then 'd.Ciclo 4-10'          
---- when pd.secuenciacliente = 3 then 'c.Ciclo 3'          
---- when pd.secuenciacliente = 2 then 'b.Ciclo 2'          
---- when pd.secuenciacliente = 1 then 'a.Ciclo 1'          
---- else '?' end rangoCiclo          
------INTO FNMGCONSOLIDADO.DBO.TmpROCASaldoCiclosVGT              
----FROM tCsCartera c with(nolock)          
----inner join tcscarteradet cd with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha        
----inner join tcspadroncarteradet pd  with(nolock) on  cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario          
----where         
----C.fecha in(select ultimodia from tclperiodo where ultimodia>=dateadd(month,-@m,@fecha) and ultimodia<=@fecha          
----union select @fecha)        
----and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))           
----and c.codoficina not in('98','97','230','231','999')       
----and cartera='ACTIVA'        
----and nrodiasatraso<=30              
----group by c.fecha           
----,case           
---- when pd.secuenciacliente >= 11 then 'e.Ciclo 11+'          
---- when pd.secuenciacliente >= 4 then 'd.Ciclo 4-10'          
---- when pd.secuenciacliente = 3 then 'c.Ciclo 3'          
---- when pd.secuenciacliente = 2 then 'b.Ciclo 2'          
---- when pd.secuenciacliente = 1 then 'a.Ciclo 1'          
---- else '?' end  order by c.fecha   
       
declare @fecha smalldatetime  ---LA FECHA DE CORTE          
select @fecha=fechaconsolidacion from vcsfechaconsolidacion          
          
/*Comparacion de cartera vigente por ciclos de 4 años*/               
declare @m int          
set @m= cast(month(@fecha) as int)+35 --mostrar registro de 4 años atras y los meses del año actual          
          
select ultimodia   
into #dias  
from tclperiodo with(nolock)    
where ultimodia>=dateadd(month,-@m,@fecha) and ultimodia<=@fecha          
union select @fecha        
      
--- ELIMINAR TODO, MENOS LOS REGISTROS DE LOS 4 AÑOS ANTERIORES.  
DELETE FROM FNMGCONSOLIDADO.DBO.TmpROCASaldoCiclosVGT   
WHERE fechaperiodo NOT IN (select ultimodia from #dias with(nolock) )  
  
  
UPDATE FNMGCONSOLIDADO.DBO.TmpROCASaldoCiclosVGT   
SET FECHACORTE=@fecha
FROM FNMGCONSOLIDADO.DBO.TmpROCASaldoCiclosVGT   
WHERE fechaperiodo IN (select ultimodia from #dias with(nolock) )  
  
---INSERTAR LA FECHA DIARIA       
-------VALIDAR --- TABLA TEMPORAL / SE BORRA TODA Y SE INSERTAN NUEVOS REGISTROS.-- ZCCU    
  
DELETE FROM FNMGCONSOLIDADO.DBO.TmpROCASaldoCiclosVGT WHERE fechaperiodo IN (@fecha)  
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCASaldoCiclosVGT    
   
select @fecha fechaCorte,c.fecha fechaperiodo          
,sum(saldocapital) saldoCapital          
,count(c.codprestamo) nroCreditos               
,case when pd.secuenciacliente >= 11 then 'e.Ciclo 11+'          
  when pd.secuenciacliente >= 4 then 'd.Ciclo 4-10'          
  when pd.secuenciacliente = 3 then 'c.Ciclo 3'          
  when pd.secuenciacliente = 2 then 'b.Ciclo 2'          
  when pd.secuenciacliente = 1 then 'a.Ciclo 1'          
  else '?' end rangoCiclo          
--INTO FNMGCONSOLIDADO.DBO.TmpROCASaldoCiclosVGT              
FROM tCsCartera c with(nolock)          
--inner join tcscarteradet cd with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha        
inner join tcspadroncarteradet pd  with(nolock) on  c.codprestamo=pd.codprestamo and c.codusuario=pd.codusuario          
where         
C.fecha in(@fecha)        
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))           
and c.codoficina not in('98','97','230','231','999')       
and cartera='ACTIVA'        
and nrodiasatraso<=30              
group by c.fecha           
,case  when pd.secuenciacliente >= 11 then 'e.Ciclo 11+'          
  when pd.secuenciacliente >= 4 then 'd.Ciclo 4-10'          
  when pd.secuenciacliente = 3 then 'c.Ciclo 3'          
  when pd.secuenciacliente = 2 then 'b.Ciclo 2'          
  when pd.secuenciacliente = 1 then 'a.Ciclo 1'          
  else '?' end  order by c.fecha   
   
   
DROP TABLE #dias
GO