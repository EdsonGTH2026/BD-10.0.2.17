SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCsArreglarCodigos3]
AS
SELECT DISTINCT TOP 100 PERCENT Datos.CC, dbo.tCsPadronCarteraDet.CodUsuario
FROM         (SELECT DISTINCT 
                                              tCsCarteraDet.CodUsuario AS CC, tCsCarteraDet.CodPrestamo AS PC, tCsPadronCarteraDet.CodUsuario AS CP, 
                                              tCsPadronCarteraDet.CodPrestamo AS PP
                       FROM          tCsPadronCarteraDet FULL OUTER JOIN
                                              tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
                                              tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario
                       WHERE      (tCsPadronCarteraDet.CodUsuario IS NULL) OR
                                              (tCsCarteraDet.CodUsuario IS NULL)) Datos INNER JOIN
                      dbo.tCsPadronCarteraDet ON Datos.PC COLLATE Modern_Spanish_CI_AI = dbo.tCsPadronCarteraDet.CodPrestamo INNER JOIN
                      dbo.tCsUnisapCA ON Datos.CC COLLATE Modern_Spanish_CI_AI = dbo.tCsUnisapCA.CodUsuario INNER JOIN
                      dbo.tCsPadronClientes ON dbo.tCsPadronCarteraDet.CodUsuario = dbo.tCsPadronClientes.CodUsuario AND 
                      dbo.tCsUnisapCA.NombreCompleto = dbo.tCsPadronClientes.NombreCompleto
ORDER BY Datos.CC
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[14] 2[45] 3) )"
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
               Top = 6
               Left = 38
               Bottom = 121
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsPadronCarteraDet"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 121
               Right = 456
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsUnisapCA"
            Begin Extent = 
               Top = 6
               Left = 494
               Bottom = 121
               Right = 685
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsPadronClientes"
            Begin Extent = 
               Top = 6
               Left = 723
               Bottom = 121
               Right = 913
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCsArreglarCodigos3'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vCsArreglarCodigos3'
GO