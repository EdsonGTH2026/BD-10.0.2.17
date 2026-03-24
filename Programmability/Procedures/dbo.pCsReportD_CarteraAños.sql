SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsReportD_CarteraAños] @fecha smalldatetime    
as    
BEGIN

set nocount on  
--declare @fecha smalldatetime
--set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)
 
declare @m int
set @m= cast(month(@fecha) as int)+23 --mostrar registro de 2 años atras y los meses del año actual

declare @fech smalldatetime
set @fech=dbo.fdufechaaperiodo(dateadd(month,-@m,@fecha))+'01'


select @fecha fechacorte,dbo.fdufechaaperiodo(fecha) periodo,EPRC gastoEPRC,inteDevengado inteDevengado
,gastoxInteres gastoxInteres,Co_CobradaPagada comisionCobrada
,inteDevengado+Co_CobradaPagada-gastoxInteres-EPRC Total
from FNMGConsolidado.dbo.tCaReporteDiario with(nolock)
where fecha in(select ultimodia from tclperiodo where ultimodia>=dateadd(month,-@m,@fecha) and ultimodia<=@fecha    
   union select @fecha) 

END
GO