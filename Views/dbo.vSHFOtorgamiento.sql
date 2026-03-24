SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vSHFOtorgamiento]
AS
SELECT     dbo.fduFechaATexto(dbo.tSHFOtorgamiento.ReporteInicio, 'AAAA') + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.ReporteInicio, 'MM') 
                      + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.ReporteInicio, 'DD') + 'T00:00:00:00' AS ReporteInicio, dbo.fduFechaATexto(dbo.tSHFOtorgamiento.ReporteFin, 
                      'AAAA') + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.ReporteFin, 'MM') + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.ReporteFin, 'DD') 
                      + 'T00:00:00:00' AS ReporteFin, dbo.tSHFOtorgamiento.Emisor, dbo.tSHFOtorgamiento.LineaNegocio, dbo.tSHFOtorgamiento.TipoTransaccion, 
                      dbo.tSHFOtorgamiento.TipoEnvio, dbo.tSHFOtorgamiento.idLineaCredito, dbo.tSHFOtorgamiento.Originador, dbo.tSHFOtorgamiento.CodPrestamo, 
                      dbo.tSHFOtorgamiento.SolucionVivienda, LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.Monto, 18, 2))) AS Monto, dbo.tSHFOtorgamiento.Divisa, 
                      dbo.tSHFOtorgamiento.Frecuencia, LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.MontoPago, 18, 2))) AS MontoPago, 
                      dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Desembolso, 'AAAA') + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Desembolso, 'MM') 
                      + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Desembolso, 'DD') + 'T00:00:00:00' AS Desembolso, dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Mininistracion, 
                      'AAAA') + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Mininistracion, 'MM') + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Mininistracion, 'DD') 
                      + 'T00:00:00:00' AS Mininistracion, dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Vencimiento, 'AAAA') + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Vencimiento, 
                      'MM') + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Vencimiento, 'DD') + 'T00:00:00:00' AS Vencimiento, dbo.tSHFOtorgamiento.Destino, 
                      dbo.tSHFOtorgamiento.Plazo, dbo.tSHFOtorgamiento.cveIC, LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.valIC, 18, 2))) AS ValIC, dbo.tSHFOtorgamiento.cveIM, 
                      LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.valIM, 18, 2))) AS ValIM, dbo.tSHFOtorgamiento.cveCA, LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.valCA, 18, 2))) AS valCA, 
                      dbo.tSHFOtorgamiento.cveCM, LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.valCM, 18, 2))) AS valCM, dbo.tSHFOtorgamiento.Nombres, dbo.tSHFOtorgamiento.Paterno, 
                      dbo.tSHFOtorgamiento.Materno, dbo.tSHFOtorgamiento.Genero, dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Nacimiento, 'AAAA') 
                      + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Nacimiento, 'MM') + '-' + dbo.fduFechaATexto(dbo.tSHFOtorgamiento.Nacimiento, 'DD') 
                      + 'T00:00:00:00' AS Nacimiento, dbo.tSHFOtorgamiento.EstadoCivil, dbo.tSHFOtorgamiento.Estudios, dbo.tSHFOtorgamiento.Dependientes, 
                      dbo.tSHFOtorgamiento.TipoPropeidad AS TipoPropiedad, dbo.tSHFOtorgamiento.Antiguedad, dbo.tSHFOtorgamiento.Municipio, dbo.tSHFOtorgamiento.TipoEmpleo, 
                      LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.Ingresos, 18, 2))) AS Ingresos, LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.DeudaTotal, 18, 2))) AS DeudaTotal, 
                      LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.IngresosConyuge, 18, 2))) AS IngresosConyuge, LTRIM(RTRIM(STR(dbo.tSHFOtorgamiento.DeudaConyuge, 18, 2))) 
                      AS DeudaConyuge
FROM         dbo.tSHFOtorgamiento INNER JOIN
                      dbo.tSHFPeriodo ON dbo.tSHFOtorgamiento.ReporteInicio = dbo.tSHFPeriodo.ReporteInicio AND 
                      dbo.tSHFOtorgamiento.ReporteFin = dbo.tSHFPeriodo.ReporteFin
WHERE     (dbo.tSHFPeriodo.Activo = 1)
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[41] 2[31] 3) )"
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
         Begin Table = "tSHFOtorgamiento"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 230
               Right = 228
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tSHFPeriodo"
            Begin Extent = 
               Top = 6
               Left = 266
               Bottom = 238
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
         Alias = 1920
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
', 'SCHEMA', N'dbo', 'VIEW', N'vSHFOtorgamiento'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vSHFOtorgamiento'
GO