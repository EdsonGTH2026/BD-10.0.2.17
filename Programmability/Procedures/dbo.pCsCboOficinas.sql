SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure [pCsCboOficinas]
CREATE PROCEDURE [dbo].[pCsCboOficinas] AS
SELECT     CodOficina, NomOficina
FROM         (SELECT     CodOficina, dbo.fduRellena('0', RTRIM(LTRIM(CodOficina)), 2, 'D') + ' ' + tClOficinas.NomOficina NomOficina
                       FROM          tClOficinas
                       WHERE  (Tipo in ('Operativo', 'Matriz', 'Servicio','Contable','Cerrada')) 
								--and (codoficina<100 or codoficina>300)
                       UNION
                       SELECT     dbo.fduOficinas(zona), Nombre
                       FROM         tClZona
	                   where activo=1 and zona<>'ZRA'
                       UNION
                       SELECT dbo.fduOficinas('%'), Nombre = 'Todas las Oficinas') Datos
ORDER BY NomOficina
GO