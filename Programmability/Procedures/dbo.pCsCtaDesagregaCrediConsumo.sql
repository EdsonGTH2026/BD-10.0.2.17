SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCtaDesagregaCrediConsumo]  @Fecha smalldatetime AS

--DECLARE @Fecha  smalldatetime

--SET @Fecha = '20080801'

SELECT     tCsCartera.Fecha AS Periodo, '' AS 'Clave de la federación', 29007 AS [Clave de la Entidad], 113 AS 'Clave de Nivel de la Entidad', 
                      '' AS 'Número de Secuencia', tCsPadronClientes.NombreCompleto AS 'Nombre / Razón Social', tCsCartera.CodUsuario AS [Número del Deudor], 
                      tCsCartera.CodPrestamo AS [Número de crédito], 1 AS Persona, ISNULL(tCsPadronClientes.UsRFC, 
                      CASE WHEN coddociden = 'RFC' THEN DI ELSE NULL END) AS RFC, '130162000000' AS 'Clasificación Contable', 
                      tCsCartera.SaldoCapital AS [Responsabilidad total a la Fecha], tCsCartera.FechaDesembolso AS [Fecha de Disposición], 
                      tCsCartera.FechaVencimiento AS [Fecha de Vencimiento], 3 AS 'Forma de Amortización', tCsCartera.TasaIntCorriente, 
                      tCsCartera.CodProducto AS Producto, tCsCartera.CodOficina AS Oficina, '' AS [Intereses Devengados no Cobrados], '' AS [Intereses Vencidos], 
                      '' AS [Intereses Refinanciados o Capitalizados], 1 AS [Situación del Crédito], '' AS [Número de Reestructuras o Renovaciones], 
                      '' AS [Calificación por Operación Metodología CNBV (Parte cubierta)], '' AS [Calificación por Operación Metodología CNBV (Parte expuesta)], 
                      '' AS [Reservas Preventivas (Parte cubierta)], '' AS [Reservas Preventivas (Parte expuesta)], 0 AS [Reservas Preventivas Totales], 
                      '' AS [Porcentaje que Garantiza el Aval], '' AS [Valor de la Garantía], '' AS [Fecha de Valuación de la Garantía], '' AS [Grado de Prelación de la Garantía], 
                      1 AS [Acreditado Relacionado], 4 AS [Tipo de Acreditado Relacionado], 0 AS [Número de Días de Mora], 0 AS Reciprocidad, 
                      2 AS [Crédito en Régimen Transitorio]
FROM         tCsCartera LEFT OUTER JOIN
                      tCsPadronClientes ON tCsCartera.CodUsuario = tCsPadronClientes.CodUsuario
WHERE     (tCsCartera.CodProducto = 301) AND (tCsCartera.Fecha = @Fecha)
ORDER BY tCsCartera.Fecha, tCsPadronClientes.NombreCompleto, tCsCartera.CodUsuario, tCsCartera.CodPrestamo, tCsPadronClientes.UsRFC, 
                      tCsCartera.SaldoCapital, tCsCartera.FechaDesembolso, tCsCartera.FechaVencimiento, tCsCartera.CodOficina, tCsCartera.CodProducto
GO