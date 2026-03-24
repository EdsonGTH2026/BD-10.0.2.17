SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACartaLN_CarteraRiesgo] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on
/*
--COMENTAR
Declare @fecha smalldatetime
declare @codoficina varchar(4)

set @fecha='20180515'
set @codoficina='37'
*/


Declare @fecini smalldatetime
Declare @fecini2 smalldatetime
Declare @fecano smalldatetime

declare @ncreBM decimal(8,2)
declare @ncreAM decimal(8,2)

set @fecha = convert(varchar,@fecha,112)
set @fecini = dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'
set @fecano = dbo.fdufechaatexto(dateadd(year,-1,@fecha),'AAAAMM')+'01'

set @fecini2 = dateadd(day,-1,@fecini)

/*Cartera en riesgo 4 días (CER@4):*/
PRINT '#################################################################################'
PRINT '############### Cartera en riesgo 4 días (CER@4): ###############################'

--Limpia la tabla de datos
delete from tCsRptEMI_LS_CarteraRiesgo where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina

create table #Periodos(
	periodo varchar(6),
	CO_nro int default(0),
	CO_desembolso money default(0),
	CO_Cer4nro int default(0),
	CO_Cer4saldo money default(0),
	VF_nro int default(0),
	VF_desembolso money default(0),
	VF_Cer4saldo money default(0),
	CO_Psaldo as (case when CO_desembolso=0.000 then 0.000 when CO_desembolso=-1 then -1  else (CO_Cer4saldo/CO_desembolso)*100 end),
	CO_Pnro as cast((case when CO_nro=0.000 then 0.00 when CO_desembolso=-1 then -1 else (CO_Cer4nro/cast(CO_nro as money))*100 end) as money),
	VF_Psaldo as (case when VF_desembolso=0.000 then 0.000 when VF_desembolso=-1 then -1 else (VF_Cer4saldo/VF_desembolso)* 100 end)
)
insert into #Periodos (periodo)
select dbo.fdufechaatexto(@fecha,'AAAAMM') fecha
union
select periodo
from tclperiodo with(nolock)
where ultimodia<=@fecha
and ultimodia>=dateadd(month,-12,@fecha)
--drop table #Periodos

update #Periodos set 
CO_desembolso=isnull(a.monto,-1), CO_nro=isnull(a.nro,-1)
from #Periodos p 
left join
(
	select dbo.fdufechaatexto(desembolso,'AAAAMM') periodo, sum(monto) monto,count(codprestamo) nro
	from tcspadroncarteradet
	where 
	--primerasesor=@codpromotor
	codoficina = @codoficina
	and desembolso>=@fecano
and codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	group by dbo.fdufechaatexto(desembolso,'AAAAMM')
) a on a.periodo=p.periodo

update #Periodos
set CO_Cer4nro=nrocer,CO_Cer4saldo=saldocer
from #Periodos p inner join 
(
	select dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM') periodo
	,count(c.codprestamo) nro
	,sum(d.saldocapital+d.interesvigente+d.interesvencido) saldo
	,count(case when c.nrodiasatraso>=4 then c.codprestamo else null end) nrocer
	,sum(case when c.nrodiasatraso>=4 then d.saldocapital+ ((d.interesvigente+d.interesvencido)* 1.16) else 0 end) saldocer
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
	where c.fecha=@fecha
	--and c.codasesor=@codpromotor
	and c.codoficina= @codoficina
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	group by dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM')
) a on a.periodo=p.periodo

--select * from #Periodos
DECLARE @STRG AS VARCHAR(8000)
DECLARE @SQL AS VARCHAR(8000)
CREATE TABLE #PIVOT ( PIVOT VARCHAR (8000) )
SET @STRG='' SET @SQL=''

/*Agrupacion para el saldo*/
--Se calculan las columnas segun el filtro de fechas
INSERT INTO #PIVOT 
SELECT DISTINCT 'sum(CASE WHEN periodo='''+ RTRIM(CAST(periodo AS VARCHAR(500))) + ''' THEN CO_Psaldo ELSE 0 END) AS ''S' + RTRIM(CAST(periodo AS VARCHAR(500))) + ''', ' AS PIVOT
FROM #Periodos

SET @SQL ='SELECT 1 Item,''Saldo'' Etiqueta, ' 
SELECT @SQL= @SQL + RTRIM(convert(varchar(500), pivot))
FROM #PIVOT 
ORDER BY PIVOT

SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
SET @SQL=@SQL + ' FROM #Periodos  ' 
--print @SQL
set @SQL =  @SQL + ' union '

/*Agrupacion para el numero*/
truncate table #PIVOT
INSERT INTO #PIVOT 
SELECT DISTINCT 'sum(CASE WHEN periodo='''+ RTRIM(CAST(periodo AS VARCHAR(500))) + ''' THEN CO_Pnro ELSE 0 END) AS ''S' + RTRIM(CAST(periodo AS VARCHAR(500))) + ''', ' AS PIVOT
FROM #Periodos

