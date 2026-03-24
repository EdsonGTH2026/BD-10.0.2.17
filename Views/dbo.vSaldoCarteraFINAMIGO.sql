SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vSaldoCarteraFINAMIGO]
AS
SELECT     dbo.tCsCartera.Fecha, dbo.tCsCartera.CodPrestamo, dbo.tCsCartera.CodSolicitud, dbo.tCsCartera.CodOficina, dbo.tClOficinas.NomOficina, 
                      dbo.tCsCartera.CodProducto, dbo.tCsCartera.CodAsesor, dbo.tCsCartera.CodUsuario, dbo.tCsCartera.CodGrupo, dbo.tCsCartera.CodFondo, 
                      dbo.tCsCartera.CodTipoCredito, dbo.tCsCartera.CodDestino, dbo.tCsCartera.Estado, dbo.tCsCartera.Estado AS EstadoConta, 
                      (CASE WHEN dbo.tCsCartera.Estado IN ('2', '3') 
                      THEN 'CASTIGADO' WHEN dbo.tCsCartera.Estado = 'CASTIGADO' THEN 'CARTERA CASTIAGADA' WHEN dbo.tCsCartera.Estado <> 'CASTIGADO' THEN 'CARTERA ACTIVA'
                       END) AS TipoCartera, dbo.tCsCartera.TipoReprog, dbo.tCsCartera.NroCuotas, dbo.tCsCartera.NroCuotasPagadas, dbo.tCsCartera.NroCuotasPorPagar, 
                      dbo.tCsCartera.NrodiasEntreCuotas, dbo.tCsCartera.FechaSolicitud, dbo.tCsCartera.FechaAprobacion, dbo.tCsCartera.FechaDesembolso, 
                      dbo.tCsCartera.FechaVencimiento, dbo.tCsCartera.MontoDesembolso, dbo.tCsCartera.SaldoCapital, dbo.tCsCartera.NroDiasAtraso, 
                      dbo.tCsCartera.SaldoCapitalVencido, dbo.tCsCartera.SaldoINTEVig, dbo.tCsCartera.SaldoINPEVig, dbo.tCsCartera.SaldoINTESus, 
                      dbo.tCsCartera.SaldoINPESus, dbo.tCsCartera.CargoMora, dbo.tCsCartera.SaldoOtrosCargos, dbo.tCsCartera.SaldoINVE, dbo.tCsCartera.SaldoINPE, 
                      dbo.tCsCartera.Calificacion, dbo.tCsCartera.ProvisionCapital, dbo.tCsCartera.ProvisionInteres, dbo.tCsCartera.TotalGarantia, 
                      CASE WHEN dbo.tCsCartera.NroDiasAtraso = 0 THEN 0.01 * dbo.tCsCartera.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 1 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 7 THEN 0.04 * dbo.tCsCartera.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 8 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 30 THEN 0.15 * dbo.tCsCartera.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 31 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 60 THEN 0.30 * dbo.tCsCartera.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 61 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 90 THEN 0.50 * dbo.tCsCartera.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 91 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 120 THEN 0.75 * dbo.tCsCartera.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 121 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 180 THEN 0.90 * dbo.tCsCartera.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 181 THEN 100 / 100 * dbo.tCsCartera.SaldoCapital
                       END AS ProvCapital, 
                      CASE WHEN dbo.tCsCartera.NroDiasAtraso = 0 THEN 0.01 * dbo.tCsCartera.SaldoINTEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 1 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 7 THEN 0.04 * dbo.tCsCartera.SaldoINTEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 8 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 30 THEN 0.15 * dbo.tCsCartera.SaldoINTEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 31 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 60 THEN 0.30 * dbo.tCsCartera.SaldoINTEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 61 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 90 THEN 0.50 * dbo.tCsCartera.SaldoINTEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 91 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 120 THEN 1 * dbo.tCsCartera.SaldoINTEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 121 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 180 THEN 1 * dbo.tCsCartera.SaldoINTEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 181 THEN 100 / 100 * dbo.tCsCartera.SaldoINTEVig
                       END AS ProvInteres, 
                      CASE WHEN dbo.tCsCartera.NroDiasAtraso = 0 THEN 0.01 * dbo.tCsCartera.SaldoINPEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 1 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 7 THEN 0.04 * dbo.tCsCartera.SaldoINPEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 8 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 30 THEN 0.15 * dbo.tCsCartera.SaldoINPEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 31 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 60 THEN 0.30 * dbo.tCsCartera.SaldoINPEVig WHEN dbo.tCsCartera.NroDiasAtraso >= 61 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 90 THEN 0.50 * dbo.tCsCartera.SaldoINPEVig END AS ProvMora
FROM         dbo.tCsCartera INNER JOIN
                      dbo.tClOficinas ON dbo.tCsCartera.CodOficina = dbo.tClOficinas.CodOficina
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
         Configuration = "(H (1[47] 2[15] 3) )"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4[30] 2[40] 3) )"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1[56] 3) )"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2[66] 3) )"
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
         Begin Table = "tCsCartera"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 201
               Right = 266
            End
            DisplayFlags = 280
            TopColumn = 47
         End
         Begin Table = "tClOficinas"
            Begin Extent = 
               Top = 40
               Left = 366
               Bottom = 155
               Right = 556
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
      Begin ColumnWidths = 44
         Width = 284
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
      PaneHidden = 
      Begin Co', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane2', N'lumnWidths = 11
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
', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 2, 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de generacion del saldo', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo Finmas del credito', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodPrestamo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de solicitud', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodSolicitud'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de la oficina donde se genero el credito', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del producto de credito', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodProducto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del asesor principal', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodAsesor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del cliente, Null si es Grupal', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de grupo, Null si es individual', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodGrupo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del fondo al cual pertenece el prestamo', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodFondo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de tipo de credito (1=Comercial; 2=Microcredito; 3=Consumo; 4=Hipotecario)', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodTipoCredito'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del destino que le da el cliente a lcredito', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'CodDestino'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado del credito segun la parametrizacion del cliente', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado del credito segun la parametrizacion del cliente', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'EstadoConta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si es refinanciado o no', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'TipoReprog'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'nro de cuotas del prestamo', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'NroCuotas'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'numero de cuotas pagadas', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'NroCuotasPagadas'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'numero de cuotas por pagar', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'NroCuotasPorPagar'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'numero de dias promedio entre cuotas', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'NrodiasEntreCuotas'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto total de desembolso pactado ', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'MontoDesembolso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de capital a la fecha', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'SaldoCapital'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'días de atraso que tiene el préstamo respecto a la última cuota no pagada. ', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'NroDiasAtraso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo capital de las cuotas con DiasAtraso > x, donde x esta parametrizado segun estado', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'SaldoCapitalVencido'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo que se debo de otros cargos a la fecha', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'SaldoOtrosCargos'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'saldo que se debe de interes compensatorio a la fecha', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'SaldoINVE'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'saldo que se debe de interes moratorio a la fecha', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'SaldoINPE'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Calificacion segun parametrizacion', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'Calificacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de la Provision', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'ProvisionCapital'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'suma de los 2 anteriores', 'SCHEMA', N'dbo', 'VIEW', N'vSaldoCarteraFINAMIGO', 'COLUMN', N'TotalGarantia'
GO