SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  Stored Procedure dbo.pCsRCGeneraDatosVs14    Script Date: 08/03/2023 09:14:53 pm ******/


CREATE Procedure [dbo].[pCsRCGeneraDatosVs14]
@TipoArchivoTexto 	Varchar(3),
@Periodo		Varchar(6)
As

--declare @TipoArchivoTexto 	Varchar(3)
--declare @Periodo		Varchar(6)
--Set @TipoArchivoTexto 	= '001'
--Set @Periodo 			= '201212'

declare @T1 datetime
declare @T2 datetime

Declare @EstructuraArchivo 	Varchar(2)
Declare @Tabla 			Varchar(50)
Declare @TablaRecorrido		Varchar(50)
Declare @Cadena			Varchar(4000)
Declare @Cadena1		Varchar(4000)
Declare @Fecha			SmallDateTime
Declare @TamañoT		Int
Declare @Campo			Varchar(100)
Declare @Campos			Varchar(4000)
Declare @Valor			Varchar(4000)
Declare @Valores		Varchar(4000)
Declare @Contador		Int
Declare @Ascii			Int
Declare @CS			Varchar(1)
Declare @CC			Varchar(1)

Declare @ValorDefecto		Varchar(100)
Declare @Tamaño			Int
Declare @TipoDato		Char(1)
Declare @CadenaD		Varchar(4000)
Declare @Fila			Int
Declare @Orden			Int
Declare @ReLlena		Bit
Declare @ReCaracter		Varchar(1)
Declare @ReAlineado		Varchar(1)
Declare @CampoDato		Varchar(50)
Declare @EtUsar			Bit
Declare @EtValor		Varchar(50)
Declare @TaValor		Varchar(10)
Declare @TaUsar			Bit
Declare @TaFormato		Varchar(1)
Declare @TaLongitud		Int
Declare @TaRelleno		Varchar(1)
Declare @TaAlineado		Varchar(1)
Declare @Requerido		Bit
Declare @Tilde			Bit
Declare @CÑ			Varchar(1)
Declare @Relacionador		Bit
Declare @CaIn			Varchar(100)
Declare @CaFi			Varchar(100)

