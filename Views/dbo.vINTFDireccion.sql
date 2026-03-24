SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE VIEW [dbo].[vINTFDireccion]
AS
SELECT DISTINCT 
                      Datos.CodUsuario, Replace(Datos.Direccion1, '  ', ' ') AS Direccion1, SUBSTRING(Replace(Datos.Direccion1, '  ', ' '), T.D1 + 1, T.D2) AS Direccion2, 
                      Datos.Colonia, Datos.Municipio, Datos.Ciudad, Datos.Estado, Datos.CodigoPostal, Datos.FechaResidencia, Datos.Telefono, Datos.Extencion, Datos.Fax, Datos.Tipo, 
                      Datos.Indicador, Datos.CodUbigeo
FROM         (SELECT     CodUsuario, CASE WHEN CHARINDEX('0', Direccion1, 1) + CHARINDEX('1', Direccion1, 1) + CHARINDEX('2', Direccion1, 1) + CHARINDEX('3', Direccion1, 1) 
                                              + CHARINDEX('4', Direccion1, 1) + CHARINDEX('5', Direccion1, 1) + CHARINDEX('6', Direccion1, 1) + CHARINDEX('7', Direccion1, 1) + CHARINDEX('8', 
                                              Direccion1, 1) + CHARINDEX('9', Direccion1, 1) + CHARINDEX(' SIN NUMERO', Direccion1, 1) = 0 AND Substring(Ltrim(Rtrim(Direccion1)), 41, 500) 
                                              = '' THEN Direccion1 + ' SIN NUMERO' ELSE Direccion1 END AS Direccion1, Colonia, Municipio, Ciudad, Estado, CodigoPostal, FechaResidencia, 
                                              Telefono, Extencion, Fax, Tipo, Indicador, CodUbigeo
                       FROM          (SELECT     CodUsuario, Replace(CASE WHEN CHARINDEX(' ', REPLACE(REPLACE(LTRIM(RTRIM(Direccion1)), '  ', ' '), '.', ''), 1) 
                                                                      > 0 THEN REPLACE(REPLACE(LTRIM(RTRIM(Direccion1)), '  ', ' '), '.', '') ELSE REPLACE(REPLACE(LTRIM(RTRIM(Direccion1)), '  ', ' '), '.', '') + ' SN' END, '/', '') AS Direccion1, 
					Colonia, Municipio, Ciudad, Estado, CodigoPostal, FechaResidencia, Telefono, Extencion, Fax, Tipo, 
                                                                      Indicador, CodUbigeo
                                               FROM          (SELECT     *
                                                                       FROM          vINTFDireccionFamiliar
                                                                       UNION
                                                                       SELECT     *
                                                                       FROM         vINTFDireccionNegocio) Datos) Datos) Datos CROSS JOIN
                          (SELECT     SUM(D1) AS D1, SUM(D2) AS D2
                            FROM          (SELECT     CASE campodato WHEN 'Direccion1' THEN Tamaño ELSE 0 END AS D1, 
                                                                           CASE campodato WHEN 'Direccion2' THEN Tamaño ELSE 0 END AS D2
                                                    FROM          tRcArchivoFragmento
                                                    WHERE      (EstructuraArchivo = 3) AND (CampoDato IN ('Direccion2', 'Direccion1'))) Datos) T









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
               Top = 2
               Left = 111
               Bottom = 238
               Right = 301
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
', 'SCHEMA', N'dbo', 'VIEW', N'vINTFDireccion'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vINTFDireccion'
GO