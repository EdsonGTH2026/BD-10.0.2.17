SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCarteradetalleFINAMIGO]
AS
SELECT     dbo.tCsCartera01.Fecha, 1 AS Cantidad, dbo.tCsCartera01.CodPrestamo, dbo.tCsCartera01.CodUsuario, dbo.tCsCartera01.CodOficina, 
                      dbo.tCsCartera.CodProducto, dbo.tCsCartera.CodGrupo, dbo.tCsCartera.Estado, (CASE WHEN dbo.tCsCartera.Estado IN ('2', '3') 
                      THEN 'CASTIGADO' WHEN dbo.tCsCartera.Estado = 'CASTIGADO' THEN 'CARTERA CASTIAGADA' WHEN dbo.tCsCartera.Estado <> 'CASTIGADO' THEN 'CARTERA ACTIVA'
                       END) AS TIPOCARTERA, dbo.tCsCartera.TipoReprog, dbo.tCsCartera.NroDiasCredito, dbo.tCsCartera.NroCuotas, dbo.tCsCartera.NroCuotasPagadas, 
                      dbo.tCsCartera.NroCuotasPorPagar, dbo.tCsCartera.FechaSolicitud, dbo.tCsCartera.FechaDesembolso, dbo.tCsCartera.FechaVencimiento, 
                      dbo.tCsCartera.MontoDesembolso, dbo.tCsCartera.NroDiasAtraso, dbo.tCsCartera01.SaldoCapital, CASE WHEN (dbo.tCsCartera.NroDiasAtraso < 90 AND
                       dbo.tCsCartera.Estado = 'VIGENTE') THEN dbo.tCsCartera01.SaldoCapital END AS SaldoCapiVigente, 
                      CASE WHEN (dbo.tCsCartera.NroDiasAtraso >= 90 OR
                      dbo.tCsCartera.Estado = 'VENCIDO DE 90 DIAS ADELAN') THEN dbo.tCsCartera01.SaldoCapital END AS SaldoCapiVencido, 
                      CASE WHEN (dbo.tCsCartera.NroDiasAtraso < 90 AND dbo.tCsCartera.Estado = 'VIGENTE') 
                      THEN dbo.tCsCartera01.SaldoINTEVIG END AS InteresOrdinVig, CASE WHEN (dbo.tCsCartera.NroDiasAtraso < 90 AND 
                      dbo.tCsCartera.Estado = 'VIGENTE') THEN dbo.tCsCartera01.SaldoINPEVIG END AS InteresPenalVig, CASE WHEN (dbo.tCsCartera.NroDiasAtraso >= 90) 
                      THEN dbo.tCsCartera01.SaldoINTEVIG END AS InteresOrdinVenc, CASE WHEN (dbo.tCsCartera.NroDiasAtraso >= 90) 
                      THEN dbo.tCsCartera01.SaldoINPEVIG END AS InteresPenalVenc, CASE WHEN (dbo.tCsCartera.NroDiasAtraso >= 90 AND 
                      dbo.tCsCartera.Estado = 'VENCIDO DE 90 DIAS ADELAN') THEN dbo.tCsCartera01.SaldoINTESus END AS InteresOrdinSusp, 
                      CASE WHEN (dbo.tCsCartera.NroDiasAtraso >= 90 AND dbo.tCsCartera.Estado = 'VENCIDO DE 90 DIAS ADELAN') 
                      THEN dbo.tCsCartera01.SaldoINPESus END AS InteresPenalSusp, CASE WHEN (dbo.tCsCartera.Estado = 'CASTIGADO') 
                      THEN dbo.tCsCartera01.SaldoCapital END AS SaldoCapiCastigado, CASE WHEN (dbo.tCsCartera.NroDiasAtraso < 90) 
                      THEN dbo.tCsCartera01.SaldoINPEVIG END AS Expr2, dbo.tCsCartera.Calificacion, dbo.tCsCartera.TasaIntCorriente, dbo.tCsCartera.TasaINPE, 
                      dbo.tCsCartera.CodFondo, dbo.tCsCartera.CodTipoCredito, dbo.tCsCartera.CodDestino, dbo.tCsCartera.CargoMora, dbo.tCsCartera01.SaldoOtrosCargos, 
                      dbo.tCsCartera01.TipoCalificacion, dbo.tCsCartera01.SaldoCargoMora, dbo.tCsCartera01.INTEDevDia, dbo.tCsCartera01.INPEDevDia, 
                      dbo.tCaClCalificacion.DescCalificacion, 
                      CASE WHEN dbo.tCsCartera.NroDiasAtraso = 0 THEN 0.01 * dbo.tCsCartera01.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 1 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 7 THEN 0.04 * dbo.tCsCartera01.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 8 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 30 THEN 0.15 * dbo.tCsCartera01.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 31 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 60 THEN 0.30 * dbo.tCsCartera01.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 61 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 90 THEN 0.50 * dbo.tCsCartera01.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 91 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 120 THEN 0.75 * dbo.tCsCartera01.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 121 AND 
                      dbo.tCsCartera.NroDiasAtraso <= 180 THEN 0.90 * dbo.tCsCartera01.SaldoCapital WHEN dbo.tCsCartera.NroDiasAtraso >= 181 THEN 100 / 100 * dbo.tCsCartera01.SaldoCapital
                       END AS ProvCapital
