SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vINTFCierre]
AS
SELECT     Datos.Periodo, COUNT(*) AS Contador, RTRIM(LTRIM(STR(SUM(Datos.SaldoActual), 18, 0))) AS SaldoActual, 
                      RTRIM(LTRIM(STR(SUM(Datos.SaldoVencido), 18, 0))) AS SaldoVencido, dbo.vINTFCabecera.Abreviatura, dbo.vINTFCabecera.Direccion, 1 AS Cabecera, 
                      0 AS Empleo, 0 AS Bloques
FROM         (SELECT DISTINCT 
                                              tINTFNombre.Periodo, tINTFCuenta.CodPrestamo, tINTFCuenta.CodUsuario, CAST(SUBSTRING(tINTFCuenta.SaldoActual, 5, 100) 
                                              AS Decimal(18, 0)) AS SaldoActual, CAST(SUBSTRING(tINTFCuenta.SaldoVencido, 5, 100) AS decimal(18, 0)) AS SaldoVencido
                       FROM          tINTFNombre INNER JOIN
                                              tINTFDireccion ON tINTFNombre.CodUsuario = tINTFDireccion.CodUsuario AND tINTFNombre.Periodo = tINTFDireccion.Periodo INNER JOIN
                                              tINTFCuenta ON tINTFNombre.CodUsuario = tINTFCuenta.CodUsuario AND tINTFNombre.Periodo = tINTFCuenta.Periodo INNER JOIN
                                              vINTFCabecera ON tINTFDireccion.Periodo = vINTFCabecera.Periodo
	     WHERE     (tINTFDireccion.Estado <> '0400')) Datos INNER JOIN
                      dbo.vINTFCabecera ON Datos.Periodo COLLATE Modern_Spanish_CI_AI = dbo.vINTFCabecera.Periodo
GROUP BY Datos.Periodo, dbo.vINTFCabecera.Abreviatura, dbo.vINTFCabecera.Direccion

GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[26] 4[13] 2[30] 3) )"
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
               Bottom = 119
               Right = 244
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "vINTFCabecera"
            Begin Extent = 
               Top = 5
               Left = 294
               Bottom = 118
               Right = 500
            End
            DisplayFlags = 280
            TopColumn = 3
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      RowHeights = 220
      Begin ColumnWidths = 10
         Width = 284
         Width = 690
         Width = 825
         Width = 990
         Width = 1095
         Width = 1590
         Width = 4365
         Width = 840
         Width = 1440
         Width = 1440
      End
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
', 'SCHEMA', N'dbo', 'VIEW', N'vINTFCierre'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vINTFCierre'
GO