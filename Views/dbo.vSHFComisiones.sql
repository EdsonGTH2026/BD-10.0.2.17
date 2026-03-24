SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vSHFComisiones]
AS
SELECT     ReporteInicio, ReporteFin, CodPrestamo, cveCA, ValCA
FROM         vSHFOtorgamiento
UNION
SELECT     ReporteInicio, ReporteFin, CodPrestamo, cveCM, ValCM
FROM         vSHFOtorgamiento


GO