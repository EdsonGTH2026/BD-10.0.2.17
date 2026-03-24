SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[pCsRescateAsignacion]
@CodPrestamo	Varchar(25),
@Asesor 	Varchar(15),
@FI		SmallDateTime,
@FF		SmallDateTime
As

/*
Declare @CodPrestamo	Varchar(25)
Declare @Asesor 	Varchar(15)
Declare @FI		SmallDateTime
Declare @FF		SmallDateTime

Set @CodPrestamo	= ''--'001-116-06-00-00040'
Set @Asesor 		= 'CYB1109771'
Set @FI			= '20091101'
Set @FF			= '20091130'
*/
Declare @Observacion 	Varchar(500)
Declare @Error		Int
Declare @FT		SmallDateTime

Set @Error 		= 0
Set @CodPrestamo 	= Ltrim(Rtrim(@CodPrestamo))

If Ltrim(Rtrim(@CodPrestamo)) = '' Begin Set @Asesor 	= '' End

If @FI > @FF
Begin
	Set @FT = @FI
	Set @FI = @FF
	Set @FF = @FT
End

If Not Exists (SELECT CodUsuario FROM tCsPadronClientes WHERE (CodUsuario = @Asesor)) And @CodPrestamo <> '' And @Asesor <> ''
Begin
	Set @Observacion = 'El Código Ingresado del Asesor es Incorrecto'		
End
Else
Begin
	If @CodPrestamo <> '' And @Asesor <> ''
	Begin
		UPDATE    tCsPadronCarteraDet
		SET       Sectorista2 = @Asesor, S2Inicio = @FI, S2Fin = @FF
		WHERE     (CodPrestamo = @CodPrestamo)	
		
		Set @Observacion = 'Fueron Afectadas ' + cast(@@Rowcount as Varchar(100)) + ' Filas' + char(10)	
		
		UPDATE    tCsCartera
		SET              Sectorista2 = tCsPadronCarteraDet.Sectorista2
		FROM         tCsPadronCarteraDet INNER JOIN
		                      tCsCartera ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.S2Inicio <= tCsCartera.Fecha AND 
		                      tCsPadronCarteraDet.S2Fin >= tCsCartera.Fecha
		WHERE     (tCsPadronCarteraDet.CodPrestamo = @CodPrestamo)	

		Set @Observacion = @Observacion + 'Fueron Afectadas ' + cast(@@Rowcount as Varchar(100)) + ' Filas'	
	End	
	Else
	Begin
		UPDATE    tCsCartera
		SET              Sectorista2 = tCsPadronCarteraDet.Sectorista2
		FROM         tCsPadronCarteraDet INNER JOIN
		                      tCsCartera ON tCsPadronCarteraDet.CodPrestamo = tCsCartera.CodPrestamo AND tCsPadronCarteraDet.S2Inicio <= tCsCartera.Fecha AND 
		                      tCsPadronCarteraDet.S2Fin >= tCsCartera.Fecha
		Where  Ltrim(Rtrim(Isnull(tCsPadronCarteraDet.Sectorista2, ''))) <> ''

		Set @Observacion = 'Fueron Afectadas ' + cast(@@Rowcount as Varchar(100)) + ' Filas' + char(10)	
	End
End

Select @Observacion As Observacion
GO