SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsSingularPlural 
Create Procedure [dbo].[pCsSingularPlural] 
@SiPl 		Varchar(1),
@Cadena	Varchar(8000),
@Resultado 	Varchar(8000) Output
As
If @SiPl = 'S'
Begin
	While CharIndex('[P:', @Cadena, 1) <> 0
	Begin
		Set @Cadena 	= Substring(@Cadena, 1, CharIndex('[P:', @Cadena, 1) - 1) +
				  Substring(@Cadena, CharIndex(']', @Cadena, CharIndex('[P:', @Cadena, 1) + 3) + 1, 5000)
	End
	While CharIndex('[S:', @Cadena, 1) <> 0
	Begin
		Set @Cadena 	= 	Substring(@Cadena, 1, CharIndex('[S:', @Cadena, 1) - 1) +
					Substring(@Cadena, CharIndex('[S:', @Cadena, 1) + 3, CharIndex(']', @Cadena, CharIndex('[S:', @Cadena, 1) + 3) - (CharIndex('[S:', @Cadena, 1) + 3)) +
					Substring(@Cadena, CharIndex(']', @Cadena, CharIndex('[S:', @Cadena, 1) + 3) + 1, 5000)	
	End
End
If @SiPl = 'P'
Begin
	While CharIndex('[S:', @Cadena, 1) <> 0
	Begin
		Set @Cadena 	= Substring(@Cadena, 1, CharIndex('[S:', @Cadena, 1) - 1) +
				  Substring(@Cadena, CharIndex(']', @Cadena, CharIndex('[S:', @Cadena, 1) + 3) + 1, 5000)
	End
	While CharIndex('[P:', @Cadena, 1) <> 0
	Begin
		Set @Cadena 	= 	Substring(@Cadena, 1, CharIndex('[P:', @Cadena, 1) - 1) +
					Substring(@Cadena, CharIndex('[P:', @Cadena, 1) + 3, CharIndex(']', @Cadena, CharIndex('[P:', @Cadena, 1) + 3) - (CharIndex('[P:', @Cadena, 1) + 3)) +
					Substring(@Cadena, CharIndex(']', @Cadena, CharIndex('[P:', @Cadena, 1) + 3) + 1, 5000)	
	End
End

Set @Resultado = @Cadena

GO