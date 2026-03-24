SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create view [dbo].[vCsCuboTransacciones]
with encryption
as
select Cantidad = 1, 
       Fecha = year(Fecha) * 10000 + month(fecha) * 100 + day(fecha), 
       CodigoCuenta, FraccionCta, Renovado, CodSistema, TranHoraIn, TranMinutoIn, TranSegundoIn, 
       TranMicroSegundoIn, TranHoraFin, TranMinutoFin, TranSegundoFin, TranMicroSegundoFin, CodOficina,
       CodOficinaCuenta, NroTransaccion,case when TipoTransacNivel1='I' then 'Ingreso'else 'Egreso' End TipoTransacNivel1, TipoTransacNivel2, TipoTransacNivel3,
       Extornado, TipoCambio, NombreCliente, DescripcionTran, CodCajero, CodMoneda, MontoCapitalTran,
       MontoInteresTran, MontoINVETran, MontoINPETran, MontoOtrosTran, MontoTotalTran, FechaApertura,
       FechaVencimiento, TipoAtencion, CodBanco, NroCuenta, NroCheque, NroSecuencial, CodMotivo, Personal,
       CodUsuario, CodAsesor, CodProducto, CodDestino, CodTipoCredito, Calificacion, MontoDescontado,
       SecDesemb, TasaInteres,Fecha FechaProceso
from tCsTransaccionDiaria


GO