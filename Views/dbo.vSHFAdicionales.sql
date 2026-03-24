SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vSHFAdicionales]
AS
SELECT     Adicionales.ReporteInicio, Adicionales.ReporteFin, Adicionales.Emisor, Adicionales.LineaNegocio, Adicionales.TipoTransaccion, Adicionales.TipoEnvio, 
                      Adicionales.idLineaCredito, Adicionales.Originador, Adicionales.CodPrestamo, CAST(Adicionales.SIINIcio AS decimal(18, 3)) AS SIINIcio, 
                      CAST(Adicionales.Cargos AS decimal(18, 3)) AS Cargos, CAST(Adicionales.Abonos AS decimal(18, 3)) AS Abonos, CAST(Adicionales.Disposiciones AS decimal(18, 4)) 
                      AS Disposiciones, Adicionales.PagosProgramado, Adicionales.MovFecha, Adicionales.MovTipo, Adicionales.MovClave, Adicionales.MovAplica, 
                      CAST(Adicionales.MovMonto AS decimal(18, 3)) AS MovMonto, Adicionales.MovDenominacion, CAST(Adicionales.SIFin AS decimal(18, 3)) AS SIFin, 
                      Adicionales.NroDiasAtraso, Adicionales.CuotasPagadas, Adicionales.UltimoPago, Adicionales.MC
