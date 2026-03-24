SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO

CREATE Procedure [dbo].[pCsCboFilaReporte]
As 
Declare @Limite Int
Declare @Paso	Int
Declare @Cadena	Varchar(4000)

Create Table #Paso ( Paso Int)

Set 	@Limite = 100
Set 	@paso 	= 0	 
While @Paso < @Limite
Begin
	Set @Paso = @Paso + 1
	Insert Into #Paso (Paso) Values(@Paso)
End
Select * from #Paso
GO