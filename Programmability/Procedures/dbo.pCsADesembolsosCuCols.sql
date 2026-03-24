SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsADesembolsosCuCols] @fecha smalldatetime,@cad varchar(8000) OUTPUT
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20171004'
--declare @cad varchar(8000)

declare @fecini smalldatetime
set @fecini=dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'

select dbo.fdufechaatexto(p.desembolso,'AAAAMMDD') fecha,p.codoficina,o.nomoficina,count(p.codprestamo) nro, sum(p.monto) monto
into #res
from tcspadroncarteradet p with(nolock)
inner join tcloficinas o with(nolock) on p.codoficina=o.codoficina
where p.desembolso>=@fecini--'20170901'
and p.codoficina<>'97'
group by dbo.fdufechaatexto(p.desembolso,'AAAAMMDD'),p.codoficina,o.nomoficina

DECLARE @SQL AS VARCHAR(8000)
SET @SQL=''

CREATE TABLE #PIVOT ( PIVOT VARCHAR (8000) )--Se calculan las columnas segun el filtro de fechas
INSERT INTO #PIVOT 
--SELECT DISTINCT ' d' + RTRIM(CAST(fecha AS VARCHAR(500))) + ' money,' AS PIVOT FROM #res WHERE fecha IS NOT NULL
SELECT DISTINCT 'd' + RTRIM(CAST(fecha AS VARCHAR(500))) + 'n int, ' AS PIVOT
FROM #res WHERE fecha IS NOT NULL
union
SELECT DISTINCT 'd' + RTRIM(CAST(fecha AS VARCHAR(500))) + 'm money, ' AS PIVOT
FROM #res WHERE fecha IS NOT NULL
--select *,substring(PIVOT,1,9) x from #PIVOT ORDER BY substring(PIVOT,1,9)
SET @SQL ='create table tCsADesembolsosCU ( codoficina varchar(4),nomoficina varchar(200),'
SELECT @SQL= @SQL + RTRIM(convert(varchar(500), pivot))
FROM #PIVOT ORDER BY PIVOT
SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
SET @SQL=@SQL + ' ) '
--print @SQL
set @cad=@SQL
--print @cad
drop table #PIVOT
drop table #res


GO