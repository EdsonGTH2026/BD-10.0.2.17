SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsReportD_CASaldoxCiclos] @fecha smalldatetime      
as      
BEGIN  
  
set nocount on    
--declare @fecha smalldatetime  
--set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)  
  
SELECT * FROM FNMGCONSOLIDADO.DBO.TmpROCASaldoxCiclos WITH(NOLOCK)
WHERE FECHA=@fecha
    
 
  
  
--declare @fechas table (fechas smalldatetime)  
--insert into @fechas   
--select ultimodia from tclperiodo  
--where ultimodia>=dateadd(month,-13,@fecha) and ultimodia<=@fecha   
--union   
--select @fecha    
  
--select @fecha fecha,c.fecha fechaPeriodo  
--,case  when pd.secuenciacliente >= 3 then 'Ciclo 3+'  
-- when pd.secuenciacliente in (1, 2)  then 'Ciclo 1-2'  
-- else 'otro'   
-- end rangoCiclo  
--,sum(cd.saldocapital) saldoCapitalTOTAL  
--,case when nrodiasatraso>=0 and nrodiasatraso<=30 then 'VIGENTE 0-30'  
--    when nrodiasatraso>=31 and nrodiasatraso<=89 then 'ATRASADO 31-89'  
--    when nrodiasatraso>=90  then 'VENCIDO 90+' end Categoria  
--FROM tcspadroncarteradet pd with(nolock)  
--left outer join tcscarteradet cd with(nolock) on cd.fecha in(select fechas from @fechas) and cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario  
--left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha  
--where c.fecha in(select ultimodia from tclperiodo where ultimodia>=dateadd(month,-13,@fecha) and ultimodia<=@fecha   
--union select @fecha)  
--and pd.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
--and c.codoficina not in('97','230','231','999')  
--and cartera='ACTIVA'  
--group by c.fecha,       
--     case  when pd.secuenciacliente >= 3 then 'Ciclo 3+'  
--              when pd.secuenciacliente in (1, 2)  then 'Ciclo 1-2'  
--              else 'otro'end   
--,case when nrodiasatraso>=0 and nrodiasatraso<=30 then 'VIGENTE 0-30'  
--    when nrodiasatraso>=31 and nrodiasatraso<=89 then 'ATRASADO 31-89'  
--    when nrodiasatraso>=90  then 'VENCIDO 90+' END  
--order by fecha  
  
END
GO