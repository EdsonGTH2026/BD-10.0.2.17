SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fduCIDAM] (@Fecha SmallDateTime, @Cliente Varchar(15))  
RETURNS Varchar(1)
AS  
BEGIN 
	Declare @Resultado Varchar(1)
	Declare @PrimerDia SmallDateTime	
	Declare @DiasAtraso Float	

	SELECT @PrimerDia = PrimerDia
	FROM         tClPeriodo
	WHERE     (Periodo = dbo.fduFechaAPeriodo(@Fecha))	

	SELECT     TOP 1 @Resultado = IAtrasoDia
	FROM         tCsDiasAtraso
	Where Fecha >= @PrimerDia and Fecha <= @Fecha And CodUsuario = @Cliente
	ORDER BY IAtrasoDia DESC
	
	If @Resultado = 'G'
		Begin
			SELECT @DiasAtraso = DiasAtraso
			FROM         tCsDiasAtraso 
			WHERE        (tCsDiasAtraso.CodUsuario = @Cliente) AND Fecha = @Fecha And Aceptado = 1
		End
	If  @DiasAtraso <= 90
		Begin
			Set @Resultado = 'F'	
		End
	
RETURN (@Resultado)	
END




GO