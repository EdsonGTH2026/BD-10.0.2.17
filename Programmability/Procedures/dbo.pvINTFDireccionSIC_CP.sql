SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pvINTFDireccion  
--CREATE view [dbo].[vINTFDireccionVr14]  
--as  
--00:01:24  
CREATE procedure [dbo].[pvINTFDireccionSIC_CP]  
as  

truncate table tCsTblDireccionesCP  
insert into tCsTblDireccionesCP  

SELECT DISTINCT   
Datos.CodUsuario,   
--replace(Replace(Datos.Direccion1, '  ', ' '),'SIN NUMERO','SN') AS Direccion1,   
--SUBSTRING(Replace(Datos.Direccion1, '  ', ' '), T.D1 + 1, T.D2) AS Direccion2,   
  
left(replace(Datos.Direccion1,' SN SN',' SN') ,40) AS Direccion1,   
SUBSTRING(replace(Datos.Direccion1,' SN SN',' SN'), 40 + 1, T.D2) AS Direccion2,  
replace(Datos.Direccion1,' SN SN',' SN') as x,  
--Datos.Direccion1 as x,   
Datos.Colonia, Datos.Municipio, Datos.Ciudad, Datos.Estado, Datos.CodigoPostal, Datos.FechaResidencia, Datos.Telefono, Datos.Extencion, Datos.Fax, Datos.Tipo,   
Datos.Indicador, Datos.CodUbigeo,OrigenDomicilio  
--into tCsTblDirecciones  
FROM (SELECT     CodUsuario,   
      CASE WHEN CHARINDEX('0', Direccion1, 1) + CHARINDEX('1', Direccion1, 1) + CHARINDEX('2', Direccion1, 1) + CHARINDEX('3', Direccion1, 1)   
      + CHARINDEX('4', Direccion1, 1) + CHARINDEX('5', Direccion1, 1) + CHARINDEX('6', Direccion1, 1) + CHARINDEX('7', Direccion1, 1) + CHARINDEX('8',   
      Direccion1, 1) + CHARINDEX('9', Direccion1, 1) + CHARINDEX(' SIN NUMERO', Direccion1, 1) = 0 AND Substring(Ltrim(Rtrim(Direccion1)), 41, 500)   
      = '' THEN Direccion1 + ' SN'   
           ELSE Direccion1   
      END AS Direccion1,   
      Colonia, Municipio, Ciudad, Estado, CodigoPostal, FechaResidencia,   
      Telefono, Extencion, Fax, Tipo, Indicador, CodUbigeo,OrigenDomicilio  
      FROM (  
    SELECT datos.CodUsuario, Replace(CASE WHEN CHARINDEX(' ', REPLACE(REPLACE(LTRIM(RTRIM(datos.Direccion1)), '  ', ' '), '.', ''), 1) > 0   
    THEN REPLACE(REPLACE(LTRIM(RTRIM(datos.Direccion1)), '  ', ' '), '.', '')   
    ELSE REPLACE(REPLACE(LTRIM(RTRIM(datos.Direccion1)), '  ', ' '), '.', '') + ' SN' END, '/', '') AS Direccion1  
    ,datos.Colonia, datos.Municipio, datos.Ciudad, datos.Estado, datos.CodigoPostal, datos.FechaResidencia  
    ,datos.Telefono, datos.Extencion, datos.Fax, datos.Tipo, datos.Indicador,datos.CodUbigeo,datos.OrigenDomicilio  
    FROM (  
     SELECT     *  
     FROM vINTFDireccionFamiliarVr14CP  with(nolock)  
     UNION  
     SELECT     *  
     FROM vINTFDireccionNegocioVr14CP  with(nolock)  
    ) Datos  
    inner join (  
     select codusuario,max(tipo) tipo  
     from (  
      SELECT     codusuario,tipo  
      FROM vINTFDireccionFamiliarVr14CP  with(nolock)  
      UNION  
      SELECT     codusuario,tipo  
      FROM vINTFDireccionNegocioVr14CP  with(nolock)  
     ) x  
     --where  codusuario='15FCS0301891'  
     group by  codusuario  
    ) y on y.codusuario=datos.codusuario and y.tipo=datos.tipo--> para filtrar solo una direccion  
   )   
   Datos  
 ) Datos   
     CROSS JOIN  
     (SELECT SUM(D1) AS D1, SUM(D2) AS D2  
      FROM (SELECT CASE campodato WHEN 'Direccion1' THEN Tamaño ELSE 0 END AS D1,   
            CASE campodato WHEN 'Direccion2' THEN Tamaño ELSE 0 END AS D2  
            FROM tRcArchivoFragmento with(nolock)  
            WHERE (EstructuraArchivo = 3) AND (CampoDato IN ('Direccion2', 'Direccion1'))) Datos) T  
GO