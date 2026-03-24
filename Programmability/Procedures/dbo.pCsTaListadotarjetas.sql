SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsTaListadotarjetas] @codusuario varchar(25)
AS
BEGIN

	SET NOCOUNT ON;

    SELECT nrotarjeta 'N° Tarjeta',fecemision 'Emitido el',fecexpira 'Expira el',fecultmvo 'Ultimo uso',saldo 'Saldo al corte' FROM ttacuentas
    where codusuario=@codusuario

END
GO