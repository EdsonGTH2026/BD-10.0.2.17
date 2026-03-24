SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
---SP para generar informacion para el reporte Operativo enviado a DG        
--se optimiza sp 2023.10.16 zccu    
  
CREATE Procedure [dbo].[pCsROCAImor] ---@fecha smalldatetime          
as          
BEGIN      
set nocount on    
      
declare @fecha smalldatetime      
set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion with(nolock))--'20231014'--  
      
select ultimodia     
into #dias    
from tclperiodo with(nolock)      
where ultimodia>=dateadd(month,-13,@fecha) and ultimodia<=@fecha            
union select @fecha          
        
--- ELIMINAR TODO, MENOS LOS REGISTROS DE LOS 13 MESES ANTERIORES.    
DELETE FROM FNMGCONSOLIDADO.DBO.TmpROCAImor     
WHERE fechaperiodo NOT IN (select ultimodia from #dias with(nolock) )       
      
UPDATE FNMGCONSOLIDADO.DBO.TmpROCAImor   
SET FECHA=@fecha
FROM FNMGCONSOLIDADO.DBO.TmpROCAImor   
WHERE fechaperiodo IN (select ultimodia from #dias with(nolock) )  

     
      
      
      
select codprestamo,fecha,nrodiasatraso    
into #CA    
from tCsCartera I with(nolock)    
---where i.fecha in(select ultimodia from tclperiodo where ultimodia>=dateadd(month,-13,@fecha) and ultimodia<=@fecha union select @fecha)  
where i.fecha = @fecha      
and i.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))      
and i.codoficina not in('97','230','231','999')      
and cartera='ACTIVA'     
    
select codprestamo,codusuario,saldocapital,fecha    
into #DET    
FROM tcscarteradet cd with(nolock)    
where cd.fecha in(select ultimodia from tclperiodo where ultimodia>=dateadd(month,-13,@fecha) and ultimodia<=@fecha          
   union select @fecha)     
       
-------VALIDAR --- TABLA TEMPORAL / SE BORRA TODA E SE INSERTAN NUEVOS REGISTROS.-- ZCCU    
DELETE FROM FNMGCONSOLIDADO.DBO.TmpROCAImor WHERE fechaperiodo IN (@fecha)       
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAImor    
    
---CONSULTA GENERAL    
select @fecha fecha,i.fecha fechaPeriodo      
,(sum(case when i.nrodiasatraso>=31 then d.saldocapital else 0 end)        
/sum(d.saldocapital))*100 Imor31      
,(sum(case when i.nrodiasatraso>=60 then d.saldocapital else 0 end)        
/sum(d.saldocapital))*100 Imor60       
,(sum(case when i.nrodiasatraso>=90 then d.saldocapital else 0 end)        
/sum(d.saldocapital))*100 Imor90      
from #CA i with(nolock)      
inner join #DET d with(nolock) on i.fecha=d.fecha and i.codprestamo=d.codprestamo          
group by i.fecha      
order by i.fecha      
    
      
 DROP TABLE #CA    
 DROP TABLE #DET    
 DROP TABLE #dias  
     
--SELECT * FROM FNMGCONSOLIDADO.DBO.TmpROCAImor with(nolock)    
    
-- set nocount on        
--declare @fecha smalldatetime      
--set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)      
      
--select @fecha fecha,i.fecha fechaPeriodo      
--  ,(sum(case when i.nrodiasatraso>=31 then d.saldocapital else 0 end)        
--    /sum(d.saldocapital))*100 Imor31      
--  ,(sum(case when i.nrodiasatraso>=60 then d.saldocapital else 0 end)        
--    /sum(d.saldocapital))*100 Imor60       
--  ,(sum(case when i.nrodiasatraso>=90 then d.saldocapital else 0 end)        
--    /sum(d.saldocapital))*100 Imor90      
--  from tcscartera i with(nolock)      
--  inner join tcscarteradet d with(nolock) on i.fecha=d.fecha and i.codprestamo=d.codprestamo        
--  where i.fecha in(select ultimodia from tclperiodo where ultimodia>=dateadd(month,-13,@fecha) and ultimodia<=@fecha       
--  union select @fecha)      
--  and i.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))      
--  and i.codoficina not in('97','230','231','999')      
--  and cartera='ACTIVA'       
        
--  group by i.fecha      
--  order by i.fecha       
END
GO