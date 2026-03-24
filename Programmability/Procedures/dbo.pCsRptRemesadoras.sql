SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsRptRemesadoras] @fecIni smalldatetime, @fecFin smalldatetime , @CodOficina varchar(200) AS
SELECT t.nrotransaccion,t.Fecha, tClOficinas.NomOficina, t.TipoTransacNivel1,  
t.TipoTransacNivel3, t.Extornado, t.codusuario ,pc.nombrecompleto cliente, t.NombreCliente,t.DescripcionTran, t.MontoTotalTran
,tco.dato, tco.valor
FROM tCsTransaccionDiaria t LEFT OUTER JOIN tClOficinas ON t.CodOficina = tClOficinas.CodOficina
left join tcspadronclientes pc on pc.codusuario=t.codusuario
left join tCsTransaccionDiariaOtros Tco on  Tco.Fecha = t.Fecha AND Tco.CodSistema = t.CodSistema AND Tco.CodOficina = t.CodOficina AND 
                      Tco.NroTransaccion = t.NroTransaccion
WHERE (t.Fecha >= @fecIni) AND (t.Fecha <= @fecFin) AND (t.CodSistema = 'tc') AND  
(t.TipoTransacNivel3 in(1,11)) 
order by nomoficina
GO