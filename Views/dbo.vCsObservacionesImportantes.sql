SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vCsObservacionesImportantes]
AS
SELECT        tCsClientesObservaciones_1.Observacion, tCsClientesObservaciones_1.Fecha, tCsClientesObservaciones_1.CodUsuario, Filtro.CodOficina, 
                         tCsClientesObservaciones_1.CodCuenta, tCsClientesObservaciones_1.CodPrestamo, tCsClientesObservaciones_1.Detalle, tCsClientesObservaciones_1.Prioridad, 
                         tCsClientesObservaciones_1.ROrigen, tCsClientesObservaciones_1.RAhorros, tCsClientesObservaciones_1.RCreditos, tCsClientesObservaciones_1.Responsable, 
                         dbo.tCsPadronClientes.CodOrigen
FROM            (SELECT        Datos_1.Fecha, MIN(Datos_1.CodUsuario) AS CodUsuario, Datos_1.CodOficina, Datos_1.Prioridad, Datos_1.Observacion
                          FROM            (SELECT        Datos_2.Fecha, Datos_2.Prioridad, Datos_2.CodOficina, MIN(Datos_2.Observacion) AS Observacion
                                                    FROM            (SELECT        Fecha, CodOficina, MIN(Prioridad) AS Prioridad
                                                                              FROM            (SELECT DISTINCT 
                                                                                                                                  dbo.tCsClientesObservaciones.Fecha, dbo.tCsClientesObservaciones.CodUsuario, 
                                                                                                                                  ISNULL(ISNULL(dbo.tCsClientesObservaciones.OCreditos, dbo.tCsClientesObservaciones.OAhorros), 
                                                                                                                                  dbo.tCsClientesObservaciones.OOrigen) AS CodOficina, dbo.tCsClientesObservaciones.Prioridad, 
                                                                                                                                  dbo.tCsClientesObservaciones.Observacion
                                                                                                        FROM            dbo.tCsClientesObservaciones INNER JOIN
                                                                                                                                  dbo.tCsClClientesObservaciones ON 
                                                                                                                                  dbo.tCsClientesObservaciones.Observacion = dbo.tCsClClientesObservaciones.Observacion
                                                                                                        WHERE        (dbo.tCsClientesObservaciones.Fecha IN
                                                                                                                                      (SELECT        MAX(Fecha) AS Fecha
                                                                                                                                        FROM            dbo.tCsClientesObservaciones AS tCsClientesObservaciones_6)) AND 
                                                                                                                                  (dbo.tCsClClientesObservaciones.ActivoCierreOperativo = 1)) AS Datos
                                                                              GROUP BY Fecha, CodOficina) AS Corte INNER JOIN
                                                                                  (SELECT DISTINCT 
                                                                                                              tCsClientesObservaciones_3.Fecha, tCsClientesObservaciones_3.CodUsuario, 
                                                                                                              ISNULL(ISNULL(tCsClientesObservaciones_3.OCreditos, tCsClientesObservaciones_3.OAhorros), 
                                                                                                              tCsClientesObservaciones_3.OOrigen) AS CodOficina, tCsClientesObservaciones_3.Prioridad, 
                                                                                                              tCsClientesObservaciones_3.Observacion
                                                                                    FROM            dbo.tCsClientesObservaciones AS tCsClientesObservaciones_3 INNER JOIN
                                                                                                              dbo.tCsClClientesObservaciones AS tCsClClientesObservaciones_2 ON 
                                                                                                              tCsClientesObservaciones_3.Observacion = tCsClClientesObservaciones_2.Observacion
                                                                                    WHERE        (tCsClientesObservaciones_3.Fecha IN
                                                                                                                  (SELECT        MAX(Fecha) AS Fecha
                                                                                                                    FROM            dbo.tCsClientesObservaciones AS tCsClientesObservaciones_6)) AND 
                                                                                                              (tCsClClientesObservaciones_2.ActivoCierreOperativo = 1)) AS Datos_2 ON Corte.Fecha = Datos_2.Fecha AND 
                                                                              Corte.CodOficina = Datos_2.CodOficina AND Corte.Prioridad = Datos_2.Prioridad
                                                    GROUP BY Datos_2.Fecha, Datos_2.Prioridad, Datos_2.CodOficina) AS Filtro_1 INNER JOIN
                                                        (SELECT DISTINCT 
                                                                                    tCsClientesObservaciones_2.Fecha, tCsClientesObservaciones_2.CodUsuario, ISNULL(ISNULL(tCsClientesObservaciones_2.OCreditos, 
                                                                                    tCsClientesObservaciones_2.OAhorros), tCsClientesObservaciones_2.OOrigen) AS CodOficina, tCsClientesObservaciones_2.Prioridad, 
                                                                                    tCsClientesObservaciones_2.Observacion
                                                          FROM            dbo.tCsClientesObservaciones AS tCsClientesObservaciones_2 INNER JOIN
                                                                                    dbo.tCsClClientesObservaciones AS tCsClClientesObservaciones_1 ON 
                                                                                    tCsClientesObservaciones_2.Observacion = tCsClClientesObservaciones_1.Observacion
                                                          WHERE        (tCsClientesObservaciones_2.Fecha IN
                                                                                        (SELECT        MAX(Fecha) AS Fecha
                                                                                          FROM            dbo.tCsClientesObservaciones AS tCsClientesObservaciones_6)) AND 
                                                                                    (tCsClClientesObservaciones_1.ActivoCierreOperativo = 1)) AS Datos_1 ON Filtro_1.Fecha = Datos_1.Fecha AND 
                                                    Filtro_1.Prioridad = Datos_1.Prioridad AND Filtro_1.CodOficina = Datos_1.CodOficina AND Filtro_1.Observacion = Datos_1.Observacion
                          GROUP BY Datos_1.Fecha, Datos_1.CodOficina, Datos_1.Prioridad, Datos_1.Observacion) AS Filtro INNER JOIN
                         dbo.tCsClientesObservaciones AS tCsClientesObservaciones_1 ON Filtro.Fecha = tCsClientesObservaciones_1.Fecha AND 
                         Filtro.Observacion = tCsClientesObservaciones_1.Observacion AND 
                         Filtro.CodUsuario COLLATE Modern_Spanish_CI_AI = tCsClientesObservaciones_1.CodUsuario AND 
                         Filtro.Prioridad = tCsClientesObservaciones_1.Prioridad INNER JOIN
                         dbo.tCsPadronClientes ON tCsClientesObservaciones_1.CodUsuario = dbo.tCsPadronClientes.CodUsuario
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[23] 4[5] 2[53] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
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
         Configuration = "(H (1[56] 4[18] 2) )"
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
         Begin Table = "tCsClientesObservaciones_1"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 135
               Right = 416
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "tCsPadronClientes"
            Begin Extent = 
               Top = 6
               Left = 454
               Bottom = 135
               Right = 661
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Filtro"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 135
               Right = 208
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
', 'SCHEMA', N'dbo', 'VIEW', N'vCsObservacionesImportantes'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vCsObservacionesImportantes'
GO