FROM         dbo.vSHFMovimiento RIGHT OUTER JOIN
                          (SELECT     Datos.ReporteInicio, Datos.ReporteFin, Datos.Emisor, Datos.LineaNegocio, Datos.TipoTransaccion, Datos.TipoEnvio, Datos.idLineaCredito, Datos.Originador, 
                      Datos.CodPrestamo, Datos.SIINIcio, Datos.Cargos, Datos.Abonos, Datos.Disposiciones, Datos.PagosProgramado, 
                      CASE WHEN Datos.MovFecha < Datos.ReporteInicio THEN Datos.ReporteFin ELSE Datos.MovFecha END AS MovFecha, Datos.MovTipo, Datos.MovClave, 
                      Datos.MovAplica, Datos.MovMonto, Datos.MovDenominacion, Datos.SIFin, Datos.NroDiasAtraso, Datos.CuotasPagadas, Datos.UltimoPago, Datos.MC
                            FROM          (SELECT     Codprestamo, MAX(MovFecha) AS MovFecha
                                                    FROM          (SELECT DISTINCT 
                                                                                                   ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, 
                                                                                                   0.00 AS SIINIcio, 0.00 AS Cargos, 0.00 AS Abonos, 0.00 AS Disposiciones, PagosProgramado, 
                                                                                                   CASE WHEN ltrim(rtrim(isnull(UltimoPago, ''))) <> '' THEN UltimoPago ELSE ReporteFin END AS MovFecha, 1 AS MovTipo, 
                                                                                                   '101' AS MovClave, 0 AS MovAplica, 0.00 AS MovMonto, MovDenominacion, 0 AS SIFin, NroDiasAtraso, CuotasPagadas, 
                                                                                                   UltimoPago, MC = '1'
                                                                            FROM          vSHFMovimiento) Datos
                                                    GROUP BY codprestamo) Corte INNER JOIN
                                                       (SELECT DISTINCT 
                                                                                ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, 0.00 AS SIINIcio, 
                                                                                0.00 AS Cargos, 0.00 AS Abonos, 0.00 AS Disposiciones, PagosProgramado, CASE WHEN ltrim(rtrim(isnull(UltimoPago, ''))) 
                                                                                <> '' THEN UltimoPago ELSE ReporteFin END AS MovFecha, 1 AS MovTipo, '101' AS MovClave, 0 AS MovAplica, 0.00 AS MovMonto, 
                                                                                MovDenominacion, 0 AS SIFin, NroDiasAtraso, CuotasPagadas, UltimoPago, MC = '1'
                                                         FROM          vSHFMovimiento) Datos ON Corte.MovFecha = Datos.MovFecha AND Corte.Codprestamo = Datos.CodPrestamo
                            UNION
                            SELECT     Datos.ReporteInicio, Datos.ReporteFin, Datos.Emisor, Datos.LineaNegocio, Datos.TipoTransaccion, Datos.TipoEnvio, Datos.idLineaCredito, Datos.Originador, 
                      Datos.CodPrestamo, Datos.SIINIcio, Datos.Cargos, Datos.Abonos, Datos.Disposiciones, Datos.PagosProgramado, 
                      CASE WHEN Datos.MovFecha < Datos.ReporteInicio THEN Datos.ReporteFin ELSE Datos.MovFecha END AS MovFecha, Datos.MovTipo, Datos.MovClave, 
                      Datos.MovAplica, Datos.MovMonto, Datos.MovDenominacion, Datos.SIFin, Datos.NroDiasAtraso, Datos.CuotasPagadas, Datos.UltimoPago, Datos.MC
                            FROM         (SELECT     Codprestamo, MAX(MovFecha) AS MovFecha
                                                   FROM          (SELECT DISTINCT 
                                                                                                  ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, 
                                                                                                  0.00 AS SIINIcio, 0.00 AS Cargos, 0.00 AS Abonos, 0.00 AS Disposiciones, PagosProgramado, 
                                                                                                  CASE WHEN ltrim(rtrim(isnull(UltimoPago, ''))) <> '' THEN UltimoPago ELSE ReporteFin END AS MovFecha, 1 AS MovTipo, 
                                                                                                  '209' AS MovClave, 0 AS MovAplica, 0.00 AS MovMonto, MovDenominacion, 0 AS SIFin, NroDiasAtraso, CuotasPagadas, 
                                                                                                  UltimoPago, MC = '2'
                                                                           FROM          vSHFMovimiento) Datos
                                                   GROUP BY codprestamo) Corte INNER JOIN
                                                      (SELECT DISTINCT 
                                                                               ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, 0.00 AS SIINIcio, 
                                                                               0.00 AS Cargos, 0.00 AS Abonos, 0.00 AS Disposiciones, PagosProgramado, CASE WHEN ltrim(rtrim(isnull(UltimoPago, ''))) 
                                                                               <> '' THEN UltimoPago ELSE ReporteFin END AS MovFecha, 1 AS MovTipo, '209' AS MovClave, 0 AS MovAplica, 0.00 AS MovMonto, 
                                                                               MovDenominacion, 0 AS SIFin, NroDiasAtraso, CuotasPagadas, UltimoPago, MC = '2'
                                                        FROM          vSHFMovimiento) Datos ON Corte.MovFecha = Datos.MovFecha AND Corte.Codprestamo = Datos.CodPrestamo
                            UNION
                            SELECT     Datos.ReporteInicio, Datos.ReporteFin, Datos.Emisor, Datos.LineaNegocio, Datos.TipoTransaccion, Datos.TipoEnvio, Datos.idLineaCredito, Datos.Originador, 
                      Datos.CodPrestamo, Datos.SIINIcio, Datos.Cargos, Datos.Abonos, Datos.Disposiciones, Datos.PagosProgramado, 
                      CASE WHEN Datos.MovFecha < Datos.ReporteInicio THEN Datos.ReporteFin ELSE Datos.MovFecha END AS MovFecha, Datos.MovTipo, Datos.MovClave, 
                      Datos.MovAplica, Datos.MovMonto, Datos.MovDenominacion, Datos.SIFin, Datos.NroDiasAtraso, Datos.CuotasPagadas, Datos.UltimoPago, Datos.MC
                            FROM         (SELECT     Codprestamo, MAX(MovFecha) AS MovFecha
                                                   FROM          (SELECT DISTINCT 
                                                                                                  ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, 
                                                                                                  0.00 AS SIINIcio, 0.00 AS Cargos, 0.00 AS Abonos, 0.00 AS Disposiciones, PagosProgramado, 
                                                                                                  CASE WHEN ltrim(rtrim(isnull(UltimoPago, ''))) <> '' THEN UltimoPago ELSE ReporteFin END AS MovFecha, 1 AS MovTipo, 
                                                                                                  '339' AS MovClave, 0 AS MovAplica, 0.00 AS MovMonto, MovDenominacion, 0 AS SIFin, NroDiasAtraso, CuotasPagadas, 
                                                                                                  UltimoPago, '3' AS MC
                                                                           FROM          dbo.vSHFMovimiento) Datos
                                                   GROUP BY codprestamo) Corte INNER JOIN
                                                      (SELECT DISTINCT 
                                                                               ReporteInicio, ReporteFin, Emisor, LineaNegocio, TipoTransaccion, TipoEnvio, idLineaCredito, Originador, CodPrestamo, 0.00 AS SIINIcio, 
                                                                               0.00 AS Cargos, 0.00 AS Abonos, 0.00 AS Disposiciones, PagosProgramado, CASE WHEN ltrim(rtrim(isnull(UltimoPago, ''))) 
                                                                               <> '' THEN UltimoPago ELSE ReporteFin END AS MovFecha, 1 AS MovTipo, '339' AS MovClave, 0 AS MovAplica, 0.00 AS MovMonto, 
                                                                               MovDenominacion, 0 AS SIFin, NroDiasAtraso, CuotasPagadas, UltimoPago, '3' AS MC
                                                        FROM          dbo.vSHFMovimiento) Datos ON Corte.MovFecha = Datos.MovFecha AND Corte.Codprestamo = Datos.CodPrestamo) Adicionales ON 
                      dbo.vSHFMovimiento.ReporteInicio = Adicionales.ReporteInicio COLLATE Modern_Spanish_CI_AI AND 
                      dbo.vSHFMovimiento.ReporteFin = Adicionales.ReporteFin COLLATE Modern_Spanish_CI_AI AND 
                      dbo.vSHFMovimiento.Emisor = Adicionales.Emisor COLLATE Modern_Spanish_CI_AI AND dbo.vSHFMovimiento.LineaNegocio = Adicionales.LineaNegocio AND 
                      dbo.vSHFMovimiento.TipoTransaccion = Adicionales.TipoTransaccion AND 
                      dbo.vSHFMovimiento.TipoEnvio = Adicionales.TipoEnvio COLLATE Modern_Spanish_CI_AI AND 
                      dbo.vSHFMovimiento.idLineaCredito = Adicionales.idLineaCredito COLLATE Modern_Spanish_CI_AI AND 
                      dbo.vSHFMovimiento.Originador = Adicionales.Originador COLLATE Modern_Spanish_CI_AI AND 
                      dbo.vSHFMovimiento.CodPrestamo = Adicionales.CodPrestamo COLLATE Modern_Spanish_CI_AI AND 
                      dbo.vSHFMovimiento.MC = Adicionales.MC COLLATE Modern_Spanish_CI_AI
WHERE     (dbo.vSHFMovimiento.MC IS NULL)


GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[21] 4[8] 2[10] 3) )"
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
         Begin Table = "vSHFMovimiento"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 123
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Adicionales"
            Begin Extent = 
               Top = 6
               Left = 274
               Bottom = 123
               Right = 472
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
      Begin ColumnWidths = 26
         Width = 284
         Width = 1980
         Width = 1980
         Width = 615
         Width = 1095
         Width = 1305
         Width = 840
         Width = 1170
         Width = 900
         Width = 1500
         Width = 720
         Width = 660
         Width = 690
         Width = 1095
         Width = 1455
         Width = 1980
         Width = 750
         Width = 855
         Width = 870
         Width = 900
         Width = 1440
         Width = 510
         Width = 1185
         Width = 1275
         Width = 1980
         Width = 375
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 4365
         Alias = 2580
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
', 'SCHEMA', N'dbo', 'VIEW', N'vSHFAdicionales'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vSHFAdicionales'
GO