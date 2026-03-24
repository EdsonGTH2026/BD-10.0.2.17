SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCaResultadoDiaSMS] AS
declare @fecha smalldatetime
--set @fecha = '20091109'
select @fecha = fechaproceso from [10.0.2.14].FINMAS.dbo.tclparametros where codoficina=99

-- DESEMBOLSOS
SELECT 'DESEMBOLSADO' titulo, SUM(a.MontoDesembolso) AS Monto
FROM [10.0.2.14].FINMAS.dbo.tCaDesemb a INNER JOIN
[10.0.2.14].FINMAS.dbo.tClOficinas o ON a.CodOficina = o.CodOficina
WHERE (a.FechaDesembolso = @fecha) AND (a.EstadoDesembolso = 'AFECTADO')
-- POR DESEMBOLSAR
UNION
SELECT 'SOLICITADO' titulo, SUM(a.MontoSolicitado) AS Monto
FROM [10.0.2.14].FINMAS.dbo.tCaSolicitud a INNER JOIN
[10.0.2.14].FINMAS.dbo.tClOficinas o ON a.CodOficina = o.CodOficina
WHERE (a.FechaSolicitud = @fecha) AND (a.CodEstado = 'TRAMITE')
UNION
-- RECUPERACIONES
SELECT 'RECUPERADO' titulo, SUM(b.MontoPagado) AS Monto
FROM [10.0.2.14].FINMAS.dbo.tCaPagoReg a INNER JOIN
[10.0.2.14].FINMAS.dbo.tCaPagoDet b ON a.CodOficina = b.CodOficina AND a.SecPago = b.SecPago INNER JOIN
[10.0.2.14].FINMAS.dbo.tClOficinas o ON a.CodOficina = o.CodOficina
WHERE (a.FechaPago = @fecha) AND (a.Extornado = 0)
GO