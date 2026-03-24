SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  View dbo.vCCResumenCuentas4    Script Date: 08/03/2023 09:14:53 pm ******/
create view [dbo].[vCCResumenCuentas4] as

select 
tCCNombre.rfc,
tCCNombre.CURP,
--tCCNombre.Paterno + ' ' + tCCNombre.Materno + ' ' + tCCNombre.ApAdicional + ' ' + tCCNombre.Nombres  as nombrecompleto,
tccNombre.Paterno, 
tCCNombre.Materno, 
tCCNombre.Nombres, 
tCCCuentas.TipoCredito , 
tCCCuentas.ClavePrevencion,
(select descripcion from tCCProducto where TipoCredito = tCCCuentas.TipoCredito) as Producto,
count(tCCCuentas.TipoCredito) as cuentas, 
sum(convert(money,tCCCuentas.CreditoMaximo)) as aprobado,
sum(convert(money,tCCCuentas.LimiteCredito)) as LimiteCredito,
sum(convert(money,tCCCuentas.SaldoActual)) as SaldoActual, 
sum(convert(money,tCCCuentas.SaldoVencido)) as SaldoVencido,
sum(convert(money,tCCCuentas.MontoPagar)) as PagoSemanal,

(case 
 when sum(convert(money,tCCCuentas.SaldoActual)) > 0 and sum(convert(money,tCCCuentas.SaldoVencido)) = 0  then 'VIGENTE'
 when sum(convert(money,tCCCuentas.SaldoActual)) = 0 and sum(convert(money,tCCCuentas.SaldoVencido)) = 0  then 'CERRADA'
 when sum(convert(money,tCCCuentas.SaldoActual)) > 0 and sum(convert(money,tCCCuentas.SaldoVencido)) > 0  then 'ATRASADA'
 else ''
 end) as EstatusGeneral,

(select  top 1
 'Otorgante: '+ NombreOtorgante +', Estatus: '+ Descripcion
 from  tCCCuentas as c, tCCSituacion as s
 where
 c.claveprevencion = s.claveprevencion
 and c.rfc = tCCNombre.rfc
 and c.TipoCredito = tCCCuentas.TipoCredito
 and c.claveprevencion = tCCCuentas.ClavePrevencion 
 order by FechaAperturaCuenta desc) as UltimaCuenta,
tCCNombre.archivo 
from tCCNombre, tCCCuentas 
where 
tCCNombre.rfc = tCCCuentas.rfc
--and tCCNombre.archivo = '2'
--and tCCCuentas.rfc like 'MOFA52%' 
group by tCCCuentas.TipoCredito,
tCCCuentas.ClavePrevencion, 
tCCCuentas.SaldoActual,
tCCNombre.rfc,tCCNombre.CURP, tCCNombre.Paterno, tCCNombre.Materno, tCCNombre.ApAdicional, tCCNombre.Nombres,
tCCNombre.archivo 



GO