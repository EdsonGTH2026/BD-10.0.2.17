SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCaRecuperaCuotas]
	@Sucursal INT,
	@Mensaje NVARCHAR(150) OUTPUT
AS BEGIN
	DECLARE @i INT, 
			@j INT, 
			@Contrato NVARCHAR(30),
			@Cuota INT,
			@Plan INT,
			@Usuario NVARCHAR(100),	
			@Cadena NVARCHAR(100)
			
	SET NOCOUNT ON
	SELECT	C1.CodPrestamo,
		NumeroPlan=C1.NumeroPlan,
		SecCuota=C1.SecCuota,
		Usuario=SUBSTRING(P.CodUsuario,2,3),
		Adeudo=MAX(C4.MontoDevengado-C4.MontoPagado-C4.MontoCondonado)
	INTO #PagosCorrientes
	FROM  TcaCuotas C1 JOIN TcaCuotas C2 ON C1.CodPrestamo=C2.CodPrestamo
		 JOIN TcaCuotasCli C3 ON C3.CodPrestamo=C2.CodPrestamo AND C3.NumeroPlan=C2.NumeroPlan and C3.SecCuota=C2.SecCuota
		 JOIN TcaPrestamos P ON P.CodPrestamo=C1.CodPrestamo
		 JOIN TcaCuotasCli C4 ON  C4.CodPrestamo=C1.CodPrestamo and C4.NumeroPlan=C1.NumeroPlan and C1.SecCuota=C4.SecCuota
	WHERE	C1.FechaVencimiento = '20111024'--GETDATE()
		AND C2.FechaVencimiento < '20111024'--GETDATE()
		AND C1.EstadoCuota not in ('CANCELADO','APROBADO')
		AND P.CodOficina=@Sucursal	
	GROUP BY C1.CodPrestamo,C1.NumeroPlan, C1.SecCuota,P.CodUsuario 
	HAVING SUM(C3.MontoDevengado-C3.MontoPagado-C3.MontoCondonado)<=0
	--------------------------------------------------------------------------------------------------
	SELECT IDENTITY(int,1,1) as NR,
		Usuario,
		Contador=Count(*),
		Total=Sum(Adeudo)
	INTO #Final
	FROM #PagosCorrientes
	GROUP BY Usuario
	SET NOCOUNT OFF
	---------------------------------------------------------------------------------------------------
	SELECT @i=ISNULL(MAX(NR),0), @j=1, @Mensaje='' FROM #Final
	WHILE @j<=@i
		BEGIN
			SELECT	@Mensaje = @Mensaje + Usuario + ' ' 
					+ CAST(Contador AS NVARCHAR(30)) + ' ' 
					+ CONVERT(VARCHAR,CONVERT(MONEY,Total),1)
					+ '; '
			FROM #Final
			WHERE NR=@j
			SET @j = @j+1		
		END
	--IF @Mensaje!=''
		SELECT @Mensaje=SUBSTRING(@Mensaje,1,LEN(@Mensaje)-1)
END
GO