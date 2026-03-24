SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboUbicacion]

As 
SELECT     CodOficina, NomOficina
FROM         (SELECT     CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
                       FROM          tClOficinas
                       WHERE  codoficina<100 and (Tipo in ('Operativo', 'Matriz', 'Servicio'))
                       UNION
                       SELECT     Zona, Nombre
                       FROM         tClZona
					   where zona<>'ZRA'
                       UNION
                       SELECT Codigo = 'ZZZ', Nombre = 'Todas las Oficinas') Datos
ORDER BY dbo.fduRellena('0', CodOficina, 3, 'D')
GO