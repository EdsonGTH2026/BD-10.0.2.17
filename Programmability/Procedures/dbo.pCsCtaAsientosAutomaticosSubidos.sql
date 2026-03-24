SET QUOTED_IDENTIFIER OFF

SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCtaAsientosAutomaticosSubidos] @FecIni smalldatetime, @FecFin smalldatetime  AS
SELECT     a.FechCbte,  cast(a.CodOficinaOri as int) CodOficinaOri, ISNULL(b.Nro, 1) AS Nro
FROM         (SELECT     FechCbte, CodOficinaOri
                       FROM         [10.0.1.15].FINMAS_CONTA.dbo.tCoTraDia
                       WHERE      (FechCbte >= @FecIni) AND (FechCbte <= @FecFin) AND (CodOficinaOri <> 99) and esanulado=0
                       GROUP BY FechCbte, CodOficinaOri) a LEFT OUTER JOIN
                          (SELECT DISTINCT FechCbte, CodOficinaOri, Nro
                            FROM          (SELECT     FechCbte, CodOficinaOri, GlosaGral AS GlosaGral, COUNT(GlosaGral) AS Nro
                                                    FROM          [10.0.1.15].FINMAS_CONTA.dbo.tCoTraDia
                                                    WHERE      (FechCbte >= @FecIni) AND (FechCbte <= @FecFin) AND (CodOficinaOri <> 99) and esanulado=0
                                                    GROUP BY FechCbte, CodOficinaOri, GlosaGral
                                                    HAVING      (COUNT(GlosaGral) > 1)) A) b ON a.FechCbte = b.FechCbte AND a.CodOficinaOri = b.CodOficinaOri
GO