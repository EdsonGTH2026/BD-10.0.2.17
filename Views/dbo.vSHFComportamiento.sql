SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vSHFComportamiento]
AS
SELECT     TOP 100 PERCENT dbo.fduFechaATexto(Datos.ReporteInicio, 'AAAA') + '-' + dbo.fduFechaATexto(Datos.ReporteInicio, 'MM') 
                      + '-' + dbo.fduFechaATexto(Datos.ReporteInicio, 'DD') + 'T00:00:00:00' AS ReporteInicio, dbo.fduFechaATexto(Datos.ReporteFin, 'AAAA') 
                      + '-' + dbo.fduFechaATexto(Datos.ReporteFin, 'MM') + '-' + dbo.fduFechaATexto(Datos.ReporteFin, 'DD') + 'T00:00:00:00' AS ReporteFin, Datos.Emisor, 
                      Datos.LineaNegocio, Datos.TipoTransaccion, Datos.TipoEnvio, Datos.idLineaCredito, Datos.Originador, Datos.CodPrestamo, 
                      ISNULL(tSHFComportamiento.SIInicio, Inicio.SIInicio) AS SIInicio, Datos.Cargos, Datos.Abonos, Datos.Disposiciones, Datos.PagosProgramado, 
                      ISNULL(dbo.fduFechaATexto(Datos.DMovFecha, 'AAAA') + '-' + dbo.fduFechaATexto(Datos.DMovFecha, 'MM') 
                      + '-' + dbo.fduFechaATexto(Datos.DMovFecha, 'DD') + 'T00:00:00:00', '') AS DMovFecha, ISNULL(CAST(Datos.DMovTipo AS Varchar(10)), '') 
                      AS DMovTipo, ISNULL(Datos.DMovClave, '') AS DMovClave, ISNULL(CAST(Datos.DMovAplica AS Varchar(10)), '') AS DMovAplica, 
                      ISNULL(Datos.DMovMonto, 0) AS DMovMonto, ISNULL(CAST(Datos.DMovDenominacion AS Varchar(10)), '') AS DMovDenominacion, 
                      ISNULL(dbo.fduFechaATexto(Datos.CMovFecha, 'AAAA') + '-' + dbo.fduFechaATexto(Datos.CMovFecha, 'MM') 
                      + '-' + dbo.fduFechaATexto(Datos.CMovFecha, 'DD') + 'T00:00:00:00', '') AS CMovFecha, ISNULL(CAST(Datos.CMovTipo AS Varchar(10)), '') 
                      AS CMovTipo, ISNULL(Datos.CMovClave, '') AS CmovClave, ISNULL(CAST(Datos.CMovAplica AS Varchar(10)), '') AS CMovAplica, 
                      ISNULL(Datos.CMovMonto, 0) AS CMovMonto, ISNULL(CAST(Datos.CMovDenominacion AS Varchar(10)), '') AS CMovDenominacion, 
                      ISNULL(dbo.fduFechaATexto(Datos.AMovFecha, 'AAAA') + '-' + dbo.fduFechaATexto(Datos.AMovFecha, 'MM') 
                      + '-' + dbo.fduFechaATexto(Datos.AMovFecha, 'DD') + 'T00:00:00:00', '') AS AMovFecha, ISNULL(CAST(Datos.AMovTipo AS Varchar(10)), '') AS AMovTipo, 
                      ISNULL(Datos.AMovClave, '') AS AMovClave, ISNULL(CAST(Datos.AMovAplica AS varchar(10)), '') AS AMovAplica, ISNULL(Datos.AMovMonto, 0) 
                      AS AMovMonto, ISNULL(CAST(Datos.AMovDenominacion AS Varchar(10)), '') AS AMovDenominacion, ISNULL(tSHFComportamiento.SIInicio, 
                      Inicio.SIInicio) + Datos.Cargos - Datos.Abonos + Datos.Disposiciones AS SIFin, Datos.NroDiasAtraso, Datos.NroCuotasPagadas, 
                      ISNULL(dbo.fduFechaATexto(Datos.UltimoPago, 'AAAA') + '-' + dbo.fduFechaATexto(Datos.UltimoPago, 'MM') 
                      + '-' + dbo.fduFechaATexto(Datos.UltimoPago, 'DD') + 'T00:00:00:00', '') AS UltimoPago, Inicio.SIInicio AS InicioDefinitivo
