SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsFondoSaldos
Create Procedure [dbo].[pCsFondoSaldos]
@Fecha 		SmallDateTime,
@Dato 		Int,
@Validar 	Bit,
@Fondo		Int,
@Eliminar	Bit,
@Tecnologia	Varchar(50),
@Estado		Varchar(50),
@DI		Int,
@DF		Int,
@DiasPivot	Int,
@Valor 		Decimal(18,4) Output
As
---VALORES DE DATO
--- 1. Codigo del Fondo
--- 2. Saldos Cuadro 2.1
--Set @Fecha = '20100228'

Declare @Contador 	Int
Declare @Saldo		Decimal(18,4) 
Declare @Valido		Bit
Declare @Creacion	Bit 
Declare @nFondo		Varchar(100)
Declare @Cadena		Varchar(8000)
Declare @Operador 	Varchar(100)

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tCsFondoSaldos]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
Begin
	Select @Contador = Count(*) From tCsFondoSaldos Where Fecha = @Fecha
	
	If @Contador Is Null Begin Set @Contador = 0 End
	If @Contador = 0 
	Begin
		Drop Table tCsFondoSaldos	
		Set @Creacion = 1			
	End
	Else
	Begin
		Set @Creacion = 0			
	End
End
Else
Begin
	Set @Creacion = 1			
End

