SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  UserDefinedFunction [dbo].[fduSecuenciaCartera]    Script Date: 01/27/2011 21:58:38 ******/

-- Drop Function fduSecuenciaCliente

CREATE FUNCTION [dbo].[fduSecuenciaCliente] (@Dato Int, @CodUsuario Varchar(50), @Fecha SmallDateTime)  
RETURNS Decimal (13, 2)
AS  
BEGIN 	
	-- 1: Secuencia General.
	-- 2: Secuencia Oficina.
	
	Declare @Resultado 	Decimal(13,2)
	Declare @Incremento	Decimal(13,2)
	Declare @Registro	SmallDateTime
	Declare @Codoficina	Varchar(4)

	If @Dato = 1
	Begin
		Select @Registro = Registro from (
		Select CodUsuario, MIN(Registro) as Registro from TcspadronClientesTipo with(nolock)
		where fecha = @Fecha 
		Group by CodUsuario) Datos
		Where codUSuario = @CodUsuario

		SELECT  @Resultado  =   COUNT(*) 
				FROM         
		(Select CodUsuario, MIN(Registro) as Registro from TcspadronClientesTipo with(nolock)
		where fecha = @Fecha 
		Group by CodUsuario) Datos
				WHERE     (Registro <= @Registro)

		SELECT  @Incremento  =   COUNT(*)  - 1
				FROM         
		(Select CodUsuario, MIN(Registro) as Registro from TcspadronClientesTipo with(nolock)
		where fecha = @Fecha 
		Group by CodUsuario) Datos
		WHERE     (Registro = @Registro) And CodUsuario <= @CodUsuario
	End
	If @Dato = 2
	Begin
		
		Select @Registro = Registro, @CodOficina = CodOficina  from (
		Select CodUsuario, CodOficinaFinal as CodOficina, MIN(Registro) as Registro 
		From TcspadronClientesTipo with(nolock)
		where fecha = @Fecha 
		Group by CodUsuario, CodOficinaFinal) Datos
		Where codUSuario = @CodUsuario

		SELECT  @Resultado  =   COUNT(*) 
				FROM         
		(Select CodUsuario, MIN(Registro) as Registro from TcspadronClientesTipo with(nolock)
		where fecha = @Fecha  and CodOficinaFinal = @CodOficina
		Group by CodUsuario) Datos
				WHERE     (Registro <= @Registro)

		SELECT  @Incremento  =   COUNT(*)  - 1
				FROM         
		(Select CodUsuario, MIN(Registro) as Registro from TcspadronClientesTipo with(nolock)
		where fecha = @Fecha and CodOficinaFinal = @CodOficina
		Group by CodUsuario) Datos
		WHERE     (Registro = @Registro) And CodUsuario <= @CodUsuario
	End	
RETURN (@Resultado - @Incremento)	
END

GO