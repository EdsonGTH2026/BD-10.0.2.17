SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- Exec pCsCaDetalleCarteraTramo 1, '24', 'ACTIVA', 30, 0, 0
-- Drop Procedure pCsCaDetalleCarteraTramo
Create Procedure [dbo].[pCsCaDetalleCarteraTramo]
@Dato				Int,
@Ubicacion			Varchar(500),
@ClaseCartera		Varchar(100),	
@Tramo				Int,
@NroDiasAtraso		Int,
@Maximo 			Int
As

--1: Para ver por Prestamo.
--2: Para Ver por Cliente.

Declare @CUbicacion		Varchar(500)
Declare @CClaseCartera	Varchar(500)
Declare @OtroDato		Varchar(1000)
Declare @Cadena			Varchar(8000)
Declare @TramoN			Varchar(50)
Declare @Limite			Int
Declare @Operador		Varchar(10)
Declare @SCarteraSana	Varchar(1000)

Set @Operador			= '<='
Set @SCarteraSana		= 'Atraso.Saldo AS MontoActual, Atraso.SecCuota AS CuotasAtrasadas, tCsCartera.ProximoVencimiento, Atraso.FechaVencimiento '

If @NroDiasAtraso		= 0 Or @Maximo = 0
Begin
	Set @NroDiasAtraso	= 0
	Set @Maximo			= 0
	Set @Operador		= '>='
	Set @SCarteraSana	= '0 AS MontoActual, 0 AS CuotasAtrasadas, tCsCartera.ProximoVencimiento, NULL AS FechaVencimiento '
End

Set @Tramo = @Tramo - 1

If @Maximo < @Tramo
Begin
	Set @Tramo = @Maximo 
End

Exec pGnlCalculaParametros 1, @Ubicacion, 		@CUbicacion 	Out, 	@Ubicacion 		Out,  @OtroDato Out
Exec pGnlCalculaParametros 2, @ClaseCartera, 	@CClaseCartera	Out, 	@ClaseCartera 	Out,  @OtroDato Out

Set @Ubicacion		= dbo.fduRellena(' ', @Ubicacion,		100, 'I')
Set @ClaseCartera	= dbo.fduRellena(' ', @ClaseCartera,	100, 'I')

Create Table #Valor
(Valor Int)

Set @Cadena = 'Insert Into #Valor Select max(NroDiasAtraso) as MAximo From Tcscartera Where CodOficina in ('+ @CUbicacion +')' 
Print @Cadena
Exec (@Cadena)

If @Maximo > (Select Valor from #Valor)
Begin
	Select @Maximo = Valor from #Valor
End 

Drop Table #Valor

CREATE TABLE #KKKKKEEEEE (
	[Maximo]			[Int]			NULL,
	[ClaseCartera] 		[varchar] 		(100) 	COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Tramo] 			[varchar] 		(11) 	COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[Ubicacion] 		[varchar] 		(100) 	COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[CodOficina] 		[varchar] 		(4) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[Oficina] 			[varchar] 		(30) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[Corte] 			[smalldatetime] NOT NULL ,
	[Cartera] 			[varchar] 		(50) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[CodPrestamo] 		[varchar] 		(100) 	COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[ClienteGrupo] 		[varchar] 		(100) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[NroDiasAtraso] 	[int] 			NULL ,
	[Asesor] 			[varchar] 		(300) 	COLLATE Modern_Spanish_CI_AI NULL ,
	[CapitalRiesgo] 	[decimal]		(19, 4)	NULL ,
	[Cuota] 			[money] 		NULL ,
	[MontoActual] 		[money] 		NULL ,
	[CuotasAtrasadas] 	[int] 			NULL,
	[ProximoVencimiento][smalldatetime] NULL ,
	[Vencimiento]  		[smalldatetime] NULL,
	[Coordinador]		[Int]			NULL,
	[C]					[Int]			NULL , 
	[Monto] 			[money] 		NULL 
) 

CREATE TABLE #Pagos (
	[CodPrestamo] [varchar] (25) COLLATE Modern_Spanish_CI_AI NOT NULL ,
	[SecCuota] [smallint]				NOT NULL ,
	[Saldo] [money]						NULL ,
	[DiasAtraso] [int]					NULL ,
	[PagoCapital] [money]				NULL ,
	[Cuota] [money]						NULL ,
	[FechaVencimiento] [smalldatetime]	NOT NULL,
	[C] [int]							NULL  
) 

Declare @Fecha			SmallDateTime

Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion 

--Drop table pagos

