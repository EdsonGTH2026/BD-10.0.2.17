SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCRAdministraClaves]
@CodOficina 	Varchar(4),  
@Proceso 	Varchar(25), 
@Empresa	Varchar(2),
@Actual		Varchar(15), 
@Nuevo	Varchar(15), 
@Estado	Varchar(50)
AS

Declare @CodUsuarioA	Varchar(15)
Declare @CodUsuarioN	Varchar(15)
Declare @Contador	Int
Declare @Cambio 	DateTime
Declare @ID		Int
Declare @IDReal		Int
SELECT  @Actual		= tCREmpresaUsuarios.ClaveOtorgante, 
	@CodusuarioA	= tCREmpresaUsuarios.CodUsuario
FROM         tCREmpresaUsuarios INNER JOIN
                      tCREmpresas ON tCREmpresaUsuarios.Empresa = tCREmpresas.Empresa
WHERE     (tCREmpresaUsuarios.ClaveOtorgante = @Actual) AND (tCREmpresas.Empresa = @Empresa)

IF @Proceso = 'CO'
BEGIN
	SELECT     tCREmpresas.Empresa AS Empresa, tCRUsuarios.Cargo, tCsPadronClientes.NombreCompleto, 
	                     tCREmpresaUsuarios.ClaveOtorgante,  tCREmpresaUsuarios.Contraseña, tCREmpresaUsuarios.Expira, tCREmpresaUsuarios.Consulta, tCREmpresaUsuarios.Estado
	FROM         tCREmpresaUsuarios INNER JOIN
	                      tCRUsuarios ON tCREmpresaUsuarios.CodUsuario = tCRUsuarios.CodUsuario INNER JOIN
	                      tCREmpresas ON tCREmpresaUsuarios.Empresa = tCREmpresas.Empresa INNER JOIN
	                      tCsPadronClientes ON tCRUsuarios.CodUsuario = tCsPadronClientes.CodUsuario
	WHERE     (tCRUsuarios.CodOficina = @CodOficina) And tCREmpresaUsuarios.Empresa = @Empresa
	UNION ALL
	SELECT     tCREmpresas.Empresa AS Empresa, tCRUsuarios.Cargo, tCsPadronClientes.NombreCompleto, 
	                     tCREmpresaUsuarios.ClaveOtorgante, tCREmpresaUsuarios.Contraseña, tCREmpresaUsuarios.Expira, tCREmpresaUsuarios.Consulta, tCREmpresaUsuarios.Estado
	FROM         tCsPadronClientes INNER JOIN
	                      tCRUsuarios ON tCsPadronClientes.CodUsuario = tCRUsuarios.CodUsuario RIGHT OUTER JOIN
	                      tCREmpresaUsuarios INNER JOIN
	                      tCREmpresas ON tCREmpresaUsuarios.Empresa = tCREmpresas.Empresa ON tCRUsuarios.CodUsuario = tCREmpresaUsuarios.CodUsuario
	WHERE     (tCREmpresaUsuarios.CodUsuario = 'VVK2402811') AND Estado Not in ('Cancelado') And tCREmpresaUsuarios.Empresa = @Empresa