If @Creacion = 1
Begin
	SELECT     *
	INTO tCsFondoSaldos
	FROM         (SELECT    tCsCartera.Fecha, tCsCartera.CodPrestamo, tCsCarteraDet.CodOficina, tCsCartera.CodFondo, tClFondos.NemFondo, tCsCartera.NroDiasAtraso, 
	                        SUM(tCsCarteraDet.SaldoCapital) AS SaldoCapital, 
				SUM(tCsCarteraDet.SaldoCapital) AS Vigente, 
				SUM(tCsCarteraDet.SaldoCapital) AS Vencido, 
				SUM(tCsCarteraDet.SaldoCapital) AS CVigente, 
				SUM(tCsCarteraDet.SaldoCapital) AS CVencido, 
	                        tCsCartera.NroCuotas, tCsCartera.CuotaActual, tCsCartera.NroCuotasPagadas, tCsCartera.NroCuotasPorPagar, 
	                        CASE WHEN Nrodiasatraso <= @DiasPivot THEN 'VIGENTE' WHEN cuotaactual = nrocuotas AND 
	                        nrodiasatraso > @DiasPivot THEN 'VENCIDO' ELSE 'ANALIZAR' END AS Proceso, tCaProducto.Tecnologia, tCaClTecnologia.Veridico,
				tCsCartera.FechaDesembolso, Monto = sum(tCsCarteraDet.montodesembolso), CodGrupo, CodAsesor, Participantes  = Count(*)
	                        FROM          tCsCarteraDet INNER JOIN
	                                              tCsCartera ON tCsCarteraDet.Fecha = tCsCartera.Fecha AND tCsCarteraDet.CodPrestamo = tCsCartera.CodPrestamo INNER JOIN
	                                              tClFondos ON tCsCartera.CodFondo = tClFondos.CodFondo INNER JOIN
	                                              tCaProducto ON tCsCartera.CodProducto = tCaProducto.CodProducto INNER JOIN
	                                              tCaClTecnologia ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia
	                       WHERE      (tCsCarteraDet.Fecha = @Fecha) AND (tCsCartera.Cartera = 'ACTIVA')
	                       GROUP BY tCsCartera.Fecha, tCsCartera.CodPrestamo, tCsCarteraDet.CodOficina, tCsCartera.CodFondo, tClFondos.NemFondo, tCsCartera.NroDiasAtraso, 
	                                              tCsCartera.NroCuotas, tCsCartera.CuotaActual, tCsCartera.NroCuotasPagadas, tCsCartera.NroCuotasPorPagar, tCaProducto.Tecnologia, 
	                                              tCaClTecnologia.Veridico, tCsCartera.FechaDesembolso, CodGrupo, CodAsesor) Datos
	
	UPDATE 	tCsFondoSaldos
	SET 	VIGENTE			= 0,
		CVIGENTE		= 0
	WHERE	PROCESO			= 'VENCIDO'
	
	UPDATE 	tCsFondoSaldos
	SET 	VENCIDO			= 0
	WHERE	PROCESO			= 'VIGENTE'
	
	UPDATE 	tCsFondoSaldos
	SET 	CVENCIDO		= 0
	WHERE	NRODIASATRASO		= 0
	
	UPDATE 	tCsFondoSaldos
	SET 	VIGENTE			= 0, 
		VENCIDO			= 0
	WHERE	PROCESO			= 'ANALIZAR'
	
	UPDATE 	tCsFondoSaldos
	SET 	CVIGENTE		= 0, 
		CVENCIDO		= 0
	WHERE	PROCESO	<> 'VENCIDO' AND NRODIASATRASO > 0
	
	UPDATE    tCsFondoSaldos
	SET       Vencido = datos.Vencido
	FROM         (SELECT     CodPrestamo, SUM(Cuota - Pago) AS Vencido
	FROM         (SELECT     tCsFondoSaldos.CodPrestamo, SUM(tCsPadronPlanCuotas.MontoCuota) AS Cuota, ISNULL(Pagos.Pago, 0) AS Pago
	FROM         tCsFondoSaldos INNER JOIN
	                      tCsPadronPlanCuotas ON tCsFondoSaldos.CodPrestamo = tCsPadronPlanCuotas.CodPrestamo AND tCsFondoSaldos.NroCuotasPagadas < tCsPadronPlanCuotas.SecCuota AND 
	                      tCsFondoSaldos.Fecha >= tCsPadronPlanCuotas.FechaVencimiento LEFT OUTER JOIN
	                          (SELECT     CodPrestamo, CodConcepto, SecCuota, SUM(MontoPagado) AS Pago
	                            FROM          tCsPagoDet
	                            WHERE      (Extornado = 0) AND Fecha <= @Fecha
	                            GROUP BY CodPrestamo, CodConcepto, SecCuota) Pagos ON tCsPadronPlanCuotas.SecCuota = Pagos.SecCuota AND 
	                      tCsPadronPlanCuotas.CodConcepto = Pagos.CodConcepto COLLATE Modern_Spanish_CI_AI AND 
	                      tCsPadronPlanCuotas.CodPrestamo = Pagos.CodPrestamo COLLATE Modern_Spanish_CI_AI
	WHERE     (tCsFondoSaldos.Proceso = 'ANALIZAR') AND (tCsPadronPlanCuotas.CodConcepto = 'CAPI') 
	GROUP BY tCsFondoSaldos.CodPrestamo, Pagos.Pago) Datos
	GROUP BY CodPrestamo) Datos INNER JOIN
	                      tCsFondoSaldos ON Datos.CodPrestamo = tCsFondoSaldos.CodPrestamo
	
	UPDATE    tCsFondoSaldos
	SET       Vigente = datos.Vigente
	FROM         (SELECT     tCsFondoSaldos.CodPrestamo, SUM(tCsPadronPlanCuotas.MontoCuota - ISNULL(Pagos.Pago, 0)) AS Vigente
	                       FROM          tCsFondoSaldos INNER JOIN
	                                              tCsPadronPlanCuotas ON tCsFondoSaldos.CodPrestamo = tCsPadronPlanCuotas.CodPrestamo AND 
	                                              tCsFondoSaldos.Fecha < tCsPadronPlanCuotas.FechaVencimiento AND tCsFondoSaldos.CuotaActual <= tCsPadronPlanCuotas.SecCuota LEFT OUTER JOIN
	                                                  (SELECT     Fecha, CodPrestamo, CodConcepto, SecCuota, SUM(MontoPagado) AS Pago
	                                                    FROM          tCsPagoDet
	                                                    WHERE      (Extornado = 0)
	                                                    GROUP BY Fecha, CodPrestamo, CodConcepto, SecCuota) Pagos ON tCsFondoSaldos.Fecha >= Pagos.Fecha AND 
	                                              tCsPadronPlanCuotas.SecCuota = Pagos.SecCuota AND tCsPadronPlanCuotas.CodConcepto = Pagos.CodConcepto COLLATE Modern_Spanish_CI_AI AND 
	                                              tCsPadronPlanCuotas.CodPrestamo = Pagos.CodPrestamo COLLATE Modern_Spanish_CI_AI
	                       WHERE      (tCsPadronPlanCuotas.CodConcepto = 'CAPI') AND (tCsFondoSaldos.Proceso = 'ANALIZAR')
	                       GROUP BY tCsFondoSaldos.CodPrestamo) Datos INNER JOIN
	                      tCsFondoSaldos ON Datos.CodPrestamo = tCsFondoSaldos.CodPrestamo
	
	UPDATE 	tCsFondoSaldos
	SET 	CVIGENTE	= VIGENTE, 
		CVENCIDO	= VENCIDO
	WHERE	PROCESO		= 'ANALIZAR' 
	
	UPDATE tCsFondoSaldos
	SET Tecnologia = 0
	WHere Cvigente = 0 and Cvencido = 0
	
	UPDATE    tCsFondoSaldos
	SET       CVencido = datos.Vencido
	FROM         (SELECT     CodPrestamo, SUM(Cuota - Pago) AS Vencido
	FROM         (SELECT     tCsFondoSaldos.CodPrestamo, SUM(tCsPadronPlanCuotas.MontoCuota) AS Cuota, ISNULL(Pagos.Pago, 0) AS Pago
	FROM         tCsFondoSaldos INNER JOIN
	                      tCsPadronPlanCuotas ON tCsFondoSaldos.CodPrestamo = tCsPadronPlanCuotas.CodPrestamo AND tCsFondoSaldos.NroCuotasPagadas < tCsPadronPlanCuotas.SecCuota AND 
	                      tCsFondoSaldos.Fecha >= tCsPadronPlanCuotas.FechaVencimiento LEFT OUTER JOIN
	                          (SELECT     CodPrestamo, CodConcepto, SecCuota, SUM(MontoPagado) AS Pago
	                            FROM          tCsPagoDet
	                            WHERE      (Extornado = 0) AND Fecha <= @Fecha
	                            GROUP BY CodPrestamo, CodConcepto, SecCuota) Pagos ON tCsPadronPlanCuotas.SecCuota = Pagos.SecCuota AND 
	                      tCsPadronPlanCuotas.CodConcepto = Pagos.CodConcepto COLLATE Modern_Spanish_CI_AI AND 
	                      tCsPadronPlanCuotas.CodPrestamo = Pagos.CodPrestamo COLLATE Modern_Spanish_CI_AI
	WHERE     Tecnologia = 0 AND (tCsPadronPlanCuotas.CodConcepto = 'CAPI') 
	GROUP BY tCsFondoSaldos.CodPrestamo, Pagos.Pago) Datos
	GROUP BY CodPrestamo) Datos INNER JOIN
	                      tCsFondoSaldos ON Datos.CodPrestamo = tCsFondoSaldos.CodPrestamo
	
	UPDATE    tCsFondoSaldos
	SET       CVigente = datos.Vigente
	FROM         (SELECT     tCsFondoSaldos.CodPrestamo, SUM(tCsPadronPlanCuotas.MontoCuota - ISNULL(Pagos.Pago, 0)) AS Vigente
	                       FROM          tCsFondoSaldos INNER JOIN
	                                              tCsPadronPlanCuotas ON tCsFondoSaldos.CodPrestamo = tCsPadronPlanCuotas.CodPrestamo AND 
	                                              tCsFondoSaldos.Fecha < tCsPadronPlanCuotas.FechaVencimiento AND tCsFondoSaldos.CuotaActual <= tCsPadronPlanCuotas.SecCuota LEFT OUTER JOIN
	                                                  (SELECT     Fecha, CodPrestamo, CodConcepto, SecCuota, SUM(MontoPagado) AS Pago
	                                                    FROM          tCsPagoDet
	                                                    WHERE      (Extornado = 0)
	                                                    GROUP BY Fecha, CodPrestamo, CodConcepto, SecCuota) Pagos ON tCsFondoSaldos.Fecha >= Pagos.Fecha AND 
	                                              tCsPadronPlanCuotas.SecCuota = Pagos.SecCuota AND tCsPadronPlanCuotas.CodConcepto = Pagos.CodConcepto COLLATE Modern_Spanish_CI_AI AND 
	                                              tCsPadronPlanCuotas.CodPrestamo = Pagos.CodPrestamo COLLATE Modern_Spanish_CI_AI
	                       WHERE      (tCsPadronPlanCuotas.CodConcepto = 'CAPI') AND Tecnologia = 0
	                       GROUP BY tCsFondoSaldos.CodPrestamo) Datos INNER JOIN
	                      tCsFondoSaldos ON Datos.CodPrestamo = tCsFondoSaldos.CodPrestamo

	UPDATE     tCsFondoSaldos
	SEt Proceso = 'VENCIDO'
	WHERE     (Proceso = 'ANALIZAR')
