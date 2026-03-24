SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fduFechaATexto] (@Fecha SmallDateTime, @Formato Varchar(8))  
RETURNS varchar(50)
AS  
BEGIN 	
	Declare @strDia   	Varchar(8)
	Declare @strMes 	Varchar(8)
	Declare @strAño  	Varchar(8)
	Declare @iD		Int		
	Declare @iM		Int
	Declare @iA		Int	
	Declare @PD		Int		
	Declare @PM		Int
	Declare @PA		Int
	Declare @TD		Varchar(8)		
	Declare @TM		Varchar(8)
	Declare @TA		Varchar(8)	
	Declare @Temp		Varchar(8)	
	
	Set @Formato	= 	Upper(@Formato)

	Set @strDia	= 	Replicate('0', 8 - Len(Cast(Day   (@Fecha) as varchar(8)))) + cast(Day  (@Fecha) as Varchar(8))
	Set @strMes	= 	Replicate('0', 8 - Len(Cast(Month (@Fecha) as varchar(8)))) + cast(Month(@Fecha) as Varchar(8))
	Set @strAño	= 	Replicate('0', 8 - Len(Cast(Year  (@Fecha) as varchar(8)))) + cast(Year (@Fecha) as Varchar(8))
	
	Set @iD		= 	CharIndex('D', @Formato)
	Set @iM		= 	CharIndex('M', @Formato)
	Set @iA		= 	CharIndex('A', @Formato)
	
	Set @Temp	=	Reverse(Substring(@Formato, @iD+1, 8))
	Set @PD		= 	Len(@Formato) - CharIndex('D', @Temp) + 2 - @iD
	
	Set @Temp	=	Reverse(Substring(@Formato, @iM+1, 8))
	Set @PM		= 	Len(@Formato) - CharIndex('M', @Temp) + 2 - @iM
	
	Set @Temp	=	Reverse(Substring(@Formato, @iA+1, 8))
	Set @PA		= 	Len(@Formato) - CharIndex('A', @Temp) + 2 - @iA
	
	Set @TD		= 	Replicate('D', @PD)
	Set @TM		= 	Replicate('M', @PM)
	Set @TA		= 	Replicate('A', @PA)
	
	If @iD > 0 
	Begin 
	Set @Formato 	= 	Substring(@Formato, 1, @iD-1)+ @TD + Substring(@Formato, @iD + Len(@TD) , 8) 		
	End
	If @iM > 0 
	Begin
	Set @Formato 	= 	Substring(@Formato, 1, @iM-1)+ @TM + Substring(@Formato, @iM + Len(@TM) , 8)	
	End
	If @iA > 0 
	Begin
	Set @Formato 	= 	Substring(@Formato, 1, @iA-1)+ @TA + Substring(@Formato, @iA + Len(@TA) , 8) 
	End 

	Set @strDia	= 	Right(@strDia, @PD)
	Set @strMes	= 	Right(@strMes, @PM)	
	Set @strAño	= 	Right(@strAño, @PA)	

	Set @Formato   	=	Replace(@Formato, @TD, @strDia)	
	Set @Formato   	=	Replace(@Formato, @TM, @strMes)
	Set @Formato   	=	Replace(@Formato, @TA, @strAño)	

RETURN (@Formato)	
--RETURN (@TD +'-'+ @TM +'-'+ @TA)	
END

GO

GRANT EXECUTE ON [dbo].[fduFechaATexto] TO [marista]
GO

GRANT EXECUTE ON [dbo].[fduFechaATexto] TO [rie_sbravoa]
GO

GRANT EXECUTE ON [dbo].[fduFechaATexto] TO [rie_ldomingueze]
GO

GRANT EXECUTE ON [dbo].[fduFechaATexto] TO [rie_jalvarezc]
GO