While @NroDiasAtraso <= @Maximo
Begin
	Set @Limite			= @NroDiasAtraso + @Tramo
	
	Truncate Table #Pagos
	
	Set @Cadena			= 'Insert Into #Pagos (CodPrestamo, SecCuota, Saldo, DiasAtraso, PagoCapital, Cuota, FechaVencimiento) SELECT CodPrestamo, '
	Set @Cadena			= @Cadena + 'SecCuota, SUM(Saldo) AS Saldo, DiasAtraso, 0 AS SaldoCapital, SUM(Cuota) AS Cuota, FechaVencimiento FROM '
	Set @Cadena			= @Cadena + '(SELECT CodPrestamo, SecCuota, SUM(MontoDevengado - MontoPagado - MontoCondonado) AS Saldo, CASE WHEN '
	Set @Cadena			= @Cadena + 'DATEDIFF(Day, FechaVencimiento, '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') < 0 THEN - 1 ELSE '
	Set @Cadena			= @Cadena + 'DATEDIFF(Day, FechaVencimiento, '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') END + 1 AS DiasAtraso, '
	Set @Cadena			= @Cadena + 'CASE CodConcepto WHEN ''CAPI'' THEN SUM(MontoDevengado - MontoPagado - MontoCondonado) ELSE 0 END AS '
	Set @Cadena			= @Cadena + 'SaldoCapital, CASE WHEN CodConcepto IN (''CAPI'', ''INTE'', ''IVAIT'') THEN SUM(MontoCuota) ELSE 0 END AS '
	Set @Cadena			= @Cadena + 'Cuota, FechaVencimiento FROM tCsPadronPlanCuotas AS tCsPadronPlanCuotas_1 WHERE '
	Set @Cadena			= @Cadena + '(FechaVencimiento '+ @Operador +' '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') AND (CodPrestamo IN '
	Set @Cadena			= @Cadena + '(SELECT CodPrestamo FROM tCsCartera WHERE (CodOficina IN (' + @CUbicacion + ')) AND (NroDiasAtraso '
	Set @Cadena			= @Cadena + '>= '+ Cast(@NroDiasAtraso as Varchar(10)) +') AND (NroDiasAtraso <= '+ Cast(@Limite as Varchar(10)) +') AND '
	Set @Cadena			= @Cadena + '(Fecha = '''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') AND (Cartera IN ('+ @CClaseCartera +')))) GROUP BY '
	Set @Cadena			= @Cadena + 'CodConcepto, CodPrestamo, SecCuota, FechaVencimiento) AS Datos GROUP BY CodPrestamo, SecCuota, DiasAtraso, '
	Set @Cadena			= @Cadena + 'FechaVencimiento HAVING (SUM(Saldo) > 0) '
	
	Print @Cadena
	Exec (@Cadena)
	
	UPDATE #Pagos
	Set Saldo = Saldo -  PagoTotal, PagoCapital = Capital
	FROM            #Pagos Pagos  INNER JOIN
							 [BD-FINAMIGO-DC].Finmas.dbo.vCaAmortizaciones AS vCaAmortizaciones_1 ON Pagos.CodPrestamo = vCaAmortizaciones_1.CodPrestamo AND 
							 Pagos.SecCuota = vCaAmortizaciones_1.SecCuota
	
	UPDATE    #Pagos
	SET              C = Datos.C
	FROM         (SELECT     CodPrestamo, COUNT(*) AS C
						   FROM          #Pagos
						   WHERE      (Saldo > 0)
						   GROUP BY CodPrestamo) Datos INNER JOIN
						  #Pagos ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = #Pagos.CodPrestamo	
	
	Set @TramoN			= '['+ dbo.fduRellena('0', @NroDiasAtraso, 4, 'D')+ '-'+ dbo.fduRellena('0', @Limite, 4, 'D') +']'
	Set @Cadena			= 'Insert Into #KKKKKEEEEE SELECT Datos.Maximo, Datos.ClaseCartera, Datos.Tramo, Datos.Ubicacion, Datos.CodOficina, '
	Set @Cadena			= @Cadena + 'Datos.Oficina, Datos.Corte, Datos.Cartera, ' + Case @Dato When 1 Then 'Datos.CodPrestamo, Datos.ClienteGrupo' When 2 Then 'Datos.ClienteGrupo As CodGrupo, D.Cliente as ClienteGrupo' End +', '
	Set @Cadena			= @Cadena + 'Datos.NroDiasAtraso, Datos.Asesor, Datos.CapitalRiesgo * D.Porcentaje AS CapitalRiesgo, Datos.Cuota * '
	Set @Cadena			= @Cadena + 'D.Porcentaje AS Cuota, Datos.MontoActual * D.Porcentaje AS MontoActual, Datos.CuotasAtrasadas, '
	Set @Cadena			= @Cadena + 'Datos.ProximoVencimiento, Datos.FechaVencimiento, D.Coordinador, Datos.C, D.Monto * D.Porcentaje As Monto FROM (SELECT '
	Set @Cadena			= @Cadena + 'Maximo = '+ Cast(@Maximo as Varchar(10)) +', ClaseCartera = '''+ @ClaseCartera +''', '
	Set @Cadena			= @Cadena + 'Tramo = '''+ @TramoN +''', Ubicacion = '''+ @Ubicacion +''', tCsCartera.CodOficina, tClOficinas.NomOficina AS '
	Set @Cadena			= @Cadena + 'Oficina, tCsCartera.Fecha AS Corte, tCsCartera.Cartera, tCsCartera.CodPrestamo, '
	Set @Cadena			= @Cadena + 'ISNULL(tCsCarteraGrupos.NombreGrupo, tCsPadronClientes.NombreCompleto) AS ClienteGrupo, Atraso.DiasAtraso AS '
	Set @Cadena			= @Cadena + 'NroDiasAtraso, tCsPadronClientes_1.Nombre1 + '', '' + CASE WHEN '
	Set @Cadena			= @Cadena + 'ltrim(rtrim(IsNull(tCsPadronClientes_1.Paterno, ''''))) = '''' THEN '
	Set @Cadena			= @Cadena + 'ltrim(rtrim(IsNull(tCsPadronClientes_1.Materno, ''''))) ELSE '
	Set @Cadena			= @Cadena + 'ltrim(rtrim(IsNull(tCsPadronClientes_1.Paterno, ''''))) END AS Asesor, tCsCartera.SaldoCapital AS '
	Set @Cadena			= @Cadena + 'CapitalRiesgo, Atraso.Cuota, Atraso.C, '+ @SCarteraSana +' FROM tCsCartera INNER JOIN (SELECT * FROM #Pagos '
	Set @Cadena			= @Cadena + 'WHERE (Saldo > 0)) AS Atraso ON tCsCartera.CodPrestamo = Atraso.CodPrestamo INNER JOIN tClOficinas ON '
	Set @Cadena			= @Cadena + 'tCsCartera.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN (SELECT CodPrestamo, SUM(PagoCapital) AS Pago '
	Set @Cadena			= @Cadena + 'FROM #Pagos AS Pagos_1 GROUP BY CodPrestamo) AS Capital ON tCsCartera.CodPrestamo = Capital.CodPrestamo '
	Set @Cadena			= @Cadena + 'LEFT OUTER JOIN tCsPadronClientes AS tCsPadronClientes_1 ON tCsCartera.CodAsesor = '
	Set @Cadena			= @Cadena + 'tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN tCsPadronClientes ON tCsCartera.CodUsuario = '
	Set @Cadena			= @Cadena + 'tCsPadronClientes.CodUsuario LEFT OUTER JOIN tCsCarteraGrupos ON tCsCartera.CodOficina = '
	Set @Cadena			= @Cadena + 'tCsCarteraGrupos.CodOficina AND tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo WHERE '
	Set @Cadena			= @Cadena + '(tCsCartera.CodOficina IN (' + @CUbicacion + ')) AND '
	Set @Cadena			= @Cadena + '(tCsCartera.NroDiasAtraso >= '+ Cast(@NroDiasAtraso as Varchar(10)) +') AND (tCsCartera.NroDiasAtraso '
    Set @Cadena			= @Cadena + '<= '+ Cast(@Limite as Varchar(10)) +') AND (tCsCartera.Fecha = '
    Set @Cadena			= @Cadena + ''''+ dbo.fduFechaATexto(@Fecha, 'AAAAMMDD') +''') AND (tCsCartera.Cartera IN ('+ @CClaseCartera +'))) Datos '
	Set @Cadena			= @Cadena + 'INNER JOIN (SELECT T.Monto, tCsPadronCarteraDet.CodPrestamo, tCsPadronCarteraDet.CodUsuario, tCsPadronCarteraDet.Coordinador, '+ Case @Dato When 1 Then '1' When 2 Then 'tCsPadronCarteraDet.Monto/T.Monto' End +' AS Porcentaje, '
	Set @Cadena			= @Cadena + 'ISNULL(tCsPadronClientes.NombreCompleto, ''No Identificado'') AS Cliente FROM (SELECT CodPrestamo, SUM(Monto) '
	Set @Cadena			= @Cadena + 'AS Monto FROM tCsPadronCarteraDet GROUP BY CodPrestamo) T INNER JOIN tCsPadronCarteraDet ON T .CodPrestamo '
	Set @Cadena			= @Cadena + 'COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo LEFT OUTER JOIN tCsPadronClientes ON '
	Set @Cadena			= @Cadena + 'tCsPadronCarteraDet.CodUsuario = tCsPadronClientes.CodUsuario WHERE (tCsPadronCarteraDet.Coordinador IN ('+ Case @Dato When 1 Then '1' When 2 Then '0,1' End +'))) '
	Set @Cadena			= @Cadena + 'D ON Datos.CodPrestamo = D.CodPrestamo '
	
	Print @Cadena
	Exec (@Cadena)
	
	Set @NroDiasAtraso	= @NroDiasAtraso + @Tramo + 1	
End 

Select * from #KKKKKEEEEE

Drop Table #KKKKKEEEEE





GO