SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE Procedure [dbo].[pGnlCambiaCodigoUsuario]
@Tabla 		Varchar(50),
@CAntiguo 		Varchar(25),
@CNuevo		Varchar(25),
@Buscar		bit = 0
As
Declare @Cadena 	Varchar(4000)
Declare @Antiguo 	Varchar(25)
Declare @Nuevo	Varchar(25)
Declare @UTabla	Varchar(50)
Declare @UCampo	Varchar(50)
Declare @Procesado 	Bit
Declare @Avance	Decimal(19,4)
Declare @Inicio		DateTime
Declare @Afectadas	Int

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tTmpConsistenciaUsuario]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin
	drop table [dbo].[tTmpConsistenciaUsuario]
End
Set @Cadena = 'SELECT DISTINCT '+ @CAntiguo +', '+ @CNuevo +', Procesado = 0 '
Set @Cadena = @CAdena  + 'INTO tTmpConsistenciaUsuario '
Set @Cadena = @CAdena  + 'FROM '+ @Tabla +' '
Set @Cadena = @CAdena  + 'WHERE ('+ @CNuevo +' IS NOT NULL) AND '
Set @Cadena = @CAdena  + '(RTRIM(LTRIM(' +@CNuevo+ ')) <> '''') AND  '+ @CAntiguo + ' <> ' + @CNuevo 

Print @Cadena

Exec(@Cadena)

Declare curUsuario Cursor For 
	SELECT *
	FROM tTmpConsistenciaUsuario
Open curUsuario
Fetch Next From curUsuario Into @Antiguo, @Nuevo,  @Procesado
While @@Fetch_Status = 0
Begin 
	Set @Antiguo = rtrim(@Antiguo)	
	Set @Nuevo = rtrim(@Nuevo)	

	Declare curTablas Cursor For 
		SELECT tabla, campo
		FROM tCsConsistenciaUsuario
		Where CambiaCodigo = 1
	Open curTablas
	Fetch Next From curTablas Into @UTabla, @UCampo
	While @@Fetch_Status = 0
	Begin 
		Set @Inicio = GetDate()		
		If @Buscar = 0
		Begin
			Set @Cadena = 'Update ' + @UTabla + ' '
			Set @Cadena = @Cadena + 'Set ' + @UCampo + ' = ''' + @Nuevo + ''' ' 
			Set @Cadena = @Cadena + 'Where ' + @UCampo + ' = ''' + @Antiguo + ''''
			Print @Cadena 
			Exec (@Cadena)
			Set @Afectadas = @@RowCount
		End
		If @Buscar = 1
		Begin
			Set @Cadena = 'Update ' + @UTabla + ' '
			Set @Cadena =  @Cadena + 'Set ' + @UCampo + ' = datos.Nuevo '
			Set @Cadena =  @Cadena + 'FROM (SELECT tCsClientes.CodOficina, tCsClientes.CodUsuario As Antes, Datos.CodUsuario AS Nuevo '
			Set @Cadena =  @Cadena + 'FROM (SELECT tCsClientes.CodDocIden, tCsClientes.DI, tCsPadronClientes.CodUsuario '
			Set @Cadena =  @Cadena + 'FROM tCsClientes INNER JOIN '
			Set @Cadena =  @Cadena + 'tCsPadronClientes ON tCsClientes.CodUsuario = tCsPadronClientes.CodOriginal AND '
			Set @Cadena =  @Cadena + 'tCsClientes.CodOficina = tCsPadronClientes.CodOficina '
			Set @Cadena =  @Cadena + 'WHERE      (tCsClientes.CodUsuario = '''+ @Antiguo +''')) Datos INNER JOIN '
			Set @Cadena =  @Cadena + 'tCsClientes ON Datos.CodDocIden COLLATE Modern_Spanish_CI_AI = tCsClientes.CodDocIden AND Datos.DI = tCsClientes.DI) Datos INNER JOIN '
			Set @Cadena =  @Cadena + @UTabla + ' ON Datos.CodOficina = '+ @UTabla +'.CodOficina AND Datos.Antes = '+ @UTabla +'.' + @UCampo
			Print @Cadena 
			Exec (@Cadena)
			Set @Afectadas = @@RowCount
		End	
		
		Insert Into tCsLogCambioCodigo (Anterior, Nuevo, Fecha, Tabla, Columna, Afectadas, Duracion) 
		Values (@Antiguo, @Nuevo, GetDate(), @UTabla, @UCampo, @Afectadas, DateDiff(Second, @Inicio, GetDate()))

	Fetch Next From curTablas Into @UTabla, @UCampo
	End 
	Close 		curTablas
	Deallocate 	curTablas
	
	Set @Cadena = 'Update tTmpConsistenciaUsuario '
	Set @Cadena = @Cadena + 'Set Procesado = 1 '
	Set @Cadena = @Cadena + 'Where ' + @CAntiguo + ' = ''' + @Antiguo + ''' AND ' + @CNuevo + '= '''  + @Nuevo + ''''
	
	Print @Cadena
	Exec (@Cadena)
	
	SELECT     @Avance = ROUND(SUM(Procesado) / CAST(COUNT(*) AS decimal(19, 4)) * 100, 2) 
	FROM         tTmpConsistenciaUsuario
	
	Print @Avance	

Fetch Next From curUsuario Into @Antiguo, @Nuevo, @Procesado
End 
Close 		curUsuario
Deallocate 	curUsuario
GO