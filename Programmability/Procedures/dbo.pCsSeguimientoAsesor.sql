SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE  [dbo].[pCsSeguimientoAsesor] AS


DECLARE @nrodiasini int DECLARE @nrodiasfin int DECLARE @codoficina varchar(5)
SET              @nrodiasini = 1
SET              @nrodiasfin = 30
SET              @codoficina = 4
                          SELECT     p.codprestamo, pr.NombreProd, p.secuenciacliente, cl.nombrecompleto, g.NombreGrupo, p.desembolso, c.NroCuotas, c.NroCuotasPagadas, 
                                                  c.NroCuotasPorPagar, ase.nombrecompleto asesor, c.nrodiasatraso, SUM(cd.saldocapital) saldocapital
                           FROM         tCsPadronCarteraDet p INNER JOIN
                                                  tcscarteradet cd ON cd.fecha = p.fechacorte AND cd.codprestamo = p.codprestamo AND cd.codusuario = p.codusuario INNER JOIN
                                                  tcscartera c ON c.codprestamo = cd.codprestamo AND c.fecha = cd.fecha INNER JOIN
                                                  tCaProducto pr ON pr.CodProducto = p.CodProducto INNER JOIN
                                                  tcspadronclientes cl ON cl.codusuario = c.codusuario LEFT OUTER JOIN
                                                  tCsCarteraGrupos g ON g.codoficina = c.codoficina AND g.codgrupo = c.codgrupo INNER JOIN
                                                  tcspadronclientes ase ON ase.codusuario = c.codasesor
                           WHERE     p.estadocalculado NOT IN ('CANCELADO', 'CASTIGADO') AND p.codoficina = @codoficina AND c.nrodiasatraso > @nrodiasini AND 
                                                  c.nrodiasatraso < @nrodiasfin
                           GROUP BY p.codprestamo, pr.NombreProd, p.secuenciacliente, cl.nombrecompleto, g.NombreGrupo, p.desembolso, c.NroCuotas, c.NroCuotasPagadas, 
                                                  c.NroCuotasPorPagar, ase.nombrecompleto, c.nrodiasatraso
GO