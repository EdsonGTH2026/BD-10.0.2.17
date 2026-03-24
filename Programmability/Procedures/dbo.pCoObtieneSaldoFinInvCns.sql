SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*
	Modificado: eaguirre (12/10/2006)
	se cambio el monbre de la tablas por sus similares en una bd consolidada
*/

CREATE PROCEDURE [dbo].[pCoObtieneSaldoFinInvCns](
	@Fecha as smalldatetime)

with encryption
AS
set nocount on -- <-- Noel. Optimizacion

declare @InvMen90 as money
declare @InvMay90 as money
declare @FinMen90 as money
declare @FinMay90 as money

declare @FechaLimite as datetime

	set @InvMen90 = 0
	set @InvMay90 = 0
	set @FinMen90 = 0
	set @FinMay90 = 0

	set @FechaLimite = dateadd (day, 90, @Fecha)	
	--print cast(@Fechalimite as varchar)
	-- Obtiene las inversiones menores a 90 días
	select @InvMen90 = isnull( sum(MontoCapital), 0)
	from tCsPrestFinDet D
	inner join tCsPrestFin P
	on D.CodPrestFin = P.CodPrestFin
	where P.Estado = '1'
	and D.FechaVencimiento <= @FechaLimite
	and D.FechaVencimiento >= @Fecha
	and P.Categoria = '1'

	-- Obtiene las inversiones mayores a 90 días
	select @InvMay90 = isnull( sum(MontoCapital), 0)
	from tCsPrestFinDet D
	inner join tCsPrestFin P
	on D.CodPrestFin = P.CodPrestFin
	where P.Estado = '1'
	and D.FechaVencimiento > @FechaLimite
	and D.FechaVencimiento >= @Fecha
	and P.Categoria = '1'

	-- Obtiene los financiamientos menores a 90 días
	select @FinMen90 = isnull( sum(MontoCapital), 0)
	from tCsPrestFinDet D
	inner join tCsPrestFin P
	on D.CodPrestFin = P.CodPrestFin
	where P.Estado = '1'
	and D.FechaVencimiento <= @FechaLimite
	and D.FechaVencimiento >= @Fecha
	and P.Categoria = '2'

	-- Obtiene los financiamientos mayores a 90 días
	select @FinMay90 = isnull( sum(MontoCapital), 0)
	from tCsPrestFinDet D
	inner join tCsPrestFin P
	on D.CodPrestFin = P.CodPrestFin
	where P.Estado = '1'
	and D.FechaVencimiento > @FechaLimite
	and D.FechaVencimiento >= @Fecha
	and P.Categoria = '2'

	select @InvMen90 as InvMen90, @InvMay90 as InvMay90, @FinMen90 as FinMen90, @FinMay90 as FinMay90
GO