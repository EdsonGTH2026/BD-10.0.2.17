SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROCEDURE pCsPrRegulatorios2
--/*
Create Procedure [dbo].[pCsPrRegulatorios2]
@Dato		Int,
@Reporte	Varchar(20),
@Fecha		SmallDateTime,
@CodOficina	Varchar(4),
@CuentaContable Varchar(100)
As
--*/
/*
Declare @Dato		Int
Declare @Reporte	Varchar(20)
Declare @Fecha		SmallDateTime
Declare @CodOficina	Varchar(4)
Declare @CuentaContable Varchar(100)
Set @Dato		= 1
Set @Reporte		= 'BCONOPE'
Set @Fecha 		= '20100301'
Set @CodOficina 	= '6'
Set @CuentaContable 	= '130110101'
*/
Declare @Cadena		Varchar(4000)
Declare @Temp		Varchar(4000)
Declare @ID1		Varchar(50)
Declare @ID2		Varchar(50)
Declare @ID3		Varchar(50)
Declare @ID4		Varchar(50)

Set @CodOficina = ltrim(rtrim(Str(@CodOficina, 3, 0)))

Declare @Servidor	Varchar(50)
Declare @BaseDatos	Varchar(50)
Declare @Tabla		Varchar(50)
Declare @Temporal	Varchar(4000)
Declare @UnDiaAntes	SmallDateTime

Set @UnDiaAntes	= DateAdd(Day, -1, @Fecha)

SELECT     @Servidor = Servidor, @BaseDatos = BaseDatos
FROM         tClOficinas
WHERE     (CodOficina = '99')

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

Print @Servidor	
Set @Servidor = '[' + @Servidor + '].'	

