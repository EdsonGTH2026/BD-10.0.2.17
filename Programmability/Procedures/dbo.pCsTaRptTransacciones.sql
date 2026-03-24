SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsTaRptTransacciones] @fecini smalldatetime, @fecfin smalldatetime, @tipomov varchar(5)
AS
BEGIN

	SET NOCOUNT ON;

SELECT nrotarjeta,codtipomov,fecha,hora,consecutivo,documento1,documento2
,F,E,consumo,tarjeta,nombre,comercio,comision,MO,Monto,usuario
  FROM FinamigoConsolidado.dbo.tTaMovimientos
  where fecha>=@fecini and fecha<=@fecfin and codtipomov like @tipomov

END
GO