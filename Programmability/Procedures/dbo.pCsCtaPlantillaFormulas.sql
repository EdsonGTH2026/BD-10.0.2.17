SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCtaPlantillaFormulas] @Reporte	varchar(2) AS
SET NOCOUNT ON
--DECLARE @Reporte	varchar(2)
--SET @Reporte	= '01'

SELECT a.Codigo,a.Descripcion,a.Nivel,a.NivelReporte,a.OrdenNivel,
			 a.TipoValor,
			 Basedatos,
			 Operacion,
			 CuentaCampo,
			 TipoCampo,oculto
FROM tCsCoPlantilla a 
WHERE (a.Reporte = @Reporte) and a.oculto=0 

SET NOCOUNT OFF
GO