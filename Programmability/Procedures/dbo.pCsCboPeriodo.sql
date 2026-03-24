SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboPeriodo]

As 
SELECT     Periodo, Descripcion, dbo.fduFechaATexto(UltimoDia,'dd-MM-aaaa') as UltimoDia
 FROM         tClPeriodo
WHERE     (Periodo >= '200712')
ORDER BY Periodo DESC
GO