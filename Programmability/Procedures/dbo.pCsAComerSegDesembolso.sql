SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAComerSegDesembolso] @fecha smalldatetime, @codoficina varchar(300)
as
SELECT p.Desembolso, p.CodPrestamo, p.CodUsuario, p.CodOficina, 
p.FechaCorte, tClOficinas.NomOficina, tClZona.Nombre AS Region, p.CodGrupo, p.Coordinador, 
p.CodProducto, p.SecuenciaPrestamo, p.SecuenciaGrupo, p.SecuenciaCliente, 
p.SaldoOriginal, p.Monto, tCaProducto.NombreProdCorto, tCsPadronClientes.NombreCompleto, tCsAsesores.NomAsesor
FROM tCsPadronCarteraDet p with(nolock)
INNER JOIN tClOficinas with(nolock) ON p.CodOficina = tClOficinas.CodOficina 
INNER JOIN tClZona with(nolock) ON tClOficinas.Zona = tClZona.Zona 
INNER JOIN tCsPadronClientes with(nolock) ON p.CodUsuario = tCsPadronClientes.CodUsuario 
INNER JOIN tCaProducto with(nolock) ON p.CodProducto = tCaProducto.CodProducto 
INNER JOIN tCsAsesores with(nolock) ON p.UltimoAsesor = tCsAsesores.CodAsesor
WHERE (p.Desembolso >= @fecha)
AND (p.CodOficina IN (select codigo from dbo.fduTablaValores(@codoficina)))
GO