END
IF @Proceso = 'CC'
BEGIN
	SELECT  @Empresa 	= tCREmpresaUsuarios.Empresa, 
		@Nuevo		= tCREmpresaUsuarios.ClaveOtorgante, 
		@CodusuarioN	= tCREmpresaUsuarios.CodUsuario
	FROM         tCREmpresaUsuarios INNER JOIN
	                      tCREmpresas ON tCREmpresaUsuarios.Empresa = tCREmpresas.Empresa
	WHERE     (tCREmpresaUsuarios.ClaveOtorgante = @Nuevo) AND (tCREmpresas.Empresa = @Empresa)
	
	IF 	@Empresa 	Is Not Null AND
		@Actual		Is Not Null AND
		@CodusuarioA	Is Not Null AND
		@Nuevo		Is Not Null AND
		@CodusuarioN	Is Not Null
	BEGIN
		Set @Contador 	= 0
		Set @Cambio 	= GetDate()
		Set @ID 	= DatePart(yy, @Cambio) + DatePart(qq, @Cambio) + DatePart(mm, @Cambio) +
				  DatePart(dy, @Cambio) + DatePart(dd, @Cambio) + DatePart(wk, @Cambio) +
				  DatePart(dw, @Cambio) + DatePart(hh, @Cambio) + DatePart(mi, @Cambio) +
				  DatePart(ss, @Cambio) + DatePart(ms, @Cambio) 

		Insert Into tCRCambios
		Select @ID, @Cambio, DatePart(yy, GetDate()) + DatePart(qq, GetDate()) + DatePart(mm, GetDate()) +
		DatePart(dy, GetDate()) + DatePart(dd, GetDate()) + DatePart(wk, GetDate()) +
		DatePart(dw, GetDate()) + DatePart(hh, GetDate()) + DatePart(mi, GetDate()) +
		DatePart(ss, GetDate()) + DatePart(ms, GetDate()) ,*
		From tCREmpresaUsuarios
		WHERE Empresa = @Empresa AND ClaveOtorgante = @Actual AND CodUsuario = @CodusuarioA

		UPDATE tCREmpresaUsuarios
		Set 	CodUsuario 	= @CodusuarioN,
			Consulta	= GetDate(),
			Estado 		= 'Cancelado',
			EnviaCorreo 	= 0
		WHERE Empresa = @Empresa AND ClaveOtorgante = @Actual AND CodUsuario = @CodusuarioA
		Set @Contador = @@RowCount

		Insert Into tCRCambios
		Select @ID, @Cambio, DatePart(yy, GetDate()) + DatePart(qq, GetDate()) + DatePart(mm, GetDate()) +
		DatePart(dy, GetDate()) + DatePart(dd, GetDate()) + DatePart(wk, GetDate()) +
		DatePart(dw, GetDate()) + DatePart(hh, GetDate()) + DatePart(mi, GetDate()) +
		DatePart(ss, GetDate()) + DatePart(ms, GetDate()) ,*
		From tCREmpresaUsuarios
		WHERE Empresa = @Empresa AND ClaveOtorgante = @Actual AND CodUsuario = @CodusuarioN		

		Set @Cambio 	= GetDate()
		Set @ID 	= DatePart(yy, @Cambio) + 
				  DatePart(qq, @Cambio) + 
				  DatePart(mm, @Cambio) +
				  DatePart(dy, @Cambio) + 
				  DatePart(dd, @Cambio) +
				  DatePart(wk, @Cambio) +
				  DatePart(dw, @Cambio) +
				  DatePart(hh, @Cambio) +
				  DatePart(mi, @Cambio) +
				  DatePart(ss, @Cambio) +
				  DatePart(ms, @Cambio) 

		Insert Into tCRCambios
		Select @ID, @Cambio, DatePart(yy, GetDate()) + DatePart(qq, GetDate()) + DatePart(mm, GetDate()) +
		DatePart(dy, GetDate()) + DatePart(dd, GetDate()) + DatePart(wk, GetDate()) +
		DatePart(dw, GetDate()) + DatePart(hh, GetDate()) + DatePart(mi, GetDate()) +
		DatePart(ss, GetDate()) + DatePart(ms, GetDate()) ,*
		From tCREmpresaUsuarios
		WHERE Empresa = @Empresa AND ClaveOtorgante = @Nuevo AND CodUsuario = @CodusuarioN

		UPDATE tCREmpresaUsuarios
		Set 	CodUsuario 	= @CodusuarioA,
			Consulta	= GetDate(),
			Estado 		= 'Todo Bien',
			EnviaCorreo	= 1
		WHERE Empresa = @Empresa AND ClaveOtorgante = @Nuevo AND CodUsuario = @CodusuarioN
		Set @Contador = @Contador + @@RowCount
		
		Insert Into tCRCambios
		Select @ID, @Cambio, DatePart(yy, GetDate()) + DatePart(qq, GetDate()) + DatePart(mm, GetDate()) +
		DatePart(dy, GetDate()) + DatePart(dd, GetDate()) + DatePart(wk, GetDate()) +
		DatePart(dw, GetDate()) + DatePart(hh, GetDate()) + DatePart(mi, GetDate()) +
		DatePart(ss, GetDate()) + DatePart(ms, GetDate()) ,*
		From tCREmpresaUsuarios
		WHERE Empresa = @Empresa AND ClaveOtorgante = @Nuevo AND CodUsuario = @CodusuarioA
	
		If @Contador = 2
		Begin
			SELECT MENSAJE = 'CAMBIO DE CLAVE DE OTORGANTE REALIZADO CON EXITO'
		End
		Else
		Begin
			SELECT MENSAJE = 'NO SE PUDO HACER EL CAMBIO DE CLAVES DE OTORGANTE'
		End
	END
	ELSE
	BEGIN
		SELECT MENSAJE = 'NO SE PUDO HACER EL CAMBIO DE CLAVES DE OTORGANTE'
	END
