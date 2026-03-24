SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsABovAcumDistribucionDatos2] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on

--declare @fecha smalldatetime
--set @fecha = '20190515'

select 
codoficina, fechapro, saldoinisis, saldofinsis, Capital, Interes, Moratorio, CargoxAtraso, Seguro, Impuestos, 
TotalCA, Capital_Progre, Interes_Progre, Capital_Facorp, Interes_Facorp, garantias, seguros, desembolsos, Ahdepositos, Ahretiros, CJ_sobrante,           
CJ_faltante, fecharecoleccion, recoleccion, aclaracionmonto, TOTAL, Bov_Reco, AnexoIni, AnexoFin, AnexoMov_Bov,          
TOTAL_BOV, DIFERENCIA            
from tCsABovAcumDistribucion 
where fechapro>= dateadd(d,-7, @fecha)
and fechapro<= @fecha
order by fechapro, codoficina

GO