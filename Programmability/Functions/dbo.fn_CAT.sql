SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_CAT](@TIR float,@periodicidad int)
	returns decimal(30, 10)
as
begin
--@periodicidad float  -->HASTA 06.10.2017
--=POTENCIA(1+B9,360/$B$4)-1
--donde B9 = TIR
--		$B$4 = periocidad

	--declare @TIR float--decimal(30,10)
	--declare @periodicidad float--int
	--set @TIR=2.2166664--2.216666666666666666666666666667
	--set @periodicidad=7
	--select (POWER(1 + @TIR/100, 360/@periodicidad)-1)* 100

	declare @cat float
	--SELECT @cat = (POWER(1 + @TIR/100, 360/@periodicidad)-1)* 100 -->HASTA 06.10.2017
	SELECT @cat = (POWER(1 + @TIR/100, (365/@periodicidad) )-1)* 100
	--select @cat
	--208.807689452445
	return @cat

end


GO