FROM         dbo.tCsCartera01 LEFT OUTER JOIN
                      dbo.tCsCartera INNER JOIN
                      dbo.tCaClCalificacion ON dbo.tCsCartera.Calificacion = dbo.tCaClCalificacion.CodCalificacion ON dbo.tCsCartera01.Fecha = dbo.tCsCartera.Fecha AND 
                      dbo.tCsCartera01.CodPrestamo = dbo.tCsCartera.CodPrestamo
WHERE     (dbo.tCsCartera01.SaldoCapital > 0) AND (dbo.tCsCartera.Fecha = '20080130') AND (dbo.tCsCartera.Estado <> 'CASTIGADO')
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[22] 4[9] 2[19] 3) )"
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
         Begin Table = "tCsCartera01"
            Begin Extent = 
               Top = 4
               Left = 154
               Bottom = 119
               Right = 347
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsCartera"
            Begin Extent = 
               Top = 0
               Left = 469
               Bottom = 115
               Right = 697
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCaClCalificacion"
            Begin Extent = 
               Top = 6
               Left = 763
               Bottom = 121
               Right = 953
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
      Begin ColumnWidths = 45
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
         Width =', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane2', N' 1440
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 2, 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de proceso', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Prestamo del crédito', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'CodPrestamo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de Usuario', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del producto de credito', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'CodProducto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de grupo, Null si es individual', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'CodGrupo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado del credito segun la parametrizacion del cliente', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si es refinanciado o no', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'TipoReprog'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de vencimiento  menos fecha de aprobacion (en dias)', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'NroDiasCredito'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'nro de cuotas del prestamo', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'NroCuotas'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'numero de cuotas pagadas', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'NroCuotasPagadas'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'numero de cuotas por pagar', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'NroCuotasPorPagar'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'monto total de desembolso pactado ', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'MontoDesembolso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'días de atraso que tiene el préstamo respecto a la última cuota no pagada. ', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'NroDiasAtraso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Capital', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'SaldoCapital'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Interes Vigente', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'InteresOrdinVig'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo de Interes Moratorio Vigente', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'InteresPenalVig'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Calificacion segun parametrizacion', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'Calificacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'tasa de interes corriente anual', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'TasaIntCorriente'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'tasa de interes moratorio anual', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'TasaINPE'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del fondo al cual pertenece el prestamo', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'CodFondo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de tipo de credito (1=Comercial; 2=Microcredito; 3=Consumo; 4=Hipotecario)', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'CodTipoCredito'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo del destino que le da el cliente a lcredito', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'CodDestino'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo por otros Cargos', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'SaldoOtrosCargos'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Tipo de Calificación', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'TipoCalificacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Saldo por cargos en Mora', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'SaldoCargoMora'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Interes Devengado del dia', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'INTEDevDia'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Interes Moratorio Devengado del dia', 'SCHEMA', N'dbo', 'VIEW', N'vCarteradetalleFINAMIGO', 'COLUMN', N'INPEDevDia'
GO