SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Exec pCsRptCaSituacionCarteraDetalle 'DDOCTOCU-1', 1, 1, 'B'
CREATE Procedure [dbo].[pCsRptCaSituacionCarteraDetalle]
@Id 		Varchar(50),
@Dato		Int,
@Fila		Int,
@Columna 	Varchar(1)

--Set @Id 	= 'DOOTTOCU-7'
--Set @Dato 	= 1
--Set @Fila	= 35
--Set @Columna	= 'B'

As
Declare @GTF DateTime
Set @GTF = GetDate()
Print '------ANALISIS DE TIEMPO--------'	
Print dbo.fduFormatoHora(Datediff(second, @GTF, Getdate()))
Print '------ANALISIS DE TIEMPO--------'	
Declare @Fecha 			SmallDateTime
Declare @Ubicacion		Varchar(100)
Declare @Nivel1			Varchar(50)
Declare @Nivel2			Varchar(50)
Declare @Nivel1C		Varchar(50)
Declare @Nivel2C		Varchar(50)
Declare @ClaseCartera	Varchar(100)	
Declare @TipoSaldo		Varchar(1000)
Declare @Reporte 		Varchar(50)
Declare @Usuario		Varchar(50)

Exec pRptParametrosID @ID, 
@Fecha 			Out,
@Ubicacion		Out,
@Nivel1			Out,
@Nivel2			Out,
@ClaseCartera	Out,
@TipoSaldo		Out,
@Reporte 		Out,
@Usuario		Out

Print '@Fecha			: ' + Cast(@Fecha as Varchar(50)) 	
Print '@Ubicación		: ' + Cast(@Ubicacion as varchar(50))	
Print '@Nivel1			: ' + Cast(@Nivel1 as Varchar(50))	
Print '@Nivel2			: ' + Cast(@Nivel2 as Varchar(50))	
Print '@ClaseCartera	: ' + Cast(@ClaseCartera	as Varchar(50))
Print '@TipoSaldo		: ' + Cast(@TipoSaldo as Varchar(50))	
Print '@Reporte			: ' + Cast(@Reporte as Varchar(50))	
Print '@Usuario			: ' + Cast(@Usuario as Varchar(50))	


Declare @Cadena		Varchar(4000)
Declare @Cadena1	Varchar(4000)
Declare @Cadena2	Varchar(4000)
Declare @Cadena3	Varchar(4000)
Declare @Cadena4	Varchar(4000)
Declare @Cadena5	Varchar(4000)
Declare @CDetalle1 	Varchar(8000)
Declare @CDetalle2 	Varchar(4000)
Declare @CDetalle3 	Varchar(4000)

Declare @CUbicacion	Varchar(500)
Declare @CClaseCartera 	Varchar(500)

Declare @Tabla 		Varchar(50)
Declare @DSelect	Varchar(8000)
Declare @DFrom1		Varchar(4000)
Declare @DFrom2		Varchar(4000)
Declare @DFrom3		Varchar(4000)
Declare @DWhere		Varchar(4000)
Declare @DGroupBy	Varchar(4000)

Declare @OtroDato	Varchar(100)
Declare @CDato 		Varchar(100)

Print Isnull(@Ubicacion, 'Nulo')

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out
--Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera 	Out, 	@ClaseCartera 	Out,  @OtroDato Out
If Substring(@Reporte, 1, 2) in ('CA')
Begin
	Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera Out, 	@ClaseCartera 	Out,  @OtroDato Out
End
If Substring(@Reporte, 1, 2) in ('AH')
Begin
	Exec pGnlCalculaParametros 5, @ClaseCartera, 	@CClaseCartera Out, 	@ClaseCartera 	Out,  @OtroDato Out
End

Exec pGnlCalculaParametros 3, @TipoSaldo, 	@TipoSaldo 	Out, 	@Tabla 		Out,  @OtroDato Out

Exec pCsRptCaDetalleCartera 	@Fecha, @CUbicacion, @Ubicacion, @CClaseCartera, @ClaseCartera, @Tabla,
				@DSelect 	Out,
				@DFrom1		Out,
				@DFrom2		Out,
				@DFrom3		Out,
				@DWhere 	Out,
				@DGroupBy	Out,
				@Usuario
Print 'Ejecución Después de Detalle'
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tRptID_'+ Left(@ID,8) +']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Set @Cadena2 = 'Begin drop table [dbo].[tRptID_'+ Left(@ID,8) +'] End'
Print 	 @Cadena2
Exec 	(@Cadena2) 

Set @Cadena2 = 'CREATE TABLE [dbo].[tRptID_'+ Left(@ID,8) +'] ( '
Set @Cadena2 = @Cadena2 + '[Fila] [int] IDENTITY (1, 1) NOT NULL , '

