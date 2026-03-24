SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsRptCartaRegional2]  @fecha smalldatetime,@zona varchar(5)    
as    
set nocount on     
   
select nomoficina
,(saldo31a89ini + saldo90Ini) carVencida31mIni
,case when saldoCapIni = 0 then 0 else ((saldo31a89ini+saldo90Ini)/saldoCapIni)*100 end porCaVencidaIni  
,(saldo31a89fin + saldo90Fin)  carVencida31mFin
,case when saldocapFinal = 0 then 0 else ((saldo31a89fin+saldo90Fin)/saldocapFinal)*100 end porCaVencidaFin  
,(saldo31a89ini+saldo90Ini)- (saldo31a89fin+saldo90Fin) PasoAVencida
,crecimiento0a30,crecimiento31a89,crecimiento90,crecimientoTotal,cobranzaPuntalTotal
--select *
from fnmgconsolidado.dbo.tcacartagerente with(nolock)  
where fecha=@fecha  
and zona=@zona  
   
   



GO