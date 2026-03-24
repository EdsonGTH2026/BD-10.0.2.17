SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pXaCaDesembolsosDiarioPorSucursal]
	(@CodOficinas AS VARCHAR(2000))
AS
BEGIN
	DECLARE @fecfin SMALLDATETIME
	DECLARE @fecini SMALLDATETIME

	SELECT @fecfin = fechaconsolidacion FROM vcsfechaconsolidacion WITH (NOLOCK)
	
	SET @fecini = dbo.fdufechaaperiodo(@fecfin) + '01'

	DECLARE @t TABLE(fecha SMALLDATETIME, nro INT, monto MONEY, nroprogresemos INT,montoprogresemos MONEY, nrofinamigo INT, montofinamigo MONEY)
	
	INSERT INTO @t
	SELECT fechadesembolso fecha, COUNT(codprestamo) nro, SUM(montodesembolso) monto, 
		   COUNT(CASE WHEN codfondo = '20' THEN codprestamo ELSE NULL END) nroprogresemos,
		   SUM(CASE WHEN codfondo = '20' THEN (montodesembolso) * 0.7 ELSE 0 END) montoprogresemos,
		   COUNT(CASE WHEN codfondo <> '20' THEN codprestamo ELSE null END) nrofinamigo,
		   SUM(CASE WHEN codfondo = '20' THEN (montodesembolso) * 0.3 ELSE montodesembolso END) montofinamigo
	FROM [10.0.2.14].finmas.dbo.tcaprestamos
	WHERE fechadesembolso = @fecfin + 1 
	AND estado = 'VIGENTE'
	AND codoficina not in('97','999')
	AND CodOficina IN (SELECT VALUE FROM dbo.fSplit(',', @CodOficinas))
	GROUP BY fechadesembolso
	
	SELECT * FROM (
		SELECT dbo.fdufechaatexto(p.desembolso,'DD/MM/AAAA') fecha,
		COUNT(p.codprestamo) nro, SUM(p.monto) monto,
		COUNT(CASE WHEN c.codfondo = 20 THEN p.codprestamo ELSE NULL END) nroprogresemos,
		SUM(CASE WHEN c.codfondo = 20 THEN (p.monto) * 0.7 ELSE 0 END) montoprogresemos,
		COUNT(CASE WHEN c.codfondo <> 20 THEN p.codprestamo ELSE NULL END) nrofinamigo,
		SUM(CASE WHEN c.codfondo = 20 THEN (p.monto) * 0.3 ELSE p.monto END) montofinamigo
	FROM tcspadroncarteradet p WITH (NOLOCK)	
	INNER JOIN tcscartera c WITH (NOLOCK) ON p.fechacorte = c.fecha AND p.codprestamo = c.codprestamo
	WHERE p.codoficina not in('97','999')
	AND p.desembolso >= @fecini and p.desembolso <= @fecfin
	AND p.CodOficina IN (SELECT VALUE FROM dbo.fSplit(',', @CodOficinas))
	GROUP BY p.desembolso
	UNION
	SELECT dbo.fdufechaatexto(fecha,'DD/MM/AAAA') fecha, nro, monto, nroprogresemos, montoprogresemos, nrofinamigo, montofinamigo 
	FROM @t) a
	ORDER BY fecha DESC
END
GO