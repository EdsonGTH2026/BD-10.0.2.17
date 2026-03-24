SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fduCambiarFormato] 
(
@Texto Varchar(1000)
)
RETURNS Varchar(1000) AS  
BEGIN 
Declare @variable	Varchar(1000)
Declare @Pos		Int

Set @Texto 	= LTrim(RTrim(@Texto))
Set @Variable	= @Texto
Set @Pos	= CharIndex(' ', @Variable, 1)
If @Pos > 0 
	Begin
	Set @Texto	= Upper(Substring(@Variable, 1, 1)) + Lower(Substring(@Variable, 2, @Pos - 1))
	End
Else
	Begin
	Set @Texto	= Upper(Substring(@Variable, 1, 1)) + Lower(Substring(@Variable, 2, 1000))
	End
While @Pos <> 0
	Begin
		Set @Variable 	= Substring(@Variable, @Pos + 1, 1000)
		Set @Pos	= CharIndex(' ', @Variable, 1)
		If @Pos > 0 
			Begin
			Set @Texto	= @Texto + ' ' + Upper(Substring(@Variable, 1, 1)) + Lower(Substring(@Variable, 2, @Pos - 1))
			End
		Else
			Begin
			Set @Texto	= @Texto + ' ' + Upper(Substring(@Variable, 1, 1)) + Lower(Substring(@Variable, 2, 1000))
			End
		Set @Pos	= CharIndex(' ', @Variable, 1)
	End  
Set @Texto = Replace(@Texto, '  ', ' ')
Return (@Texto)
END


GO