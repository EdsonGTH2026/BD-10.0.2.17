SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pTCffPendientesComprobar]
	AS
BEGIN
	SET NOCOUNT ON;

SELECT t.CodOficina,t.NumFondoFijo,t.NumFFTrans,t.FechaTrans,t.MontoTrans,t.UsRendir
,t.FechaEstRend,t.Observaciones,t.NumTransFFOri,u.nombrecompleto,f.SaldoFinSis
      ,f.FechaAReponer,f.FechaACerrar
  FROM [10.0.2.14].finmas.dbo.tTcFFTransac t inner join [10.0.2.14].finmas.dbo.tTcFondoFijo f on t.codoficina=f.codoficina and t.NumFondoFijo=f.NumFondoFijo
  inner join [10.0.2.14].finmas.dbo.tususuarios u on u.codusuario=f.CodUsFF
  where t.rendido=0 and not (t.fechaestrend is null) and t.anulada=0

END
GO