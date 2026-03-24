SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop proc pCsAhLocalidadesElejibles
CREATE PROCEDURE [dbo].[pCsAhLocalidadesElejibles] @estado varchar(5),@municipio varchar(5)  
AS  
BEGIN  
 SET NOCOUNT ON;  
  
  SELECT Nombre_Entidad,Clave_Municipio,Nombre_Municipio,Clave_Localidad,Nombre_Localidad,Poblacion_Total, Segmento, Marginalidad  
  FROM tclUbigeoSITI  
  where clave_entidad=@estado and clave_municipio=@municipio  
END  

GO