SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[fduCIDAA] (@Fecha SmallDateTime, @Cliente Varchar(15))  
RETURNS Varchar(1)
AS  
BEGIN 
	Declare @Resultado 	Varchar(1)
	Declare @PrimerDia 	SmallDateTime	
	Declare @Contador 	Int	
	Declare @DiasAtraso 	Float

	SELECT @PrimerDia = PrimerDia
	FROM         tClPeriodo
	WHERE     (Periodo = (Case When Month(@Fecha) <> 12 Then dbo.fduFechaAPeriodo(@Fecha) - 99 Else dbo.fduFechaAPeriodo(@Fecha) - 11 End))	
		
	SELECT TOP 1 @Resultado = IAtrasoMes
	FROM         tCsDiasAtraso INNER JOIN
	                      tClPeriodo ON tCsDiasAtraso.Fecha = tClPeriodo.UltimoDia
	WHERE        (tCsDiasAtraso.CodUsuario = @Cliente) AND Fecha >= @PrimerDia and Fecha <= @Fecha
	ORDER BY IAtrasoMes DESC

	IF @Resultado Is Null
		Begin
			SELECT TOP 1 @Resultado = IAtrasoMes
			FROM         tCsDiasAtraso 
			WHERE        (tCsDiasAtraso.CodUsuario = @Cliente) AND Fecha = @Fecha						
		End	
	
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

	If @Resultado = 'G'
		Begin
			SELECT  @Contador = Count(*)
			FROM      tCsDiasAtraso 
			WHERE   (tCsDiasAtraso.CodUsuario = @Cliente) AND Fecha >=  @Fecha - 121 And Fecha <= @Fecha  And IAtrasoDia = 'G' And Aceptado = 1
		End
	If @Contador > 120
		Begin
			Set @Resultado = 'H'	
		End
	
RETURN (@Resultado)	
END








GO