SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pXaCaIncentivosVs3] @CodAsesor varchar(15)
as
	--declare @CodAsesor varchar(15)
	--set @CodAsesor='CNF811009M9T18'
	DECLARE @Fecha SMALLDATETIME
	SELECT @Fecha = FechaConsolidacion FROM vCsFechaConsolidacion WITH (NOLOCK)
	--SELECT @Fecha = '2021/08/31'

	SELECT --CAST(SUBSTRING(a.fecha,1,4) + '/' + SUBSTRING(a.fecha,5,2) + '/' + SUBSTRING(a.fecha,7,2) AS DATETIME) AS fecha 
	dbo.fdufechaatexto(a.fecha,'dd/MM/AAAA') fecha
		   ,(a.codoficina + ' - ' + c.DescOficina) AS oficina, a.codasesor, a.coordinador, 
		   dbo.fXaFullMonthsSeparation(b.Ingreso, GETDATE()) AS Antiguedad
			 --, a.saldocapital, a.desembolso, a.pordeudese, a.categoria, 
		  -- a.PorBonoInte, a.programado_s, a.pagado_s, a.porpagado_s, a.nivelCO, a.puntosCO, a.saldo, a.saldo30, a.imor30, a.Imor1, 
		  -- a.Imor8, a.Imor16, a.nivelp2, a.puntosp2, a.puntaje, a.nivelBono, a.PorBono, a.saldo30ini, a.saldo30fin,nroptmos30ini,nroptmos30fin
			 --, a.Metacrecimiento, 
		  -- a.Asignacionca, a.Quitaca, a.crecimiento, a.Alcancecreci, a.PorcentajeBono, a.nroliquida, a.nrorenova, a.AlcanceRenov, 
		  -- a.bonipena, a.InteresCobrado, a.BonoPosiGanar, a.MontoBono, a.bonoobtenido, a.ayudatrans, a.bonofinal
	,a.saldocapital,	categoria,	BonoObjetivo,	programado_s,	pagado_s,	porpagado_s,	nivel,	saldo0a15,	saldo16a30,	saldo31,	saldoT
	,	Imor15,	Imor1,	Imor8,	Imor16,	Imor30,	saldo30ini,	saldo30fin,	crecimiento,	nroptmos30ini,	nroptmos30fin,	Metacrecimiento,	Asignacionca
	,	Quitaca,	Alcancecreci,	nroliquida,	nrorenova,	AlcanceRenov,	pmerPorcentaje,	sgdoPorcentaje,	ayudatrans,	BonoObtenido,	bonoFinal
	,BonoObtenido*BonoObjetivo/100 BonoObjetivoFinal
	FROM tCsACaIncentivosvs3 a WITH (NOLOCK)
	LEFT JOIN tCsEmpleados b WITH (NOLOCK) ON a.codasesor = b.CodUsuario
	LEFT JOIN tClOficinas c WITH (NOLOCK) ON a.codoficina = c.CodOficina
	WHERE fecha = @Fecha
	AND codasesor = @CodAsesor
GO