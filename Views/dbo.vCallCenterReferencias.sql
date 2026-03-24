SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCallCenterReferencias]
AS
SELECT DISTINCT 
                      dbo.tCsCarteraDet.Fecha, dbo.tCsCarteraDet.CodPrestamo, dbo.tCsCarteraDet.CodUsuario, tCsPadronClientes_1.NombreCompleto, 
                      dbo.tClOficinas.NomOficina, dbo.tCsCartera.CodProducto, dbo.tCaProducto.NombreProd, dbo.tCsAsesores.NomAsesor, dbo.tCsCartera.CodGrupo, 
                      dbo.tCsCartera.Estado, dbo.tCsCartera.FechaDesembolso, dbo.tCsCartera.FechaVencimiento, dbo.tCsCartera.MontoDesembolso, 
                      dbo.tCsCartera.NroDiasAtraso, dbo.tCsCarteraDet.SaldoCapital, dbo.tCsCarteraDet.SaldoInteres AS InteresOrdinario, 
                      dbo.tCsCarteraDet.SaldoMoratorio AS InteresMoratorio, dbo.tCsCartera.CargoMora, dbo.tCsCarteraDet.OtrosCargos, 
                      dbo.tCsCarteraDet.SaldoInteres + dbo.tCsCarteraDet.SaldoMoratorio + dbo.tCsCartera.CargoMora + dbo.tCsCarteraDet.OtrosCargos AS SumaInteresyConceptos,
                       (dbo.tCsCarteraDet.SaldoInteres + dbo.tCsCarteraDet.SaldoMoratorio + dbo.tCsCartera.CargoMora + dbo.tCsCarteraDet.OtrosCargos) 
                      * 0.15 AS IVAIntyConceptos, 
                      dbo.tCsCarteraDet.SaldoCapital + dbo.tCsCarteraDet.SaldoInteres + dbo.tCsCarteraDet.SaldoMoratorio + dbo.tCsCartera.CargoMora + dbo.tCsCarteraDet.OtrosCargos
                       + (dbo.tCsCarteraDet.SaldoInteres + dbo.tCsCarteraDet.SaldoMoratorio + dbo.tCsCartera.CargoMora + dbo.tCsCarteraDet.OtrosCargos) 
                      * 0.15 AS DeudaTotal, tCsPadronClientes_1.CodDocIden, tCsPadronClientes_1.DI, tCsPadronClientes_1.UsRUC, 
                      tCsPadronClientes_1.FechaNacimiento, tCsPadronClientes_1.CodEstadoCivil, tCsPadronClientes_1.Sexo, tCsPadronClientes_1.CodUbiGeoDirFamPri, 
                      tCsPadronClientes_1.DireccionDirFamPri, tCsPadronClientes_1.TelefonoDirFamPri, tCsPadronClientes_1.CodUbiGeoDirNegPri, 
                      tCsPadronClientes_1.DireccionDirNegPri, tCsPadronClientes_1.TelefonoDirNegPri, .tUsReferencias.Nombre AS NomReferencia, 
                      tUsReferencias.Direccion AS DirReferencia, tUsReferencias.Telefono AS TelReferencia
FROM         dbo.tCsClientes INNER JOIN
                      tCsReferencias tUsReferencias ON dbo.tCsClientes.CodOrigen = .tUsReferencias.CodUsuario INNER JOIN
                      dbo.tCsPadronClientes ON dbo.tCsClientes.CodUsuario = dbo.tCsPadronClientes.CodOriginal INNER JOIN
                      dbo.tCsCartera INNER JOIN
                      dbo.tCaProducto ON dbo.tCsCartera.CodProducto = dbo.tCaProducto.CodProducto INNER JOIN
                      dbo.tCsAsesores ON dbo.tCsCartera.CodAsesor = dbo.tCsAsesores.CodAsesor INNER JOIN
                      dbo.tCsCarteraDet ON dbo.tCsCartera.Fecha = dbo.tCsCarteraDet.Fecha AND 
                      dbo.tCsCartera.CodPrestamo = dbo.tCsCarteraDet.CodPrestamo INNER JOIN
                      dbo.tClOficinas ON dbo.tCsCarteraDet.CodOficina = dbo.tClOficinas.CodOficina ON 
                      dbo.tCsPadronClientes.CodUsuario = dbo.tCsCarteraDet.CodUsuario LEFT OUTER JOIN
                      dbo.tCsPadronClientes tCsPadronClientes_1 ON dbo.tCsCarteraDet.CodUsuario = tCsPadronClientes_1.CodUsuario
WHERE     (dbo.tCsCartera.NroDiasAtraso >= 90) AND (dbo.tCsCarteraDet.SaldoCapital > 0)

GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[44] 4[13] 2[26] 3) )"
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
               Top = 0
               Left = 206
               Bottom = 181
               Right = 434
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tClOficinas"
            Begin Extent = 
               Top = 128
               Left = 792
               Bottom = 241
               Right = 982
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCaProducto"
            Begin Extent = 
               Top = 8
               Left = 5
               Bottom = 121
               Right = 195
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsAsesores"
            Begin Extent = 
               Top = 99
               Left = 367
               Bottom = 222
               Right = 557
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tUsReferencias"
            Begin Extent = 
               Top = 164
               Left = 0
               Bottom = 276
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsCarteraDet"
            Begin Extent = 
               Top = 17
               Left = 484
               Bottom = 130
               Right = 674
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsClientes"
            Begin Extent = 
               Top = 268
               Left = 300
               Bottom = 381
               Right = 490
            End
  ', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane2', N'          DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsPadronClientes"
            Begin Extent = 
               Top = 297
               Left = 666
               Bottom = 410
               Right = 856
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsPadronClientes_1"
            Begin Extent = 
               Top = 0
               Left = 710
               Bottom = 113
               Right = 900
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
         Column = 6135
         Alias = 900
         Table = 2280
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 2, 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de proceso', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Prestamo del crédito', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'CodPrestamo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Usuario', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Nombre completo como se 
reporta', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'NombreCompleto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del producto de credito', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'CodProducto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre del Asesor', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'NomAsesor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de grupo, Null si es individual', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'CodGrupo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado del credito segun la parametrizacion del cliente', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto total de desembolso pactado ', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'MontoDesembolso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'días de atraso que tiene el préstamo respecto a la última cuota no pagada. ', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'NroDiasAtraso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Capital', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'SaldoCapital'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo Interes Corriente', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'InteresOrdinario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo Interes Moratorio', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'InteresMoratorio'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Codigo de documento de 
identidad', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'CodDocIden'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Documento de Identidad', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'DI'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'El RUC o R.F.C. del 
usuario.', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'UsRUC'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de Nacimiento', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'FechaNacimiento'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'C=Casado, D=Divorciado, 
S=Soltero, U=Union Libre, V=Viudo', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'CodEstadoCivil'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1=Masc, 0=Feme', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'Sexo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de Ubigeo de la 
dirección principal de domicilio del cliente.', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'CodUbiGeoDirFamPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Detalle de dirección 
principal familiar del cliente.', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'DireccionDirFamPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Teléfono de la dirección 
principal de la familia.', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'TelefonoDirFamPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Código de Ubigeo de la 
dirección principal de negocio del cliente.', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'CodUbiGeoDirNegPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Detalle de dirección 
principaldel negocio del cliente.', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'DireccionDirNegPri'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Teléfono de la dirección 
principal del negocio.', 'SCHEMA', N'dbo', 'VIEW', N'vCallCenterReferencias', 'COLUMN', N'TelefonoDirNegPri'
GO