If @Nivel1 = @Nivel2
Begin
	Set @Nivel1C = @Nivel1
	Set @Nivel2C = @Nivel2 + 'A' 
End
Else
Begin
	Set @Nivel1C = @Nivel1
	Set @Nivel2C = @Nivel2 
End

If @Dato = 1
Begin
	Set @Cadena2 = @Cadena2 + '['+ @Nivel1C +'] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL , '
	Set @Cadena2 = @Cadena2 + '['+ @Nivel2C +'] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL, '
	Set @Cadena2 = @Cadena2 + '[Cadena] AS ('' AND Detalle.'+ @Nivel1 +' = '''''' + ['+ @Nivel1C +'] + '''''' AND Detalle.'+ @Nivel2 +' = '''''' + ['+ @Nivel2C +'] + '''''''') '
	Set @Cadena3 = @Nivel1C + ', ' + @Nivel2C
	Set @Cadena4 = @Nivel1 + ', ' + @Nivel2
End
If @Dato = 2
Begin	
	Set @Cadena2 = @Cadena2 + '['+ @Nivel2C +'] [varchar] (1031) COLLATE Modern_Spanish_CI_AI NULL, '
	Set @Cadena2 = @Cadena2 + '[Cadena] AS ('' AND Detalle.'+ @Nivel2 +' = '''''' + ['+ @Nivel2C +'] + '''''''') '
	Set @Cadena3 = @Nivel2C
	Set @Cadena4 = @Nivel2
End
If @Nivel1 = @Nivel2
Begin
	Set @Cadena5 = @Nivel1 
End
Else
Begin
	Set @Cadena5 = @Cadena4
End

Set @Cadena2 = @Cadena2 + ') ON [PRIMARY]'

Print 	@Cadena2
Exec   (@Cadena2)

Set @Cadena 	= 'INSERT INTO tRptID_'+ Left(@ID,8) +' ('+ @Cadena3 + ') SELECT '+ @Cadena4 +' FROM ('
Set @Cadena1 	= ') Datos GROUP BY ' + @Cadena5 + ' ORDER BY ' + @Cadena5

Print '@Cadena 	: ' + @Cadena
Print '@DSelect	: ' + @DSelect	
Print '@DFrom1	: ' + @DFrom1		
Print '@DFrom2	: ' + @DFrom2		
Print '@DFrom3  : ' + @DFrom3		
Print '@DWhere  : ' + @DWhere 	
Print '@DGroupBy: ' + @DGroupBy	
Print '@Cadena1	: ' + @Cadena1

Print '------ANALISIS DE TIEMPO--------'	
Print dbo.fduFormatoHora(Datediff(second, @GTF, Getdate()))
Print '------ANALISIS DE TIEMPO--------'	

Exec (@Cadena + @DSelect + @DFrom1 + @DFrom2 + @DFrom3 + @DWhere + @DGroupBy + @Cadena1)	


--/*
Create Table #Cadena ([Cadena] Varchar(4000))

Set @Cadena = 'Insert Into #Cadena Select Cadena From [tRptID_'+ Left(@ID,8) +'] '
Set @Cadena = @Cadena + 'Where Fila = ' +  cast(@Fila as Varchar(5))
Print @Cadena
Exec (@Cadena)

Select @Cadena4 = Cadena from #Cadena

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tRptID_'+ Left(@ID,8) +']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin Set @Cadena2 = 'drop table [dbo].[tRptID_'+ Left(@ID,8) +']'  End 
Else Begin  Set @Cadena2 = '' End 
Print 	 @Cadena2
Exec 	(@Cadena2) 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tRrtFilaColumna_'+ Left(@ID,8) +']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin Set @Cadena2 = 'drop table [dbo].[tRrtFilaColumna_'+ Left(@ID,8) +']' End 
Else Begin  Set @Cadena2 = '' End 
Print 	 @Cadena2
Exec 	(@Cadena2) 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tRrtTotal_'+ Left(@ID,8) +']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin Set @Cadena2 = 'drop table [dbo].[tRrtTotal_'+ Left(@ID,8) +']' End 
Else Begin  Set @Cadena2 = '' End 
Print 	 @Cadena2
Exec 	(@Cadena2) 

Set @CDetalle1 		=  'SELECT  tCsPrReportesAnexos.Identificador, tCsPrReportesAnexos.DescIdentificador AS Padre, tCsPrReportesAnexos.Descripcion AS Hijo, Detalle.* Into tRrtFilaColumna_'+ Left(@ID,8) +' FROM tCsPrReportesAnexos INNER JOIN ( '  +  @DSelect + @DFrom1 
Set @CDetalle2 		=  @DFrom2 + @DFrom3 
Set @CDetalle3 		=  @DWhere + @DGroupBy + ') Detalle ON tCsPrReportesAnexos.pInicio <= Detalle.Dias AND '
Set @CDetalle3		=  @CDetalle3 + 'tCsPrReportesAnexos.PFin >= Detalle.Dias WHERE '
Set @CDetalle3		=  @CDetalle3 + '(tCsPrReportesAnexos.Reporte = '''+ @Reporte +''') AND (tCsPrReportesAnexos.Identificador = '''+ @Columna +''') ' + @Cadena4 

Print 'Detalle1 : ' + @CDetalle1
Print 'Detalle2 : ' + @CDetalle2
Print 'Detalle3 : ' + @CDetalle3

Print '------ANALISIS DE TIEMPO--------'	
Print dbo.fduFormatoHora(Datediff(second, @GTF, Getdate()))
Print '------ANALISIS DE TIEMPO--------'	

Exec  (@CDetalle1 + @CDetalle2 + @CDetalle3) 

Print '------ANALISIS DE TIEMPO--------'	
Print dbo.fduFormatoHora(Datediff(second, @GTF, Getdate()))
Print '------ANALISIS DE TIEMPO--------'	

Set @CDetalle1 		=  'SELECT Identificador = '''+ @Columna +''', Etiqueta = '''+ @OtroDato +''', Total = SUM('+ @TipoSaldo +')  Into tRrtTotal_'+ Left(@ID,8) +' FROM tCsPrReportesAnexos INNER JOIN ( '  +  @DSelect + @DFrom1 
Set @CDetalle2 		=  @DFrom2 + @DFrom3 
Set @CDetalle3 		=  @DWhere + @DGroupBy + ') Detalle ON tCsPrReportesAnexos.pInicio <= Detalle.Dias AND '
Set @CDetalle3		=  @CDetalle3 + 'tCsPrReportesAnexos.PFin >= Detalle.Dias WHERE '
Set @CDetalle3		=  @CDetalle3 + '(tCsPrReportesAnexos.Reporte = '''+ @Reporte +''') AND (tCsPrReportesAnexos.Identificador = ''A'') ' + @Cadena4 

Print @CDetalle1
Print @CDetalle2
Print @CDetalle3

Print '------ANALISIS DE TIEMPO--------'	
Print dbo.fduFormatoHora(Datediff(second, @GTF, Getdate()))
Print '------ANALISIS DE TIEMPO--------'	

Exec  (@CDetalle1 + @CDetalle2 + @CDetalle3) 

Set @CDetalle1 = 'SELECT Datos.Fecha, tRrtFilaColumna.Asesor, tRrtFilaColumna.CodPrestamo, tCsPadronClientes.Nombres + '', '' + tCsPadronClientes.Paterno AS Cliente, '
Set @CDetalle1 = @CDetalle1 + 'tRrtFilaColumna.Genero, tRrtFilaColumna.CP3_Colonia, tRrtFilaColumna.ZonaLugar, tRrtFilaColumna.Tecnologia, tRrtFilaColumna.TipoCredito, '
Set @CDetalle1 = @CDetalle1 + 'tRrtFilaColumna.ClaseCartera, tCsCartera.FechaDesembolso, tCsCarteraDet.MontoDesembolso, tCsCartera.TipoReprog, tCsCartera.NroDiasAtraso, '
Set @CDetalle1 = @CDetalle1 + 'tCsCartera.Estado, tCsCarteraDet.SaldoCapital, tCsCarteraDet.InteresVigente + tCsCarteraDet.InteresVencido As InteresCorriente, tCsCarteraDet.InteresCtaOrden, '
Set @CDetalle1 = @CDetalle1 + 'tCsCarteraDet.MoratorioVigente + tCsCarteraDet.MoratorioVencido As InteresMoratorio, tCsCarteraDet.MoratorioCtaOrden, tCsCarteraDet.OtrosCargos, '
Set @CDetalle1 = @CDetalle1 + 'tCsCarteraDet.Impuestos, tCsCarteraDet.CargoMora, tCsCartera.NroCuotas, tCsCartera.NroCuotasPagadas, '
Set @CDetalle1 = @CDetalle1 + 'Datos.Nivel1, Datos.DNivel1 , Datos.Nivel2, Datos.DNivel2, Datos.identificador, Datos.Desembolso, Datos.Saldo, Clientes.Clientes, Prestamos.Prestamos, tRrtTotal.Total, '
Set @CDetalle1 = @CDetalle1 + 'tRrtTotal.Etiqueta, Datos.Padre, Datos.Hijo, '''+ @TipoSaldo +''' AS TipoSaldo, '
Set @CDetalle1 = @CDetalle1 + ''''+ @Ubicacion +''' AS Ubicacion, '''+ @ClaseCartera +''' AS ClaseCartera, tCsCartera.ProximoVencimiento '
Set @CDetalle1 = @CDetalle1 + 'FROM tCsCartera INNER JOIN '
Set @CDetalle1 = @CDetalle1 + 'tCsCarteraDet ON tCsCartera.Fecha = tCsCarteraDet.Fecha AND tCsCartera.CodPrestamo = tCsCarteraDet.CodPrestamo RIGHT OUTER JOIN '
Set @CDetalle1 = @CDetalle1 + '(SELECT Fecha, Nivel1 = '''+ @Nivel1 +''', '
If @Dato = 1
Begin
	Set @CDetalle1 = @CDetalle1 + @Nivel1 
End
If @Dato = 2
Begin
	Set @CDetalle1 = @CDetalle1 + '''Resumen'''
End
Set @CDetalle1 = @CDetalle1 + ' AS DNivel1, Nivel2 = '''+ @Nivel2 +''', ''['+ Cast(@Fila as Varchar(5)) +'] '' + '+ @Nivel2 +' AS DNivel2, identificador, Padre, Hijo, SUM(Desembolso) AS Desembolso, '
Set @CDetalle1 = @CDetalle1 + 'SUM('+ @TipoSaldo +') AS Saldo '
Set @CDetalle1 = @CDetalle1 + 'FROM tRrtFilaColumna_'+ Left(@ID,8) +' '
Set @CDetalle1 = @CDetalle1 + 'GROUP BY Fecha, identificador, Padre, Hijo, '
If @Dato = 1
Begin
	Set @CDetalle1 = @CDetalle1 + @Nivel1 +', '+ @Nivel2 
End
If @Dato = 2
Begin
	Set @CDetalle1 = @CDetalle1 + @Nivel2 
End
Set @CDetalle1 = @CDetalle1 + ' ) Datos INNER JOIN '
Set @CDetalle1 = @CDetalle1 + '(SELECT identificador, COUNT(*) AS Clientes '
Set @CDetalle1 = @CDetalle1 + 'FROM (SELECT DISTINCT identificador, CodUsuario '
Set @CDetalle1 = @CDetalle1 + 'FROM tRrtFilaColumna_'+ Left(@ID,8) +') Clientes '
Set @CDetalle1 = @CDetalle1 + 'GROUP BY identificador) Clientes ON Datos.identificador = Clientes.identificador INNER JOIN '
Set @CDetalle1 = @CDetalle1 + '(SELECT identificador, COUNT(*) AS Prestamos '
Set @CDetalle1 = @CDetalle1 + 'FROM (SELECT DISTINCT identificador, CodPrestamo '
Set @CDetalle1 = @CDetalle1 + 'FROM tRrtFilaColumna_'+ Left(@ID,8) +') Clientes '
Set @CDetalle1 = @CDetalle1 + 'GROUP BY identificador) Prestamos ON Datos.identificador = Prestamos.identificador INNER JOIN '
Set @CDetalle1 = @CDetalle1 + 'tRrtTotal_'+ Left(@ID,8) +' tRrtTotal ON Datos.identificador = tRrtTotal.Identificador COLLATE Modern_Spanish_CI_AI INNER JOIN '
Set @CDetalle1 = @CDetalle1 + 'tRrtFilaColumna_'+ Left(@ID,8) +' tRrtFilaColumna ON Datos.identificador COLLATE Modern_Spanish_CI_AI = tRrtFilaColumna.Identificador ON '
Set @CDetalle1 = @CDetalle1 + 'tCsCarteraDet.Fecha = tRrtFilaColumna.Fecha AND tCsCarteraDet.CodPrestamo = tRrtFilaColumna.CodPrestamo AND '
Set @CDetalle1 = @CDetalle1 + 'tCsCarteraDet.CodUsuario = tRrtFilaColumna.CodUsuario LEFT OUTER JOIN '
Set @CDetalle1 = @CDetalle1 + 'tCsPadronClientes ON tRrtFilaColumna.CodUsuario = tCsPadronClientes.CodUsuario '

Print  @CDetalle1
Exec  (@CDetalle1) 

Drop Table #Cadena
--*/
--/*
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tRrtFilaColumna_'+ Left(@ID,8) +']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin Set @Cadena2 = 'drop table [dbo].[tRrtFilaColumna_'+ Left(@ID,8) +']' End 
Else Begin  Set @Cadena2 = '' End 
Print 	 @Cadena2
Exec 	(@Cadena2) 

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tRrtTotal_'+ Left(@ID,8) +']') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin Set @Cadena2 = 'drop table [dbo].[tRrtTotal_'+ Left(@ID,8) +']' End 
Else Begin  Set @Cadena2 = '' End 
Print 	 @Cadena2
Exec 	(@Cadena2)
Print '------ANALISIS DE TIEMPO--------'	
Print dbo.fduFormatoHora(Datediff(second, @GTF, Getdate()))
Print '------ANALISIS DE TIEMPO--------'	
--*/

GO