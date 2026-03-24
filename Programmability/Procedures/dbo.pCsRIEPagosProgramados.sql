SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsRIEPagosProgramados] @fecini smalldatetime,@fecfin smalldatetime
as
	SELECT codprestamo,codusuario,fechavencimiento,sum(montocuota) montocuota
	FROM [FinamigoConsolidado].[dbo].[tCsPadronPlanCuotas] with(nolock)
	where fechavencimiento>=@fecini and fechavencimiento<=@fecfin
	and estadocuota<>'CANCELADO'
	group by codprestamo,codusuario,fechavencimiento

GO

GRANT EXECUTE ON [dbo].[pCsRIEPagosProgramados] TO [jarriagaa]
GO