SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pCsADesembolsosCu '20171004'
--drop procedure pCsCADesembolsosCu
create procedure [dbo].[pCsADesembolsosCu] @fecha smalldatetime
as
--declare @fecha smalldatetime
declare @fecini smalldatetime
set @fecini=dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'

select dbo.fdufechaatexto(p.desembolso,'AAAAMMDD') fecha,p.codoficina,o.nomoficina,count(p.codprestamo) nro, sum(p.monto) monto
into #res
from tcspadroncarteradet p with(nolock)
inner join tcloficinas o with(nolock) on p.codoficina=o.codoficina
where p.desembolso>=@fecini--'20170901'
--and p.desembolso<='20170930'
and p.codoficina<>'97'
group by dbo.fdufechaatexto(p.desembolso,'AAAAMMDD'),p.codoficina,o.nomoficina

DECLARE @SQL AS VARCHAR(8000)
CREATE TABLE #PIVOT ( PIVOT VARCHAR (8000) )
SET @SQL=''

--Se calculan las columnas segun el filtro de fechas
INSERT INTO #PIVOT 
SELECT DISTINCT 'sum(CASE WHEN fecha='''+ RTRIM(CAST(fecha AS VARCHAR(500))) + ''' THEN nro ELSE 0 END) AS ''n' + RTRIM(CAST(fecha AS VARCHAR(500))) + ''', ' AS PIVOT
FROM #res WHERE fecha IS NOT NULL
union
SELECT DISTINCT 'sum(CASE WHEN fecha='''+ RTRIM(CAST(fecha AS VARCHAR(500))) + ''' THEN monto ELSE 0 END) AS ''m' + RTRIM(CAST(fecha AS VARCHAR(500))) + ''', ' AS PIVOT
FROM #res WHERE fecha IS NOT NULL

SET @SQL ='SELECT codoficina,nomoficina, '
SELECT @SQL= @SQL + RTRIM(convert(varchar(500), pivot))
FROM #PIVOT ORDER BY PIVOT
--print @SQL
SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
SET @SQL=@SQL + ' FROM #res GROUP BY codoficina,nomoficina'
--print @SQL
EXECUTE (@SQL) 

drop table #PIVOT
drop table #res
GO