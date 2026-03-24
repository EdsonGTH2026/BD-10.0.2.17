SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop View vCsResponsables  
  
Create View [dbo].[vCsResponsables]  
As  
SELECT        tClOficinas.CodOficina, GA.GerenteAgencia, CO.CoordinadorOperaciones, CA.AsesorAhorros  
FROM            (SELECT        OD AS CodOficina, LTRIM(RTRIM(SUBSTRING(MAX(AsesorAhorros), 2, 100))) AS AsesorAhorros  
                          FROM            (SELECT        Datos.CodUsuario, Datos.CodOficina, CAST(Datos.Peso + ISNULL(Datos.Estado, 0) AS Varchar(1))   
                                                                              + Datos.NombreCompleto AS AsesorAhorros, Datos.OficinaEmpleado, Datos.CodPuesto, Datos.Descripcion, Datos.Peso, Datos.OD,   
                                                                              Datos.Estado  
                                                    FROM            (SELECT        Datos_3.CodUsuario, tUsUsuarios.CodOficina, tUsUsuarios.NombreCompleto, tCsEmpleados.CodOficina AS OficinaEmpleado,   
                                                                                                        tCsEmpleados.CodPuesto, tCsClPuestos.Descripcion, CASE CodPuesto WHEN '4' THEN 1 ELSE 0 END AS Peso,   
                                                                                                        CASE WHEN ltrim(rtrim(isnull(tCsEmpleados.CodOficina, tUsUsuarios.CodOficina)))   
                                                                                                        = '' THEN tUsUsuarios.CodOficina ELSE ltrim(rtrim(isnull(tCsEmpleados.CodOficina, tUsUsuarios.CodOficina))) END AS OD,   
                                                                                                        tCsEmpleados.Estado  
                                                                              FROM            (SELECT        CURP, RFC, Paterno, Materno, Nombres, Nacimiento, Ingreso, Salida, Codusuario, CodOficina,   
                                                                                                                                  Correo, CopiaCorreo, DataNegocio, CodEmpleado, CodOficinaNom, CodPuesto, Estado, CE, Domicilio, Ubicacion,   
                                                                                                                                  Tiempo, EstadoCivil, Escolaridad, TipoPropiedad, Celular  
                                                                                                        FROM            tCsEmpleados AS tCsEmpleados_2  
                                                                                                        WHERE        (Estado = 1)) AS tCsEmpleados INNER JOIN  
                                                                                                        tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN  
                                                                                                        tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo RIGHT OUTER JOIN  
                                                                                                            (SELECT DISTINCT ISNULL(tSgComitesMiembros.CodUsuario, tSgAutorizaciones.CodUsAutoriza) AS CodUsuario  
                                                                                                              FROM            [10.0.2.14].Finmas.dbo.tSgComitesMiembros AS tSgComitesMiembros RIGHT OUTER JOIN  
                                                                                                                                        [10.0.2.14].Finmas.dbo.tSgAutorizaciones AS tSgAutorizaciones ON   
                                                                                                                                        tSgComitesMiembros.CodComite = tSgAutorizaciones.CodComite  
                                                                                                              WHERE        (tSgAutorizaciones.CodAutoriza IN ('AH-023', 'AH-027', 'AH-045'))) AS Datos_3 INNER JOIN  
                                                                                                        [10.0.2.14].Finmas.dbo.tUsUsuarios AS tUsUsuarios ON Datos_3.CodUsuario = tUsUsuarios.CodUsuario ON   
                                                                                                        tCsPadronClientes.CodOrigen = tUsUsuarios.CodUsuario) AS Datos INNER JOIN  
                                                                                  (SELECT        OD, CASE WHEN SUM(Peso) > 1 THEN 1 ELSE SUM(Peso) END AS Peso  
                                                                                    FROM            (SELECT        Datos_1.CodUsuario, tUsUsuarios.CodOficina, tUsUsuarios.NombreCompleto,   
                                                                                                                                        tCsEmpleados_3.CodOficina AS OficinaEmpleado, tCsEmpleados_3.CodPuesto, tCsClPuestos_1.Descripcion,   
                                                                                                                                        CASE CodPuesto WHEN '4' THEN 1 ELSE 0 END AS Peso,   
                                                                                                                                        CASE WHEN ltrim(rtrim(isnull(tCsEmpleados_3.CodOficina, tUsUsuarios.CodOficina)))   
                                                                                                                                        = '' THEN tUsUsuarios.CodOficina ELSE ltrim(rtrim(isnull(tCsEmpleados_3.CodOficina, tUsUsuarios.CodOficina)))   
                                                                                                                                        END AS OD, tCsEmpleados_3.Estado  
                                                                                                              FROM            (SELECT        CURP, RFC, Paterno, Materno, Nombres, Nacimiento, Ingreso, Salida,   
                                                                                                                                                                  Codusuario, CodOficina, Correo, CopiaCorreo, DataNegocio, CodEmpleado, CodOficinaNom,   
                                                                                                                                                                  CodPuesto, Estado, CE, Domicilio, Ubicacion, Tiempo, EstadoCivil, Escolaridad, TipoPropiedad,
   
                                                                                                                                                                  Celular  
                                                                                                                                        FROM            tCsEmpleados AS tCsEmpleados_1  
                                                                                                                                        WHERE        (Estado = 1)) AS tCsEmpleados_3 INNER JOIN  
                                                                                                                                        tCsPadronClientes AS tCsPadronClientes_1 ON   
                                                                                                                                        tCsEmpleados_3.Codusuario = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN  
                                                                                                                                        tCsClPuestos AS tCsClPuestos_1 ON tCsEmpleados_3.CodPuesto = tCsClPuestos_1.Codigo RIGHT OUTER JOIN  
                                                                                                                                            (SELECT DISTINCT   
                                                                ISNULL(tSgComitesMiembros.CodUsuario, tSgAutorizaciones.CodUsAutoriza) AS CodUsuario  
                                                                                                                                              FROM            [10.0.2.14].Finmas.dbo.tSgComitesMiembros AS tSgComitesMiembros RIGHT OUTER JOIN  
                                                                                                                                                                        [10.0.2.14].Finmas.dbo.tSgAutorizaciones AS tSgAutorizaciones ON   
                                                                                                                                                                        tSgComitesMiembros.CodComite = tSgAutorizaciones.CodComite  
                                                                                                                                              WHERE        (tSgAutorizaciones.CodAutoriza IN ('AH-023', 'AH-027', 'AH-045'))) AS Datos_1 INNER JOIN  
                                                                                                                                        [10.0.2.14].Finmas.dbo.tUsUsuarios AS tUsUsuarios ON   
                                                                                                                                        Datos_1.CodUsuario = tUsUsuarios.CodUsuario ON tCsPadronClientes_1.CodOrigen = tUsUsuarios.CodUsuario)   
                                                                                                              AS Datos_2  
                                                                                    GROUP BY OD) AS Filtro ON Datos.OD = Filtro.OD AND Datos.Peso = Filtro.Peso) AS Datos  
                          GROUP BY OD) AS CA RIGHT OUTER JOIN  
                         tClOficinas ON CA.CodOficina = tClOficinas.CodOficina LEFT OUTER JOIN  
                             (SELECT        tCaClParametros.CodOficina, tUsUsuarios.NombreCompleto AS GerenteAgencia  
                               FROM            [10.0.2.14].Finmas.dbo.tUsUsuarios AS tUsUsuarios INNER JOIN  
                                                         [10.0.2.14].Finmas.dbo.tCaClParametros AS tCaClParametros ON tUsUsuarios.CodUsuario = tCaClParametros.CodEncargadoCA) AS GA ON   
                         tClOficinas.CodOficina = GA.CodOficina LEFT OUTER JOIN  
                             (SELECT        tTcParametros.CodOficina, tUsUsuarios.NombreCompleto AS CoordinadorOperaciones  
                               FROM            [10.0.2.14].Finmas.dbo.tTcParametros AS tTcParametros INNER JOIN  
                                                         [10.0.2.14].Finmas.dbo.tUsUsuarios AS tUsUsuarios ON tTcParametros.CodUsBoveda = tUsUsuarios.CodUsuario) AS CO ON   
                         tClOficinas.CodOficina = CO.CodOficina  
  

GO