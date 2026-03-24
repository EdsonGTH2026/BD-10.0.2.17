SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsRptID]
@ID 		Varchar(50),
@Parametro	Varchar(50),
@Reporte	Varchar(50),
@Valor		Varchar(50)
As

Print 'ID: ' + Isnull(@ID, 'Nulo') 		
Print @Parametro	
Print @Reporte	
Print @Valor		

Declare @Veces 	Int
Declare @Firma		Varchar(100)

Select	@Veces = Isnull(Veces, 0) , @Firma = Firma
From	tCsPrID
Where	[Id] = @Id And Parametro = @Parametro

If @Veces is null
Begin
	Set @Veces 	= 1
	Set @Firma 	= null
End
Else 
Begin
	Set @Veces = @Veces + 1
End

Delete From tCsPrID
Where		[Id] = @Id And Parametro = @Parametro

Insert 	Into tCsPrID 	([Id], 	Fecha, 		Reporte, 	Parametro, 	Valor, 		Veces,	Firma)
Values					(@Id, 	GetDate(), 	@Reporte, 	@Parametro,	@Valor,		@Veces, @Firma)
GO