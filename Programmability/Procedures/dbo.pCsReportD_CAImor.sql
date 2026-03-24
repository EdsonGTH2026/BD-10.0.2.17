SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
CREATE Procedure [dbo].[pCsReportD_CAImor] @fecha smalldatetime      
as      
BEGIN  
  
set nocount on  
  
--declare @fecha smalldatetime  
--set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)  
  
SELECT * FROM FNMGCONSOLIDADO.DBO.TmpROCAImor WITH(NOLOCK)
WHERE FECHA=@fecha
    

  
  
  
  
  
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