FROM         (SELECT     ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, SUM(SIInicio) 
                                              AS SIInicio, SUM(Cargos) AS Cargos, SUM(Abonos) AS Abonos, SUM(Disposiciones) AS Disposiciones, PagosProgramado, MAX(DMovFecha)
                                               AS DMovFecha, MAX(DMovTipo) AS DMovTipo, MAX(DMovClave) AS DMovClave, MAX(DMovAplica) AS DMovAplica, SUM(DMovMonto) 
                                              AS DMovMonto, MAX(DMovDenominacion) AS DMovDenominacion, MAX(CMovFecha) AS CMovFecha, MAX(CMovTipo) AS CMovTipo, 
                                              MAX(CMovClave) AS CMovClave, MAX(CMovAplica) AS CMovAplica, SUM(CMovMonto) AS CMovMonto, MAX(CMovDenominacion) 
                                              AS CMovDenominacion, MAX(AMovFecha) AS AMovFecha, MAX(AMovTipo) AS AMovTipo, MAX(AMovClave) AS AMovClave, MAX(AMovAplica) 
                                              AS AMovAplica, SUM(AMovMonto) AS AMovMonto, MAX(AMovDenominacion) AS AMovDenominacion, NroDiasAtraso, NroCuotasPagadas, 
                                              UltimoPago, CodUsuario
                       FROM          (SELECT     ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, SIInicio,
                                                                       CASE tSHFComportamiento.movtipo WHEN 1 THEN tSHFComportamiento.movmonto ELSE 0 END AS Cargos, 
                                                                      CASE tSHFComportamiento.movtipo WHEN 2 THEN tSHFComportamiento.movmonto ELSE 0 END AS Abonos, Disposiciones, 
                                                                      PagosProgramado, CASE movtipo WHEN 6 THEN MovFecha END AS DMovFecha, 
                                                                      CASE movtipo WHEN 6 THEN MovTipo END AS DMovTipo, CASE movtipo WHEN 6 THEN MovClave END AS DMovClave, 
                                                                      CASE movtipo WHEN 6 THEN MovAplica END AS DMovAplica, CASE movtipo WHEN 6 THEN MovMonto END AS DMovMonto, 
                                                                      CASE movtipo WHEN 6 THEN MovDenominacion END AS DMovDenominacion, 
                                                                      CASE movtipo WHEN 1 THEN MovFecha END AS CMovFecha, CASE movtipo WHEN 1 THEN MovTipo END AS CMovTipo, 
                                                                      CASE movtipo WHEN 1 THEN MovClave END AS CMovClave, CASE movtipo WHEN 1 THEN MovAplica END AS CMovAplica, 
                                                                      CASE movtipo WHEN 1 THEN MovMonto END AS CMovMonto, 
                                                                      CASE movtipo WHEN 1 THEN MovDenominacion END AS CMovDenominacion, 
                                                                      CASE movtipo WHEN 2 THEN MovFecha END AS AMovFecha, CASE movtipo WHEN 2 THEN MovTipo END AS AMovTipo, 
                                                                      CASE movtipo WHEN 2 THEN MovClave END AS AMovClave, CASE movtipo WHEN 2 THEN MovAplica END AS AMovAplica, 
                                                                      CASE movtipo WHEN 2 THEN MovMonto END AS AMovMonto, 
                                                                      CASE movtipo WHEN 2 THEN MovDenominacion END AS AMovDenominacion, NroDiasAtraso, NroCuotasPagadas, UltimoPago, 
                                                                      CodUsuario
                                               FROM          tSHFComportamiento) Datos
                       GROUP BY ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, 
                                              PagosProgramado, NroDiasAtraso, NroCuotasPagadas, UltimoPago, CodUsuario) Datos INNER JOIN
                          (SELECT     Datos.ReporteInicio, Datos.ReporteFin, Datos.CodPrestamo, Datos.CodUsuario, tSHFComportamiento.SIInicio
                            FROM          (SELECT     Datos.ReporteInicio, Datos.ReporteFin, Datos.CodPrestamo, Datos.CodUsuario, Datos.MovFecha, 
                                                                           MAX(tSHFComportamiento.MovTipo) AS MovTipo
                                                    FROM          (SELECT     ReporteInicio, ReporteFin, CodPrestamo, CodUsuario, MIN(MovFecha) AS MovFecha
                                                                            FROM          tSHFComportamiento
                                                                            GROUP BY ReporteInicio, ReporteFin, CodPrestamo, CodUsuario) Datos INNER JOIN
                                                                           tSHFComportamiento ON Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND 
                                                                           Datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
                                                                           Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
                                                                           Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario AND 
                                                                           Datos.MovFecha = tSHFComportamiento.MovFecha
                                                    GROUP BY Datos.ReporteInicio, Datos.ReporteFin, Datos.CodPrestamo, Datos.CodUsuario, Datos.MovFecha) Datos INNER JOIN
                                                   tSHFComportamiento ON Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND 
                                                   Datos.ReporteFin = tSHFComportamiento.ReporteFin AND 
                                                   Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodPrestamo AND 
                                                   Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tSHFComportamiento.CodUsuario AND 
                                                   Datos.MovFecha = tSHFComportamiento.MovFecha AND Datos.MovTipo = tSHFComportamiento.MovTipo) Inicio ON 
                      Datos.ReporteInicio = Inicio.ReporteInicio AND Datos.ReporteFin = Inicio.ReporteFin AND Datos.CodPrestamo = Inicio.CodPrestamo AND 
                      Datos.CodUsuario = Inicio.CodUsuario INNER JOIN
                      dbo.tSHFPeriodo ON Datos.ReporteInicio = dbo.tSHFPeriodo.ReporteInicio AND Datos.ReporteFin = dbo.tSHFPeriodo.ReporteFin LEFT OUTER JOIN
                          (SELECT     *
                            FROM          tSHFComportamiento
                            WHERE      movtipo = 2) tSHFComportamiento ON Datos.AMovDenominacion = tSHFComportamiento.MovDenominacion AND 
                      Datos.AMovMonto = tSHFComportamiento.MovMonto AND Datos.AMovAplica = tSHFComportamiento.MovAplica AND 
                      Datos.AMovClave = tSHFComportamiento.MovClave AND Datos.ReporteInicio = tSHFComportamiento.ReporteInicio AND 
                      Datos.ReporteFin = tSHFComportamiento.ReporteFin AND Datos.AMovFecha = tSHFComportamiento.MovFecha AND 
                      Datos.AMovTipo = tSHFComportamiento.MovTipo
WHERE     (dbo.tSHFPeriodo.Activo = 1)
ORDER BY Datos.ReporteInicio, Datos.ReporteFin, Datos.CodPrestamo, Datos.DMovFecha, Datos.CMovFecha, Datos.AMovFecha

GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[11] 2[24] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[50] 2[25] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1 [56] 4 [18] 2))"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Datos"
            Begin Extent = 
               Top = 9
               Left = 507
               Bottom = 214
               Right = 697
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Inicio"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 146
               Right = 456
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tSHFPeriodo"
            Begin Extent = 
               Top = 4
               Left = 760
               Bottom = 157
               Right = 950
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "tSHFComportamiento"
            Begin Extent = 
               Top = 132
               Left = 11
               Bottom = 245
               Right = 201
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 38
         Width = 284
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1740
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Wid', 'SCHEMA', N'dbo', 'VIEW', N'vSHFComportamiento'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane2', N'th = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 1440
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'vSHFComportamiento'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 2, 'SCHEMA', N'dbo', 'VIEW', N'vSHFComportamiento'
GO