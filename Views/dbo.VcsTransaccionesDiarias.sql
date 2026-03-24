SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[VcsTransaccionesDiarias]
AS
SELECT     dbo.tCsTransaccionDiaria.Fecha, dbo.tCsTransaccionDiaria.CodOficina, dbo.tCsTransaccionDiaria.CodSistema, dbo.tClOficinas.CodOficina AS Expr1, 
                      dbo.tClOficinas.NomOficina, dbo.tCsTransaccionDiaria.DescripcionTran, dbo.tCsTransaccionDiaria.CodCajero, 
                      dbo.tCsTransaccionDiaria.MontoCapitalTran, dbo.tCsTransaccionDiaria.MontoInteresTran, dbo.tCsTransaccionDiaria.MontoINVETran, 
                      dbo.tCsTransaccionDiaria.MontoINPETran, dbo.tCsTransaccionDiaria.MontoOtrosTran, dbo.tCsTransaccionDiaria.MontoTotalTran, 
                      dbo.tCsTransaccionDiaria.FechaApertura, dbo.tCsTransaccionDiaria.FechaVencimiento, dbo.tCsTransaccionDiaria.CodUsuario, 
                      dbo.tCsTransaccionDiaria.CodAsesor, dbo.tCsTransaccionDiaria.CodProducto
FROM         dbo.tCsTransaccionDiaria INNER JOIN
                      dbo.tClOficinas ON dbo.tCsTransaccionDiaria.CodOficina = dbo.tClOficinas.CodOficina
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "tCsTransaccionDiaria"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 117
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tClOficinas"
            Begin Extent = 
               Top = 6
               Left = 259
               Bottom = 117
               Right = 434
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
      Begin ColumnWidths = 19
         Width = 284
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
', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de generacion del saldo', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la Oficina donde se realizó la transaccion', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del sistema que genera la transaccion', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'CodSistema'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Descripcion o glosa de la transaccion', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'DescripcionTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de cajero', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'CodCajero'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto capital de la transaccion', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'MontoCapitalTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto interes de la transaccion', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'MontoInteresTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto INVE de la transaccion', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'MontoINVETran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto INPE de la transaccion', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'MontoINPETran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto de otros conceptos de la transaccion', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'MontoOtrosTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto total de la transaccion', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'MontoTotalTran'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'ahorros', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'FechaApertura'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'ahorros', 'SCHEMA', N'dbo', 'VIEW', N'VcsTransaccionesDiarias', 'COLUMN', N'FechaVencimiento'
GO