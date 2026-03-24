SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop view [dbo].[vClientes]
CREATE VIEW [dbo].[vClientes]
AS
SELECT     CodOficina + '' + CodUsuario AS CodUsu, NombreCompleto, CodDocIden, DI, usRFC as RUC, FechaNacimiento, CodEstadoCivil, Sexo, CodUbiGeoDirFamPri, 
                      DireccionDirFamPri, TelefonoDirFamPri, CodUbiGeoDirNegPri, DireccionDirNegPri, TelefonoDirNegPri
FROM         dbo.tCsPadronClientes with(nolock)

GO