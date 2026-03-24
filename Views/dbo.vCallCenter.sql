SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCallCenter]
AS
SELECT     dbo.tCsCartera01.Fecha, dbo.tCsCartera01.CodPrestamo, dbo.tCsCartera01.CodUsuario, dbo.tCsPadronClientes.NombreCompleto, 
                      dbo.tClOficinas.NomOficina, dbo.tCsCartera.CodProducto, dbo.tCaProducto.NombreProd, dbo.tCsPadronAsesores.NomAsesor, 
                      dbo.tCsCartera.CodGrupo, dbo.tCsCartera.Estado, dbo.tCsCartera.FechaDesembolso, dbo.tCsCartera.FechaVencimiento, 
                      dbo.tCsCartera.MontoDesembolso, dbo.tCsCartera.NroDiasAtraso, dbo.tCsCartera01.SaldoCapital, dbo.tCsCartera01.SaldoINTE AS InteresOrdinario, 
                      dbo.tCsCartera01.SaldoINPE AS InteresMoratorio, dbo.tCsCartera.CargoMora,  
                      dbo.tCsCartera01.SaldoINTE + dbo.tCsCartera01.SaldoINPE + dbo.tCsCartera.CargoMora  AS SumaInteresyConceptos,
                       (dbo.tCsCartera01.SaldoINTE + dbo.tCsCartera01.SaldoINPE + dbo.tCsCartera.CargoMora ) 
                      * 0.15 AS IVAIntyConceptos, 
                      dbo.tCsCartera01.SaldoCapital + dbo.tCsCartera01.SaldoINTE + dbo.tCsCartera01.SaldoINPE + dbo.tCsCartera.CargoMora 
                       + (dbo.tCsCartera01.SaldoINTE + dbo.tCsCartera01.SaldoINPE + dbo.tCsCartera.CargoMora ) 
                      * 0.15 AS DeudaTotal, dbo.tCsPadronClientes.CodDocIden, dbo.tCsPadronClientes.DI, dbo.tCsPadronClientes.UsRUC, 
                      dbo.tCsPadronClientes.FechaNacimiento, dbo.tCsPadronClientes.CodEstadoCivil, dbo.tCsPadronClientes.Sexo, 
                      dbo.tCsPadronClientes.CodUbiGeoDirFamPri, dbo.tCsPadronClientes.DireccionDirFamPri, dbo.tCsPadronClientes.TelefonoDirFamPri, 
                      dbo.tCsPadronClientes.CodUbiGeoDirNegPri, dbo.tCsPadronClientes.DireccionDirNegPri, dbo.tCsPadronClientes.TelefonoDirNegPri
FROM         dbo.tCsCartera INNER JOIN
                      dbo.tCsCartera01 ON dbo.tCsCartera.Fecha = dbo.tCsCartera01.Fecha AND dbo.tCsCartera.CodPrestamo = dbo.tCsCartera01.CodPrestamo INNER JOIN
                      dbo.tClOficinas ON dbo.tCsCartera01.CodOficina = dbo.tClOficinas.CodOficina INNER JOIN
                      dbo.tCaProducto ON dbo.tCsCartera.CodProducto = dbo.tCaProducto.CodProducto LEFT OUTER JOIN
                      dbo.tCsPadronClientes ON dbo.tCsCartera01.CodUsuario = dbo.tCsPadronClientes.CodUsuario LEFT OUTER JOIN
                      dbo.tCsPadronAsesores ON dbo.tCsCartera.CodAsesor = dbo.tCsPadronAsesores.CodAsesor
WHERE     (dbo.tCsCartera.NroDiasAtraso between 31 and 89)  AND (dbo.tCsCartera01.SaldoCapital > 0) AND (dbo.tCsCartera01.Fecha = '20080220')


GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[21] 4[14] 2[35] 3) )"
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
         Begin Table = "tCsCartera"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 167
               Right = 266
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsCartera01"
            Begin Extent = 
               Top = 0
               Left = 280
               Bottom = 174
               Right = 473
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tClOficinas"
            Begin Extent = 
               Top = 224
               Left = 535
               Bottom = 339
               Right = 725
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCaProducto"
            Begin Extent = 
               Top = 212
               Left = 744
               Bottom = 327
               Right = 934
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsPadronClientes"
            Begin Extent = 
               Top = 0
               Left = 765
               Bottom = 113
               Right = 955
            End
            DisplayFlags = 280
            TopColumn = 32
         End
         Begin Table = "tCsPadronAsesores"
            Begin Extent = 
               Top = 146
               Left = 206
               Bottom = 279
               Right = 396
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
      Begin ColumnWidths = 35
         Wid', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane2', N'th = 284
         Width = 1440
         Width = 1740
         Width = 1455
         Width = 2940
         Width = 1440
         Width = 1440
         Width = 1440
         Width = 2265
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 2, 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de proceso', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Prestamo del crédito', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'CodPrestamo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Usuario', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del producto de credito', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'CodProducto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre del Asesor', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'NomAsesor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de grupo, Null si es individual', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'CodGrupo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado del credito segun la parametrizacion del cliente', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto total de desembolso pactado ', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'MontoDesembolso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'días de atraso que tiene el préstamo respecto a la última cuota no pagada. ', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'NroDiasAtraso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Capital', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'SaldoCapital'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo Interes Corriente', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'InteresOrdinario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo Interes Moratorio', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenter', 'COLUMN', N'InteresMoratorio'
GO