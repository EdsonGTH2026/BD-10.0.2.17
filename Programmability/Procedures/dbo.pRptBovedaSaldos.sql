SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pRptBovedaSaldos

CREATE procedure [dbo].[pRptBovedaSaldos] @Fecha smalldatetime 
as 

Declare @Ayer		SmallDateTime
Declare @Proceso 	SmallDateTime
Declare @Cadena		Varchar(4000)
Declare @CodOficina	Varchar(4)
Declare @Servidor	Varchar(100)
Declare @BaseDatos	Varchar(100)
Declare @IP		Varchar(100)

Declare @Cuenta Varchar(100) 

Set @Cuenta 	= '110110101'

SELECT   @Proceso =   FechaConsolidacion + 1 
FROM         vCsFechaConsolidacion

If @Fecha = @Proceso
Begin
	Declare Oficinas Cursor For
		SELECT DISTINCT Servidor, BaseDatos
		FROM         tClOficinas
		WHERE     (Tipo IN ('Operativo', 'Matriz', 'Servicio'))
		
		/*SELECT    CodOficina, Servidor, BaseDatos
		FROM      tClOficinas
		WHERE     Tipo in ('Operativo', 'Matriz', 'Servicio')
		ORDER BY Cast(CodOficina as Int) Asc*/
	Open 	Oficinas
	Fetch Next From Oficinas Into @Servidor, @BaseDatos
	While @@Fetch_Status = 0
	Begin
		Set @IP = @Servidor
		if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[B]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
		Begin drop table [dbo].[B]End
		Set @Cadena = 'CREATE TABLE [dbo].[B] ( '
		Set @Cadena = @Cadena + '[Cadena] [varchar] (1157) COLLATE Modern_Spanish_CI_AI NULL ' 
		Set @Cadena = @Cadena + ') ON [PRIMARY] '
		Exec(@Cadena)
		Set @Cadena = 'NBTSTAT -a '+ Ltrim(rTrim(@Servidor))
		Insert Into B
		Exec master..xp_cmdshell @Cadena
		
		SELECT   @Servidor =  RTRIM(LTRIM(SUBSTRING(LTRIM(RTRIM(Cadena)), 1, CHARINDEX('<00>', LTRIM(RTRIM(Cadena)), 1) - 1))) 
		FROM         B
		WHERE     (Cadena LIKE '%<00>  UNIQUE%') OR (Cadena LIKE '%<00>  Único%')
	
		If @Servidor Is null 
		Begin
			Set @Cadena = 'Servidor no Encontrado'
			Select @Cadena as Observacion
		End
		Else
		Begin
			Set @Servidor 	= '[' + @Servidor + '].'	
			
			Delete From tCsUsuariosRH
			Where CodOficina in (SELECT     CodOficina
						FROM         tClOficinas
						WHERE     (Servidor = @IP) AND (BaseDatos = @BaseDatos)) And Fecha = @Fecha and TablaOrigen = 'tCsBovedaSaldos'
			
			Set @Cadena 	= 'Insert Into tCsUsuariosRH '
			Set @Cadena 	= @Cadena + '(TablaOrigen, Fecha, CodOficina, Tipo1, Decimal1, Decimal2, Decimal3) '
			Set @Cadena 	= @Cadena + 'SELECT ''tCsBovedaSaldos'',  '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''', tTcBovedaSaldos.CodOficina, tTcBovedaSaldos.CodMoneda, tTcBovedaSaldos.SaldoIniSis, '
			Set @Cadena 	= @Cadena + 'tTcBovedaSaldos.SaldoFinSis, tTcBovedaSaldos.SaldoFinUs '
			Set @Cadena 	= @Cadena + 'FROM (SELECT CodOficina, MAX(FechaPro) AS Fecha '
			Set @Cadena 	= @Cadena + 'FROM '+ @Servidor +'['+ @BaseDatos +'].dbo.tTcBovedaSaldos tTcBovedaSaldos '
			Set @Cadena 	= @Cadena + 'WHERE (CodOficina IN (SELECT CodOficina FROM tClOficinas WHERE (Servidor = '''+ @IP +''') AND (BaseDatos = '''+ @BaseDatos +'''))) AND (FechaPro <= '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') GROUP BY CodOficina) Proceso INNER JOIN '
			Set @Cadena 	= @Cadena + @Servidor +'['+ @BaseDatos +'].dbo.tTcBovedaSaldos tTcBovedaSaldos ON Proceso.Fecha = tTcBovedaSaldos.FechaPro AND Proceso.Codoficina = tTcBovedaSaldos.CodOficina '
			Set @Cadena 	= @Cadena + 'WHERE (tTcBovedaSaldos.CodOficina IN (SELECT CodOficina FROM tClOficinas WHERE (Servidor = '''+ @IP +''') AND (BaseDatos = '''+ @BaseDatos +''')))'
			Print @Cadena
			Exec  (@Cadena)
			
			Delete From tCsBovedaSaldos Where Fecha = @Fecha
			Insert Into tCsBovedaSaldos
			Select  Fecha, CodOficina, Tipo1, Decimal1, Decimal2, Decimal3 
			From tCsUsuariosRH
			Where TablaOrigen = 'tCsBovedaSaldos' and Fecha = @Fecha 
						
		End	
	Fetch Next From Oficinas Into @Servidor, @BaseDatos
	End 
	Close 		Oficinas
	Deallocate 	Oficinas
End

Set @Ayer	= DateAdd(day, -1, @Fecha)

CREATE TABLE #SaldosBoveda1 (
	[Fecha] 	[smalldatetime] NOT NULL ,
	[CodOficina] 	[varchar] (100) NULL ,
	[DescOficina] 	[varchar] (1033) COLLATE Modern_Spanish_CI_AI NULL ,
	[SaldoFinSisMn] [decimal](38, 4) NULL ,
	[SaldoFinSisMe] [decimal](38, 4) NULL ,
	[SaldoFinUsMn] 	[decimal](38, 4) NULL ,
	[SaldoFinUsMe] 	[decimal](38, 4) NULL ,
	[Contabilidad] 	[decimal](38, 4) NULL , 
	[ASaldoFinSisMn][decimal](38, 4) NULL ,
	[ASaldoFinSisMe][decimal](38, 4) NULL ,
	[ASaldoFinUsMn] [decimal](38, 4) NULL ,
	[ASaldoFinUsMe] [decimal](38, 4) NULL ,
	[AContabilidad] [decimal](38, 4) NULL ) 

Set @Cadena = 'Insert Into #SaldosBoveda1 (Fecha, CodOficina, DescOficina, SaldoFinSisMn, SaldoFinSisMe, SaldoFinUsMn, SaldoFinUsMe) '
Set @Cadena = @Cadena + 'Exec pRptBovedaSaldosMatriz ''' + dbo.fdufechaatexto(@Ayer, 'AAAAMMDD') + ''', ''' + dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') + ''''

Exec (@Cadena)

Set @Cadena = 'UPDATE #SaldosBoveda1 SET ASaldoFinSisMn = ayer.SaldoFinSisMn, ASaldoFinSisMe = ayer.SaldoFinSisMe, ASaldoFinUsMn = ayer.SaldoFinUsMn, '
Set @Cadena = @Cadena + 'ASaldoFinUsMe = ayer.SaldoFinUsMe FROM (SELECT DateAdd(day, 1, Fecha)  AS Fecha, DescOficina, SaldoFinSisMn, SaldoFinSisMe, '
Set @Cadena = @Cadena + 'SaldoFinUsMn, SaldoFinUsMe FROM #SaldosBoveda1 WHERE (Fecha = ''' + dbo.fdufechaatexto(@Ayer, 'AAAAMMDD') + ''')) Ayer INNER '
Set @Cadena = @Cadena + 'JOIN #SaldosBoveda1 ON Ayer.Fecha = #SaldosBoveda1.Fecha AND Ayer.DescOficina COLLATE Modern_Spanish_CI_AI = #SaldosBoveda1.DescOficina '

Exec(@Cadena)

Set @Cadena = 'DELETE FROM #SaldosBoveda1 WHERE  (Fecha = ''' + dbo.fdufechaatexto(@Ayer, 'AAAAMMDD') + ''')'

Exec (@Cadena)

Declare @Contador	Int 

SELECT     @Contador = Count(*)
FROM         tCsServidores
WHERE     (IdTextual = CAST(YEAR(@Fecha) as Varchar(10))) AND (Tipo = 2)

If @Contador Is Null Begin Set @Contador = 0 End

If @Contador = 1
Begin 
	SELECT     @Servidor = NombreIP, @BaseDatos = NombreBD
	FROM         tCsServidores
	WHERE     (IdTextual = CAST(YEAR(@Fecha) as Varchar(10))) AND (Tipo = 2)
End
Else
Begin
	SELECT     @Servidor = Servidor, @BaseDatos = BaseDatos
	FROM         tClOficinas
	WHERE     (CodOficina = '99')
End

If exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[B]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin drop table [dbo].[B]End
Set @Cadena = 'CREATE TABLE [dbo].[B] ( '
Set @Cadena = @Cadena + '[Cadena] [varchar] (1157) COLLATE Modern_Spanish_CI_AI NULL ' 
Set @Cadena = @Cadena + ') ON [PRIMARY] '
Exec(@Cadena)
Set @Cadena = 'NBTSTAT -a '+ Ltrim(rTrim(@Servidor))
Insert Into B
Exec master..xp_cmdshell @Cadena

SELECT   @Servidor =  RTRIM(LTRIM(SUBSTRING(LTRIM(RTRIM(Cadena)), 1, CHARINDEX('<00>', LTRIM(RTRIM(Cadena)), 1) - 1))) 
FROM         B
WHERE     (Cadena LIKE '%<00>  UNIQUE%') OR (Cadena LIKE '%<00>  Único%')

Print @Servidor	
Set @Servidor = '[' + @Servidor + '].'	

Set @Cadena = 'Exec ' + @Servidor +'['+ @BaseDatos +'].dbo.pCsCoCuentaContable '''+ dbo.fdufechaatexto(@Fecha, 'AAAAMMDD') +''', '''+ @Cuenta +''', ''CodOficina'''
Exec(@Cadena)
Set @Cadena = 'UPDATE SaldosBoveda SET Contabilidad = Datos.Saldo * -1 FROM #SaldosBoveda1 SaldosBoveda INNER JOIN (SELECT     ISNULL(SUM(KRptID_Tabla.Saldo), 0) AS Saldo, KRptID_Tabla.Agrupado '
Set @Cadena = @Cadena  + 'FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora '
Set @Cadena = @Cadena  + 'FROM ' + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla '
Set @Cadena = @Cadena  + 'WHERE (Parametro = '''+ @Cuenta +''') AND (Fecha = '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') '
Set @Cadena = @Cadena  + 'GROUP BY Fecha, Parametro) Datos INNER JOIN '
Set @Cadena = @Cadena  + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla ON Datos.Fecha = KRptID_Tabla.Fecha AND Datos.Parametro COLLATE Modern_Spanish_CI_AI = KRptID_Tabla.Parametro AND '
Set @Cadena = @Cadena  + 'Datos.Hora = KRptID_Tabla.Hora GROUP BY KRptID_Tabla.Fecha, KRptID_Tabla.Parametro, KRptID_Tabla.Agrupado) Datos ON SaldosBoveda.CodOficina = Datos.Agrupado COLLATE Modern_Spanish_CI_AI '
Exec(@Cadena)
Set @Cadena = 'Exec ' + @Servidor +'['+ @BaseDatos +'].dbo.pCsCoCuentaContable '''+ dbo.fdufechaatexto(@Ayer, 'AAAAMMDD') +''', '''+ @Cuenta +''', ''CodOficina'''
Exec(@Cadena)
Set @Cadena = 'UPDATE SaldosBoveda SET AContabilidad = Datos.Saldo * -1 FROM #SaldosBoveda1 SaldosBoveda INNER JOIN (SELECT     ISNULL(SUM(KRptID_Tabla.Saldo), 0) AS Saldo, KRptID_Tabla.Agrupado '
Set @Cadena = @Cadena  + 'FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora '
Set @Cadena = @Cadena  + 'FROM ' + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla '
Set @Cadena = @Cadena  + 'WHERE (Parametro = '''+ @Cuenta +''') AND (Fecha = '''+ dbo.fduFechaATexto(@Ayer, 'AAAAMMDD') +''') '
Set @Cadena = @Cadena  + 'GROUP BY Fecha, Parametro) Datos INNER JOIN '
Set @Cadena = @Cadena  + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla ON Datos.Fecha = KRptID_Tabla.Fecha AND Datos.Parametro COLLATE Modern_Spanish_CI_AI = KRptID_Tabla.Parametro AND '
Set @Cadena = @Cadena  + 'Datos.Hora = KRptID_Tabla.Hora GROUP BY KRptID_Tabla.Fecha, KRptID_Tabla.Parametro, KRptID_Tabla.Agrupado) Datos ON SaldosBoveda.CodOficina = Datos.Agrupado COLLATE Modern_Spanish_CI_AI '
Exec(@Cadena)

Update #SaldosBoveda1  Set Contabilidad = 0 Where Contabilidad Is null
Update #SaldosBoveda1  Set AContabilidad = 0 Where AContabilidad Is null


Select Fecha, DescOficina, 	SaldoFinSisMn, SaldoFinUsMn, Contabilidad, 
				ASaldoFinSisMn, ASaldoFinUsMn, AContabilidad 
From #SaldosBoveda1 

Drop Table #SaldosBoveda1
GO