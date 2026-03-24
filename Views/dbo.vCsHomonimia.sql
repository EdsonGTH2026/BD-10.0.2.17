SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCsHomonimia]
AS
SELECT     A.Nombre, A.CodUsuario AS A, B.CodUsuario AS B
FROM         (SELECT     Filtro.Nombre, Clientes.*
                       FROM          (SELECT     Nombre, COUNT(*) AS Expr1
                                               FROM          (SELECT     CodUsuario, LTRIM(RTRIM(ISNULL(Paterno, ''))) + ' ' + LTRIM(RTRIM(ISNULL(Materno, ''))) + ' ' + LTRIM(RTRIM(ISNULL(Nombres, ''))) 
                                                                                              AS Nombre, NombreCompleto
                                                                       FROM          tCsPadronClientes
                                                                       WHERE      codtpersona = '01'
                                                                       UNION
                                                                       SELECT     CodUsuario, Isnull(NombreCompleto, '') AS Nombre, NombreCompleto
                                                                       FROM         tCsPadronClientes
                                                                       WHERE     codtpersona = '02') Clientes
                                               GROUP BY Nombre
                                               HAVING      (COUNT(*) > 1)) Filtro INNER JOIN
                                                  (SELECT     *
                                                    FROM          tCsPadronClientes) Clientes ON Filtro.Nombre = LTRIM(RTRIM(ISNULL(Clientes.Paterno, ''))) + ' ' + LTRIM(RTRIM(ISNULL(Clientes.Materno, 
                                              ''))) + ' ' + LTRIM(RTRIM(ISNULL(Clientes.Nombres, '')))) A INNER JOIN
                          (SELECT     Filtro.Nombre, Clientes.*
                            FROM          (SELECT     Nombre, COUNT(*) AS Expr1
                                                    FROM          (SELECT     CodUsuario, LTRIM(RTRIM(ISNULL(Paterno, ''))) + ' ' + LTRIM(RTRIM(ISNULL(Materno, ''))) + ' ' + LTRIM(RTRIM(ISNULL(Nombres, 
                                                                                                   ''))) AS Nombre, NombreCompleto
                                                                            FROM          tCsPadronClientes
                                                                            WHERE      codtpersona = '01'
                                                                            UNION
                                                                            SELECT     CodUsuario, Isnull(NombreCompleto, '') AS Nombre, NombreCompleto
                                                                            FROM         tCsPadronClientes
                                                                            WHERE     codtpersona = '02') Clientes
                                                    GROUP BY Nombre
                                                    HAVING      (COUNT(*) > 1)) Filtro INNER JOIN
                                                       (SELECT     *
                                                         FROM          tCsPadronClientes) Clientes ON Filtro.Nombre = LTRIM(RTRIM(ISNULL(Clientes.Paterno, ''))) + ' ' + LTRIM(RTRIM(ISNULL(Clientes.Materno, 
                                                   ''))) + ' ' + LTRIM(RTRIM(ISNULL(Clientes.Nombres, '')))) B ON A.Nombre = B.Nombre AND A.CodUsuario <> B.CodUsuario
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[17] 4[11] 2[54] 3) )"
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
               Left = 274
               Bottom = 123
               Right = 472
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 123
               Right = 236
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
      Begin ColumnWidths = 4
         Width = 284
         Width = 2430
         Width = 1275
         Width = 1275
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCsHomonimia'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vCsHomonimia'
GO