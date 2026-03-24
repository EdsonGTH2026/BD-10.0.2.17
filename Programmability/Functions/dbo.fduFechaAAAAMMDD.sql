SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[fduFechaAAAAMMDD] (@Fecha smallDateTime)  
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
	
	Set @Texto =  @strAño +  @strMes  +  @strDia		


RETURN (@Texto)	
END


GO