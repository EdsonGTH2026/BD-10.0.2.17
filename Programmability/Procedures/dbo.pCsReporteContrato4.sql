SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--Exec pCsReporteContrato4 0, '', '', ''
--Exec	pCsReporteContrato1 18, 'KVALERA', 'ZZZ', '4CMM2804651'

CREATE Procedure [dbo].[pCsReporteContrato4]
@Dato			Int,
@Usuario		Varchar(50) ,
@Ubicacion		Varchar(500),
@Prestamo		Varchar(25)
AS
--@Dato
--0: Para ejeccuión de Prueba.
--1: Para Autorizacion de Registro de Huellas.
--2: Para Autorización de Consulta de Saldos de Ahorros.

Declare @Firma	Varchar(100)
Declare @Motivo	Varchar(1000)
 
If @Dato = 0
Begin
	Set @Usuario = 'kvalera' 
	Select Top 1 @Prestamo = Ltrim(rtrim(CodUsuario))
	From [BD-FINAMIGO-DC].Finmas.dbo.vUsHuellasAutorizacion 
	Order by NewId()	
End

If @Dato IN (0, 1)
Begin
	Set @Prestamo = Ltrim(Rtrim(@Prestamo))

	Exec pCsFirmaElectronica @Usuario, 'US', @Prestamo, @Firma Out
	
	Select @Motivo = Observacion
	From [BD-FINAMIGO-DC].Finmas.dbo.vUsHuellasAutorizacion 
	Where CodUsuario = @Prestamo
	
	Update tCsFirmaElectronica
	Set Motivo = @Motivo
	Where Firma = @Firma
	
	Exec	pCsReporteContrato1 18, @Usuario, @Ubicacion, @Prestamo
	
	UPDATE [BD-FINAMIGO-DC].Finmas.dbo.tUsUsuarios
	Set FirmaHuella = dbo.fdufechaatexto(getdate(),'DDMMAAAA') --@Firma
	Where CodUsuario = @Prestamo
End

If @Dato = 0
Begin 
	Delete From tCsFirmaElectronica
	Where Firma = @Firma
End 



GO