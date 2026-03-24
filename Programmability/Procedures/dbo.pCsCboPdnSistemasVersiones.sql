SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboPdnSistemasVersiones]
As
SELECT     CodSistema + dbo.fduRellena('0', UltVerRevision + 1, 4, 'D') AS Dato, '[' + CAST(UltVerMayor AS varchar(5)) + '.' + CAST(UltVerMenor AS varchar(5)) 
                      + '.' + CAST(UltVerRevision + 1 AS varchar(5)) + '] ' + Nombre AS Nombre,   '[' + CodSistema + ' ' + dbo.fduRellena('0', UltVerMayor, 2, 'D') + '.' + dbo.fduRellena('0', UltVerMenor, 3, 'D') + '.' + dbo.fduRellena('0', UltVerRevision, 4, 'D') 
                      + ']' AS Version, UPPER(Nombre) AS Sistema, FechaUltAct
FROM         [BD-FINAMIGO-DC].Finmas.dbo.tSgSistemas tSgSistemas
WHERE     (Activo = 1)
GO