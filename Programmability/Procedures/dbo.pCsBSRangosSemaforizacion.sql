SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsBSRangosSemaforizacion] @nivel int,@CodIndicador int, @periodo as varchar(6) AS

--DECLARE @Fecha smalldatetime
--select @Fecha = fechaconsolidacion from vCsFechaConsolidacion

DECLARE @ultdia smalldatetime
select @ultdia = ultimodia from tclperiodo where periodo=@periodo--dbo.fduFechaAPeriodo(@Fecha)

SELECT tCsBsMetaxUEN.NCamValor Nro, tClOficinas.NomOficina, tCsBsRangos.Color, tCsBsMetaxUEN.ValorMin, 
tCsBsMetaxUEN.ValorMax, tCsBsMetaxUEN.ValorProg AS Meta
FROM         tCsBsMetaxUEN LEFT OUTER JOIN
tCsBsRangos ON tCsBsMetaxUEN.iCodIndicador = tCsBsRangos.iCodIndicador AND tCsBsMetaxUEN.ItemColor = tCsBsRangos.ItemColor LEFT OUTER JOIN
tClOficinas ON tCsBsMetaxUEN.NCamValor = tClOficinas.CodOficina
WHERE     (tCsBsMetaxUEN.Fecha = @ultdia) AND (tCsBsMetaxUEN.iCodIndicador =@CodIndicador)
and tCsBsMetaxUEN.iCodTipoBS=@nivel
ORDER BY CAST(tClOficinas.CodOficina AS int), tCsBsRangos.ItemColor
GO