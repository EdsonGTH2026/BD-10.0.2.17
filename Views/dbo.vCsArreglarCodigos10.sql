SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCsArreglarCodigos10]
AS
Select * from (
SELECT     *, Compara = 
case 	when Left(Antiguo, 1) = Left(Nuevo, 1) and right(rtrim(ltrim(Antiguo)), 2) = right(rtrim(ltrim(nuevo)), 2) then 1 
	when right(rtrim(ltrim(Antiguo)), 7) = right(rtrim(ltrim(nuevo)), 7) then 1
	when Left(Antiguo, 3) = Left(Nuevo, 3) then 1
	when Left(right(rtrim(ltrim(Antiguo)), 7), 4) = Left(right(rtrim(ltrim(nuevo)), 7),4) then 1
end 
FROM         (SELECT     corte.CodCuenta, corte.FraccionCta, corte.Renovado, corte.FormaManejo, corte.Contador, datos.Contador AS Expr1, 
                                              CASE WHEN tCsClientesAhorrosFecha.CodUsCuenta <> datos.Codusuario THEN tCsClientesAhorrosFecha.CodUsCuenta ELSE '' END AS Nuevo, 
                                              datos.Codusuario AS Antiguo
                       FROM          (SELECT     CodCuenta, FraccionCta, Renovado, Codusuario, COUNT(*) AS Contador
                                               FROM          tCsClientesAhorrosFecha
                                               WHERE      (FormaManejo = 1) AND (Fecha >=
                                                                          (SELECT     DATEADD([day], - 46, FechaConsolidacion)
                                                                            FROM          vCsFechaConsolidacion))
                                               GROUP BY CodCuenta, FraccionCta, Renovado, codusuario) datos INNER JOIN
                                                  (SELECT     CodCuenta, FraccionCta, Renovado, FormaManejo, COUNT(*) AS Contador, MAX(fecha) AS Fecha
                                                    FROM          tCsClientesAhorrosFecha
                                                    WHERE      (FormaManejo = 1) AND (Fecha >=
                                                                               (SELECT     DATEADD([day], - 46, FechaConsolidacion)
                                                                                 FROM          vCsFechaConsolidacion))
                                                    GROUP BY CodCuenta, FraccionCta, Renovado, FormaManejo) corte ON datos.CodCuenta = corte.CodCuenta AND 
                                              datos.FraccionCta = corte.FraccionCta AND datos.Renovado = corte.Renovado AND datos.Contador <> corte.Contador INNER JOIN
                                              tCsClientesAhorrosFecha ON corte.Fecha = tCsClientesAhorrosFecha.Fecha AND 
                                              corte.CodCuenta COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.CodCuenta AND 
                                              corte.FraccionCta COLLATE Modern_Spanish_CI_AI = tCsClientesAhorrosFecha.FraccionCta AND corte.Renovado = tCsClientesAhorrosFecha.Renovado AND
                                               corte.FormaManejo = tCsClientesAhorrosFecha.FormaManejo) Datos
WHERE     (Nuevo <> '') )Datos  Where Compara = 1

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
         Begin Table = "Datos"
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCsArreglarCodigos10'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vCsArreglarCodigos10'
GO