SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduFechaAPeriodo] (@Fecha smallDateTime)  
RETURNS varchar(10)
AS  
BEGIN 	
	Declare @Texto   Varchar(10)
	Declare @strDia   Varchar(2)
	Declare @strMes Varchar(2)
	declare @strAño  Varchar(4)		
	
	Set @strDia	= 	Replicate('0', 2 - Len(Cast(Day    (@Fecha) as varchar(2)))) + cast(Day(@Fecha)   as Varchar(2))
	Set @strMes	= 	Replicate('0', 2 - Len(Cast(Month(@Fecha) as varchar(2)))) + cast(Month(@Fecha) as Varchar(2))
	Set @strAño	= 	Replicate('0', 4 - Len(Cast(Year   (@Fecha) as varchar(4)))) + cast(Year(@Fecha)  as Varchar(4))
	
	Set @Texto =  @strAño +  @strMes  
	Set @Texto  = ltrim(rtrim(@Texto))


RETURN (@Texto)	
END



GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [marista]
GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [mchavezs2]
GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [rie_sbravoa]
GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [ope_lvegav]
GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [ope_dalvarador]
GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [ope_lcoronas]
GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [rie_ldomingueze]
GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [rie_jalvarezc]
GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [mledesmav]
GO

GRANT EXECUTE ON [dbo].[fduFechaAPeriodo] TO [Int_dreyesg]
GO