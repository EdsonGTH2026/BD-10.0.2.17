SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsEstadoCuentaCarteraSaldos2017]
    @CodPrestamo char(19),
    @FechaIni datetime,
    @FechaCorte datetime
AS
BEGIN

/*
--COMETAR
declare @Codprestamo as char(19)
declare @FechaCorte datetime
set @Codprestamo = '008-166-06-07-00116'
set @FechaCorte = '20161231'
*/


	declare @CodOficina varchar(3)
	declare @Estado varchar(20)
	declare @UltimaFechaCartera datetime
	if exists (select 1 from tcscartera with(nolock) where fecha = @FechaCorte and codprestamo = @Codprestamo)
	begin
	    set @UltimaFechaCartera = @FechaCorte

		select @Estado = Estado from tcscartera with(nolock)
		where codprestamo = @Codprestamo
		and Fecha = @UltimaFechaCartera

		select @Estado as Estado,
		Fecha, CodPrestamo, CodUsuario, CodOficina, CodDestino, MontoDesembolso, SaldoCapital, 
--SaldoInteres, 
(InteresVigente + InteresVencido + InteresCtaOrden )as SaldoInteres,
--SaldoMoratorio,
(MoratorioVigente + MoratorioVencido + MoratorioCtaOrden) as SaldoMoratorio,
		OtrosCargos, Impuestos, CargoMora, UltimoMovimiento, CapitalAtrasado, CapitalVencido, SaldoEnMora, TipoCalificacion, 
		InteresVigente, InteresVencido, InteresCtaOrden, InteresDevengado, MoratorioVigente, MoratorioVencido, MoratorioCtaOrden,
		MoratorioDevengado, SecuenciaCliente, SecuenciaGrupo, PReservaCapital, SReservaCapital, PReservaInteres, SReservaInteres,
		--(SaldoCapital + SaldoInteres + SaldoMoratorio + OtrosCargos + Impuestos + CargoMora) as 'SaldoTotal'
		(SaldoCapital + (InteresVigente + InteresVencido + InteresCtaOrden) + (MoratorioVigente + MoratorioVencido + MoratorioCtaOrden) +  Impuestos + CargoMora) + isnull(OtrosCargos,0) as 'SaldoTotal'
		from tCsCarteraDet with(nolock)
		where codprestamo = @Codprestamo
		and Fecha = @UltimaFechaCartera
	end
	else
	   -- select @UltimaFechaCartera = max(Fecha) from tcscartera where codprestamo = @Codprestamo
	begin
		select @CodOficina = max(CodOficina ) from tcscartera with(nolock) where codprestamo = @Codprestamo

		select @UltimaFechaCartera = max(Fecha) from tcscartera with(nolock) where codprestamo = @Codprestamo
		select @Estado = estado from tcscartera with(nolock) where codprestamo = @Codprestamo and fecha = @UltimaFechaCartera
		--set @Estado = 'PAGADO'

		select @Estado as Estado,
		'' as Fecha, @Codprestamo as CodPrestamo, '' as CodUsuario, @CodOficina as CodOficina, '' as CodDestino, 0 as MontoDesembolso, 0 as SaldoCapital, 0 as SaldoInteres, 0 as SaldoMoratorio,
		0 as OtrosCargos, 0 as Impuestos, 0 as CargoMora, '' as UltimoMovimiento, 0 as CapitalAtrasado, 0 as CapitalVencido, 0 as SaldoEnMora, '' as TipoCalificacion, 
		0 as InteresVigente, 0 as InteresVencido, 0 as InteresCtaOrden, 0 as InteresDevengado, 0 as MoratorioVigente, 0 as MoratorioVencido, 0 as MoratorioCtaOrden,
		0 as MoratorioDevengado, 0 as SecuenciaCliente, 0 as SecuenciaGrupo, 0 as PReservaCapital, 0 as SReservaCapital, 0 as PReservaInteres, 0 as SReservaInteres,
		0 as 'SaldoTotal'
		
	end

END

GO