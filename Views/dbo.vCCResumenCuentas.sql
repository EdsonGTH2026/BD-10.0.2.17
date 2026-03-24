SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/****** Object:  View dbo.vCCResumenCuentas    Script Date: 08/03/2023 09:14:53 pm ******/
create view [dbo].[vCCResumenCuentas] as
select 
tCCNombre.rfc,
tCCNombre.CURP,
tCCNombre.Paterno + ' ' + tCCNombre.Materno + ' ' + tCCNombre.ApAdicional + ' ' + tCCNombre.Nombres  as nombrecompleto,
tCCNombre.Paterno, 
tCCNombre.Materno, 
tCCNombre.Nombres, 
tCCCuentas.TipoCredito as Producto, 
count(tCCCuentas.TipoCredito) as cuentas, 
sum(convert(money,tCCCuentas.CreditoMaximo)) as aprobado,
sum(convert(money,tCCCuentas.LimiteCredito)) as LimiteCredito,
sum(convert(money,tCCCuentas.SaldoActual)) as SaldoActual, 
sum(convert(money,tCCCuentas.SaldoVencido)) as SaldoVencido,
sum(convert(money,tCCCuentas.MontoPagar)) as PagoSemanal
from tCCNombre, tCCCuentas where 
tCCNombre.rfc =  tCCCuentas.rfc
--and tCCCuentas.rfc like 'MOFA52%' 
group by tCCCuentas.TipoCredito, tCCCuentas.SaldoActual,
tCCNombre.rfc,tCCNombre.CURP, tCCNombre.Paterno, tCCNombre.Materno, tCCNombre.ApAdicional, tCCNombre.Nombres 

GO