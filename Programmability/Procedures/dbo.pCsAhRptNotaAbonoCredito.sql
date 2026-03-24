SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsAhRptNotaAbonoCredito]  @FechaIni smalldatetime, @FechaFin smalldatetime   AS

SELECT     tAhTransaccionMaestra.Fecha, tAhTransaccionMaestra.CodOficina, tClOficinas.NomOficina, tAhTransaccionMaestra.CodTipoTrans, tAhTransaccionMaestra.CodCuenta, 
                      tAhClTipoTrans.Descripcion, tAhTransaccionMaestra.NroCaja, tAhTransaccionMaestra.CodCajero, tAhTransaccionMaestra.Observacion, 
                      tAhTransaccionMaestra.MontoTotal, tAhTransaccionMaestra.SaldoCta, tAhTransaccionMaestra.NroSecuencial, tAhTransaccionMaestra.CodMotivo
FROM         tAhTransaccionMaestra INNER JOIN
                      tClOficinas ON tAhTransaccionMaestra.CodOficina = tClOficinas.CodOficina INNER JOIN
                      tAhClTipoTrans ON tAhTransaccionMaestra.CodTipoTrans = tAhClTipoTrans.idTipoTrans
WHERE     (tAhTransaccionMaestra.CodTipoTrans IN ('3', '4')) AND (tAhTransaccionMaestra.CodSistema = 'ah') AND (tAhTransaccionMaestra.Fecha >= @FechaIni) AND 
                      (tAhTransaccionMaestra.Fecha <= @FechaFin)
GO