SET @SQL = @SQL + 'SELECT 2 Item,''Numero'' Etiqueta, '
SELECT @SQL= @SQL + RTRIM(convert(varchar(500), pivot))
FROM #PIVOT 
ORDER BY PIVOT

SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
SET @SQL=@SQL + ' FROM #Periodos  ' 
--print @SQL   --COMENTAR

create table #Tbl(
	item int,
	etiqueta varchar(10),
	m1 decimal(8,2),
	m2 decimal(8,2),
	m3 decimal(8,2),
	m4 decimal(8,2),
	m5 decimal(8,2),
	m6 decimal(8,2),
	m7 decimal(8,2),
	m8 decimal(8,2),
	m9 decimal(8,2),
	m10 decimal(8,2),
	m11 decimal(8,2),
	m12 decimal(8,2),
	m13 decimal(8,2),
	PEstatus decimal(8,2),
	NEstatus varchar(15),
	Estatus decimal(8,2)
)

SET @SQL = 'insert into #Tbl(item,etiqueta,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13) select * from(' + @SQL + ') a '
--print @SQL
EXECUTE (@SQL) 

declare @valor1 money
declare @valor2 money

select @valor1 = (case m1 when -1 then 0 else m1 end)+(case m2 when -1 then 0 else m2 end)+(case m3 when -1 then 0 else m3 end)+
                          (case m4 when -1 then 0 else m4 end)+(case m5 when -1 then 0 else m5 end)+(case m6 when -1 then 0 else m6 end)+
                          (case m7 when -1 then 0 else m7 end)+(case m8 when -1 then 0 else m8 end)+(case m9 when -1 then 0 else m9 end)+
                          (case m10 when -1 then 0 else m10 end)+(case m11 when -1 then 0 else m11 end)+(case m12 when -1 then 0 else m12 end)
from #Tbl where item = 1

select @valor2 = (case m1 when -1 then 0 else 1 end)+(case m2 when -1 then 0 else 1 end)+(case m3 when -1 then 0 else 1 end)+
                          (case m4 when -1 then 0 else 1 end)+(case m5 when -1 then 0 else 1 end)+(case m6 when -1 then 0 else 1 end)+
                          (case m7 when -1 then 0 else 1 end)+(case m8 when -1 then 0 else 1 end)+(case m9 when -1 then 0 else 1 end)+
                          (case m10 when -1 then 0 else 1 end)+(case m11 when -1 then 0 else 1 end)+(case m12 when -1 then 0 else 1 end)
from #Tbl where item = 1

--select @valor1 as '@valor', @valor2 as '@valor2'
if @valor2 > 0 
	begin
		update #Tbl set PEstatus = @valor1 / @valor2 where item = 1
	end
----------------
select @valor1 = (case m1 when -1 then 0 else m1 end)+(case m2 when -1 then 0 else m2 end)+(case m3 when -1 then 0 else m3 end)+
                          (case m4 when -1 then 0 else m4 end)+(case m5 when -1 then 0 else m5 end)+(case m6 when -1 then 0 else m6 end)+
                          (case m7 when -1 then 0 else m7 end)+(case m8 when -1 then 0 else m8 end)+(case m9 when -1 then 0 else m9 end)+
                          (case m10 when -1 then 0 else m10 end)+(case m11 when -1 then 0 else m11 end)+(case m12 when -1 then 0 else m12 end)
from #Tbl where item = 2

select @valor2 = (case m1 when -1 then 0 else 1 end)+(case m2 when -1 then 0 else 1 end)+(case m3 when -1 then 0 else 1 end)+
                          (case m4 when -1 then 0 else 1 end)+(case m5 when -1 then 0 else 1 end)+(case m6 when -1 then 0 else 1 end)+
                          (case m7 when -1 then 0 else 1 end)+(case m8 when -1 then 0 else 1 end)+(case m9 when -1 then 0 else 1 end)+
                          (case m10 when -1 then 0 else 1 end)+(case m11 when -1 then 0 else 1 end)+(case m12 when -1 then 0 else 1 end)
from #Tbl where item = 2

--select @valor1 as '@valor', @valor2 as '@valor2'
if @valor2 > 0 
	begin
		update #Tbl set PEstatus = @valor1 / @valor2 where item = 2
	end
