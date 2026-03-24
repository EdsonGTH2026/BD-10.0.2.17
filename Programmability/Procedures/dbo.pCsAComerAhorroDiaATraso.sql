SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAComerAhorroDiaATraso] @fecha smalldatetime, @codoficina varchar(300)
as
SELECT tClZona.Nombre as Region,tClOficinas.NomOficina, ca.Cartera, ca.Fecha, ca.CodPrestamo, ca.NroDiasAtraso, ISNULL(tCsCarteraGrupos.NombreGrupo, 
tCsPadronClientes.NombreCompleto) AS Grupo, tCsPadronClientes.NombreCompleto AS Clientes, cd.SaldoCapital, cd.InteresVigente, 
cd.InteresVencido, cd.InteresCtaOrden, cd.MoratorioVigente, cd.MoratorioVencido, cd.MoratorioCtaOrden, 
cd.OtrosCargos, cd.Impuestos, cd.CargoMora, tCsClientesAhorrosFecha.CodCuenta,tCsClientesAhorrosFecha.Capital
FROM tCsCartera ca with(nolock) INNER JOIN
tCsCarteraDet cd with(nolock) ON ca.Fecha = cd.Fecha AND ca.CodPrestamo = cd.CodPrestamo 
INNER JOIN tCsClientesAhorrosFecha with(nolock)
ON cd.Fecha = tCsClientesAhorrosFecha.Fecha AND cd.CodUsuario = tCsClientesAhorrosFecha.CodUsCuenta 
INNER JOIN tCsPadronClientes with(nolock) ON cd.CodUsuario = tCsPadronClientes.CodUsuario 
INNER JOIN tClOficinas with(nolock) ON cd.CodOficina = tClOficinas.CodOficina 
INNER JOIN tClZona with(nolock) ON tClOficinas.Zona = tClZona.Zona 
LEFT OUTER JOIN tCsCarteraGrupos with(nolock) ON ca.CodOficina = tCsCarteraGrupos.CodOficina AND ca.CodGrupo = tCsCarteraGrupos.CodGrupo
WHERE (ca.Fecha=@fecha) and ca.cartera<>'ADMINISTRATIVA'
AND (ca.NroDiasAtraso > 0)
AND ca.codoficina in (select codigo from dbo.fduTablaValores(@codoficina))
ORDER BY ca.CodOficina, ca.Cartera, ca.CodPrestamo
GO