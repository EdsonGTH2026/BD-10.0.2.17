SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsAhTransacciones1] @fecha smalldatetime, @Codoficina varchar(5) AS

SELECT     Fecha, CodigoCuenta, CodSistema, CodOficina, NroTransaccion, TipoTransacNivel1, TipoTransacNivel2, TipoTransacNivel3, Extornado, 
                      NombreCliente, DescripcionTran, MontoCapitalTran, MontoInteresTran, MontoINVETran, MontoINPETran, MontoOtrosTran, MontoTotalTran
FROM         tCsTransaccionDiaria
WHERE     (Fecha = @fecha) AND (CodOficina = @Codoficina)
GO