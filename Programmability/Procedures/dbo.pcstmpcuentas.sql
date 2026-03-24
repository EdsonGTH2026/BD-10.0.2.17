SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pcstmpcuentas]
AS
BEGIN
	SET NOCOUNT ON;

  SELECT a.CodCuenta,a.codoficina,cl.codorigen
  FROM tCsAhorros a with(nolock)
  inner join tCspadronclientes cl with(nolock) 
  on cl.codusuario=a.CodAsesor
  where a.fecha='20121130' and a.codoficina!='2'

END
GO