END
IF @Proceso = 'CE'
BEGIN
	IF 	@Empresa 	Is Not Null AND
		@Actual		Is Not Null AND
		@CodusuarioA	Is Not Null 
	BEGIN
		Set @Contador = 0

		Set @Cambio 	= GetDate()
		Set @ID 	= DatePart(yy, @Cambio) + 
				  DatePart(qq, @Cambio) + 
				  DatePart(mm, @Cambio) +
				  DatePart(dy, @Cambio) + 
				  DatePart(dd, @Cambio) +
				  DatePart(wk, @Cambio) +
				  DatePart(dw, @Cambio) +
				  DatePart(hh, @Cambio) +
				  DatePart(mi, @Cambio) +
				  DatePart(ss, @Cambio) +
				  DatePart(ms, @Cambio) 

		Insert Into tCRCambios
		Select @ID, @Cambio, DatePart(yy, GetDate()) + DatePart(qq, GetDate()) + DatePart(mm, GetDate()) +
		DatePart(dy, GetDate()) + DatePart(dd, GetDate()) + DatePart(wk, GetDate()) +
		DatePart(dw, GetDate()) + DatePart(hh, GetDate()) + DatePart(mi, GetDate()) +
		DatePart(ss, GetDate()) + DatePart(ms, GetDate()) ,*
		From tCREmpresaUsuarios
		WHERE Empresa = @Empresa AND ClaveOtorgante = @Actual AND CodUsuario = @CodusuarioA

		UPDATE tCREmpresaUsuarios
		Set 	Consulta	= GetDate(),
			Estado 		= @Estado
		WHERE Empresa = @Empresa AND ClaveOtorgante = @Actual AND CodUsuario = @CodusuarioA		
		Set @Contador = @@RowCount
		
		Insert Into tCRCambios
		Select @ID, @Cambio, DatePart(yy, GetDate()) + DatePart(qq, GetDate()) + DatePart(mm, GetDate()) +
		DatePart(dy, GetDate()) + DatePart(dd, GetDate()) + DatePart(wk, GetDate()) +
		DatePart(dw, GetDate()) + DatePart(hh, GetDate()) + DatePart(mi, GetDate()) +
		DatePart(ss, GetDate()) + DatePart(ms, GetDate()) ,*
		From tCREmpresaUsuarios
		WHERE Empresa = @Empresa AND ClaveOtorgante = @Actual AND CodUsuario = @CodusuarioA	

		--If @Contador = 1
		--Begin SELECT MENSAJE = 'CAMBIO DE ESTADO REALIZADO CON EXITO' End
		--Else
		--Begin
			--SELECT MENSAJE = 'NO SE PUDO HACER EL CAMBIO DE ESTADO'
		--End
	END
	ELSE
	BEGIN
		SELECT MENSAJE = 'NO SE PUDO HACER EL CAMBIO DE ESTADO'
	END
END
IF @Proceso = 'EC'
BEGIN
	DECLARE @EmpresaN		Varchar(100)
	DECLARE @CC			Varchar(200)
	DECLARE @CCPredefinido		Bit
	DECLARE @IPConsolidado		Varchar(50)
	DECLARE @BaseConsolidado	Varchar(50)
	
	UPDATE tCREmpresaUsuarios
	SET EnviaCorreo = 0

	UPDATE tCREmpresaUsuarios
	SET EnviaCorreo = 1
	WHERE Empresa = @Empresa AND ClaveOtorgante = @Actual

	SELECT     @EmpresaN = Nombre
	FROM         tCREmpresas
	WHERE     (Empresa = @Empresa)
	
	Set @CC			= 'kvalera@financierafinamigo.com.mx; eburgos@financierafinamigo.com.mx; hguzman@financierafinamigo.com.mx'
	Set @CCPredefinido	= 1
	Set @IpConsolidado	= '10.0.1.13'
	Set @BaseConsolidado	= 'FinamigoConsolidado'
	
	Exec VALERCOM.master.dbo.pCsCREnvioCorreo @EmpresaN, @CC, @CCPredefinido, @IPConsolidado, @BaseConsolidado	

END
GO