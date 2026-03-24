SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pRptBovedaSaldosMatriz] @FI smalldatetime ,  @FF smalldatetime
as 

--declare @FI smalldatetime ,  @FF smalldatetime
--set @FI='20171012'
--set @FF='20171013'

SELECT CodOficina,FechaPro,SaldoFinSis
into #Anexo
FROM [10.0.2.14].[Finmas].[dbo].[tTcCajasAnexoSaldos]
where fechapro>=@FI and fechapro<=@FF

SELECT     g.Fecha, g.CodOficina, '[' + dbo.fduRellena('0', g.CodOficina, 3, 'D') + '] ' + o.NomOficina AS DescOficina, SUM(g.SaldoFinSisMn) AS SaldoFinSisMn, 
                      SUM(g.SaldoFinSisMe) AS SaldoFinSisMe, SUM(g.SaldoFinUsMn) AS SaldoFinUsMn, SUM(g.SaldoFinUsMe) AS SaldoFinUsMe
FROM (SELECT     b.Fecha, b.CodOficina
		,CASE WHEN b.codmoneda = 6 THEN SUM(b.SaldoFinSis) ELSE 0 END AS SaldoFinSisMn
		,CASE WHEN b.codmoneda <> 6 THEN SUM(b.SaldoFinSis) ELSE 0 END AS SaldoFinSisMe
		--,CASE WHEN b.codmoneda = 6 THEN SUM(b.SaldoFinUs) ELSE 0 END AS SaldoFinUsMn
		,CASE WHEN b.codmoneda = 6 THEN SUM(a.SaldoFinSis) ELSE 0 END AS SaldoFinUsMn
		,CASE WHEN b.codmoneda <> 6 THEN SUM(b.SaldoFinUs) ELSE 0 END AS SaldoFinUsMe
        FROM   tCsBovedaSaldos b with(nolock)
		left outer join #Anexo a on a.codoficina=b.codoficina and a.fechapro=b.fecha
        WHERE b.Fecha >= @FI and b.Fecha <= @FF 
        GROUP BY b.Fecha, b.CodOficina, b.CodMoneda
) g INNER JOIN tClOficinas o with(nolock) ON g.CodOficina = o.CodOficina
GROUP BY g.Fecha, g.CodOficina, o.NomOficina

drop table #Anexo
GO