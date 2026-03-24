SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCaSolicitudEvaluacionScorePuntosCiclo](@fecha smalldatetime, @score money, @ciclo int,
	@codSolicitud varchar(20), @codOficina varchar(3))
AS
BEGIN
SET NOCOUNT ON

	DECLARE @puntos int

	--PARA GENERAR LAYOUT
	INSERT INTO finmas.dbo.tCaRegistroEvaluacionScoreCiclo
	SELECT	TOP 1 s.codUsuario, s.codSolicitud, s.codOficina, u.nombreCompleto, s.codProducto, s.montoSolicitado, s.montoAprobado,
			rs.razon1, rs.razon2, rs.razon3, rs.razon4, rs.valor 
	FROM finmas.dbo.tcaSolicitud s
	INNER JOIN finmas.dbo.tususuarios u
		ON u.codUsuario = s.codUsuario
	INNER JOIN finamigosic.dbo.tCcConsulta cc
		ON cc.codUsuario = s.codUsuario
	INNER JOIN finamigosic.dbo.tCcRespuestaScore rs	
		ON cc.idcc = rs.idcc
	WHERE s.codSolicitud = @codSolicitud
	AND s.codOficina = @codOficina
	ORDER BY cc.fechaRespuesta	DESC
	
	SELECT @puntos = Puntos 
	FROM finmas.dbo.tCaSolicitudEvaluacionScoreCiclo 
	WHERE @fecha BETWEEN vigenciaIni AND vigenciaFin
	AND @score BETWEEN valorMin AND valorMax
	AND @ciclo BETWEEN cicloMin AND cicloMax
END
GO