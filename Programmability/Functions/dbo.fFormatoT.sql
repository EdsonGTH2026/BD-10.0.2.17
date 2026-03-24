SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--OSC, 11/02/2016
--Funcion para dar formato a texto
CREATE FUNCTION [dbo].[fFormatoT](@Texto as varchar(150), @AnchoFijo as int, @Longitud as int, @Relleno as char, @Alineacion as char)
RETURNS varchar(200)
--WITH SCHEMABINDING 
AS
BEGIN
/*
declare @Texto varchar (20)
declare @AnchoFijo int
declare @Longitud int
declare @Relleno char
declare @Alineacion char

set @Texto = 'Hola'
set @AnchoFijo = 1
set @Longitud = 10
set @Relleno = '&'
set @Alineacion = 'D'
*/
	declare @x int
	declare @Cadena varchar(200)

	set @Cadena = ltrim(ltrim(@Texto))
	--print 'Cadena: ' + @Cadena

	if @AnchoFijo > 0 
		begin
			--print 'A'
			--si el texto el mayor a la longitud, la recorta, sino la rellena
			if len(@Cadena) > @Longitud
				begin
					--print 'A.1'
					set @Cadena = left(@Cadena, @Longitud)
				end
			else
				begin
					--print 'A.2'
					set @x = @Longitud - len(@Cadena)

					if upper(@Alineacion) = 'I'
						begin
							--print 'A.2.1'
							set @Cadena = @Cadena + replicate(@Relleno,@x)
						end
					else
						begin
							--print 'A.2.2'
							set @Cadena = replicate(@Relleno,@x) + @Cadena 
						end
					
				end
		end
	else
		begin
			--print 'B'
			--set @Cadena = @Cadena
			set @Cadena = left(@Cadena, @Longitud)

		end

--select @Cadena --comentar

	return @Cadena
END

GO