----------------
select @valor1 = (case m1 when -1 then 0 else m1 end)+(case m2 when -1 then 0 else m2 end)+(case m3 when -1 then 0 else m3 end)+
                          (case m4 when -1 then 0 else m4 end)+(case m5 when -1 then 0 else m5 end)+(case m6 when -1 then 0 else m6 end)+
                          (case m7 when -1 then 0 else m7 end)+(case m8 when -1 then 0 else m8 end)+(case m9 when -1 then 0 else m9 end)+
                          (case m10 when -1 then 0 else m10 end)+(case m11 when -1 then 0 else m11 end)+(case m12 when -1 then 0 else m12 end)
from #Tbl where item = 3

select @valor2 = (case m1 when -1 then 0 else 1 end)+(case m2 when -1 then 0 else 1 end)+(case m3 when -1 then 0 else 1 end)+
                          (case m4 when -1 then 0 else 1 end)+(case m5 when -1 then 0 else 1 end)+(case m6 when -1 then 0 else 1 end)+
                          (case m7 when -1 then 0 else 1 end)+(case m8 when -1 then 0 else 1 end)+(case m9 when -1 then 0 else 1 end)+
                          (case m10 when -1 then 0 else 1 end)+(case m11 when -1 then 0 else 1 end)+(case m12 when -1 then 0 else 1 end)
from #Tbl where item = 3

--select @valor1 as '@valor', @valor2 as '@valor2'
if @valor2 > 0 
	begin
		update #Tbl set PEstatus = @valor1 / @valor2 where item = 3
	end

update #Tbl set NEstatus=(case when PEstatus<=4 then 'EXCELENTE' when PEstatus>4 and PEstatus<=6 then 'ACEPTABLE' else 'NO ACEPTABLE' end) where etiqueta='Saldo'
update #Tbl set NEstatus=(case when PEstatus<=4 then 'EXCELENTE' when PEstatus>4 and PEstatus<=6 then 'ACEPTABLE' else 'NO ACEPTABLE' end) where etiqueta='Numero'
update #Tbl set NEstatus=(case when PEstatus<=4 then 'ACEPTABLE' else 'NO ACEPTABLE' end) where etiqueta='Saldo VF'

declare @bonoSaldoCA decimal(8,2)
declare @bonoSaldoVF decimal(8,2)
declare @cerSaldo varchar(15)
declare @cerNro varchar(15)

select @cerSaldo=nestatus from #Tbl  where etiqueta='Saldo'
select @cerNro=nestatus from #Tbl  where etiqueta='Numero'

Select @bonoSaldoCA=case when @cerNro='EXCELENTE' then excelente when @cerNro='ACEPTABLE' then aceptable else noaceptable end from tcscacartascalidad where alcance=@cerSaldo
update #Tbl set estatus=@bonoSaldoCA where etiqueta in('Saldo','Numero')

declare @CApstatus money
select @CApstatus=pestatus from #Tbl where etiqueta='Saldo'

--Inserta Datos en la tabla final
insert into tCsRptEMI_LS_CarteraRiesgo (Fecha, CodOficina, item, etiqueta, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, PEstatus, NEstatus, Estatus )
select @fecha, @codoficina, item, etiqueta, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, PEstatus, NEstatus, Estatus from #Tbl

--<<<<<<<<<<<<<<< TITULOS CARTERA RIESGO
CREATE TABLE #PIVOT2 (id integer identity, PIVOT VARCHAR (8000) )
declare @sql2 as varchar(500)
set @sql2 = ''

INSERT INTO #PIVOT2 (PIVOT) 
SELECT ' '''+ substring( RTRIM(CAST(periodo AS VARCHAR(50))) ,5, 2) + 'M ' + substring( RTRIM(CAST(periodo AS VARCHAR(50))) ,1, 4) +  ''' ' AS PIVOT
FROM #Periodos
order by periodo

--print '#PIVOT2'
--select * from #PIVOT2 order by id

SET @sql2 ='SELECT ''' + convert(varchar,@fecha,112) + ''', '''+ @codoficina + ''', 0 as Item, ''%CER@4'' as Etiqueta ' 
SELECT @sql2= @sql2 + ',' + RTRIM(convert(varchar(15), pivot)) + ''
FROM #PIVOT2 
ORDER BY id -- PIVOT

SET @sql2 = @sql2 + ', ''PEstatus'', ''NEstatus'',''Estatus'' '

--select @sql2 as '@sql2'

--Inserta titulos en la tabla final
SET @SQL = 'insert into tCsRptEMI_LS_CarteraRiesgo (Fecha, CodOficina, item, etiqueta, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, PEstatus, NEstatus, Estatus ) '
SET @SQL = @SQL + @sql2
EXECUTE (@SQL) 
--print @SQL
-->>>>>>>>>>>>>>>>>>>>>>>>

--Regresa todos los datos
--select * from tCsRptEMI_LS_CarteraRiesgo where Fecha = @fecha and CodOficina = @codoficina order by item  --COMENTAR


drop table #PIVOT
drop table #Periodos
drop table #Tbl
drop table #PIVOT2


GO