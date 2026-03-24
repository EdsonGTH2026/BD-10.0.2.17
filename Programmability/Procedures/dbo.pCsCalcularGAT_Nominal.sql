SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCalcularGAT_Nominal](@TasaBruta money, @PlazoDias integer)
AS
BEGIN

	declare @GATnominal money
	declare @m money
	declare @r money

set @PlazoDias = 360 --CHECAR

	set @GATnominal = 0	
	set @r = @TasaBruta 
print '@r= ' + convert(varchar, @r)
	set @m = 360 / @PlazoDias
print '@m= ' + convert(varchar, @m)
	
	set @GATnominal = (1+(@r/@m))
	
	set @GATnominal = power(@GATnominal,@m)
	
	set @GATnominal = @GATnominal -1

	select @GATnominal as GAT_Nominal
	
END
GO