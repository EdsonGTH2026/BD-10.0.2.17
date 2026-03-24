SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vCsSAT]
AS
SELECT        Datos.Corte, Datos.CodUsuario, LTRIM(RTRIM(ISNULL(dbo.tCsPadronClientes.CodTPersona, ''))) AS CodTPersona, Datos.Ext, dbo.tUsClTipoPersona.IDE, 
                         dbo.tUsClTipoPersona.IVA, Datos.Cuenta, CASE WHEN ltrim(rtrim(Isnull(tCsPadronClientes.CodTPersona, ''))) = '01' AND UsRFCVAl = 1 AND Len(ltrim(rtrim(usrfc))) 
                         = 13 THEN Substring(ltrim(rtrim(ISNULL(tCsPadronClientes.UsRFC, tCsPadronClientes.UsRFCBD))), 1, 13) WHEN ltrim(rtrim(Isnull(tCsPadronClientes.CodTPersona, 
                         ''))) = '01' THEN Substring(ltrim(rtrim(ISNULL(tCsPadronClientes.UsRFCBD, tCsPadronClientes.UsRFC))), 1, 13) 
                         WHEN ltrim(rtrim(Isnull(tCsPadronClientes.CodTPersona, ''))) <> '01' THEN Substring(ltrim(rtrim(ISNULL(tCsPadronClientes.UsRFC, tCsPadronClientes.UsRFCBD))), 1, 
                         12) END AS RFC, dbo.tCsPadronClientes.NombreCompleto, dbo.tCsPadronClientes.FechaNacimiento, 
                         CHARINDEX(dbo.fduFechaATexto(dbo.tCsPadronClientes.FechaNacimiento, 'AAMMDD'), ISNULL(dbo.tCsPadronClientes.UsRFCBD, dbo.tCsPadronClientes.UsRFC), 1) 
                         AS Valida
FROM            dbo.tUsClTipoPersona RIGHT OUTER JOIN
                         dbo.tCsPadronClientes ON dbo.tUsClTipoPersona.CodTPersona = dbo.tCsPadronClientes.CodTPersona RIGHT OUTER JOIN
                             (SELECT DISTINCT 
                                                         dbo.vCsFechaConsolidacion.FechaConsolidacion AS Corte, dbo.tCsClientesAhorrosFecha.CodUsCuenta AS CodUsuario, 'IDE' AS Ext, 
                                                         dbo.tCsPadronAhorros.CodCuenta AS Cuenta
                               FROM            dbo.tCsPadronAhorros INNER JOIN
                                                         dbo.tCsClientesAhorrosFecha ON dbo.tCsPadronAhorros.Renovado = dbo.tCsClientesAhorrosFecha.Renovado AND 
                                                         dbo.tCsPadronAhorros.FraccionCta = dbo.tCsClientesAhorrosFecha.FraccionCta AND 
                                                         dbo.tCsPadronAhorros.CodCuenta = dbo.tCsClientesAhorrosFecha.CodCuenta AND 
                                                         dbo.tCsPadronAhorros.FechaCorte = dbo.tCsClientesAhorrosFecha.Fecha INNER JOIN
                                                         dbo.vCsFechaConsolidacion ON dbo.tCsClientesAhorrosFecha.Fecha = dbo.vCsFechaConsolidacion.FechaConsolidacion
                               UNION
                               SELECT DISTINCT 
                                                        vCsFechaConsolidacion_1.FechaConsolidacion, dbo.tCsPadronCarteraDet.CodUsuario, 'IVA' AS Ext, dbo.tCsPadronCarteraDet.CodPrestamo
                               FROM            dbo.tCsPadronCarteraDet INNER JOIN
                                                        dbo.vCsFechaConsolidacion AS vCsFechaConsolidacion_1 ON 
                                                        dbo.tCsPadronCarteraDet.FechaCorte = vCsFechaConsolidacion_1.FechaConsolidacion INNER JOIN
                                                        dbo.tCsCartera ON dbo.tCsPadronCarteraDet.FechaCorte = dbo.tCsCartera.Fecha AND 
                                                        dbo.tCsPadronCarteraDet.CodPrestamo = dbo.tCsCartera.CodPrestamo 
                                                        --AND dbo.tCsCartera.Cartera NOT IN ('ADMINISTRATIVA')
                                                        ) AS Datos ON 
                         dbo.tCsPadronClientes.CodUsuario = Datos.CodUsuario

GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[46] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1[20] 2[58] 3) )"
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
         Begin Table = "tUsClTipoPersona"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 236
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsPadronClientes"
            Begin Extent = 
               Top = 0
               Left = 428
               Bottom = 225
               Right = 626
            End
            DisplayFlags = 280
            TopColumn = 15
         End
         Begin Table = "Datos"
            Begin Extent = 
               Top = 6
               Left = 664
               Bottom = 135
               Right = 834
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
   End
   Begin CriteriaPane = 
      PaneHidden = 
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCsSAT'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vCsSAT'
GO