if exists (select * from dbo.sysobjects where id = object_id(N'dbo.TablaRecorrido') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table dbo.TablaRecorrido End

Set @Fecha = Cast(dbo.fduFechaAtexto(DateAdd(Month, 1, Cast(@Periodo + '01' as SmallDateTime)), 'AAAAMM') + '01' as SmallDateTime) - 1

Declare curEstructuraArchivo Cursor For 
	SELECT     EstructuraArchivo, Tabla, TablaRecorrido
	FROM   tRcTipoEstructuraArchivo
	WHERE     (TipoArchivoTexto = '001') And Activo = 1--@TipoArchivoTexto
Open curEstructuraArchivo
Fetch Next From curEstructuraArchivo Into @EstructuraArchivo, @Tabla, @TablaRecorrido
While @@Fetch_Status = 0
Begin 
	set @T1 = getdate()
	if exists (select * from dbo.sysobjects where id = object_id(N'dbo.TablaRecorrido') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin 
		Select @Contador = Count(*)
		From TablaRecorrido
		Where Representa = @TablaRecorrido

		If @Contador = 0
		Begin 
			drop table dbo.TablaRecorrido
		End 
	End

	if Not exists (select * from dbo.sysobjects where id = object_id(N'dbo.TablaRecorrido') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin
	    if (@TablaRecorrido='vINTFNombre')
	begin
	  --exec finamigoconsolidado.dbo.pvINTFNombre '20121231' --33108
	  Set @Cadena = 'exec finamigoconsolidado.dbo.pvINTFNombreVr14 '''+dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+''' '
	  Print @Cadena
			    Exec (@Cadena)
	end
	    if (@TablaRecorrido='vINTFCuenta')
	begin
	  --exec finamigoconsolidado.dbo.pvINTFCuenta '20121231'
	  Set @Cadena = 'exec finamigoconsolidado.dbo.pvINTFCuenta '''+dbo.fduFechaAtexto(@Fecha, 'AAAAMMDD')+''' '
	  Print @Cadena
			    Exec (@Cadena)
	end	  
		--SELECT Representa = 'vINTFCuenta' , IDENTITY(int, 1, 1) AS Fila, * Into TablaRecorrido FROM vINTFCuenta
		Set @Cadena = 'SELECT Representa = ''' + @TablaRecorrido  + ''' , IDENTITY(int, 1, 1) AS Fila, * Into TablaRecorrido FROM ' + @TablaRecorrido
		Print @Cadena
		Exec (@Cadena)
	End
	print @TablaRecorrido

	set @T2 = getdate()
	print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' crea tabla recorrido o continua'
	set @T1 = getdate()

	SELECT  @TamañoT = SUM(Tamaño +  DataLength(Isnull(CInicio, '')) + DataLength(Isnull(CFin, ''))), @Contador = Max(Orden)
	FROM   tRcArchivoFragmento
	WHERE     (EstructuraArchivo = @EstructuraArchivo)

	Set @Cadena 	= 'CREATE TABLE dbo.'+ @Tabla +' ( '
	Set @Cadena 	= @Cadena + 'Periodo varchar (6) COLLATE Modern_Spanish_CI_AI NOT NULL , '
	Set @Cadena 	= @Cadena + 'Fila int NOT NULL , '
	Set @Cadena 	= @Cadena + 'Cadena varchar ('+ Cast(@TamañoT as Varchar(4)) +') COLLATE Modern_Spanish_CI_AI NOT NULL , '
	Set @Cadena 	= @Cadena + 'Usados int NULL , '	

	Set @Campos 	= 'Periodo, Fila, Cadena '

	Declare curFragmento Cursor For 
		SELECT     CASE tipodato WHEN 'C' THEN '' + nombre + ' varchar (' + cast((tamaño + Case UsarEtiqueta When 1 Then Len(Ltrim(rtrim(Etiqueta))) When 0 then 0 end +
												 Case UsarTamaño 	 When 1 Then LongitudTamaño When 0 then 0 end + 
												  DataLength(Isnull(CInicio, '')) + DataLength(Isnull(CFin, '')) ) AS varchar(6)) 
		    + ') COLLATE Modern_Spanish_CI_AI NOT NULL , ' WHEN 'N' THEN '' + nombre + ' Int  NOT NULL , ' END AS Campo, tRcArchivoFragmento.Nombre
		FROM   tRcArchivoFragmento 
		WHERE     (tRcArchivoFragmento.EstructuraArchivo = @EstructuraArchivo)
		ORDER BY tRcArchivoFragmento.Orden
	Open curFragmento
	Fetch Next From curFragmento Into @Cadena1, @Campo
	While @@Fetch_Status = 0
	Begin 
		Set @Cadena 	= @Cadena 	+ @Cadena1	
		Set @Campos	= @Campos 	+ ', ' + @Campo

	Fetch Next From curFragmento Into @Cadena1, @Campo
	End 
	Close 		curFragmento
	Deallocate 	curFragmento
	
	If Len(Ltrim(Rtrim(@Cadena))) <> 0 
	Begin
		Set @Cadena = Substring(Ltrim(Rtrim(@Cadena)), 1, Len(Ltrim(Rtrim(@Cadena))) - 1)
	End
	
	if Not exists (select * from dbo.sysobjects where id = object_id(N'dbo.'+ @Tabla +'') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
	Begin
		Set @Cadena = @Cadena + ')ON PRIMARY'
		Exec (@Cadena)
	End	

	Set @Cadena = 'DELETE FROM ' + @Tabla + ' WHERE (Periodo = ''' + @Periodo + ''')'
	Exec (@Cadena)

	Set @Valores	= ''
	Set @CadenaD	= ''	

	print 'Inicia crufracmento'	

	Declare curFragmento Cursor For 
		SELECT    tRcArchivoFragmento.Nombre, 
		   	tRcArchivoFragmento.ValorDefecto, tRcArchivoFragmento.Tamaño, tRcArchivoFragmento.TipoDato, TablaRecorrido.Fila, tRcArchivoFragmento.Orden,
					tRcArchivoFragmento.Rellenado, tRcArchivoFragmento.CaracterRelleno, tRcArchivoFragmento.Alineado, tRcArchivoFragmento.CampoDato,
					tRcArchivoFragmento.UsarEtiqueta, tRcArchivoFragmento.Etiqueta, tRcArchivoFragmento.UsarTamaño, tRcArchivoFragmento.FormatoTamaño, tRcArchivoFragmento.LongitudTamaño, 
					tRcArchivoFragmento.RellenoTamaño, tRcArchivoFragmento.AlineadoTamaño, tRcArchivoFragmento.Requerido, tRcArchivoFragmento.MantenerTilde, tRcArchivoFragmento.CaracterÑ,
					tRcArchivoFragmento.DatoRelacionador, tRcArchivoFragmento.CInicio, tRcArchivoFragmento.CFin 
		FROM   tRcArchivoFragmento CROSS JOIN
		    TablaRecorrido
		WHERE     (tRcArchivoFragmento.EstructuraArchivo = @EstructuraArchivo)
		ORDER BY TablaRecorrido.Fila, tRcArchivoFragmento.Orden
	Open curFragmento
	Fetch Next From curFragmento Into 	@Campo, 	@ValorDefecto, 	@Tamaño, 	@TipoDato,	
						@Fila,		@Orden, 	@ReLlena, 	@ReCaracter,	
						@ReAlineado,	@CampoDato,	@EtUsar,	@EtValor, 	
						@TaUsar,	@TaFormato,	@TaLongitud,	@TaRelleno,	
						@TaAlineado,	@Requerido,	@Tilde,		@CÑ,
						@Relacionador,	@CaIn,		@CaFi
	While @@Fetch_Status = 0
	Begin 		
		Set @Valor = ''
		--Cuando el valor lo extrae de alguna tabla.
		If @CampoDato Is Not Null And Ltrim(Rtrim(@CampoDato)) <> ''
		Begin
			Delete From tRcFragmentoDato 
			Where 	Periodo 	= @Periodo 		And
				Fila		= @Fila			And
				Representa 	= @TablaRecorrido 	And
				Campo		= @Campo
		
			Set @Cadena = 'Insert Into tRcFragmentoDato  (Periodo, Fila, Representa, Campo, Dato) '
			Set @Cadena = @Cadena + 'Select Periodo = ''' +  @Periodo + ''', Fila = '+ Cast(@Fila as Varchar(10)) + ', '
			Set @Cadena = @Cadena + 'Representa = ''' +  @TablaRecorrido + ''', Campo = '''+ @Campo + ''', '
			Set @Cadena = @Cadena + 'Dato = ' +  @CampoDato + ' FROM TablaRecorrido Where Fila = '+ Cast(@Fila as Varchar(10)) + ' AND Representa = ''' +  @TablaRecorrido + ''''			
			
			--Print @Cadena
			Exec (@Cadena)						
			--OBTIENE VALOR
			Select 	@Valor 		= Isnull(Dato, '') , 
				@TaValor	= Len(Isnull(Dato, ''))
			From tRcFragmentoDato
			Where 	Periodo 	= @Periodo 		And
				Fila		= @Fila			And
				Representa 	= @TablaRecorrido 	And
				Campo		= @Campo

			Set @Valor 	= Substring(@Valor, 1, @Tamaño)
			Set @TaValor	= DataLength(@Valor)

			If Len(@Valor) <> DataLength(@Valor)
			Begin
				Print 'OBSERVACION('+ @campo +'): Tener cuenta valor ya que el tamaño es inconsistente'
				Print '-- Valor 	: ' + @Valor
				Print '-- Len		: ' + Cast(Len(@Valor) as Varchar(10))
				Print '-- DataLength	: ' + Cast(DataLength(@Valor) as Varchar(10))
			End
		End				

		If @ValorDefecto Is Not Null 
		Begin
			--OBTIENE VALOR
			Set @Valor 	= IsNull(Substring(@ValorDefecto, 1, @Tamaño), '')
			Set @TaValor	= Len(IsNull(Substring(@ValorDefecto, 1, @Tamaño), ''))
		End		
		
		If @ReLlena = 1 
		Begin
			If @Requerido = 0 And @Valor = '' 
			Begin
				Set @Valor = ''
			End
			Else
			Begin
				Set @Valor = dbo.fduRellena(@ReCaracter, @Valor, @Tamaño, @ReAlineado)
			End 
			Set @TaValor	= Len(@Valor)
		End

		Set @Valor = Replace(@Valor, 'Ñ', @CÑ)
		
		IF @CaIn is Null Begin Set @CaIn = ''  End 
		IF @CaFi is Null Begin Set @CaFi = ''  End		

		Set @Valor = @CaIn + @Valor + @CaFi

		Set @TaValor = Ltrim(Rtrim(@TaValor))
		If @TaUsar = 1
		Begin
			If Rtrim(Ltrim(@TaRelleno)) <> ''
			Begin
				Set @TaValor = dbo.fduRellena(@TaRelleno, @TaValor, @TaLongitud, @TaAlineado) 
			End
		End
		Else 
		Begin
			Set @TaValor = ''
		End

		If @EtUsar = 0 
		Begin
			Set @EtValor = ''
		End		

		If @Requerido = 0 And Ltrim(Rtrim(@Valor)) = ''
		Begin
			Set @EtValor 	= ''
			Set @TaValor 	= ''
			Set @Valor 	= ''
		End
				
		Set @Valor = @EtValor + @TaValor + @Valor
		
		Print 'Valor Inicial	:' + @Valor
		Print 'Tilde		:' + Cast(@Tilde as Varchar(1))
		If @Tilde = 0 
		Begin	
			Set @CS = 'A'
			Set @CC = 'Á'		
			Set @Ascii = Ascii(@CC)			
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ ') 	: ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara 					: ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))

				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End	
			Set @CS = 'E'
			Set @CC = 'É'		
			Set @Ascii = Ascii(@CC)
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ ') 	: ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara 					: ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))
				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End		
			Set @CS = 'I'
			Set @CC = 'Í'		
			Set @Ascii = Ascii(@CC)
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ ') 	: ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara 					: ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))
				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End	
			Set @CS = 'O'
			Set @CC = 'Ó'		
			Set @Ascii = Ascii(@CC)
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ '): ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara : ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))
				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End	
			Set @CS = 'U'
			Set @CC = 'Ú'		
			Set @Ascii = Ascii(@CC)
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ ') 	: ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara 					: ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))
				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End	
			Set @CS = 'a'
			Set @CC = 'á'		
			Set @Ascii = Ascii(@CC)
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ ') 	: ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara 					: ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))
				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End	
			Set @CS = 'e'
			Set @CC = 'é'		
			Set @Ascii = Ascii(@CC)
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ ') 	: ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara 					: ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))
				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End	
			Set @CS = 'i'
			Set @CC = 'í'		
			Set @Ascii = Ascii(@CC)
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ ') 	: ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara 					: ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))
				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End	
			Set @CS = 'o'
			Set @CC = 'ó'		
			Set @Ascii = Ascii(@CC)
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ ') 	: ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara 					: ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))
				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End		
			Set @CS = 'u'
			Set @CC = 'ú'		
			Set @Ascii = Ascii(@CC)
			If charindex(@CC, @Valor, 1) <> 0 
			Begin
				--Print 'Tilde Encontrada(' + Char(@Ascii)+ ') 	: ' + Cast(charindex(@CC, @Valor, 1) as Varchar(10))
				--Print 'Compara 					: ' + Cast(Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) as Varchar(10))	
				--Print 'Con : ' + Cast(@Ascii as Varchar(10)) + ' Ó ' + Cast(@Ascii - 128 as Varchar(10))
				If 	Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = @Ascii Or
					Ascii(Substring(@Valor, charindex(@CC, @Valor, 1), 1)) = Ascii(@CS)
				Begin
					Set @Valor = Replace(@Valor, @CC, @CS)
				End
			End		
		End
		
		If @Relacionador = 0 
		Begin
			Set @CadenaD = @CadenaD + @Valor	
		End 
		Print 'Tipo de Dato = '  + @TipoDato 
		If @TipoDato = 'C'
		Begin
			Set @Valor = '''' + @Valor + ''', ' 
		End
		If @TipoDato = 'N'
		Begin
			Set @Valor = @Valor + ', '
		End
		
		Print @Campo + ' : ' + IsNull(@Valor, 'Valor Nulo')

		Set @Valores	= @Valores 	+ @Valor

		--Print @Valores
		Print @Contador
		Print @Orden
		If @Contador = @Orden
		Begin
			If Len(Ltrim(Rtrim(@Valores))) <> 0 And Right(Ltrim(Rtrim(@Valores)), 1) = ','
			Begin				
				Set @Valores = Substring(Ltrim(Rtrim(@Valores)), 1, Len(Ltrim(Rtrim(@Valores))) - 1)
			End			
			Set @Cadena 	= 'INSERT INTO ' + @Tabla  + ' ('+ @Campos +') VALUES ('''+ @Periodo + ''', ' + Cast(@Fila as Varchar(10))+ ', ''' + @CadenaD  +''', ' + @Valores + ')'
			Print @Tabla
			Print @Campos
			Print @Periodo
			Print @Fila
			Print @CadenaD
			Print @Valores
			Print '@Cadena : ' + Isnull(@Cadena, '') 	
			Exec (@Cadena)
			
			Set @Valores = ''
			Set @CadenaD = ''
		End
	Fetch Next From curFragmento Into 	@Campo, 	@ValorDefecto, 	@Tamaño, 	@TipoDato,	
						@Fila,		@Orden, 	@ReLlena, 	@ReCaracter,	
						@ReAlineado,	@CampoDato,	@EtUsar,	@EtValor, 	
						@TaUsar,	@TaFormato,	@TaLongitud,	@TaRelleno,	
						@TaAlineado,	@Requerido, 	@Tilde,		@CÑ,
						@Relacionador,	@CaIn,		@CaFi
	End 
	Close 		curFragmento
	Deallocate 	curFragmento

	set @T2 = getdate()
	print 'Tiempo '+ cast( datediff(millisecond, @T1, @T2) as char(6)) + ' termina curfracmento'
	set @T1 = getdate()	

Fetch Next From curEstructuraArchivo Into @EstructuraArchivo, @Tabla, @TablaRecorrido
End 
Close 		curEstructuraArchivo
Deallocate 	curEstructuraArchivo

GO