SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vINTFCabecera]
AS
SELECT     dbo.tClEmpresas.KOB + dbo.tClEmpresas.NroInstitucion + dbo.fduRellena('0', dbo.tClEmpresas.OficinaPrincipal, 4, 'D') AS ClaveUsuario, 
                      dbo.tClEmpresas.NombreActividad AS NombreUsuario, dbo.fduFechaATexto(dbo.tINTFPeriodo.FechaReporte, 'DDMMAAAA') AS FechaReporte, 
                      dbo.tINTFPeriodo.Corte, dbo.tINTFPeriodo.Periodo, dbo.tClEmpresas.Abreviatura, UPPER(dbo.tClEmpresas.Direccion) AS Direccion
FROM         dbo.tClEmpresas CROSS JOIN
                      dbo.tINTFPeriodo
WHERE     (dbo.tClEmpresas.CodEmpresa = 1) AND (dbo.tClEmpresas.Activo = 1) AND (dbo.tINTFPeriodo.Activo = 1)
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
         Begin Table = "tClEmpresas"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 179
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 7
         End
         Begin Table = "tINTFPeriodo"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 119
               Right = 456
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
      Begin ColumnWidths = 8
         Width = 284
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
', 'SCHEMA', N'dbo', 'VIEW', N'vINTFCabecera'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vINTFCabecera'
GO