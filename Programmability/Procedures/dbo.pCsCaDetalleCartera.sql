SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCaDetalleCartera] @Fecha smalldatetime AS
SELECT     cd.Fecha, cd.CodPrestamo, cd.CodUsuario, cli.Cliente, CAST(cd.CodOficina AS int) AS CodOficina, tClOficinas.NomOficina, c.CodSolicitud, 
                      c.CodProducto, LTRIM(RTRIM(c.CodAsesor)) AS CodAsesor, Asesores.Asesor, 
                      CASE codproducto WHEN '116' THEN c.CodUsuario ELSE '' END AS CodCoordinador, 
                      CASE codproducto WHEN '116' THEN Coordinadores.Coordinador ELSE '' END AS Coordinador, c.CodTipoCredito, c.CodDestino, c.Estado, 
                      c.TipoReprog, c.NroCuotas, c.NroCuotasPagadas, c.NroCuotasPorPagar, c.FechaDesembolso, c.FechaVencimiento, cd.MontoDesembolso, 
                      c.NroDiasAtraso, cd.SaldoCapital, cd.CapitalAtrasado, cd.CapitalVencido, cd.SaldoInteres, cd.SaldoInteres * tCsClIVA.PorcenIVA AS SaldoInteresIVA, 
                      cd.SaldoMoratorio, cd.SaldoMoratorio * tCsClIVA.PorcenIVA AS SaldoMoratorioIVA, cd.OtrosCargos, cd.cargomora, cd.UltimoMovimiento, cd.SaldoEnMora, 
                      cd.TipoCalificacion, cd.InteresVigente, cd.InteresVencido, cd.MoratorioVigente, cd.MoratorioVencido, cd.InteresCtaOrden, cd.MoratorioCtaOrden, 
                      c.Calificacion, cd.sReservaCapital, cd.sReservaInteres, c.GarantiaLiquidaMonetizada, c.GarantiaPreferidaMonetizada, c.GarantiaMuyRapidaRealizacion, 
                      c.TotalGarantia, c.TasaIntCorriente, c.TasaINVE, c.TasaINPE, cli.CodDocIden, cli.DI, 
                      CASE codproducto WHEN '116' THEN 'SOLIDARIO' ELSE 'INDIVIDUAL' END AS Tecnologia, 
                      CASE codproducto WHEN '121' THEN 'PREFACIL' WHEN '116' THEN 'SOLIDARIO' ELSE 'INDIVIDUAL' END AS Tecnologia2, 
                      tCsCarteraGrupos.NombreGrupo, cd.SecuenciaCliente,  cd.SecuenciaGrupo
FROM         tCsCartera c INNER JOIN
                      tCsCarteraDet cd ON c.Fecha = cd.Fecha AND c.CodPrestamo = cd.CodPrestamo LEFT OUTER JOIN
                      tCsCarteraGrupos ON c.CodOficina = tCsCarteraGrupos.CodOficina AND c.CodGrupo = tCsCarteraGrupos.CodGrupo LEFT OUTER JOIN
                          (SELECT     CodUsuario, Paterno + ' ' + Materno + ', ' + Nombres Coordinador
                            FROM          tCspadronClientes) Coordinadores ON c.CodUsuario = Coordinadores.CodUsuario LEFT OUTER JOIN
                          (SELECT     CodUsuario, Paterno + ' ' + Materno + ', ' + Nombres Asesor
                            FROM          tCspadronClientes) Asesores ON c.CodAsesor = Asesores.CodUsuario LEFT OUTER JOIN
                          (SELECT     CodUsuario, Paterno + ' ' + Materno + ', ' + Nombres Cliente, CodDocIden, DI, CodUbiGeoDirFamPri, DireccionDirFamPri, 
                                                   TelefonoDirFamPri, LabCodActividad
                            FROM          tCspadronClientes) cli ON cd.CodUsuario = cli.CodUsuario LEFT OUTER JOIN
                      tClOficinas ON cd.CodOficina = tClOficinas.CodOficina CROSS JOIN
                      tCsClIVA
where cd.Fecha = @Fecha
GO