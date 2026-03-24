SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--select * from  tCsPlanCuotas C

CREATE PROCEDURE [dbo].[pCoObtieneSaldoCreditosCns](
	@Fecha as smalldatetime
--	@FechaCns as smalldatetime
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

	select @FechaCns = max(Fecha) from tCsPlanCuotas

--select max(Fecha) from tCsPlanCuotas
--sp_help tCsPlanCuotas
	
	set @FechaLimite = dateadd (day, 90, @Fecha)	
	--print cast(@Fechalimite as varchar)
	-- Obtiene los saldos de crédito menores a 90 días
	select @CaMen90 = isnull( sum(MontoDevengado - MontoPagado - MontoCondonado), 0)
	from  tCsPlanCuotas C
	where C.EstadoCuota <> 'TRAMITE'
	and C.EstadoCuota <> 'ANULADO'
	and C.EstadoCuota <> 'CANCELADO'
	and CodConcepto = 'CAPI'
	and C.FechaVencimiento <= @FechaLimite AND Fecha = @FechaCns

	-- Obtiene los saldos de crédito mayores a 90 días
	select @CaMay90 = isnull(sum(MontoDevengado - MontoPagado - MontoCondonado), 0)
	from tCsPlanCuotas C
	where C.EstadoCuota <> 'TRAMITE'
	and C.EstadoCuota <> 'ANULADO'
	and C.EstadoCuota <> 'CANCELADO'
	and CodConcepto = 'CAPI'
	and C.FechaVencimiento > @FechaLimite AND Fecha = @FechaCns
 
	select @CaMen90 as SaldoMen90, @CaMay90 as SaldoMay90

GO