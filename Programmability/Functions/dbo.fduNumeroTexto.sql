SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduNumeroTexto] 
(
@Numero 	Decimal(25,10),
@Decimal	Int
)  
RETURNS Varchar(50) AS  
BEGIN 
	Set @Numero 	= Round(@Numero, @Decimal)

	Declare @PEnte		Varchar(20)
	Declare @PDeci		Varchar(20)
	Declare @Temporal 	Varchar(50)
	Declare @Final 		Varchar(50)
	
	Set @PEnte 	= Rtrim(Ltrim(Str(@Numero, 18, 5)))
	Set @PEnte 	= Substring(@PEnte, 1, CharIndex('.', @PEnte, 1) - 1)
	Set @PDeci 	= Str(@Numero, 18, @Decimal)
	Set @PDeci 	= Rtrim(Ltrim(SubString(@PDeci, CharIndex('.', @PDeci, 1) + 1, @Decimal)))
	
	Set @PDeci 	= dbo.fdurellena('0', @PDeci, Len(@PDeci) - @Decimal, 'I')
	Set @Temporal 	= @PEnte
	Set @Final 	= ''
		
	While Len(@Temporal) > 3
	Begin
		Set @Final 	= ',' + Right(@Temporal, 3) + @Final
		Set @Temporal 	=  Left(@Temporal, Len(@Temporal) - 3)	
	End 
	
	Set @PDeci = Substring(@PDeci, 1, @Decimal)
	
	Set @Final 	= Right(@Temporal, 3) + @Final + Case When @PDeci <> '' Then '.' + @PDeci else '' end
	
Return(@Final)
END











GO