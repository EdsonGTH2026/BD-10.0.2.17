SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[udpSgCboClientes] @Nombre VARCHAR (50) AS
BEGIN
	SELECT TOP 20 codusuario, nombrecompleto, codorigen 
	FROM tCsPadronClientes WITH (NOLOCK)
	WHERE nombrecompleto LIKE @Nombre
END
GO