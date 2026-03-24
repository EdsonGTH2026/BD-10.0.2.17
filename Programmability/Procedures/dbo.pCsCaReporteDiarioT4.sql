SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* TABLA4. COBRANZA PUNTUAL  */

Create Procedure [dbo].[pCsCaReporteDiarioT4]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

select fecha,monto_puntual Puntual,monto_Anticipado Anticipado,monto_Atrasado Atrasado,monto_pagoParcial  Pago_Parcial
from FNMGConsolidado.dbo.tCaReporteDiario
where fecha=@fecha
GO