End
If @Validar = 1
Begin
	Set @Valido = 1
	SELECT     @Contador = Count(*)
	FROM         tCsFondoSaldos
	WHERE     (SaldoCapital <> Vigente + Vencido)
	
	If @Contador > 0 Begin Set @Valido = 0 End
	
	SELECT     @Contador = Count(*)
	FROM         tCsFondoSaldos
	WHERE     (SaldoCapital <> CVigente + CVencido)
	
	If @Contador > 0 Begin Set @Valido = 0 End
	
	Select @Saldo = Sum(SaldoCapital) From tCsFondoSaldos
	Exec pCsCaAnexosSaldo @Fecha, '02', 0, 99999, 2, '1,2,3,4', 'TODAS', 'SD',  @Valor Out
	
	If @Saldo <> @Valor Begin Set @Valido = 0 End
End
Else
Begin
	Set @Valido = 1
End
If @Valido = 1
Begin
	If @Dato = 1 -- Nombre de Fono
	Begin
		Set @Valor = @Fondo
	End
	If @Dato = 8 -- Dias Pivot
	Begin
		Set @Valor = @DiasPivot
	End
	If @Dato In(2, 3, 4, 5, 6, 7) -- Saldos Cuadro 2.1
	Begin
		Create Table #Valor (Valor Decimal(18,4))
		If @Fondo > 0
		Begin
			Set @Operador = '='			
		End
		Else
		Begin
			Set @Operador = '<>'
		End
		Set @Cadena = 'FROM tCsFondoSaldos WHERE (CodFondo ' + @Operador + ' '+ Cast(ABS(@Fondo) as Varchar(5)) +') AND (Veridico Like ''%'+ @Tecnologia +'%'') AND (NroDiasAtraso >= '+ Cast(@DI as Varchar(5)) +') AND (NroDiasAtraso <= '+ Cast(@DF as Varchar(5)) +') '
		Print IsNull(@Cadena, 'Cadena Nula')
		If @Dato = 2
		Begin
			Set @Cadena = 'Insert Into #Valor SELECT SUM('+ @Estado +') ' + @Cadena
		End
		If @Dato = 3
		Begin
			Set @Cadena = 'Insert Into #Valor SELECT COUNT(*) '+ @Cadena +' AND (Proceso Like ''%'+ @Estado +'%'')'
		End
		If @Dato = 4
		Begin
			Set @Cadena = 'Insert Into #Valor SELECT SUM(Participantes) ' + @Cadena + ' AND (dbo.fduFechaATexto(FechaDesembolso, ''AAAAMM'') = '''+ dbo.fdufechaatexto(@Fecha, 'AAAAMM') +''')'
		End
		If @Dato = 5
		Begin
			Set @Cadena = 'Insert Into #Valor SELECT SUM(Monto) ' + @Cadena + ' AND (dbo.fduFechaATexto(FechaDesembolso, ''AAAAMM'') = '''+ dbo.fdufechaatexto(@Fecha, 'AAAAMM') +''')'
		End
		If @Dato = 6
		Begin
			Set @Cadena = 'Insert Into #Valor SELECT COUNT(*) FROM(SELECT DISTINCT CodGrupo ' + @Cadena + ' AND (dbo.fduFechaATexto(FechaDesembolso, ''AAAAMM'') = '''+ dbo.fdufechaatexto(@Fecha, 'AAAAMM') +''')) Datos '
		End
		If @Dato = 7
		Begin
			Set @Cadena = 'Insert Into #Valor SELECT COUNT(*) FROM (SELECT DISTINCT CodAsesor FROM tCsFondoSaldos) Datos'
		End
		
		Print @Cadena
		Exec (@Cadena)
		Select @Valor = Valor From #Valor
		Drop Table #Valor
	End
End
If @Eliminar = 1
Begin
	Drop Table tCsFondoSaldos
End
GO