SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAComerSegServicios] @fecha smalldatetime, @codoficina varchar(300)
as

SELECT t.Fecha, tClZona.Nombre, t.CodOficina, tClOficinas.NomOficina, t.NroTransaccion, 
t.NombreCliente, t.DescripcionTran, t.MontoTotalTran
FROM tCsTransaccionDiaria t with(nolock) 
INNER JOIN tClOficinas with(nolock) ON t.CodOficina = tClOficinas.CodOficina 
INNER JOIN tClZona with(nolock) ON tClOficinas.Zona = tClZona.Zona
WHERE (t.Fecha>=@fecha) AND (t.CodSistema = 'tc') and t.extornado=0
and t.codoficina in (select codigo from dbo.fduTablaValores(@codoficina))
GO