SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

    
---SP para generar informacion para el reporte Operativo enviado a DG        
--se optimiza sp 2023.10.16 zccu      
     
CREATE Procedure [dbo].[pCsROCAsaldoCubetas]           
as            
BEGIN        
        
set nocount on          
declare @fecha smalldatetime        
set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)--'20231010'--        
      
      
select ultimodia       
into #dias      
from tclperiodo with(nolock)        
where ultimodia>=dateadd(month,-13,@fecha) and ultimodia<=@fecha              
union select @fecha            
          
--- ELIMINAR TODO, MENOS LOS REGISTROS DE LOS 13 MESES ANTERIORES.      
DELETE FROM FNMGCONSOLIDADO.DBO.TmpROCAsaldoCubetas       
WHERE fechaperiodo NOT IN (select ultimodia from #dias with(nolock))        
      
UPDATE FNMGCONSOLIDADO.DBO.TmpROCAsaldoCubetas     
SET FECHA=@fecha  
FROM FNMGCONSOLIDADO.DBO.TmpROCAsaldoCubetas     
WHERE fechaperiodo IN (select ultimodia from #dias with(nolock) )    
     
      
      
      
-------VALIDAR --- TABLA TEMPORAL / SE BORRA TODA E SE INSERTAN NUEVOS REGISTROS.-- ZCCU      
DELETE  FNMGCONSOLIDADO.DBO.TmpROCAsaldoCubetas  WHERE fechaperiodo = @fecha        
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAsaldoCubetas      
      
select @fecha fecha,fecha fechaPeriodo        
 ,(case when nrodiasatraso = 0 then 'c0dm'         
  when nrodiasatraso>=1 and nrodiasatraso<=7 then 'c1a7dm'         
  when nrodiasatraso>=8 and nrodiasatraso <=15 then 'c8a15dm'        
  when nrodiasatraso>=16 and nrodiasatraso <=21 then  'c16a21dm'   
  when nrodiasatraso>=22 and nrodiasatraso <=30 then  'c22a30dm'   
  when nrodiasatraso>=31 and nrodiasatraso <=60 then   'c31a60dm'        
  when nrodiasatraso>=61 and nrodiasatraso <=89 then  'c61a89dm'        
  when nrodiasatraso>=90 and nrodiasatraso <=120 then  'c90a120dm'        
  when nrodiasatraso>=121 and nrodiasatraso <=150 then 'c121a150dm'        
  when nrodiasatraso>=151 and nrodiasatraso <=180 then  'c151a180dm'        
  when nrodiasatraso>=181 and nrodiasatraso <=210 then   'c181a210dm'        
  when nrodiasatraso>=211 and nrodiasatraso <=240 then 'c211a240dm'        
  when nrodiasatraso>=241 then 'c241dm' else '' end) Cubetas        
 ,sum(saldocapital) saldoCapitalTOTAL        
 ,case when nrodiasatraso>=0 and nrodiasatraso<=30 then 'VIGENTE 0-30'        
  when nrodiasatraso>=31 and nrodiasatraso<=89 then 'ATRASADO 31-89'        
  when nrodiasatraso>=90  then 'VENCIDO 90+' end Categoria        
  --INTO FNMGCONSOLIDADO.DBO.TmpROCAsaldoCubetas      
 from tcscartera i with(nolock)        
 --where fecha in(select ultimodia from tclperiodo where ultimodia>=dateadd(month,-13,@fecha) and ultimodia<=@fecha         
 --union select @fecha)-- fecha corte-- A PARTIR DE QUE FECHA COSECHAS SE EVALUA     
where fecha = @fecha -- fecha corte-- A PARTIR DE QUE FECHA COSECHAS SE EVALUA        
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))        
and codoficina not in('97','230','231','999','98')        
and cartera='ACTIVA'          
 group by fecha,(case when nrodiasatraso = 0 then 'c0dm'         
  when nrodiasatraso>=1 and nrodiasatraso<=7 then 'c1a7dm'         
  when nrodiasatraso>=8 and nrodiasatraso <=15 then 'c8a15dm'        
  when nrodiasatraso>=16 and nrodiasatraso <=21 then  'c16a21dm'   
  when nrodiasatraso>=22 and nrodiasatraso <=30 then  'c22a30dm'        
  when nrodiasatraso>=31 and nrodiasatraso <=60 then   'c31a60dm'        
  when nrodiasatraso>=61 and nrodiasatraso <=89 then  'c61a89dm'        
  when nrodiasatraso>=90 and nrodiasatraso <=120 then  'c90a120dm'        
  when nrodiasatraso>=121 and nrodiasatraso <=150 then 'c121a150dm'        
  when nrodiasatraso>=151 and nrodiasatraso <=180 then  'c151a180dm'        
  when nrodiasatraso>=181 and nrodiasatraso <=210 then   'c181a210dm'        
  when nrodiasatraso>=211 and nrodiasatraso <=240 then 'c211a240dm'        
  when nrodiasatraso>=241 then 'c241dm' else '' end)        
  ,case when nrodiasatraso>=0 and nrodiasatraso<=30 then 'VIGENTE 0-30'        
  when nrodiasatraso>=31 and nrodiasatraso<=89 then 'ATRASADO 31-89'        
  when nrodiasatraso>=90  then 'VENCIDO 90+' END        
 order by fecha   
   
                         ---- caso sin desglosar para la version anterior  
 INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAsaldoCubetas  
 SELECT @fecha fecha,fecha fechaPeriodo,'c16a30dm'  Cubetas,SUM(saldoCapitalTotal) saldoCapitalTotal, 'VIGENTE 0-30' Categoria     
 FROM FNMGCONSOLIDADO.DBO.TmpROCAsaldoCubetas WITH(NOLOCK)  
WHERE fecha=@fecha and FECHAPeriodo=@fecha  
and Cubetas in ('c16a21dm', 'c22a30dm')  
group by fecha  
    
     
DROP TABLE #dias      
END  
GO