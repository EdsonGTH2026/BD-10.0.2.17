SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsRFCRiesgo]
(@Periodo as varchar(11))

as

--Declare @Periodo Varchar(6)
--Set @Periodo = '20140228'

SELECT  Periodo = @Periodo, NOMBRECOMPLETO,NOMBRES,PATERNO,MATERNO,cast(FECHANACIMIENTO as varchar(11)) as FECHANACIMIENTO,RFC, CURP = Isnull(CURP, '')
FROM         (SELECT     NOMBRECOMPLETO,NOMBRES,PATERNO,MATERNO,FECHANACIMIENTO, CASE WHEN ltrim(rtrim(isnull(UsRFC, ''))) = '' OR
                                              LEFT(usRFC, 10) <> LEFT(usRFCBD, 10) THEN usRFCBD ELSE UsRFCBD END AS RFC, usCURP AS CURP
                       FROM          tCsPadronClientes
                       WHERE      (dbo.fduFechaATexto(FechaIngreso, 'AAAAMM') = @Periodo)
                       UNION
                       SELECT     tCsPadronClientes.NOMBRECOMPLETO,tCsPadronClientes.Nombres,tCsPadronClientes.paterno,tCsPadronClientes.materno,tCsPadronClientes.FECHANACIMIENTO, CASE WHEN ltrim(rtrim(isnull(UsRFC, ''))) = '' OR
                                             LEFT(usRFC, 10) <> LEFT(usRFCBD, 10) THEN usRFCBD ELSE UsRFCBD END AS RFC, tCsPadronClientes.usCURP AS CURP
                       FROM         tCsPadronClientes INNER JOIN
                                             tCsPadronCarteraDet ON tCsPadronClientes.CodUsuario = tCsPadronCarteraDet.CodUsuario
                       WHERE     (dbo.fduFechaATexto(tCsPadronCarteraDet.Desembolso, 'AAAAMM') = @Periodo)) AS Datos
                       
                       
                       
                       --select top 3 * from tCsPadronClientes
GO