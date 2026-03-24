SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCsFechaConsolidacion]
AS


SELECT     MAX(Fecha)   AS FechaConsolidacion
FROM         (SELECT     (CASE WHEN Consolidadoahorros > consolidadocartera THEN Consolidadoahorros ELSE consolidadocartera END) AS Fecha
                     FROM          tClOficinas with(nolock)) A
GO

GRANT SELECT ON [dbo].[vCsFechaConsolidacion] TO [jmartinezc]
GO

GRANT SELECT ON [dbo].[vCsFechaConsolidacion] TO [marista]
GO

GRANT SELECT ON [dbo].[vCsFechaConsolidacion] TO [ayescasc]
GO

GRANT
  DELETE,
  INSERT,
  REFERENCES,
  SELECT,
  UPDATE
ON [dbo].[vCsFechaConsolidacion] TO [mchavezs2]
GO

DENY REFERENCES ([FechaConsolidacion]) ON [dbo].[vCsFechaConsolidacion] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[vCsFechaConsolidacion] TO [rie_sbravoa]
GO

GRANT
  DELETE,
  INSERT,
  SELECT,
  UPDATE
ON [dbo].[vCsFechaConsolidacion] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[vCsFechaConsolidacion] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[vCsFechaConsolidacion] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[vCsFechaConsolidacion] TO [int_mmartinezp]
GO

GRANT SELECT ON [dbo].[vCsFechaConsolidacion] TO [rie_rgonzalezc]
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
         Begin Table = "A"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 74
               Right = 244
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
      Begin ColumnWidths = 12
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCsFechaConsolidacion'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vCsFechaConsolidacion'
GO