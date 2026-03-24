SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vAvalesCallCenter]
AS
SELECT     dbo.tCsCarteraDet.Fecha, dbo.tCsCarteraDet.CodPrestamo, dbo.tCsPadronClientes.CodUsuario, dbo.tCsPadronClientes.NombreCompleto, 
                      dbo.tCsGarantias.DocPropiedad AS Aval, dbo.tCsClientes.NombreCompleto AS NombredeAval, dbo.tCsClientes.CodDocIden, dbo.tCsClientes.DI, 
                      dbo.tCsClientes.UsRUC, dbo.tCsClientes.CodUbiGeoDirFamPri, dbo.tCsClientes.DireccionDirFamPri, dbo.tCsClientes.TelefonoDirFamPri, 
                      dbo.tCsClientes.CodUbiGeoDirNegPri, dbo.tCsClientes.DireccionDirNegPri, dbo.tCsClientes.TelefonoDirNegPri, dbo.tCsGarantias.TipoGarantia
FROM         dbo.tCsCartera INNER JOIN
                      dbo.tCaProducto ON dbo.tCsCartera.CodProducto = dbo.tCaProducto.CodProducto INNER JOIN
                      dbo.tCsCarteraDet ON dbo.tCsCartera.Fecha = dbo.tCsCarteraDet.Fecha AND 
                      dbo.tCsCartera.CodPrestamo = dbo.tCsCarteraDet.CodPrestamo INNER JOIN
                      dbo.tClOficinas ON dbo.tCsCarteraDet.CodOficina = dbo.tClOficinas.CodOficina LEFT OUTER JOIN
                      dbo.tCsPadronClientes ON dbo.tCsCarteraDet.CodUsuario = dbo.tCsPadronClientes.CodUsuario RIGHT OUTER JOIN
                      dbo.tCsGarantias INNER JOIN
                      dbo.tCsClientes ON dbo.tCsGarantias.DocPropiedad = dbo.tCsClientes.CodOrigen ON 
                      dbo.tCsCarteraDet.CodPrestamo = dbo.tCsGarantias.Codigo
WHERE     (dbo.tCsCartera.Estado <> 'castigado') AND (dbo.tCsCartera.NroDiasAtraso >= 90) AND (dbo.tCsGarantias.TipoGarantia = 'IPN') AND 
                      (dbo.tCsCarteraDet.SaldoCapital > 0)
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[27] 4[15] 2[14] 3) )"
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
         Begin Table = "tCsGarantias"
            Begin Extent = 
               Top = 151
               Left = 230
               Bottom = 358
               Right = 420
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsCartera"
            Begin Extent = 
               Top = 0
               Left = 212
               Bottom = 147
               Right = 440
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tClOficinas"
            Begin Extent = 
               Top = 141
               Left = 812
               Bottom = 256
               Right = 1002
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCaProducto"
            Begin Extent = 
               Top = 4
               Left = 5
               Bottom = 119
               Right = 195
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsCarteraDet"
            Begin Extent = 
               Top = 15
               Left = 519
               Bottom = 168
               Right = 709
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsPadronClientes"
            Begin Extent = 
               Top = 14
               Left = 818
               Bottom = 127
               Right = 1008
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsClientes"
            Begin Extent = 
               Top = 183
               Left = 517
               Bottom = 296
               Right = 707
           ', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane2', N' End
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
      Begin ColumnWidths = 17
         Width = 284
         Width = 1440
         Width = 1740
         Width = 2400
         Width = 1440
         Width = 1440
         Width = 2925
         Width = 1155
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
         Table = 2520
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
', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 2, 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de proceso', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Prestamo del crédito', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'CodPrestamo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Nombre completo como se 
reporta', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'NombreCompleto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del avalúo o valor único de la garantía especifica', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'Aval'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Nombre completo como se 
reporta', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'NombredeAval'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo de documento de 
identidad', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'CodDocIden'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Documento de Identidad', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'DI'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'El RUC o R.F.C. del 
usuario.', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'UsRUC'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de Ubigeo de la 
dirección principal de domicilio del cliente.', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'CodUbiGeoDirFamPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Detalle de dirección 
principal familiar del cliente.', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'DireccionDirFamPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Teléfono de la dirección 
principal de la familia.', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'TelefonoDirFamPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de Ubigeo de la 
dirección principal de negocio del cliente.', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'CodUbiGeoDirNegPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Detalle de dirección 
principaldel negocio del cliente.', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'DireccionDirNegPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Teléfono de la dirección 
principal del negocio.', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'TelefonoDirNegPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo de garantía', 'SCHEMA', N'dbo', 'VIEW', N'vAvalesCallCenter', 'COLUMN', N'TipoGarantia'
GO