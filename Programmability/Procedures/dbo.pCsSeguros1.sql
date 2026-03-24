SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Exec pCsSeguros1 1, 'pmartinezg', '017-156-06-02-00400-017SRR0304671'
CREATE Procedure [dbo].[pCsSeguros1]
	@Dato		Int,
	@Usuario	Varchar(50),
	@Codigo		Varchar(100)
As
--1: Se muestra poliza.
--2: Solo Procesa.
--Set @Usuario		= 'kvalera'
--Set @Codigo		= '002-116-06-07-00287-002FCE1609531'
--No se utiliza 
Declare @CodOficina		Varchar(4)
Declare @CodPrestamo	Varchar(30)
Declare @Contador		Int
Declare @Firma			Varchar(100)
Declare @NumPoliza		Varchar(50)

If @Codigo Is null 
Begin 
	Set @Codigo = '' 
End
Else 
Begin 
	Set @Codigo = Ltrim(rtrim(@Codigo))
End 

If ltrim(rtrim(Isnull(@Codigo, ''))) = ''
Begin
	If ltrim(rtrim(Isnull(@Codigo, ''))) = ''
	Begin 
		Select Top 1 @CodOficina = CodOficina from tcloficinas
		Where codOficina not in (99, 76, 71, 75)
		Order by newid()	

		Create Table #A
		(
		Codigo Varchar(100),
		Nombre Varchar(250)
		)

		Insert Into #A
		Exec pCsCboCuentaOperativa 9, @Usuario

		Select Top 1 @Codigo = Codigo, @CodPrestamo = Left(Codigo,19), @NumPoliza = Right(Codigo,13) From #A
		Order by newid()
		Drop Table #A
	End
	
	Update TsgUsuarios
	Set CodOficina	= @CodOficina
	Where Usuario	= @Usuario
End
Else
Begin
	Set @CodOficina	= Cast(Left(@Codigo,3) as int)
	Set @CodPrestamo	= Left(@Codigo,19)
	Set @NumPoliza	= Right(@Codigo,13)
End
Select	@CodOficina	= CodOficina
From	tSgUsuarios
Where	Usuario		= @Usuario 

Print @Codigo
Print @CodOficina 

If @Codigo <> ''
Begin
	SELECT     @Contador = COUNT(*) 
	FROM         (SELECT DISTINCT tCsFirmaReporteDetalle.Grupo
						   FROM          tCsFirmaElectronica INNER JOIN
												  tCsFirmaReporteDetalle ON tCsFirmaElectronica.Firma = tCsFirmaReporteDetalle.Firma
						   WHERE      (tCsFirmaElectronica.Dato = @CodPrestamo) AND (tCsFirmaReporteDetalle.Grupo IN ('G', 'I', 'A'))) Datos

	--Select @Codigo		As Codigo
	--Union
	--Select @CodPrestamo As Codigo
	--Union
	--Select Cast(@Contador As Varchar(30)) As Codigo
	Print @Contador
	IF @Contador < 3
	Begin
		Exec pCsReporteContrato 1, @Usuario, @CodOficina, @CodPrestamo
	End
	Else
	Begin
		SELECT   @Firma =  tCsFirmaElectronica.Firma
		FROM         tCsFirmaElectronica INNER JOIN
							  tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma
		WHERE     (tCsFirmaElectronica.Dato = '017-156-06-02-00400') And Sistema = 'CA'
	
		Exec pCsSegurosRegistro @CodPrestamo, @Firma
	End
	If @Dato = 1
	Begin
		Exec pCsSeguros @Usuario, '02', @NumPoliza
	End
	--Update tCsSeguros Set Firma = '' Where Firma = 'V01KAAARDGMT111003340307SE02-002CPE1112811002'
End

GO