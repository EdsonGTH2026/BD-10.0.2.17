SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


CREATE FUNCTION [dbo].[fduEscaleraCartera] (
	@Fecha 		SmallDateTime, 
	@CodPrestamo 	Varchar(25),
	@Escalera	varchar(1),
	@Campo		Varchar(50)
	)  
RETURNS varchar(50)
AS  
BEGIN 	
	Declare @Resultado Varchar(50)
	If Upper(@Campo) = 'CODASESOR'
	Begin
		If @Escalera = 'S'
		Begin
			Select @Resultado = tCsCartera.CodAsesor From (
			SELECT  CodPrestamo,  MIN(Fecha) as Fecha
			FROM         tCsCartera
			WHERE     (Fecha > @Fecha) AND (CodPrestamo = @CodPrestamo)
			Group by CodPrestamo) Filtro Inner Join tCsCartera On tCsCartera.Codprestamo = Filtro.CodPrestamo
			And tCsCartera.Fecha = Filtro.Fecha
		End
		If @Escalera = 'B'
		Begin
			Select @Resultado = tCsCartera.CodAsesor From (
			SELECT  CodPrestamo,  MAX(Fecha) as Fecha
			FROM         tCsCartera
			WHERE     (Fecha < @Fecha) AND (CodPrestamo = @CodPrestamo)
			Group by CodPrestamo) Filtro Inner Join tCsCartera On tCsCartera.Codprestamo = Filtro.CodPrestamo
			And tCsCartera.Fecha = Filtro.Fecha
		End	
	End
	If Upper(@Campo) = 'FECHA'
	Begin
		If @Escalera = 'S'
		Begin
			Select @Resultado = 	Replicate('0', 4 - Len(Cast(Year (tCsCartera.Fecha) as varchar(4)))) + cast(Year (tCsCartera.Fecha) as Varchar(4)) +
						Replicate('0', 2 - Len(Cast(Month(tCsCartera.Fecha) as varchar(2)))) + cast(Month(tCsCartera.Fecha) as Varchar(2)) +
						Replicate('0', 2 - Len(Cast(Day  (tCsCartera.Fecha) as varchar(2)))) + cast(Day  (tCsCartera.Fecha) as Varchar(2))
			From (
			SELECT  CodPrestamo,  MIN(Fecha) as Fecha
			FROM         tCsCartera
			WHERE     (Fecha > @Fecha) AND (CodPrestamo = @CodPrestamo)
			Group by CodPrestamo) Filtro Inner Join tCsCartera On tCsCartera.Codprestamo = Filtro.CodPrestamo
			And tCsCartera.Fecha = Filtro.Fecha
		End
		If @Escalera = 'B'
		Begin
			Select @Resultado = 	Replicate('0', 4 - Len(Cast(Year (tCsCartera.Fecha) as varchar(4)))) + cast(Year (tCsCartera.Fecha) as Varchar(4)) +
						Replicate('0', 2 - Len(Cast(Month(tCsCartera.Fecha) as varchar(2)))) + cast(Month(tCsCartera.Fecha) as Varchar(2)) +
						Replicate('0', 2 - Len(Cast(Day  (tCsCartera.Fecha) as varchar(2)))) + cast(Day  (tCsCartera.Fecha) as Varchar(2))
			From (
			SELECT  CodPrestamo,  MAX(Fecha) as Fecha
			FROM         tCsCartera
			WHERE     (Fecha < @Fecha) AND (CodPrestamo = @CodPrestamo)
			Group by CodPrestamo) Filtro Inner Join tCsCartera On tCsCartera.Codprestamo = Filtro.CodPrestamo
			And tCsCartera.Fecha = Filtro.Fecha
		End	
	End
RETURN (@Resultado)	
END


GO