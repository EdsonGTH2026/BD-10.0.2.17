SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create view [dbo].[vCsCuboAhorros]
with encryption
as
select Cantidad = 1, 
       Fecha = year(Fecha) * 10000 + month(fecha) * 100 + day(fecha), 
       CodCuenta, FraccionCta, Renovado, CodOficina, CodProducto, CodMoneda, CodUsuario,
       FormaManejo, FechaApertura, FechaVencimiento, FechaCierre, TasaInteres, FechaUltMov,
       TipoCambioFijo, SaldoCuenta, SaldoMonetizado, MontoInteres, IntAcumulado, MontoInteresCapitalizado,
       MontoBloqueado, MontoRetenido, InteresCalculado, Plazo, Lucro, CodAsesor, CodOficinaUltTransaccion,
       TipoUltTransaccion, FechaUltCapitalizacion, IdDocRespaldo, NroSerie, idEstadoCta, NomCuenta,
       FondoConfirmar, Observacion, EnGarantia, Garantia, CuentaPreferencial, CuentaReservada, CodCuentaAnt,
       AplicaITF, PorcCliente, PorcInst, idTipoCapi, FechaCambioEstado, FechaInactivacion, NroSolicitud,
       CodTipoInteres, IdTipoRenova, PlazoDiasRenov, InteresCapitalizable, CodPrestamo, MontoGarantia,
       TipoConta, ContaCodigo,Fecha FechaProceso
from tCsAhorros


GO