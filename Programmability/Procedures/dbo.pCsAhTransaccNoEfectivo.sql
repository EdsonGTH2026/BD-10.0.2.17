SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
 CREATE PROCEDURE [dbo].[pCsAhTransaccNoEfectivo]   @fechaIni smalldatetime,  @fechaFin smalldatetime   AS

SELECT     Fecha, CodigoCuenta, CodSistema, CodOficina, NroTransaccion, TipoTransacNivel1, TipoTransacNivel2, TipoTransacNivel3, Extornado, 
                      NombreCliente, DescripcionTran, MontoCapitalTran, MontoInteresTran, MontoINVETran, MontoINPETran, MontoOtrosTran, MontoTotalTran, 
                      CodOficinaCuenta, CodMotivo, CodAsesor, CodProducto, CodCajero
FROM         tCsTransaccionDiaria
WHERE      (Fecha >= @fechaIni  and Fecha <= @fechaFin) AND (CodSistema = 'ah') and TipoTransacNivel1='I' and  TipoTransacNivel2= 'INTERNO' and TipoTransacNivel3= '4'  and PATINDEX ('%desem%',DescripcionTran) =0
GO