SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--select * FROM tCsAhorros
--SELECT Fecha, CodCuenta, FraccionCta, Renovado, CodOficina, CodProducto, 
--CodMoneda, CodUsuario, FormaManejo, FechaApertura, FechaVencimiento, 
--FechaCierre, TasaInteres, FechaUltMov, TipoCambioFijo, SaldoCuenta, 
--SaldoMonetizado, MontoInteres, IntAcumulado, MontoInteresCapitalizado, 
--MontoBloqueado, MontoRetenido, InteresCalculado, Plazo, Lucro, CodAsesor, 
--CodOficinaUltTransaccion, TipoUltTransaccion, FechaUltCapitalizacion, 
--IdDocRespaldo, NroSerie, idEstadoCta, NomCuenta, FondoConfirmar, Observacion,
-- EnGarantia, Garantia, CuentaPreferencial, CuentaReservada, CodCuentaAnt, 
--AplicaITF, PorcCliente, PorcInst, idTipoCapi, FechaCambioEstado, FechaInactivacion, 
--NroSolicitud, CodTipoInteres, IdTipoRenova, PlazoDiasRenov, InteresCapitalizable, 
--CodPrestamo, MontoGarantia, TipoConta, ContaCodigo FROM tCsAhorros
CREATE PROCEDURE [dbo].[pCoObtieneSaldoDepositosCns](
	@Fecha as smalldatetime
--	@FechaCns as smalldatetime
) 

with encryption
AS
set nocount on -- <-- Noel. Optimizacion

declare @DepMen90 as money
declare @DepMay90 as money

declare @FechaLimite as datetime,
	@FechaCns as datetime

	set @DepMen90 = 0
	set @DepMay90 = 0
	
	set @FechaLimite = dateadd (day, 90, @Fecha)	
	--print cast(@Fechalimite as varchar)
	select @FechaCns = max(Fecha) from tCsAhorros
	-- Obtiene los datos menores a 90
	select @DepMen90 = isnull( sum(SaldoCuenta),0)
	from tCsAhorros
	where CodProducto not like '2%'
	and IdEstadoCta <> 'CC' and Fecha = @FechaCns

	select @DepMen90 = @DepMen90 + isnull( sum(SaldoCuenta),0)
	from tCsAhorros
	where CodProducto like '2%'
	and IdEstadoCta <> 'CC'
	and Plazo <= 90
	and FechaVencimiento >= @Fecha and Fecha = @FechaCns

	select @FechaCns = max(Fecha) from tCsGiros
--	select * from tCsGiros
	select @DepMen90 = @DepMen90 + isnull(sum(MontoGiro), 0)
	from tCsGiros
	where (TipoGiro = 'O' or TipoGiro = 'R')
	and (EstadoGiro = 'D' or EstadoGiro = 'P')  and Fecha = @FechaCns

	-- Obtiene los datos mayores a 90
	select @FechaCns = max(Fecha) from tCsAhorros

	select @DepMay90 = isnull( sum(SaldoCuenta),0)
	from tCsAhorros
	where CodProducto like '2%'
	and IdEstadoCta <> 'CC'
	and Plazo > 90
	and FechaVencimiento >= @Fecha and Fecha = @FechaCns

	select @DepMen90 as SaldoMen90, @DepMay90 as SaldoMay90

GO