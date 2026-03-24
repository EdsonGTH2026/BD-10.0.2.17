SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fduDSM] (@Fecha SmallDateTime, @Formato Varchar(2))  
RETURNS Varchar(100)
AS  
BEGIN

Declare @Resultado	Varchar(100)
Declare @Parte		Varchar(1)
Declare @N			Int
Declare @L			Varchar(100)
Declare @FI			SmallDateTime
Declare @FF			SmallDateTime

Set @Formato	=	Upper	(@Formato)
Set @Parte		=	Left	(@Formato, 1)
Set @Formato	=	Right	(@Formato, 1)
Set @FI			=	DateAdd(m, datepart(m, Convert(datetime, Convert(varchar(12), @Fecha)))-1, Convert(datetime, 'jan 1 ' + Convert(varchar(5), datepart(yy, Convert(datetime, Convert(varchar(12), @Fecha))))))
Set @FF			=	DateAdd(y, -1, DateAdd(m, datepart(m, Convert(datetime, Convert(varchar(12), @Fecha))), Convert(datetime, 'jan 1 ' + Convert(varchar(5), datepart(yy, Convert(datetime, Convert(varchar(12), @Fecha)))))))

If @Parte		=	'D'
Begin
	Set @N		=	DatePart(dw, @Fecha)
	Set @L		=	Case @N
						 When 1 Then 'Domingo'
						 When 2 Then 'Lunes'
						 When 3 Then 'Martes'
						 When 4 Then 'Miércoles'
						 When 5 Then 'Jueves'
						 When 6 Then 'Viernes'
						 When 7 Then 'Sábado'
					End			  
End
If @Parte		= 'S'
Begin
	Set @N		=	Case	
						When datediff(wk, @FI, @Fecha) = 0 and datepart(dd, @Fecha) <= 7 then 1
						When datediff(wk, @FI, @Fecha) = 1 and datepart(dd, @Fecha) <=14 then 2
						When datediff(wk, @FI, @Fecha) = 2 and datepart(dd, @Fecha) <=21 then 3
						When datediff(wk, @FI, @Fecha) = 3 and datepart(dd, @Fecha) <=28 then 4
						When datediff(wk, @FI, @Fecha) = 4 and datepart(dd, @Fecha) <=35 then 5
						When datediff(wk, @FI, @Fecha) = 5 and datepart(dd, @Fecha) <=35 then 6
					End	
	
	Set @L		=	Case @N
						 When 1 Then 'Primera Semana'
						 When 2 Then 'Segunda Semana'
						 When 3 Then 'Tercera Semana'
						 When 4 Then 'Cuarta Semana'
						 When 5 Then 'Quinta Semana'
						 When 6 Then 'Sexta Semana'						 
					End	
End
If @Parte		= 'M'
Begin
	Set @N		=	DatePart(m, @Fecha)
	Set @L		=	Case @N
						When 1	Then 'Enero'
						When 2	Then 'Febrero'
						When 3	Then 'Marzo'
						When 4	Then 'Abril'
						When 5	Then 'Mayo'
						When 6	Then 'Junio'
						When 7	Then 'Julio'
						When 8	Then 'Agosto'
						When 9	Then 'Septiembre'
						When 10 Then 'Octubre'
						When 11 Then 'Noviembre'
						When 12 Then 'Diciembre'
					End	
End
	
Set @Resultado = Case @Formato When 'N' Then Cast(@N as Varchar(5)) When 'L' Then @L end

RETURN (@Resultado)
END
GO