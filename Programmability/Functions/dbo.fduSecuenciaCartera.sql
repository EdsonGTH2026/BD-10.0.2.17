SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fduSecuenciaCartera] (@Dato Int, @CodPrestamo Varchar(50), @CodGrupo Varchar(10), @CodUsuario Varchar(25), @Desembolso SmallDateTime, @CodOficina Varchar(4))  
RETURNS Decimal (13, 2)
AS  
BEGIN 	
	Declare @Resultado 	Decimal(13,2)
	Declare @Incremento	Decimal(13,2)

	If @Dato = 1
	Begin
		SELECT  @Resultado  =   COUNT(*) 
		FROM         (SELECT DISTINCT CodPrestamo, Desembolso
		                       FROM          tCsPadronCarteraDet with(nolock)) Datos
		WHERE     (Desembolso <= @Desembolso)
	
		SELECT  @Incremento  =   COUNT(*)  - 1
		FROM         (SELECT DISTINCT CodPrestamo, Desembolso
		                       FROM          tCsPadronCarteraDet with(nolock)) Datos
		WHERE     (Desembolso = @Desembolso) And CodPrestamo <= @CodPrestamo
	End
	If @Dato = 2
	Begin
		
		If @CodGrupo Is null
		Begin
			Set @CodGrupo = @CodUsuario
		End
		
		SELECT  @Resultado  =   COUNT(*) 
		FROM         (SELECT DISTINCT CodPrestamo, Desembolso, CodGrupo = Isnull(CodGrupo, CodUsuario), CodOficina
		                       FROM          tCsPadronCarteraDet with(nolock)) Datos
		WHERE     (Desembolso <= @Desembolso) And (CodGrupo = @CodGrupo)   --And (CodOficina = @CodOficina)
	
		SELECT  @Incremento  =   COUNT(*)  - 1
		FROM         (SELECT DISTINCT CodPrestamo, Desembolso, CodGrupo = Isnull(CodGrupo, CodUsuario), CodOficina
		                       FROM          tCsPadronCarteraDet with(nolock)) Datos
		WHERE     (Desembolso = @Desembolso) And (CodPrestamo <= @CodPrestamo) And (CodGrupo = @CodGrupo)  --And (CodOficina = @CodOficina)
	End
	If @Dato = 3
	Begin
		SELECT  @Resultado  =   COUNT(*) 
		FROM         (SELECT DISTINCT CodPrestamo, Desembolso, CodUsuario
		                       FROM          tCsPadronCarteraDet with(nolock)) Datos
		WHERE     (Desembolso <= @Desembolso) And (CodUsuario = @CodUsuario) 
	
		SELECT  @Incremento  =   COUNT(*)  - 1
		FROM         (SELECT DISTINCT CodPrestamo, Desembolso, CodUsuario
		                       FROM          tCsPadronCarteraDet with(nolock)) Datos
		WHERE     (Desembolso = @Desembolso) And (CodPrestamo <= @CodPrestamo) And (CodUsuario = @CodUsuario) 
	End
RETURN (@Resultado - @Incremento)	
END

GO