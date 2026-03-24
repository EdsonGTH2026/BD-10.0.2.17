SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAComerPadronAhorro] @fecha smalldatetime, @codoficina varchar(300)
as
--declare @fecha smalldatetime
--set @fecha='20201117'
SELECT tCsAhorros.Fecha, tCsAhorros.CodOficina, tClOficinas.NomOficina, 
tCsPadronClientes.NombreCompleto, tCsAhorros.CodCuenta, tCsAhorros.fraccioncta, 
tCsAhorros.Renovado, tCsAhorros.FechaApertura, tCsAhorros.FechaVencimiento, tCsAhorros.FechaCierre, tCsAhorros.TasaInteres, 
tCsAhorros.FechaUltMov, tCsAhorros.SaldoCuenta, tCsAhorros.MontoInteres, tCsAhorros.IntAcumulado, tCsAhorros.MontoInteresCapitalizado, 
tCsAhorros.MontoBloqueado, tCsAhorros.MontoRetenido, tCsAhorros.InteresCalculado, tCsAhorros.Plazo, 
tCsAhorros.FechaUltCapitalizacion,
e.Descripcion estadocuenta,p.Abreviatura
FROM         tCsAhorros with(nolock)
INNER JOIN tClOficinas with(nolock) ON tCsAhorros.CodOficina = tClOficinas.CodOficina 
INNER JOIN tCsPadronClientes with(nolock) ON tCsAhorros.CodUsuario = tCsPadronClientes.CodUsuario 
inner join tAhClEstadoCuenta e with(nolock) on e.idEstadoCta=tcsahorros.idEstadoCta
inner join tAhProductos p with(nolock) on p.idproducto=tCsAhorros.codproducto
WHERE tCsAhorros.Fecha=@fecha AND  tCsAhorros.idEstadoCta <> 'CC'
and substring(tCsAhorros.codcuenta,5,1)='2'
GO