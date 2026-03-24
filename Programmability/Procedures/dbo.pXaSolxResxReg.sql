SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--[pXaSolxResxReg]
--drop procedure [[pXaSolxResxReg]]
CREATE procedure [dbo].[pXaSolxResxReg]
as
	exec [10.0.2.14].finmas.dbo.pXaSolxResxReg

--Declare @Fecha 		SmallDateTime
--Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

--SELECT p.codsolicitud,p.codoficina
----,p.estado codestadoactual
--,case when p.estado = 1 then 'ENPROCESO'
--		when p.estado in(2,21,22) then 'ENPROCESO'
--		when p.estado = 3 then 'ENPROCESO'
--		when p.estado = 24 then 'ENPROCESO'
--		when p.estado = 4 then 'ENPROCESO'
--		when p.estado = 5 then 'ENPROCESO'
--		when p.estado = 11 then 'Cancelado'
--		when p.estado = 23 then 'ENPROCESO'
--		when p.estado = 31 then 'ENPROCESO'
--		when p.estado = 6 then 'FONDEO' --> fondeo ENPROCESO
--		when p.estado = 7 then 'PORENTREGAR'
--		when p.estado = 8 then 'ENTREGADO' --> debe lo colocado en el día
--		when p.estado = 9 then 'Revisión de expediente'
--		when p.estado = 10 then 'Expediente completo'
--		when p.estado = 12 then 'ENPROCESO'
--		when p.estado = 61 then 'FONDEO' --> fondeo ENPROCESO
--		else 'No definido' end estadoactual
--,s.montoaprobado,cl.nombres +' '+cl.paterno regional
--into #sol
--FROM [10.0.2.14].finmas.dbo.tCaSolicitudProce p --with(nolock)
--inner join [10.0.2.14].finmas.dbo.tcasolicitud s --with(nolock) 
--on s.codsolicitud=p.codsolicitud and s.codoficina=p.codoficina and s.codproducto=p.codproducto
--inner join tcloficinas c on c.codoficina=s.codoficina
--inner join tclzona z on z.zona=c.zona
--inner join tcspadronclientes cl on cl.codusuario=z.responsable
--where p.estado in (3,4,24,23,21,22,31,6,61,7,5,1,2)

--insert into #sol
--select p.codsolicitud,p.codoficina
----,p.estado codestadoactual
--,'ENTREGADO' estadoactual 
--,p.montodesembolso monto
--,cl.nombres +' '+cl.paterno regional
--FROM [10.0.2.14].[Finmas].[dbo].[tCaPrestamos] p
--inner join tcloficinas c with(nolock) on c.codoficina=p.codoficina
--inner join tclzona z with(nolock) on z.zona=c.zona
--inner join tcspadronclientes cl with(nolock) on cl.codusuario=z.responsable
--where fechadesembolso>=@Fecha+1 --'20180322'--
--and p.estado='VIGENTE' --not in ('TRAMITE','APROBADO','ANULADO')--,'CANCELADO'
--and p.codoficina<>97

--create table #sol2(
--	i int identity(1,1) not null,
--	estado varchar(30),
--	numero int,
--	monto money,
--	regional varchar(200)
--)
--insert into #sol2 (estado,numero,monto,regional)
--select estadoactual,nro,monto,regional
--from (
--	select case when estadoactual='ENTREGADO' then 1
--				when estadoactual='PORENTREGAR' then 2
--				when estadoactual='ENPROCESO' then 3
--				else 10 end orden
--	,estadoactual,count(estadoactual) nro,sum(montoaprobado) monto
--	,regional
--	from #sol
--	group by estadoactual,regional
--) a 
--union 
--select estado,nro,monto,regional
--from (
--	select 10 orden
--	,'Total' estado,count(estadoactual) nro,sum(montoaprobado) monto
--	,regional
--	from #sol
--	where estadoactual in ('PORENTREGAR','ENPROCESO','FONDEO')
--	group by regional
--) a

----select * from #sol2

--insert into #sol2 (estado,numero,monto,regional)
--select estado,sum(numero) numero,sum(monto) monto,'TOTAL GENERAL' regional 
--from #sol2
--group by estado

--DECLARE @STRG AS VARCHAR(8000)
--DECLARE @SQL AS VARCHAR(8000)
--CREATE TABLE #PIVOT ( PIVOT VARCHAR (8000) )
--SET @STRG='' SET @SQL=''

----Se calculan las columnas segun el filtro de fechas
--INSERT INTO #PIVOT 
--SELECT DISTINCT 'sum(CASE WHEN estado='''+ RTRIM(CAST(estado AS VARCHAR(500))) + ''' THEN numero ELSE 0 END) AS ''N' + RTRIM(CAST(estado AS VARCHAR(500))) + ''' '
--+ ',sum(CASE WHEN estado='''+ RTRIM(CAST(estado AS VARCHAR(500))) + ''' THEN monto ELSE 0 END) AS ''M' + RTRIM(CAST(estado AS VARCHAR(500))) + ''', ' AS PIVOT
--FROM #sol2 WHERE estado IS NOT NULL

--SET @SQL ='SELECT Regional, '
--SELECT @SQL= @SQL + RTRIM(convert(varchar(500), pivot))
--FROM #PIVOT ORDER BY PIVOT
----print @SQL
--SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
--SET @SQL=@SQL + ' FROM #sol2 GROUP BY regional '
----print @SQL
--EXECUTE (@SQL) 

--drop table #PIVOT

--drop table #sol
--drop table #sol2


GO