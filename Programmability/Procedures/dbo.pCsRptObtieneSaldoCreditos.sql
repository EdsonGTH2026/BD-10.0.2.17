SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsRptObtieneSaldoCreditos](
	@Fecha as smalldatetime
) 

with encryption
AS
set nocount on -- <-- Noel. Optimizacion

declare @CaMen90 as money
declare @CaMay90 as money

declare @FechaLimite as datetime,
	@FechaCns as datetime

	set @CaMen90 = 0
	set @CaMay90 = 0


	set @FechaLimite = dateadd (day, 90, @Fecha)	
	-- Obtiene los saldos de crédito menores a 90 días
	select @CaMen90 = isnull( sum(MontoDevengado - MontoPagado - MontoCondonado), 0)
	from tCsCartera pr
	inner join tCsPlanCuotas C on pr.codPrestamo =C.CodPrestamo and pr.Estado not in 
	('TRAMITE','CASTIGADO','APROBADO','CANCELADO','EJECUCION')  and pr.Fecha = @Fecha
--	from  tCsPlanCuotas C
	where 
---	C.EstadoCuota <> 'TRAMITE'
--	and C.EstadoCuota <> 'ANULADO'
	C.EstadoCuota <> 'CANCELADO'
	and CodConcepto = 'CAPI'
	and C.FechaVencimiento <= @FechaLimite AND pr.Fecha = @Fecha

	-- Obtiene los saldos de crédito mayores a 90 días
	select @CaMay90 = isnull(sum(MontoDevengado - MontoPagado - MontoCondonado), 0)
	from tCsCartera pr
	inner join tCsPlanCuotas C on pr.codPrestamo =C.CodPrestamo and pr.Estado not in 
	('TRAMITE','CASTIGADO','APROBADO','CANCELADO','EJECUCION')  and pr.Fecha = @Fecha
--	from tCsPlanCuotas C
	where 
--	C.EstadoCuota <> 'TRAMITE'
--	and C.EstadoCuota <> 'ANULADO'
	C.EstadoCuota <> 'CANCELADO'
	and CodConcepto = 'CAPI'
	and C.FechaVencimiento > @FechaLimite AND pr.Fecha = @Fecha
 
	select @CaMen90 as SaldoMen90, @CaMay90 as SaldoMay90
GO