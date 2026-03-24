SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pRptBovedaDato] @fechapro smalldatetime , @CodOficina  varchar(4)
as
SELECT     b.fecha, b.codoficina, o.NomOficina as DescOficina, b.fechapro, b.cierrepreliminar, b.cierredefinitivo, b.fechahoraapertura, b.fechahoracierre, b.NumBovTransDia, 
                      b.NumCajaDia, ss.SaldoIniSisMn, ss.SaldoFinSisMn, ss.SaldoFinUsMn, ss.SaldoIniSisMe, ss.SaldoFinSisMe, ss.SaldoFinUsMe
FROM         (SELECT     fecha, codoficina, fecha fechapro, cierrepreliminar, cierredefinitivo, fechahoraapertura, fechahoracierre, NumBovTransDia, 
                                              NumCajaDia
                       FROM          tCsBoveda
                       WHERE      fecha = @fechapro AND codoficina = @CodOficina) b INNER JOIN
                          (SELECT     fecha, codoficina, fechapro, SUM(SaldoIniSisMn) SaldoIniSisMn, SUM(SaldoFinSisMn) SaldoFinSisMn, SUM(SaldoFinUsMn) 
                                                   SaldoFinUsMn, SUM(SaldoIniSisMe) SaldoIniSisMe, SUM(SaldoFinSisMe) SaldoFinSisMe, SUM(SaldoFinUsMe) SaldoFinUsMe
                            FROM          (SELECT     fecha, codoficina, fecha fechapro, SaldoIniSisMn = CASE WHEN codmoneda = 6 THEN saldoinisis ELSE 0 END, 
                                                                           SaldoFinSisMn = CASE WHEN codmoneda = 6 THEN saldofinsis ELSE 0 END, 
                                                                           SaldoFinUsMn = CASE WHEN codmoneda = 6 THEN saldofinus ELSE 0 END, 
                                                                           SaldoIniSisMe = CASE WHEN codmoneda = 2 THEN saldoinisis ELSE 0 END, 
                                                                           SaldoFinSisMe = CASE WHEN codmoneda = 2 THEN saldofinsis ELSE 0 END, 
                                                                           SaldoFinUsMe = CASE WHEN codmoneda = 2 THEN saldofinus ELSE 0 END
                                                    FROM          tCsBovedaSaldos
                                                    WHERE      fecha = @fechapro AND codoficina = @CodOficina) s
                            GROUP BY fecha, codoficina, fechapro) ss ON b.fechapro = ss.fechapro AND b.codoficina = ss.codoficina INNER JOIN
                      tClOficinas o ON b.codoficina = o.CodOficina
GO