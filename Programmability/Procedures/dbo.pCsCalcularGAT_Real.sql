SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCalcularGAT_Real](@TasaBruta money, @PlazoDias integer, @FechaConsulta smalldatetime)
AS
BEGIN

	declare @GATnominal money
	declare @GATreal money
	declare @m money
	declare @pi money

    select @pi = Valor from tCsInflacion where Periodo = substring( convert(varchar,@FechaConsulta,112),1,6)
print '@pi=' + convert(varchar,@pi)

	set @GATnominal = dbo.fCsCalcularGAT_Nominal(@TasaBruta, @PlazoDias)
print '@GATnominal=' + convert(varchar,@GATnominal)

	set @GATreal = ((1 + @GATnominal) / (1 + @pi)) - 1

	select @GATreal as GAT_Real
	
END
GO