If @Dato = 1 -- Para Manejo de Diferencias
Begin
	Create Table #A (Valor varchar(50))
 
	Set @Temp	= dbo.fduRellena('0', @CodOficina, 3, 'D')

	SELECT 	@Cadena = CASE Procedimiento WHEN 'pCsCaAnexosSaldo' THEN 'DECLARE @Valor Decimal(18,4) Exec pCsCaAnexosSaldo ''' + dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') + '''' + REPLACE(REPLACE(Parametros, 
	                      SUBSTRING(Parametros, CHARINDEX('''', Parametros, 1), CHARINDEX('''', Parametros, CHARINDEX('''', Parametros, 1) + 1) - CHARINDEX('''', Parametros, 1) + 1), 
	                      SUBSTRING(Parametros, CHARINDEX('''', Parametros, 1), CHARINDEX('''', Parametros, CHARINDEX('''', Parametros, 1) + 1) - CHARINDEX('''', Parametros, 1)) 
	                      + @Temp + ''''), 'DD', 'DDP') + ', @Valor output ' ELSE '' END,
		@ID1	=   REPLACE(REPLACE(REPLACE(Parametros, ' ', ''), ',', ''), '''', '') + 'P'  
	FROM       tCsPrReportesAnexos
	WHERE     (Reporte = @Reporte) AND (OtroDato = @CuentaContable) AND (SUBSTRING(DescIdentificador, 1, 2) = 'C2')
	
	Print @Cadena
	Exec (@Cadena)
	
	Set @Cadena	= 'Insert Into #A SELECT DISTINCT KRptID_Tabla.Tabla FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora FROM KRptID_Tabla WHERE '
	Set @Cadena	= @Cadena + '(Fecha = ''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''') AND (Parametro = ''' + @ID1 + ''') GROUP BY Fecha, '
	Set @Cadena	= @Cadena + 'Parametro) Filtro INNER JOIN KRptID_Tabla ON Filtro.Fecha = KRptID_Tabla.Fecha AND Filtro.Parametro = '
	Set @Cadena	= @Cadena + 'KRptID_Tabla.Parametro AND Filtro.Hora = KRptID_Tabla.Hora '
	
	Print @Cadena
	Exec (@Cadena)

	Select @ID1 = Valor From #A
	Truncate Table #A	

	SELECT 	@Cadena = CASE Procedimiento WHEN 'pCsCaAnexosSaldo' THEN 'DECLARE @Valor Decimal(18,4) Exec pCsCaAnexosSaldo ''' + dbo.fduFechaATexto(@Fecha -  1, 'AAAAMMDD') + '''' + REPLACE(REPLACE(Parametros, 
                      	SUBSTRING(Parametros, CHARINDEX('''', Parametros, 1), CHARINDEX('''', Parametros, CHARINDEX('''', Parametros, 1) + 1) - CHARINDEX('''', Parametros, 1) + 1), 
                      	SUBSTRING(Parametros, CHARINDEX('''', Parametros, 1), CHARINDEX('''', Parametros, CHARINDEX('''', Parametros, 1) + 1) - CHARINDEX('''', Parametros, 1)) 
                      	+ @Temp + ''''), 'DD', 'DDP') + ', @Valor output ' ELSE '' END,
		@ID2	=   REPLACE(REPLACE(REPLACE(Parametros, ' ', ''), ',', ''), '''', '') + 'P'  
	FROM       tCsPrReportesAnexos
	WHERE     (Reporte = @Reporte) AND (OtroDato = @CuentaContable) AND (SUBSTRING(DescIdentificador, 1, 2) = 'C2')
	
	Print @Cadena
	Exec (@Cadena)

	Set @Cadena	= 'Insert Into #A SELECT DISTINCT KRptID_Tabla.Tabla FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora FROM KRptID_Tabla WHERE '
	Set @Cadena	= @Cadena + '(Fecha = ''' + dbo.FduFechaAtexto(@UnDiaAntes, 'AAAAMMDD') + ''') AND (Parametro = ''' + @ID2 + ''') GROUP BY Fecha, '
	Set @Cadena	= @Cadena + 'Parametro) Filtro INNER JOIN KRptID_Tabla ON Filtro.Fecha = KRptID_Tabla.Fecha AND Filtro.Parametro = '
	Set @Cadena	= @Cadena + 'KRptID_Tabla.Parametro AND Filtro.Hora = KRptID_Tabla.Hora '
	
	Print @Cadena
	Exec (@Cadena)

	Select @ID2 = Valor From #A
	Truncate Table #A	

	Set @Cadena = 'Exec ' + @Servidor +'['+ @BaseDatos +'].dbo.pCsCoCuentaContable ''' + dbo.fduFechaATexto(@Fecha,  'AAAAMMDD') + ''', '''+ @CuentaContable +''', ''CuentaOperativa[=]'', ''('+ @CodOficina +')'''
	Exec(@Cadena)
	Print @Cadena	

	Set @Temp = '(SELECT DISTINCT KRptID_Tabla.Tabla FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora FROM ' + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla '
	Set @Temp = @Temp + 'WHERE (Fecha = ''' + dbo.fduFechaATexto(@Fecha,  'AAAAMMDD') + ''') AND (Parametro = '''+ @CuentaContable +''') GROUP BY Fecha, Parametro) Filtro INNER JOIN '
	Set @Temp = @Temp + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla ON Filtro.Fecha = KRptID_Tabla.Fecha AND Filtro.Parametro = KRptID_Tabla.Parametro AND Filtro.Hora = KRptID_Tabla.Hora) '

	Set @Cadena = 'DELETE FROM KRptID_Tabla WHERE Tabla IN ' + @Temp
	Exec (@Cadena)
	Print @Cadena	

	Set @Cadena = 'INSERT INTO KRptID_Tabla SELECT * from ' + @Servidor +'['+ @BaseDatos +'].dbo.KRptID_Tabla KRptID_Tabla WHERE Tabla IN ' + @Temp
	Exec(@Cadena)
	Print @Cadena	

	Set @Cadena	= 'Insert Into #A SELECT DISTINCT KRptID_Tabla.Tabla FROM (SELECT Fecha, Parametro, MAX(Hora) AS Hora FROM KRptID_Tabla WHERE '
	Set @Cadena	= @Cadena + '(Fecha = ''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''') AND (Parametro = ''' + @CuentaContable + ''') GROUP BY Fecha, '
	Set @Cadena	= @Cadena + 'Parametro) Filtro INNER JOIN KRptID_Tabla ON Filtro.Fecha = KRptID_Tabla.Fecha AND Filtro.Parametro = '
	Set @Cadena	= @Cadena + 'KRptID_Tabla.Parametro AND Filtro.Hora = KRptID_Tabla.Hora '
	
	Print @Cadena
	Exec (@Cadena)

	Select @ID3 = Valor From #A
	Truncate Table #A	

	If @ID3 Is Null Begin Set @ID3 = ''	End
	--Select @ID1 As Uno UNION Select @ID2 as Dos UNION Select @ID3 as Tres
	
	Set @Cadena 	= 'SELECT *, MovimientoO - MovimientoC AS Diferencia FROM (SELECT Operativo.*, CASE WHEN CuentaOperativa IS NULL THEN 0 ELSE 1 '
	Set @Cadena	= @Cadena + 'END AS Ope, CASE WHEN Agrupado IS NULL THEN 0 ELSE 1 END AS Con, ISNULL(Contable.Saldo, 0) AS MovimientoC FROM '
	Set @Cadena	= @Cadena + '(SELECT DISTINCT Datos.*, Datos.Anterior - Datos.Actual AS MovimientoO, CASE WHEN Actual = 0 AND Cancelacion = '
	Set @Cadena 	= @Cadena + '''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''' THEN ''Cuenta Operativa Cancelada'' WHEN Anterior = 0 AND ' 
	Set @Cadena 	= @Cadena + 'Desembolso = ''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''' THEN ''Cuenta Operativa Aperturada'' WHEN Anterior '
	Set @Cadena 	= @Cadena + '> actual AND tcspagodet.fecha = ''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''' THEN ''Cuenta Operativa con '
	Set @Cadena 	= @Cadena + 'Amortización'' ELSE ''Cuenta Operativa tiene '' + Cast(NroDiasAtraso AS Varchar(5)) + '' Días de Atraso'' END AS '
	Set @Cadena 	= @Cadena + 'Operativo FROM (SELECT ISNULL(Actual.Fecha, Anterior.Fecha) AS Fecha, ISNULL(Actual.Parametro, Anterior.Parametro) '
	Set @Cadena 	= @Cadena + 'AS Parametro, ISNULL(Actual.Agrupado, Anterior.Agrupado) AS CuentaOperativa, ISNULL(Anterior.Saldo, 0) AS Anterior, '
	Set @Cadena 	= @Cadena + 'ISNULL(Actual.Saldo, 0) AS Actual FROM (SELECT * FROM KRptID_Tabla WHERE (Tabla = ''' + @ID1 + ''') AND Fecha = '
	Set @Cadena 	= @Cadena + '''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''') Actual FULL OUTER JOIN (SELECT * FROM KRptID_Tabla WHERE '
	Set @Cadena 	= @Cadena + '(Tabla = ''' + @ID2 + ''') AND fecha = ''' + dbo.FduFechaAtexto(@UnDiaAntes, 'AAAAMMDD') + ''') Anterior ON '
	Set @Cadena 	= @Cadena + 'Actual.Parametro = Anterior.Parametro AND Actual.Agrupado = Anterior.Agrupado) Datos LEFT OUTER JOIN (SELECT * FROM '
	Set @Cadena 	= @Cadena + 'tCsCartera WHERE (Fecha = ''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''')) tCsCartera ON Datos.CuentaOperativa '
	Set @Cadena 	= @Cadena + '= tCsCartera.CodPrestamo LEFT OUTER JOIN (SELECT * FROM tCsPagoDet WHERE (Fecha = '
	Set @Cadena	= @Cadena + '''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''') AND (Extornado = 0)) tCsPagoDet ON Datos.CuentaOperativa '
	Set @Cadena	= @Cadena + 'COLLATE Modern_Spanish_CI_AI = tCsPagoDet.CodPrestamo LEFT OUTER JOIN tCsPadronCarteraDet ON Datos.CuentaOperativa '
	Set @Cadena	= @Cadena + 'COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo WHERE (Datos.Anterior <> Datos.Actual)) Operativo '
	Set @Cadena	= @Cadena + 'FULL OUTER JOIN (SELECT * FROM KRptID_Tabla WHERE (Tabla = ''' + @ID3 + ''') And Fecha = '
	Set @Cadena	= @Cadena + '''' + dbo.FduFechaAtexto(@Fecha, 'AAAAMMDD') + ''') Contable ON Operativo.CuentaOperativa = Contable.Agrupado) Datos '

	Print @Cadena
	Exec(@Cadena)
	
End 
GO