SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
     
CREATE Procedure [dbo].[pCsReportD_CaCreCarteraVgte] @fecha smalldatetime          
as          
BEGIN      
      
set nocount on     
  
  
SELECT fecha,saldoTotal FROM FNMGCONSOLIDADO.DBO.TmpROCreCAVigte WITH(NOLOCK)  
ORDER BY FECHA  
  
     
----declare @fecha smalldatetime      
----set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)      
      
--/* GRAFICA1.CRECIMIENTO DE CARTERA VIGENTE EN EL MES*/      
      
--declare @fecini smalldatetime      
--set @fecini =cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1        
      
--select c.fecha fecha      
--,sum(t.saldocapital)saldoTotal      
--from tcscarteradet t with(nolock)      
--inner join tcscartera c with(nolock) on c.fecha=t.fecha and c.codprestamo=t.codprestamo      
--where c.fecha>=@fecini      
--and c.fecha<=@fecha    
--and    
--c.codoficina not in('97','231','230','999') and c.estado='VIGENTE'      
       
--group by  c.fecha      
--order by c.fecha      
      
END
GO