SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
/*Where CodPrestamo in('015-116-06-01-00279', '015-116-06-02-00415', '015-116-06-08-00095')*/
CREATE VIEW [dbo].[vINTFNombre]
AS
SELECT DISTINCT 
                      LTRIM(RTRIM(CodUsuario)) AS CodUsuario, Paterno, CASE WHEN rtrim(Ltrim(Materno)) = '' THEN 'NO PROPORCIONADO' ELSE Materno END AS Materno, Adicional, 
                      Nombre1, LTRIM(RTRIM(Nombre2)) AS Nombre2, Nacimiento, LTRIM(RTRIM(UsRFC)) AS UsRFC, Prefijo, Sufijo, Nacionalidad, Residencia, LicenciaConducir, 
                      EstadoCivil, Sexo, CedulaProfesional, IFE, ImpuestoOtroPais, ClaveOtroPais, NumeroDependientes, EdadesDependientes, DefuncionFecha, DefuncionIndicador
FROM         (SELECT     Tipo, Fecha, CodPrestamo, CodUsuario, Paterno, Materno, Adicional, Nombre1, Nombre2, Nacimiento, UsRFC, Prefijo, Sufijo, Nacionalidad, Residencia, 
                                              LicenciaConducir, EstadoCivil, Sexo, CedulaProfesional, IFE, ImpuestoOtroPais, ClaveOtroPais, NumeroDependientes, EdadesDependientes, 
                                              DefuncionFecha, DefuncionIndicador
                       FROM          dbo.vINTFNombreCartera
                       UNION
                       SELECT     Tipo, Fecha, CodPrestamo, CodUsuario, Paterno, Materno, Adicional, Nombre1, Nombre2, Nacimiento, UsRFC, Prefijo, Sufijo, Nacionalidad, Residencia, 
                                             LicenciaConducir, EstadoCivil, Sexo, CedulaProfesional, IFE, ImpuestoOtroPais, ClaveOtroPais, NumeroDependientes, EdadesDependientes, 
                                             DefuncionFecha, DefuncionIndicador
                       FROM         dbo.vINTFNombreAvales
                       UNION
                       SELECT     Tipo, Fecha, CodPrestamo, CodUsuario, Paterno, Materno, Adicional, Nombre1, Nombre2, Nacimiento, UsRFC, Prefijo, Sufijo, Nacionalidad, Residencia, 
                                             LicenciaConducir, EstadoCivil, Sexo, CedulaProfesional, IFE, ImpuestoOtroPais, ClaveOtroPais, NumeroDependientes, EdadesDependientes, 
                                             DefuncionFecha, DefuncionIndicador
                       FROM         dbo.vINTFNombreCancelados
                       UNION
                       SELECT     Tipo, Fecha, CodPrestamo, CodUsuario, Paterno, Materno, Adicional, Nombre1, Nombre2, Nacimiento, UsRFC, Prefijo, Sufijo, Nacionalidad, Residencia, 
                                             LicenciaConducir, EstadoCivil, Sexo, CedulaProfesional, IFE, ImpuestoOtroPais, ClaveOtroPais, NumeroDependientes, EdadesDependientes, 
                                             DefuncionFecha, DefuncionIndicador
                       FROM         dbo.vINTFNombreCodeudores) AS Datos
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[29] 4[4] 2[49] 3) )"
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
               Bottom = 119
               Right = 228
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
', 'SCHEMA', N'dbo', 'VIEW', N'vINTFNombre'
GO

EXEC sys.sp_addextendedproperty N'MS_DiagramPaneCount', 1, 'SCHEMA', N'dbo', 'VIEW', N'vINTFNombre'
GO