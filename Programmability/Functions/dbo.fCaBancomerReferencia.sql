SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE function [dbo].[fCaBancomerReferencia] (
   @cadena varchar(20)
)
RETURNS varchar(20)
--WITH ENCRYPTION
AS
BEGIN
	
	--declare @cadena varchar(20)
	declare @cadena2 varchar(20)
	declare @cadena3 varchar(20)
	declare @longitud int
	declare @index int
	declare @caracter varchar(1)
	declare @caracter2 varchar(1)
	declare @numero int
	declare @numero2 int
	declare @numero3 int
	declare @suma int
	
	declare @DecenaInf int
	declare @DecenaSup int
	declare @Diferencia int
	declare @Referencia varchar(20)

	declare @PrintShow bit
	set @PrintShow=0
	
	--set @cadena = 'abcdefghi1234567890' --PRUEBA COMENTAR
	--set @cadena = 'AZ00035SG00002L87' --PRUEBA COMENTAR
	
	/*
	1.	En caso de que la Referencia contenga letras se deberán substituir por su correspondiente número de acuerdo a la siguiente tabla.
	
	A = 1	B = 2	C = 3	D = 4	E = 5	F= 6	G = 7	H = 8	I = 9
	J = 1	K = 2	L = 3	M = 4	N = 5	O = 6	P = 7	Q = 8	R = 9
	S = 1	T = 2	U = 3	V = 4	W = 5	X = 6	Y = 7	Z = 8	
	*/
	set @cadena = ltrim(rtrim(@cadena))
	set @longitud = len(@cadena)

	set @cadena2 = ''
	
	set @index = 1
	while @index <= @longitud
	begin
		select @caracter = substring(@cadena,@index,1)
		--if @PrintShow=1 print '@index=' +convert(varchar,@index) + ', @caracter = ' + @caracter
		
		--reemplaza cada caracter por un numero
		select @caracter2 = dbo.fCaBancomerConversion(@caracter) 
		--		if @PrintShow=1 print '@caracter = ' + @caracter + ', @caracter2=' + @caracter2
		set @cadena2 = @cadena2 + @caracter2
		--incrementa el index
		set @index = @index +1
	end
	
	--if @PrintShow=1 print '@cadena2=' + @cadena2
	
	--====================================================
	/*
	2.	De derecha a izquierda se van multiplicando cada uno de los dígitos por los números 2 y 1, siempre iniciando la secuencia con el número 2 aun cuando el número a multiplicar sea 0 deberá tomarse en cuenta. Si el resultado de multiplicar el número 2 por el dígito de la referencia es mayor a 9, se deberán sumar las unidades y las decenas , de tal forma que solo se tenga como resultado un número menor 0 igual a 9.
	
	1     8     0    0     0     3     5     1     7	0     0     0      0     2     3     8     7
	*     *     *    *     *     *     *     *     *	*     *     *	   *     *     *     *     *
	2     1     2    1     2     1     2     1     2	1     2     1      2     1     2     1     2
	=     =     =    =     =     =     =     =     =    =     =     =      =     =     =     =     =
	2     8     0    0     0	 3    1+0	 1    1+4	0     0     0      0     2     6     8	  1+4
	
	3.	Se suman todos los resultados de las multiplicaciones del punto 1.
	2 + 8 + 0 + 0 + 0 + 3 + 1 +  1 + 5 + 0 + 0 + 0 +  0 + 2 + 6+ 8  + 5 = 41  
	*/
	--print '======================================'
	set @suma=0
	--Invierte la cadena
	set @cadena3 = reverse(@cadena2)
	--if @PrintShow=1 print '@cadena3= ' + @cadena3
	
	set @longitud = len(@cadena3)
	set @index = 1
	while @index <= @longitud
	begin
		select @caracter = substring(@cadena3,@index,1)
		--if @PrintShow=1 print '@index=' +convert(varchar,@index) + ', @caracter = ' + @caracter
		set @numero = convert(int,@caracter)
		--if @PrintShow=1 print '@caracter=' + @caracter + ', @numero=' + convert(varchar,@numero)
	
		if (@index % 2) = 0
		begin
			--if @PrintShow=1 print 'index=' + convert(varchar,@index) + ' es par'
			--se multiplica x 1
			set @numero2 = @numero * 1
			--if @PrintShow=1 print '@numero * 1 = ' +convert(varchar,@numero2)
		end
		if (@index % 2) = 1
		begin
			--if @PrintShow=1 print 'index=' + convert(varchar,@index) + ' es impar'
			--se multiplica x 2
			set @numero2 = @numero * 2
			--if @PrintShow=1 print '@numero * 2 = ' +convert(varchar,@numero2)
		end
	
		if @numero2 > 9
			begin
				select @numero3 = (case @numero2
				when 10 then 1 --1+0
				when 11 then 2 --1+1
				when 12 then 3 --1+2
				when 13 then 4 --1+3
				when 14 then 5 --1+4
				when 15 then 6 --1+5
				when 16 then 7 --1+6
				when 17 then 8 --1+7
				when 18 then 9 --1+8
				end)
			end
		else
			begin
				set @numero3 = @numero2
			end
		
		--if @PrintShow=1 print '@numero2=' + convert(varchar,@numero2) + ', @numero3=' + convert(varchar,@numero3)			
		set @suma = @suma + @numero3
		--if @PrintShow=1 print '@suma= ' + convert(varchar,@suma)
	
		--set @cadena2 = @cadena2 + @caracter2
		--incrementa el index
		set @index = @index +1
	end

	/*
	4.	El resultado de la suma indicada en el punto 2, deberá restársele a la decena superior mas próxima. El resultado de esta substracción será el dígito verificador.
	
	50 - 41 = 9
	
	Dígito Verificador: 9
	*/
	
	select @DecenaInf = round(@suma, -1,1)
	set @DecenaSup = @DecenaInf + 10
	
	--if @PrintShow=1 print '@suma=' + convert(varchar,@suma) + ',@DecenaInf=' + convert(varchar,@DecenaInf) + ',@DecenaSup=' + convert(varchar,@DecenaSup)
	
	set @Diferencia = @DecenaSup - @suma
	--if @PrintShow=1 print '@Diferencia= ' + convert(varchar,@Diferencia)
	
	/*
	5.	A la referencia se le agregara el dígito verificador y esa será la línea de captura que recibirá el cajero en ventanilla. 
	
	Referencia Completa: AZ00035SG00002L879
	*/
	
	if @Diferencia <= 9
		begin
			set @Referencia = @cadena + convert(varchar,@Diferencia)
		end
	else
		begin
			set @Referencia = @cadena + '0'
		end
	
	--if @PrintShow=1 print '@Referencia = ' + @Referencia  
	
	return (@Referencia)

END


GO