SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fCsCalcularGAT_Nominal](@TasaBruta money, @PlazoDias integer)
RETURNS money
AS
BEGIN

	declare @GATnominal money
	declare @m money
	declare @r money

	set @PlazoDias = 360 --CHECAR

	set @GATnominal = 0	
	--set @r = @TasaBruta / 100
	set @r = @TasaBruta 
	set @m = 360 / @PlazoDias
	
	set @GATnominal = (1+(@r/@m))
	
	set @GATnominal = power(@GATnominal,@m)
	
	set @GATnominal = @GATnominal -1

	return @GATnominal
	
END
GO