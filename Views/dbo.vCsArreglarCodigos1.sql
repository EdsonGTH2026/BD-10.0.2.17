SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCsArreglarCodigos1]
AS
SELECT     TOP 100 PERCENT datos.CodPrestamo, CASE WHEN Isnull(Codusuario, 'MAL') <> 'Mal' THEN 'BIEN' ELSE 'MAL' END AS Estado, 
                      datos.F AS Codusuario
FROM         (SELECT     Datos.CC, Datos.CodUsuario, tCsPadronCarteraDet.CodUsuario AS Final, F = Isnull(tCsPadronCarteraDet.CodUsuario, Datos.CC), 
                                              Isnull(Datos.CodPrestamo, tCsPadronCarteraDet.CodPrestamo) AS CodPrestamo
                       FROM          (SELECT     datos.CodPrestamo, datos.CC, tCsCarteraDet.CodUsuario
                                               FROM          (SELECT     MAX(tCsCarteraDet.Fecha) AS Fecha, tCsCarteraDet.CodPrestamo, Datos.CC
                                                                       FROM          tCsCarteraDet INNER JOIN
                                                                                                  (SELECT DISTINCT 
                                                                                                                           tCsCarteraDet.CodUsuario AS CC, tCsCarteraDet.CodPrestamo AS PC, 
                                                                                                                           tCsPadronCarteraDet.CodUsuario AS CP, tCsPadronCarteraDet.CodPrestamo AS PP
                                                                                                    FROM          tCsPadronCarteraDet FULL OUTER JOIN
                                                                                                                           tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
                                                                                                                           tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario
                                                                                                    WHERE      (tCsPadronCarteraDet.CodUsuario IS NULL) OR
                                                                                                                           (tCsCarteraDet.CodUsuario IS NULL)) Datos ON 
                                                                                              tCsCarteraDet.CodPrestamo = Datos.PC COLLATE Modern_Spanish_CI_AI AND 
                                                                                              tCsCarteraDet.CodUsuario = Datos.CC COLLATE Modern_Spanish_CI_AI
                                                                       GROUP BY tCsCarteraDet.CodPrestamo, Datos.CC) datos INNER JOIN
                                                                      tCsCarteraDet ON datos.Fecha = tCsCarteraDet.Fecha AND 
                                                                      datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsCarteraDet.CodPrestamo) Datos FULL OUTER JOIN
                                              tCsPadronCarteraDet ON Datos.CodPrestamo COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodPrestamo AND 
                                              Datos.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsPadronCarteraDet.CodUsuario) datos INNER JOIN
                          (SELECT DISTINCT 
                                                   tCsCarteraDet.CodUsuario AS CC, tCsCarteraDet.CodPrestamo AS PC, tCsPadronCarteraDet.CodUsuario AS CP, 
                                                   tCsPadronCarteraDet.CodPrestamo AS PP
                            FROM          tCsPadronCarteraDet FULL OUTER JOIN
                                                   tCsCarteraDet ON tCsPadronCarteraDet.CodPrestamo = tCsCarteraDet.CodPrestamo AND 
                                                   tCsPadronCarteraDet.CodUsuario = tCsCarteraDet.CodUsuario
                            WHERE      (tCsPadronCarteraDet.CodUsuario IS NULL) OR
                                                   (tCsCarteraDet.CodUsuario IS NULL)) C ON datos.CodPrestamo = C.PC
WHERE     (datos.CodUsuario IS NULL) OR
                      (datos.Final IS NULL)
ORDER BY datos.CodPrestamo
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
         Begin Table = "datos"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 121
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 121
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCsArreglarCodigos1'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vCsArreglarCodigos1'
GO