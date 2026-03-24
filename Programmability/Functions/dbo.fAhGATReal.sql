SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fAhGATReal] (@Fecha as smalldatetime, @GATNominal as Money)
RETURNS Money
AS
BEGIN

--COMENTAR
/*
declare @Fecha as smalldatetime
declare @GATNominal as money
set @Fecha = '20171215'
set @GATNominal = 5.38
*/
	declare @GATReal money
	DECLARE @mediana Money
	DECLARE @mediana2 Money
	declare @GATNominal2 as money

	select top 1 @mediana = isnull(MedianaInflacion,0) from tAhClMedianaInflacion where FechaPublicacion <= @Fecha order by FechaPublicacion desc
	--select @mediana --COMENTAR
	--print '@GATNominal:' + convert(varchar,@GATNominal)
	--print '@mediana:' + convert(varchar,@mediana)

	if @mediana > 0 
		begin
			set @GATNominal2 = @GATNominal/100
			set @mediana2 = @mediana/100
			--print '@GATNominal2:' + convert(varchar,@mediana2)
			--print '@mediana2:' + convert(varchar,@mediana2)
			
			--select @mediana2
			--set @GATReal = ((1 + @GATNominal) / (1+ @mediana2)) -1
			set @GATReal = (((1 + @GATNominal2) / (1+ @mediana2)) -1) * 100
		end
	else
		begin
			set @GATReal = @GATNominal
		end 

	--select @GATReal --COMENTAR
	--print '@GATReal: ' + convert(varchar,@GATReal)
	return @GATReal
END
GO