SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Procedure [dbo].[pCsCboSATResultado]
As
Select Estado, Nombre From (
SELECT        Padron.Estado, ISNULL(Estado.Nombre, 'Llamar a Sistemas') AS Nombre, Isnull(Estado.Verificado, 1) as Verificado
FROM            (SELECT DISTINCT Estado
                          FROM            tSATExentasPadron
                          WHERE        (Activo = 1)) AS Padron LEFT OUTER JOIN
                             (SELECT        Estado, Nombre, Verificado
                               FROM            tSATEstado) AS Estado ON Padron.Estado = Estado.Estado) Datos
Where Verificado = 1
GO