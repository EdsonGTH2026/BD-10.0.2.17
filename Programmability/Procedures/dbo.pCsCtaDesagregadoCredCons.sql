SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCtaDesagregadoCredCons] @Fecha smalldatetime  AS

SELECT     tCsCartera.Fecha, 'Clave de la Federación' = '', 'Clave de la Entidad' = '29007', 'Clave de Nivel de la Entidad' = '113', 'Número de Secuencia' = '', 
           tCsPadronClientes.NombreCompleto AS 'Nombre / Razón Social', tCsCartera.CodUsuario AS 'Número del Deudor', REPLACE(tCsCartera.CodPrestamo, '-', '') 
           AS 'Número del Crédito', 'persona' = 1, tCsPadronClientes.UsRFC AS 'RFC', 'Clasificación Contable' = 130162000000, 
           tCsCartera.SaldoCapital AS 'Responsabilidad Total a la Fecha', tCsCartera.FechaDesembolso AS 'Fecha de Disposición', 
           tCsCartera.FechaVencimiento AS 'Fecha de Vencimiento', 'Forma de Amortización' = 3, tCsCartera.TasaIntCorriente AS 'Tasa de Interés Bruta',
	   'Intereses Devengados no Cobrados'='', 'Intereses Vencidos'='','Intereses Refinanciados o Capitalizados'='',
	   'Situación del Crédito'=1, 'Número de Reestructuras o Renovaciones'='', 'Calificación por Operación Metodología CNBV (Parte cubierta)'='',
	   'Calificación por Operación Metodología CNBV (Parte expuesta)'='','Reservas Preventivas (Parte cubierta)'='',
	   'Reservas Preventivas (Parte expuesta)'='', 'Reservas Preventivas Totales'=0, 'Porcentaje que Garantiza el Aval'='',
	   'Valor de la Garantía'='', 'Fecha de Valuación de la Garantía'='', 'Grado de Prelación de la Garantía'='',
	   'Acreditado Relacionado'=1, 'Tipo de Acreditado Relacionado'=4, tCsCartera.NroDiasAtraso as 'Número de Días de Mora', 'Reciprocidad'='',
	   'Crédito en Régimen Transitorio'=2 
FROM         tCsCartera LEFT OUTER JOIN
                      tClOficinas ON tCsCartera.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN
                      tCsPadronClientes ON tCsCartera.CodUsuario = tCsPadronClientes.CodUsuario
WHERE     (tCsCartera.Fecha = @Fecha) AND (tCsCartera.CodOficina = 98)
GO