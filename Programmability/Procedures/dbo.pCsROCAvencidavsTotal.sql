SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
---SP para generar informacion para el reporte Operativo enviado a DG -- zccu  
--se optimiza sp 2023.10.16 zccu    
  
CREATE Procedure [dbo].[pCsROCAvencidavsTotal]    
as          
BEGIN      
    
set nocount on        
declare @fecha smalldatetime      
set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)      
    
select ultimodia     
into #dias    
from tclperiodo with(nolock)      
where ultimodia>=dateadd(month,-12,@fecha) and ultimodia<=@fecha            
union select @fecha     
  
--- ELIMINAR TODO, MENOS LOS REGISTROS DE 1 AÑO ANTERIOR.  -- ZCCU    
DELETE FROM FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal     
WHERE fechaperiodo NOT IN (select ultimodia from #dias with(nolock) )    
    
UPDATE FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal   
SET FECHA=@fecha
FROM FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal   
WHERE fechaperiodo IN (select ultimodia from #dias with(nolock))  
    
    
    
  
select @fecha fecha,c.fecha fechaPeriodo      
 ,sum(c.saldocapital) saldoCapitalTotal      
 ,sum(case when nrodiasatraso>=90  then c.saldocapital else 0 end) 'VENCIDO'       
 ,sum(case when nrodiasatraso>=31 then c.saldocapital else 0 end) 'SALDO31M'       
 ,case when pd.secuenciacliente >= 3 then 'Ciclo 3+'      
   when pd.secuenciacliente in (1, 2)  then 'Ciclo 1-2'      
   else 'otro' end rangoCiclo      
  into #base      
 -- FROM tcspadroncarteradet pd with(nolock)      
 --left outer join tcscarteradet cd with(nolock) on  cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario      
 --left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha      
 FROM tCsCartera c  with(nolock)      
 left outer join tcspadroncarteradet pd with(nolock) on c.codprestamo=pd.codprestamo and c.fecha=@fecha   
 where c.fecha=@fecha   
 and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))      
 and c.codoficina not in('97','230','231','999')      
 and cartera='ACTIVA'      
 group by c.fecha      
  ,case  when pd.secuenciacliente >= 3 then 'Ciclo 3+'      
  when pd.secuenciacliente in (1, 2)  then 'Ciclo 1-2'      
  else 'otro'       
   end       
    
  ---INSERTAR LA FECHA DIARIA         
-------VALIDAR --- TABLA TEMPORAL / SE BORRA TODA Y SE INSERTAN NUEVOS REGISTROS.-- ZCCU      
    
DELETE FROM FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal WHERE fechaperiodo IN (@fecha)    
    
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal    
select fecha,fechaPeriodo,sum(case when rangociclo='Ciclo 1-2' then (SALDO31M) end)/sum(saldoCapitalTotal)*100 VIGENTE      
,'%CARTERA 31+ vs CARTERA TOTAL'categoria,'ciclo 1-2'rangoCiclo     
--INTO FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal    
from #base with(nolock)      
group by fecha,fechaPeriodo      
--union      
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal    
select fecha,fechaPeriodo,sum(case when rangociclo='Ciclo 3+' then (SALDO31M)end)/sum(saldoCapitalTotal)*100 saldoCapital      
,'%CARTERA 31+ vs CARTERA TOTAL'categoria,'Ciclo 3+'rangoCiclo from #base with(nolock)      
group by fecha,fechaPeriodo      
--union      
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal    
select fecha,fechaPeriodo,sum(case when rangociclo='Ciclo 1-2' then (VENCIDO) end)/sum(saldoCapitalTotal)*100 saldoCapital      
,'%CARTERA 90+ vs CARTERA TOTAL'categoria,'ciclo 1-2'rangoCiclo from #base with(nolock)      
group by fecha,fechaPeriodo      
--union      
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal    
select fecha,fechaPeriodo,sum(case when rangociclo='Ciclo 3+' then (VENCIDO)end)/sum(saldoCapitalTotal)*100 saldoCapital      
,'%CARTERA 90+ vs CARTERA TOTAL'categoria,'Ciclo 3+'rangoCiclo from #base with(nolock)      
group by fecha,fechaPeriodo      
--union      
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal    
select fecha,fechaPeriodo,sum(VENCIDO)/sum(saldoCapitalTotal)*100 saldoCapital,'%CARTERA 90+ vs CARTERA TOTAL'categoria,'%CARTERA 90+ vs CARTERA TOTAL'      
from #base with(nolock) group by fecha,fechaPeriodo      
--union     
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAvencidavsTotal        
select fecha,fechaPeriodo,sum(SALDO31M)/sum(saldoCapitalTotal)*100 saldoCapital,'%CARTERA 31+ vs CARTERA TOTAL'categoria,'%CARTERA 31+ vs CARTERA TOTAL'       
from #base with(nolock) group by fecha,fechaPeriodo      
      
drop table #base      
DROP TABLE #dias    
  
END
GO