SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fduSecuenciaCAProductivo] (@CodPrestamo Varchar(50), @CodUsuario Varchar(25), @Desembolso SmallDateTime, @codproducto varchar(20))
RETURNS Decimal (13, 2)
AS  
BEGIN 	
	Declare @Resultado 	Decimal(13,2)
	Declare @Incremento	Decimal(13,2)
		
	SELECT  @Resultado  =   COUNT(*) 
	FROM  (
		SELECT DISTINCT CodPrestamo, Desembolso, CodUsuario
		FROM          tCsPadronCarteraDet with(nolock)
		WHERE     (Desembolso <= @Desembolso) And (CodUsuario = @CodUsuario)  and codproducto in(select codigo from dbo.fduTablaValores(@codproducto))
	) Datos
	
	
	--SELECT  @Incremento  =   COUNT(*)  - 1
	--FROM         (SELECT DISTINCT CodPrestamo, Desembolso, CodUsuario
	--	                    FROM          tCsPadronCarteraDet with(nolock)
	--						) Datos
	--WHERE     (Desembolso = @Desembolso) And (CodPrestamo <= @CodPrestamo) And (CodUsuario = @CodUsuario) 

--RETURN (@Resultado - @Incremento)
	return isnull(@Resultado,0)
END


GO