SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
 /****** Object:  View dbo.vINTFNombreVr14CP    Script Date: 08/03/2023 09:06:02 pm ******/  
  
CREATE VIEW [dbo].[vINTFNombreVr14CP]  
AS  
SELECT DISTINCT   
      RTRIM(CodUsuario) AS CodUsuario, Paterno, CASE WHEN rtrim(Ltrim(Materno)) = '' THEN 'NO PROPORCIONADO' ELSE Materno END AS Materno,   
      Adicional, Nombre1, LTRIM(RTRIM(Nombre2)) AS Nombre2, Nacimiento, LTRIM(RTRIM(UsRFC)) AS UsRFC, Prefijo, Sufijo, Nacionalidad, Residencia,   
      LicenciaConducir, EstadoCivil, Sexo, CedulaProfesional, IFE,  
CURP,  
ClaveOtroPais, NumeroDependientes, EdadesDependientes,   
      DefuncionFecha, DefuncionIndicador, CodPrestamo  
FROM (  
 SELECT * FROM FinamigoConsolidado.dbo.tCsBuroxTblReInomVr14CP with(nolock)  
) Datos  
  
  
GO