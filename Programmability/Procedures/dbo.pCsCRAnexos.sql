SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCRAnexos]
@Empresa	Varchar(2),
@Nombre 	Varchar(100)
As

--Set @Empresa	= 'BC'
--Set @Nombre 	= 'KEMY VALERA VALLES'

Declare @CodUsuario Varchar(25)

Exec pCsNombreACodigo @Nombre, @CodUsuario Out

Print @CodUsuario

SELECT     tCREmpresas.NombreLegal, Empresa.Empresa, Empleado.Empleado, Empleado.Puesto, Empleado.Correo, Empleado.Telmex, Empleado.Fax, 
                      Representante.Representante, tCsPadronClientes.NombreCompleto AS Funcionario, Empresa.RFC, Empleado.CodUsuario, Atencion.Atencion, 
                      Atencion.APuesto, Atencion.ATelefono, Atencion.AFax, Atencion.ACorreo, Atencion2.Atencion2, Atencion2.BPuesto, Atencion2.BTelefono, 
                      Atencion2.BFax, Atencion2.BCorreo, Empresa.ETelefono, Empresa.EFax, tCREmpresas.RepresentanteLegal, Empleado.RFC AS EmRFC, 
                      tClOficinas.Tipo
FROM         (SELECT     tCsPadronClientes.CodUsuario, tCsPadronClientes.NombreCompleto AS Empleado, tCsClPuestos.Descripcion AS Puesto, tCsEmpleados.Correo, tClOficinas.Telmex, 
                      tClOficinas.Fax, tCsEmpleados.RFC, tCsEmpleados.CodOficina
FROM         tCsEmpleados INNER JOIN
                      tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario INNER JOIN
                      tClOficinas ON tCsEmpleados.CodOficina = tClOficinas.CodOficina INNER JOIN
                      tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo
WHERE     (tCsEmpleados.Codusuario = @CodUsuario)) Empleado INNER JOIN
                      tClOficinas ON Empleado.CodOficina COLLATE Modern_Spanish_CI_AI = tClOficinas.CodOficina CROSS JOIN
                          (SELECT     tCsPadronClientes.NombreCompleto AS Atencion, tCsClPuestos.Descripcion AS APuesto, tClOficinas.Telmex AS ATelefono, tClOficinas.Fax AS AFax, 
                      tCsEmpleados.Correo AS ACorreo
FROM         tCsEmpleados INNER JOIN
                      tClOficinas ON tCsEmpleados.CodOficina = tClOficinas.CodOficina INNER JOIN
                      tCRResponsables INNER JOIN
                      tCsPadronClientes ON tCRResponsables.CodUsuario = tCsPadronClientes.CodUsuario ON tCsEmpleados.Codusuario = tCRResponsables.CodUsuario INNER JOIN
                      tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo
WHERE     (tCRResponsables.Responsable = '03') AND (tCRResponsables.Activo = 1)) Atencion CROSS JOIN
                          (SELECT     tCsPadronClientes.NombreCompleto AS Atencion2, tCsClPuestos.Descripcion AS BPuesto, tClOficinas.Telmex AS BTelefono, 
                                                   tClOficinas.Fax AS BFax, tCsEmpleados.Correo AS BCorreo
                            FROM         tCsEmpleados INNER JOIN
                      tClOficinas ON tCsEmpleados.CodOficina = tClOficinas.CodOficina INNER JOIN
                      tCRResponsables INNER JOIN
                      tCsPadronClientes ON tCRResponsables.CodUsuario = tCsPadronClientes.CodUsuario ON tCsEmpleados.Codusuario = tCRResponsables.CodUsuario INNER JOIN
                      tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo
                            WHERE      (tCRResponsables.Responsable = '04') AND (tCRResponsables.Activo = 1)) Atencion2 CROSS JOIN
                          (SELECT     tCsPadronClientes.NombreCompleto AS Representante
                            FROM          tCRResponsables INNER JOIN
                                                   tCsPadronClientes ON tCRResponsables.CodUsuario = tCsPadronClientes.CodUsuario
                            WHERE      (tCRResponsables.Responsable = '01')) Representante CROSS JOIN
                          (SELECT     tCsPadronClientes.NombreCompleto AS Empresa, tCsPadronClientes.UsRFC AS RFC, tClOficinas.Telmex AS ETelefono, 
                                                   tClOficinas.Fax AS EFax
                            FROM          tCRResponsables INNER JOIN
                                                   tCsPadronClientes ON tCRResponsables.CodUsuario = tCsPadronClientes.CodUsuario INNER JOIN
                                                   tClOficinas ON tCsPadronClientes.CodOficina = tClOficinas.CodOficina
                            WHERE      (tCRResponsables.Responsable = '02') AND (tCRResponsables.Activo = 1)) Empresa CROSS JOIN
                      tCsPadronClientes INNER JOIN
                      tCREmpresas ON tCsPadronClientes.CodUsuario = tCREmpresas.FuncionarioFacultado
WHERE     (tCREmpresas.Empresa = @Empresa)
GO