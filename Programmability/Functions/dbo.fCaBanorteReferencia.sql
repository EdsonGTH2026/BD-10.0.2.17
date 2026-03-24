SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE function [dbo].[fCaBanorteReferencia] (
   @CadenaInicial varchar(20),
   @NumEmpresa varchar(5)
)
RETURNS varchar(20)
--WITH ENCRYPTION
AS
BEGIN
	--declare @CadenaInicial varchar(20)
	--set @CadenaInicial = 'JP13H679'
    
	--declare @NumEmpresa varchar(5)
	--set @NumEmpresa = '315'

	declare @CadenaLen int
	declare @cadena2 varchar(20)
    declare @cadena3 varchar(20)
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

    set @PrintShow = 0
	
	/*
       1. En caso de que la cadena inicial contenga letras se deberán substituir por su correspondiente número de acuerdo a la siguiente tabla.
       
       A = 2  B = 2  C = 2
	   D = 3  E = 3  F = 3
	   G = 4  H = 4  I = 4
       J = 5  K = 5  L = 5
	   M = 6  N = 6  O = 6
	   P = 7  Q = 7  R = 7
	   S = 8  T = 8  U = 8
	   V = 9  W = 9  X = 9
	   Y = 0  Z = 0

	   Ejemplo: JP13H679 = 57134679
    */

	set @CadenaInicial = ltrim(rtrim(@CadenaInicial))
    set @CadenaLen = len(@CadenaInicial)
    set @cadena2 = ''
    set @index = 1

	while @index <= @CadenaLen
		begin
			select @caracter = substring(@CadenaInicial, @index, 1)
            --if @PrintShow=1 print '@index=' +convert(varchar,@index) + ', @caracter = ' + @caracter

			--reemplaza cada caracter por un numero
            select @caracter2 = dbo.fCaBanorteConversion(@caracter) 
            --           if @PrintShow=1 print '@caracter = ' + @caracter + ', @caracter2=' + @caracter2
            set @cadena2 = @cadena2 + @caracter2

            --incrementa el index
            set @index = @index +1
		end

	--if @PrintShow=1 print '@cadena2=' + @cadena2

	/*
		2. De derecha a izquierda se van multiplicando cada uno de los dígitos por los números 2 y 1, 
		   siempre iniciando la secuencia con el número 2 aun cuando el número a multiplicar sea 0 deberá 
		   tomarse en cuenta. Si el resultado de multiplicar el número 2 por el dígito de la referencia es 
		   mayor a 9, se deberán sumar las unidades y las decenas, de tal forma que solo se tenga como 
		   resultado un número menor 0 igual a 9.
		   
		   Ejemplo: 315 (Numero de empresa) 57134679 (referencia)
		   0     0     3     1     5     0     0     5     7     1     3     4     6     7     9
		   *     *     *     *     *     *     *     *     *     *     *     *     *     *     *
		   2     1     2     1     2     1     2     1     2     1     2     1     2     1     2
		   =     =     =     =     =     =     =     =     =     =     =     =     =     =     =
		   0     0     6     1     1+0   0     0     5     1+4   1     6     4     1+2   7     1+8
		   
		3. Se suman todos los resultados de las multiplicaciones del punto 2.
		   0 + 0 + 6 + 1 + 1 + 0 +  0 + 5 + 5 + 1 + 6 + 4 + 3 + 7 + 9 = 48
	*/
    
	set @suma = 0
	
	-- Se agrega el número de empresa y se invierte la cadena para hacer la multiplicación y suma de los
	-- valores del punto 2.
    set @cadena3 = reverse(@NumEmpresa + @cadena2)
    --if @PrintShow=1 print '@cadena3= ' + @cadena3

	set @CadenaLen = len(@cadena3)
    set @index = 1

	while @index <= @CadenaLen
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
		4. El resultado de la suma indicada en el punto 3, deberá restársele a la decena superior mas próxima. 
		El resultado de esta substracción será el dígito verificador.
		
		10 - 8 = 2
		
		Dígito Verificador: 2
	*/
       
    select @DecenaInf = round(@suma, -1, 1)
	set @DecenaSup = @DecenaInf + 10
    
	--if @PrintShow=1 print '@suma=' + convert(varchar,@suma) + ',@DecenaInf=' + convert(varchar,@DecenaInf) + ',@DecenaSup=' + convert(varchar,@DecenaSup)
    
	set @Diferencia = @DecenaSup - @suma
    --if @PrintShow=1 print '@Diferencia= ' + convert(varchar,@Diferencia)
       
    /*
       5. A la referencia se le agregara el dígito verificador y esa será la línea de captura que recibirá el cajero en ventanilla. 
       
       Referencia Completa: JP13H6792
    */
    
	if @Diferencia <= 9
		begin
			set @Referencia = @CadenaInicial + convert(varchar,@Diferencia)
		end
	else
		begin
			set @Referencia = @CadenaInicial + '0'
		end
	
	--if @PrintShow=1 print '@Referencia = ' + @Referencia  
	
	--print 'Digito verificador: ' + CAST(@Diferencia AS VARCHAR)
	--print @Referencia
	return (@Referencia)
END

GO