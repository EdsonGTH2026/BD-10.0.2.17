SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsPatmirActualizaLoc
CREATE PROCEDURE [dbo].[pCsPatmirActualizaLoc]
AS
--CORRE EN CONSOLIDADO (17)
DECLARE @tUsuLoc TABLE (CodUsuario   CHAR(15),
                        CodLocalidad CHAR(15),
                        FechaIngreso SMALLDATETIME)
INSERT INTO @tUsuLoc 
--PROCESO PARA ACTULIZAR LA LOCALIDAD PATMIR EN EL CONSOLIDADO, DE UN DIA ANTERIOR
SELECT DISTINCT d.CodUsuario, d.CodLocalidad, u.FechaIngreso
  FROM [10.0.2.14].Finmas.dbo.tUsUsuarios u, [10.0.2.14].Finmas.dbo.tUsUsuarioDireccion d 
 WHERE u.CodUsuario = d.CodUsuario
   --AND u.FechaIngreso >= getdate()-1 --DEFINIR CUANTOS DIAS ATRÁS SE EJECUTARÁ EL PROCESO
   AND d.CodLocalidad IS NOT NULL
   AND d.CodLocalidad <> ''
 union all
--PROCESO PARA ACTULIZAR LOS CAMBIOS EN LA LOCALIDAD PATMIR 
SELECT f.CodUsuario, f.CodLocalidad, GETDATE() FechaIngreso --c.CodOrigen, 
       --f.CodLocalidad, c.LocPatmir --Campo Localidad Patmir en tcspadronclientes
  FROM [10.0.2.14].Finmas.dbo.tUsUsuarioDireccion f, tcspadronclientes c 
 WHERE f.CodUsuario    = c.CodOrigen 
   AND f.CodLocalidad IS NOT NULL
   AND f.CodLocalidad <> ''  
   AND f.CodLocalidad <> c.LocPatmir   
--select * from @tUsuLoc
--ACTUALIZA LOCALIDAD PATMIR
UPDATE c
   SET c.LocPatmir = f.CodLocalidad 
  FROM @tUsuLoc f , tcspadronclientes c 
 WHERE f.CodUsuario = c.CodOrigen 
 
 
   

  




  
   
GO