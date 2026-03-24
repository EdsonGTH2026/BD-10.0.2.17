SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fCsCalcularGAT_Real](@TasaBruta money, @PlazoDias integer, @FechaConsulta smalldatetime)
RETURNS money
AS
BEGIN

	declare @GATnominal money
	declare @GATreal money
	declare @m money
	declare @pi money

    select @pi = Valor from tCsInflacion where Periodo = substring( convert(varchar,@FechaConsulta,112),1,6)

	set @GATnominal = dbo.fCsCalcularGAT_Nominal(@TasaBruta, @PlazoDias)

	set @GATreal = ((1 - @GATnominal) / (1 - @pi)) - 1

	return @GATreal
	
END
GO