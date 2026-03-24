SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsDetalleCarteraOficina] @Fecha smalldatetime, @Codoficina varchar(4) AS
SELECT     cd.Fecha, cd.CodPrestamo, cd.CodUsuario, cli.Cliente, CAST(cd.CodOficina AS int) AS CodOficina, tClOficinas.NomOficina, c.CodSolicitud, 
                      c.CodProducto, LTRIM(RTRIM(c.CodAsesor)) AS CodAsesor, Asesores.Asesor, 
                      CASE codproducto WHEN '116' THEN c.CodUsuario ELSE '' END AS CodCoordinador,   CASE codproducto WHEN '116' THEN Coordinadores.Coordinador ELSE '' END Coordinador, c.CodTipoCredito, c.CodDestino, 
                      c.Estado, c.TipoReprog, c.NroCuotas, c.NroCuotasPagadas, c.NroCuotasPorPagar, c.FechaDesembolso, c.FechaVencimiento, cd.MontoDesembolso, 
                      c.NroDiasAtraso, cd.SaldoCapital, cd.CapitalAtrasado, cd.CapitalVencido, cd.SaldoInteres, cd.SaldoMoratorio, cd.OtrosCargos, cd.UltimoMovimiento, 
                      cd.SaldoEnMora, cd.TipoCalificacion, cd.InteresVigente, cd.InteresVencido, cd.MoratorioVigente, cd.MoratorioVencido, cd.InteresCtaOrden, 
                      cd.MoratorioCtaOrden, c.Calificacion, c.ProvisionCapital, c.ProvisionInteres, c.GarantiaLiquidaMonetizada, c.GarantiaPreferidaMonetizada, 
                      c.GarantiaMuyRapidaRealizacion, c.TotalGarantia, c.TasaIntCorriente, c.TasaINVE, c.TasaINPE, cli.CodDocIden, cli.DI, 
                      CASE codproducto WHEN '121' THEN 'SOLIDARIO' WHEN '116' THEN 'SOLIDARIO' ELSE 'INDIVIDUAL' END AS Tecnologia, 
                                                                                                                      CASE codproducto WHEN '121' THEN 'PREFACIL' WHEN '116' THEN 'SOLIDARIO' ELSE 'INDIVIDUAL' END AS
                                                                                                                       Tecnologia2
FROM         tCsCartera c INNER JOIN
                      tCsCarteraDet cd ON c.Fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo LEFT OUTER JOIN
                          (SELECT     CodUsuario, Paterno + ' ' + Materno + ', ' + Nombres Coordinador
                            FROM          tCspadronClientes) Coordinadores ON c.CodUsuario = Coordinadores.CodUsuario LEFT OUTER JOIN
                          (SELECT     CodUsuario, Paterno + ' ' + Materno + ', ' + Nombres Asesor
                            FROM          tCspadronClientes) Asesores ON c.CodAsesor = Asesores.CodUsuario LEFT OUTER JOIN
                          (SELECT     CodUsuario, Paterno + ' ' + Materno + ', ' + Nombres Cliente, CodDocIden, DI, CodUbiGeoDirFamPri, DireccionDirFamPri, 
                                                   TelefonoDirFamPri, LabCodActividad
                            FROM          tCspadronClientes) cli ON cd.CodUsuario = cli.CodUsuario LEFT OUTER JOIN
                      tClOficinas ON cd.CodOficina = tClOficinas.CodOficina
where cd.Fecha = @Fecha and c.codoficina=@codoficina
GO