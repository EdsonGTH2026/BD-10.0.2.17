SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vSHFMovimiento]
AS
SELECT     dbo.fduFechaATexto(dbo.tSHFComportamiento.ReporteInicio, 'AAAA') + '-' + dbo.fduFechaATexto(dbo.tSHFComportamiento.ReporteInicio, 'MM') 
                      + '-' + dbo.fduFechaATexto(dbo.tSHFComportamiento.ReporteInicio, 'DD') + 'T00:00:00:00' AS ReporteInicio, dbo.fduFechaATexto(dbo.tSHFComportamiento.ReporteFin, 
                      'AAAA') + '-' + dbo.fduFechaATexto(dbo.tSHFComportamiento.ReporteFin, 'MM') + '-' + dbo.fduFechaATexto(dbo.tSHFComportamiento.ReporteFin, 'DD') 
                      + 'T00:00:00:00' AS ReporteFin, dbo.tSHFComportamiento.Emisor, dbo.tSHFComportamiento.LineaNegocio, dbo.tSHFComportamiento.TipoTransaccion, 
                      dbo.tSHFComportamiento.TipoEnvio, dbo.tSHFComportamiento.idLineaCredito, dbo.tSHFComportamiento.Originador, dbo.tSHFComportamiento.CodPrestamo, 
                      RTRIM(LTRIM(STR(dbo.tSHFComportamiento.SIInicio, 18, 2))) AS SIInicio, 
                      LTRIM(RTRIM(STR(CASE WHEN tSHFComportamiento.movtipo = 1 THEN tSHFComportamiento.movmonto ELSE 0 END, 18, 2))) AS Cargos, 
                      RTRIM(LTRIM(STR(CASE WHEN tSHFComportamiento.movtipo = 2 THEN tSHFComportamiento.movmonto ELSE 0 END, 18, 2))) AS Abonos, 
                      LTRIM(RTRIM(STR(dbo.tSHFComportamiento.Disposiciones, 18, 2))) AS Disposiciones, dbo.tSHFComportamiento.PagosProgramado, 
                      ISNULL(dbo.fduFechaATexto(dbo.tSHFComportamiento.MovFecha, 'AAAA') + '-' + dbo.fduFechaATexto(dbo.tSHFComportamiento.MovFecha, 'MM') 
                      + '-' + dbo.fduFechaATexto(dbo.tSHFComportamiento.MovFecha, 'DD') + 'T00:00:00:00', '') AS MovFecha, dbo.tSHFComportamiento.MovTipo, 
                      CASE WHEN tSHFComportamientoDetalle.MovClave = '102' THEN tSHFComportamientoDetalle.MovClave ELSE dbo.tCaClConcepto.SHF END AS MovClave, 
                      dbo.tSHFComportamiento.MovAplica, LTRIM(RTRIM(STR(dbo.tSHFComportamientoDetalle.Monto, 18, 2))) AS MovMonto, 
                      LTRIM(RTRIM(STR(dbo.tSHFComportamiento.MovDenominacion, 5, 0))) AS MovDenominacion, 
                      LTRIM(RTRIM(STR(dbo.tSHFComportamiento.SIInicio + CASE WHEN tSHFComportamiento.movtipo = 1 THEN tSHFComportamiento.movmonto ELSE 0 END - CASE WHEN
                       tSHFComportamiento.movtipo = 2 THEN tSHFComportamiento.movmonto ELSE 0 END + dbo.tSHFComportamiento.Disposiciones, 18, 2))) AS SIFin, 
                      dbo.tSHFComportamiento.NroDiasAtraso, dbo.tSHFComportamiento.NroCuotasPagadas AS CuotasPagadas, 
                      ISNULL(dbo.fduFechaATexto(dbo.tSHFComportamiento.UltimoPago, 'AAAA') + '-' + dbo.fduFechaATexto(dbo.tSHFComportamiento.UltimoPago, 'MM') 
                      + '-' + dbo.fduFechaATexto(dbo.tSHFComportamiento.UltimoPago, 'DD') + 'T00:00:00:00', '') AS UltimoPago, 
                      CASE WHEN tSHFComportamientoDetalle.MovClave = '102' THEN Substring(tSHFComportamientoDetalle.MovClave, 1, 1) ELSE substring(dbo.tCaClConcepto.SHF, 1, 
                      1) END AS MC
FROM         dbo.tCaClConcepto RIGHT OUTER JOIN
                      dbo.tSHFComportamientoDetalle ON dbo.tCaClConcepto.CodConcepto = dbo.tSHFComportamientoDetalle.CodConcepto RIGHT OUTER JOIN
                      dbo.tSHFComportamiento INNER JOIN
                      dbo.tSHFPeriodo ON dbo.tSHFComportamiento.ReporteInicio = dbo.tSHFPeriodo.ReporteInicio AND 
                      dbo.tSHFComportamiento.ReporteFin = dbo.tSHFPeriodo.ReporteFin ON dbo.tSHFComportamientoDetalle.ReporteInicio = dbo.tSHFComportamiento.ReporteInicio AND 
                      dbo.tSHFComportamientoDetalle.ReporteFin = dbo.tSHFComportamiento.ReporteFin AND 
                      dbo.tSHFComportamientoDetalle.CodPrestamo = dbo.tSHFComportamiento.CodPrestamo AND 
                      dbo.tSHFComportamientoDetalle.CodUsuario = dbo.tSHFComportamiento.CodUsuario AND 
                      dbo.tSHFComportamientoDetalle.MovFecha = dbo.tSHFComportamiento.MovFecha AND 
                      dbo.tSHFComportamientoDetalle.MovTipo = dbo.tSHFComportamiento.MovTipo
WHERE     (dbo.tSHFPeriodo.Activo = 1)
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[46] 4[19] 2[22] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[18] 2[63] 3) )"
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
      ActivePaneConfig = 2
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "tCaClConcepto"
            Begin Extent = 
               Top = 21
               Left = 0
               Bottom = 136
               Right = 220
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tSHFComportamientoDetalle"
            Begin Extent = 
               Top = 13
               Left = 287
               Bottom = 197
               Right = 477
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tSHFComportamiento"
            Begin Extent = 
               Top = 3
               Left = 565
               Bottom = 280
               Right = 770
            End
            DisplayFlags = 280
            TopColumn = 2
         End
         Begin Table = "tSHFPeriodo"
            Begin Extent = 
               Top = 0
               Left = 859
               Bottom = 113
               Right = 1049
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
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 11985
         Alias = 2190
         Table = 3030
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
', 'SCHEMA', N'dbo', 'VIEW', N'vSHFMovimiento'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vSHFMovimiento'
GO