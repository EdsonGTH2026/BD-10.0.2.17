SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACartaPromotores2] @fecha smalldatetime,@codpromotor varchar(15),@codoficina varchar(4)
as
set nocount on
--tCsCaCartaPtmosEspeciales--creditos que no se consideran del promotor

Declare @fecini smalldatetime
Declare @fecini2 smalldatetime
Declare @fecano smalldatetime

declare @ncreBM decimal(8,2)
declare @ncreAM decimal(8,2)

set @fecha = convert(varchar,@fecha,112)

--COMENTAR
/*
Declare @fecha smalldatetime
declare @codpromotor varchar(15)
declare @codoficina varchar(4)

set @fecha='20180515'
set @codpromotor='CGM891025M5RR3'
set @codoficina='37'
*/

set @fecini = dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'
set @fecano = dbo.fdufechaatexto(dateadd(year,-1,@fecha),'AAAAMM')+'01'

set @fecini2 = dateadd(day,-1,@fecini)


--########################################### NIVEL
declare @nivel int
declare @saldocartera money
select 
--@saldocartera=sum(d.saldocapital+ (d.interesvigente+d.interesvencido)*1.16) --saldo
@saldocartera= sum(case when c.nrodiasatraso<=29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha= @fecini2 --@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

set @nivel = case when @saldocartera<=800000 then 1 
				  when @saldocartera>800000 and @saldocartera<=1000000 then 2
				  when @saldocartera>1000000 and @saldocartera<=1200000 then 3
				  when @saldocartera>1200000 then 4 else 0 end

--Actualiza el Nivel del Promotor
--update tCsRptEMIPC_Promotor set
--Nivel = convert(varchar,@nivel)
--where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina


/* ################################################ DATOS PROMOTOR */

declare @Promotor varchar(50)
declare @Oficina varchar(50)

select @Promotor = NombreCompleto from tCsPadronClientes where codusuario = @codpromotor
select @Oficina = NomOficina from tClOficinas where codoficina = @codoficina

delete from tCsRptEMIPC_Promotor where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina

insert into tCsRptEMIPC_Promotor (Fecha, CodPromotor, CodOficina, Promotor, Oficina, Nivel)
values (@fecha, @codpromotor, @codoficina, @Promotor, @Oficina, convert(varchar,@nivel))

select * from tCsRptEMIPC_Promotor where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina

--################################################

/*Cartera en riesgo 4 días (CER@4):*/
create table #Periodos(
	periodo varchar(6),
	CO_nro int default(0),
	CO_desembolso money default(0),
	CO_Cer4nro int default(0),
	CO_Cer4saldo money default(0),
	VF_nro int default(0),
	--VF_Cer4nro int default(0),
	VF_desembolso money default(0),
	VF_Cer4saldo money default(0),
	--CO_Psaldo as (case when CO_desembolso=0 then 0 else (CO_Cer4saldo/CO_desembolso)*100 end),
	CO_Psaldo as (case when CO_desembolso=0.000 then 0.000 when CO_desembolso=-1 then -1  else (CO_Cer4saldo/CO_desembolso)*100 end),
	--CO_Pnro as cast((case when CO_nro=0 then 0 else (CO_Cer4nro/cast(CO_nro as decimal(16,2)))*100 end) as decimal(16,2)),
	CO_Pnro as cast((case when CO_nro=0.000 then 0.00 when CO_desembolso=-1 then -1 else (CO_Cer4nro/cast(CO_nro as money))*100 end) as money),
	--VF_Psaldo as (case when VF_desembolso=0 then 0 else (VF_Cer4saldo/VF_desembolso)* 100 end)
	VF_Psaldo as (case when VF_desembolso=0.000 then 0.000 when VF_desembolso=-1 then -1 else (VF_Cer4saldo/VF_desembolso)* 100 end)
)
insert into #Periodos (periodo)
select dbo.fdufechaatexto(@fecha,'AAAAMM') fecha--'201805' fecha
union
select periodo
from tclperiodo with(nolock)
where ultimodia<=@fecha--'20180515'
and ultimodia>=dateadd(month,-12,@fecha)--'20180515')
--drop table #Periodos

update #Periodos set 
--CO_desembolso=a.monto,CO_nro=a.nro
CO_desembolso=isnull(a.monto,-1), CO_nro=isnull(a.nro,-1)
from #Periodos p 
--inner join 
left join
(
	select dbo.fdufechaatexto(desembolso,'AAAAMM') periodo, sum(monto) monto,count(codprestamo) nro
	from tcspadroncarteradet
	where primerasesor=@codpromotor--'CGM891025M5RR3'
	and desembolso>=@fecano--'20170501'
and codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	group by dbo.fdufechaatexto(desembolso,'AAAAMM')
) a on a.periodo=p.periodo

update #Periodos set 
--VF_desembolso=a.monto
VF_desembolso=isnull(a.monto,-1)
from #Periodos p 
--inner join 
left join
(
	select dbo.fdufechaatexto(desembolso,'AAAAMM') periodo, sum(monto) monto,count(codprestamo) nro
	from tcspadroncarteradet
	where codverificador=@codpromotor--'CGM891025M5RR3'
	and desembolso>=@fecano--'20170501'
and codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	group by dbo.fdufechaatexto(desembolso,'AAAAMM')
) a on a.periodo=p.periodo

update #Periodos
set CO_Cer4nro=nrocer,CO_Cer4saldo=saldocer
from #Periodos p inner join 
(
	select dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM') periodo
	,count(c.codprestamo) nro
	,sum(d.saldocapital+d.interesvigente+d.interesvencido) saldo--+d.interesctaorden
	,count(case when c.nrodiasatraso>=4 then c.codprestamo else null end) nrocer
	--,sum(case when c.nrodiasatraso>=4 then d.saldocapital+d.interesvigente+d.interesvencido else 0 end) saldocer--+d.interesctaorden
	,sum(case when c.nrodiasatraso>=4 then d.saldocapital+ ((d.interesvigente+d.interesvencido)* 1.16) else 0 end) saldocer
	--select c.codprestamo,c.nrodiasatraso,d.saldocapital,d.interesvigente,d.interesvencido,d.interesctaorden
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
	where c.fecha=@fecha--'20180515'
	and c.codasesor=@codpromotor--'CGM891025M5RR3'
	and c.codoficina= @codoficina
	--and c.fechadesembolso>='20180501'
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	group by dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM')
) a on a.periodo=p.periodo

update #Periodos
set VF_nro=a.nro,VF_Cer4saldo=saldocer
from #Periodos p inner join 
(
	select dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM') periodo
	,count(c.codprestamo) nro
	,sum(d.saldocapital+d.interesvigente+d.interesvencido) saldo--+d.interesctaorden
	,count(case when c.nrodiasatraso>=4 then c.codprestamo else null end) nrocer
	--,sum(case when c.nrodiasatraso>=4 then d.saldocapital+d.interesvigente+d.interesvencido else 0 end) saldocer--+d.interesctaorden
	,sum(case when c.nrodiasatraso>=4 then d.saldocapital+ ((d.interesvigente+d.interesvencido)* 1.16) else 0 end) saldocer--+d.interesctaorden
	--,c.nrodiasatraso
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
	inner join tcspadroncarteradet p with(nolock) on p.codprestamo=d.codprestamo and p.codusuario=d.codusuario
	where c.fecha=@fecha--'20180515'
	and p.codverificador=@codpromotor--'CGM891025M5RR3'
	and c.codoficina=@codoficina
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

SET @SQL ='SELECT 1 Item,''Saldo'' Etiqueta, ' --periodo,
SELECT @SQL= @SQL + RTRIM(convert(varchar(500), pivot))
FROM #PIVOT 
ORDER BY PIVOT

SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
SET @SQL=@SQL + ' FROM #Periodos  ' --GROUP BY periodo
--print @SQL
set @SQL =  @SQL + ' union '

/*Agrupacion para el numero*/
truncate table #PIVOT
INSERT INTO #PIVOT 
SELECT DISTINCT 'sum(CASE WHEN periodo='''+ RTRIM(CAST(periodo AS VARCHAR(500))) + ''' THEN CO_Pnro ELSE 0 END) AS ''S' + RTRIM(CAST(periodo AS VARCHAR(500))) + ''', ' AS PIVOT
FROM #Periodos

SET @SQL = @SQL + 'SELECT 2 Item,''Numero'' Etiqueta, ' --periodo,
SELECT @SQL= @SQL + RTRIM(convert(varchar(500), pivot))
FROM #PIVOT 
ORDER BY PIVOT

SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
SET @SQL=@SQL + ' FROM #Periodos  ' --GROUP BY periodo
--print @SQL
set @SQL =  @SQL + ' union '

/*Agrupacion para el saldo verificador*/
truncate table #PIVOT
INSERT INTO #PIVOT 
SELECT DISTINCT 'sum(CASE WHEN periodo='''+ RTRIM(CAST(periodo AS VARCHAR(500))) + ''' THEN VF_Psaldo ELSE 0 END) AS ''S' + RTRIM(CAST(periodo AS VARCHAR(500))) + ''', ' AS PIVOT
FROM #Periodos

SET @SQL = @SQL + 'SELECT 3 Item,''Saldo VF'' Etiqueta, ' --periodo,
SELECT @SQL= @SQL + RTRIM(convert(varchar(500), pivot))
FROM #PIVOT 
ORDER BY PIVOT

SET @SQL = SUBSTRING(@SQL,1,LEN(@SQL)-1)
SET @SQL=@SQL + ' FROM #Periodos  ' --GROUP BY periodo

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
print @SQL
EXECUTE (@SQL) 

-->>>>>>>>>>>>>>>> TITULOS CARTERA RIESGO
CREATE TABLE #PIVOT2 (id integer identity, PIVOT VARCHAR (8000) )
declare @sql2 as varchar(500)
set @sql2 = ''

INSERT INTO #PIVOT2 (PIVOT) 
SELECT ' '''+ substring( RTRIM(CAST(periodo AS VARCHAR(50))) ,5, 2) + 'M ' + substring( RTRIM(CAST(periodo AS VARCHAR(50))) ,1, 4) +  ''' ' AS PIVOT
FROM #Periodos
order by periodo

--print '#PIVOT2'
--select * from #PIVOT2 order by id

SET @sql2 ='SELECT ''' + convert(varchar,@fecha,112) + ''',''' + @codpromotor + ''','''+ @codoficina + ''', ''CarteraRiesgoTit'', 0 as Item, ''%CER@4'' as Etiqueta ' 
SELECT @sql2= @sql2 + ',' + RTRIM(convert(varchar(15), pivot)) + ''
FROM #PIVOT2 
ORDER BY id -- PIVOT

SET @sql2 = @sql2 + ', ''Estatus'', ''% de Bono'' '

--select @sql2 as '@sql2'
--EXECUTE (@sql2)

--SET @SQL = 'insert into #Tbl(item,etiqueta,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13) ' + @sql2 + '  '
--print @SQL
--EXECUTE (@SQL) 

delete from tCsRptEMIPC_CarteraRiesgoTitulos where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
SET @SQL = 'insert into tCsRptEMIPC_CarteraRiesgoTitulos (Fecha, CodPromotor, CodOficina, Tipo, item, etiqueta, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, Estatus, Bono ) '
SET @SQL = @SQL + @sql2
EXECUTE (@SQL) 

--print @SQL
select * from tCsRptEMIPC_CarteraRiesgoTitulos where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina

drop table #PIVOT2
-->>>>>>>>>>>>>>>>>>>>>>>>

drop table #PIVOT
drop table #Periodos


--update #Tbl set PEstatus=(m1+m2+m3+m4+m5+m6+m7+m8+m9+m10+m11+m12)/12
/*
update #Tbl set PEstatus=((case m1 when -1 then 0 else m1 end)+(case m2 when -1 then 0 else m2 end)+(case m3 when -1 then 0 else m3 end)+
                          (case m4 when -1 then 0 else m4 end)+(case m5 when -1 then 0 else m5 end)+(case m6 when -1 then 0 else m6 end)+
                          (case m7 when -1 then 0 else m7 end)+(case m8 when -1 then 0 else m8 end)+(case m9 when -1 then 0 else m9 end)+
                          (case m10 when -1 then 0 else m10 end)+(case m11 when -1 then 0 else m11 end)+(case m12 when -1 then 0 else m12 end))
                          /
                          ((case m1 when -1 then 0 else 1 end)+(case m2 when -1 then 0 else 1 end)+(case m3 when -1 then 0 else 1 end)+
                          (case m4 when -1 then 0 else 1 end)+(case m5 when -1 then 0 else 1 end)+(case m6 when -1 then 0 else 1 end)+
                          (case m7 when -1 then 0 else 1 end)+(case m8 when -1 then 0 else 1 end)+(case m9 when -1 then 0 else 1 end)+
                          (case m10 when -1 then 0 else 1 end)+(case m11 when -1 then 0 else 1 end)+(case m12 when -1 then 0 else 1 end))
*/

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

select @bonoSaldoVF=case when PEstatus<=4 then 100 when PEstatus>4 and PEstatus<=6 then 80 else 70 end from #Tbl where etiqueta='Saldo VF'
update #Tbl set estatus=@bonoSaldoVF where etiqueta in('Saldo VF')

declare @CApstatus money
select @CApstatus=pestatus from #Tbl where etiqueta='Saldo'

--select 'CarteraRiesgo',* from #Tbl  --COMENTAR

--OSC
delete from tCsRptEMIPC_CarteraRiesgo where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_CarteraRiesgo (Fecha, CodPromotor, CodOficina, Tipo, item, etiqueta, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, PEstatus, NEstatus, Estatus )
select @fecha, @codpromotor, @codoficina, 'CarteraRiesgo',item, etiqueta, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, PEstatus, NEstatus, Estatus from #Tbl

drop table #Tbl

select * from tCsRptEMIPC_CarteraRiesgo where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina

--################################################

--Colocación del mes:
--declare @nivel int
--set @nivel=4 --comentar
create table #CADe(
	codprestamo varchar(25),
	codusuario varchar(15),
	monto money,
	fecult smalldatetime,
	codasesor varchar(15),
saldo money
)
insert into #CADe (codprestamo,codusuario,monto,fecult)
select p.codprestamo,p.codusuario,p.monto,max(a.desembolso) fecha
from tcspadroncarteradet p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and p.desembolso>a.desembolso
where p.primerasesor=@codpromotor--'CGM891025M5RR3'
and p.desembolso>=@fecini--'20180501' 
and p.desembolso<=@fecha--'20180515'
and p.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
group by p.codprestamo,p.codusuario,p.monto

--select d.codprestamo,p.primerasesor
update #CADe
set codasesor = p.primerasesor
from #CADe d inner join tcspadroncarteradet p with(nolock) on p.codusuario=d.codusuario and p.desembolso=d.fecult
where p.primerasesor<>@codpromotor--'CGM891025M5RR3'

--Actualiza saldo
update #CADe set
saldo = isnull((select saldocapital+((interesvigente+interesvencido)*1.16) 
                from tcscarteradet where Fecha = @fecha and codprestamo = #CADe.codprestamo), #CADe.monto)


declare @RenoNro int
declare @RenoSal money
declare @RenoSal2 money
declare @CliPropios int
select @RenoNro=count(case when codasesor is not null then codprestamo else null end) --Hnro
,@RenoSal=sum(case when codasesor is not null then monto else 0 end) --Hmonto
,@CliPropios= count(codprestamo)-count(case when codasesor is not null then codprestamo else null end)
,@RenoSal2=sum(case when codasesor is not null then saldo else 0 end) --Hmonto
from #CADe

--select @RenoNro '@RenoNro',@RenoSal '@RenoSal',@CliPropios '@CliPropios'
Declare @nronuevo int
select @nronuevo=count(case when fecult is null then codprestamo else null end) --Nnro
--,isnull(sum(case when fecult is null then monto else 0 end),0) Nmonto 
from #CADe where fecult is null

declare @MetaNuevoCre varchar(50)
declare @MetaPorBono money
set @MetaNuevoCre = case when @nivel=1 then '8 créditos'
						when @nivel=2 then '4 créditos'
						when @nivel=3 then 'Sin meta'
						when @nivel=4 then 'Sin meta'
						else 'REVISAR' end
set @MetaPorBono = case when @nivel=1 then 
								case when @nronuevo<5 then 0
									 when @nronuevo>=5 and @nronuevo<8 then 50
									 else 100 end
						when @nivel=2 then
								case when @nronuevo<2 then 0
									 when @nronuevo>=2 and @nronuevo<4 then 50
									 else 100 end
						when @nivel=3 then 0
						when @nivel=4 then 0
						else -1 end

/*
--COMETAR
select 'Colocacion',
count(codprestamo) Tnro
,sum(monto) Tmonto
,count(case when fecult is not null then codprestamo else null end) Rnro
,sum(case when fecult is not null then monto else 0 end) Rmonto
,count(case when fecult is null then codprestamo else null end) Nnro
,sum(case when fecult is null then monto else 0 end) Nmonto
,count(case when codasesor is not null then codprestamo else null end) Hnro
,sum(case when codasesor is not null then monto else 0 end) Hmonto
,@MetaNuevoCre 'meta',@MetaPorBono 'pormeta'
from #CADe
*/

--OSC
delete from tCsRptEMIPC_ColocacionMes where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_ColocacionMes (Fecha, CodPromotor, CodOficina, Tipo, Tnro, Tmonto, Rnro, Rmonto, Nnro, Nmonto, Hnro, Hmonto, meta, pormeta )
select 
	@fecha, @codpromotor, @codoficina,
	'Colocacion',
	count(codprestamo) Tnro
	,sum(monto) Tmonto
	,count(case when fecult is not null then codprestamo else null end) Rnro
	,sum(case when fecult is not null then monto else 0 end) Rmonto
	,count(case when fecult is null then codprestamo else null end) Nnro
	,sum(case when fecult is null then monto else 0 end) Nmonto
	,count(case when codasesor is not null then codprestamo else null end) Hnro
	,sum(case when codasesor is not null then monto else 0 end) Hmonto
	,@MetaNuevoCre 'meta',@MetaPorBono 'pormeta'
from #CADe

---->AGREGAR A LA TABLA QUE MOSTRARA EL REPORTE
drop table #CADe

select * from tCsRptEMIPC_ColocacionMes where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina

--##############################################33

/*Cartera:*/
--OJO : comentar estas variables en producción porque son calculados en fragmentos anteriores
--declare @RenoNro int
--declare @RenoSal money
--declare @CliPropios int
--set @RenoNro=1
--set @RenoSal=8000
--set @CliPropios=15

create table #Ca(
	item int,
	etiqueta varchar(300),
	NCBM int,
	SCBM money,
	NCAM int,
	SCAM money
)

insert into #Ca (item,etiqueta,NCBM,SCBM,NCAM,SCAM)
select 1,'Inicio' etiqueta
--,count(case when c.nrodiasatraso<=29 and d.SaldoCapital >= 500 then c.codprestamo else null end) NCBM
,count(case when c.nrodiasatraso<=29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then c.codprestamo else null end) NCBM
--,sum(case when c.nrodiasatraso<=29 and d.SaldoCapital >= 500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCBM
,sum(case when c.nrodiasatraso<=29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCBM
--,count(case when c.nrodiasatraso>29 and d.SaldoCapital >= 500 then c.codprestamo else null end) NCAM
,count(case when c.nrodiasatraso>29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then c.codprestamo else null end) NCAM
--,sum(case when c.nrodiasatraso>29 and d.SaldoCapital >= 500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCAM
,sum(case when c.nrodiasatraso>29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCAM
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.cartera='ACTIVA'
and c.codasesor=@codpromotor--'CGM891025M5RR3'
and c.fecha=@fecini2 --@fecini--'20180501'
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

--Actualiza los campos AM de la etiqueta INICIO, pero ahora considerando la cartera diferente a CANCELADA y sin importar que se el saldo sea mayor a 500
update #Ca set
#Ca.NCAM = x.NCAM,
#Ca.SCAM = x.SCAM
--select *
from #Ca
inner join (
	select 1 as item,'Inicio' as etiqueta
	,count(case when c.nrodiasatraso>29 then c.codprestamo else null end) NCAM
	,sum(case when c.nrodiasatraso>29  then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCAM
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	where c.cartera<>'CANCELADA'
	and c.codasesor=@codpromotor--'CGM891025M5RR3'
	and c.fecha=@fecini2 --@fecini--'20180501'
	and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
) as x on x.item = #Ca.item and x.etiqueta = #Ca.etiqueta

insert into #Ca (item,etiqueta,NCBM,SCBM,NCAM,SCAM)
select 2,'Hoy' etiqueta
,count(case when c.nrodiasatraso<=29 then c.codprestamo else null end) NCBM
,sum(case when c.nrodiasatraso<=29 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCBM
,count(case when c.nrodiasatraso>29 then c.codprestamo else null end) NCAM
,sum(case when c.nrodiasatraso>29 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCAM
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.cartera='ACTIVA'
and c.codasesor=@codpromotor--'CGM891025M5RR3'
and c.fecha=@fecha--'20180515'
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

--Actualiza los campos AM de la etiqueta HOY, pero ahora considerando la cartera diferente a CANCELADA y sin importar que se el saldo sea mayor a 500
update #Ca set
#Ca.NCAM = x.NCAM,
#Ca.SCAM = x.SCAM
--select *
from #Ca
inner join (
	select 2 as item,'Hoy' as etiqueta
	,count(case when c.nrodiasatraso>29 then c.codprestamo else null end) NCAM
	,sum(case when c.nrodiasatraso>29  then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCAM
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	where c.cartera<>'CANCELADA'
	and c.codasesor=@codpromotor--'CGM891025M5RR3'
	and c.fecha=@fecha --@fecini--'20180501'
	and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
) as x on x.item = #Ca.item and x.etiqueta = #Ca.etiqueta

insert into #Ca (item,etiqueta,NCBM,SCBM)
select 3,'Cre500' etiqueta
--,count(case when c.nrodiasatraso<=29 then (case when d.SaldoCapital>=500 then c.codprestamo else null end) else null end) NCBM500
,count(case when c.nrodiasatraso<=29 then (case when (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16)>=500 then c.codprestamo else null end) else null end) NCBM500
--,sum(case when c.nrodiasatraso<=29 then (case when d.SaldoCapital>=500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) else 0 end) SCBM500
,sum(case when c.nrodiasatraso<=29 then (case when (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16)>=500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) else 0 end) SCBM500
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.cartera='ACTIVA'
and c.codasesor=@codpromotor--'CGM891025M5RR3'
and c.fecha=@fecha--'20180515'
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

Declare @DifCASal money

declare @num int
declare @sal int
declare @num1 int
declare @sal1 int
declare @num2 int
declare @sal2 int

select @num1=ncbm,@sal1=scbm from #Ca where etiqueta='Inicio'
select @num2=ncbm,@sal2=scbm from #Ca where etiqueta='Cre500'

insert into #Ca (item,etiqueta,NCBM,SCBM)
select 4,'CreHuer' e,@num2-@num1 num,@sal2-@sal1 sal

insert into #Ca (item,etiqueta,NCBM,SCBM)
--select 5,'CrePro' e,@num2-@num1-@RenoNro num,@sal2-@sal1-@RenoSal sal
select 5,'CrePro' e,@num2-@num1-@RenoNro num,@sal2-@sal1-@RenoSal2 sal

--set @DifCASal=(-1)*(@sal2-@sal1-@RenoSal)
set @DifCASal=(@sal2-@sal1)

declare @MetaCredito varchar(300)
declare @PorBono decimal(8,2)

set @MetaCredito = case when @nivel=1 then '10 clientes propios o 18 con huérfanos'
						when @nivel=2 then 'Sin decremento en saldo de cartera'
						when @nivel=3 then 'Sin decremento en saldo de cartera'
						when @nivel=4 then 'No tener decremento mayor a $50,000'
						else 'REVISAR' end

insert into #Ca (item,etiqueta)
select 6, @MetaCredito e

--Se utiliza la misma forma de calculo de crecimiento propio y crecimiento huerfano
set @CliPropios = @num2-@num1-@RenoNro 
set @RenoNro = @num2-@num1 

if(@nivel=1)
begin
	set @PorBono = case when @CliPropios>=10 or @RenoNro>=18 then 100
				   when (@CliPropios>=8 or @CliPropios<10) and (@RenoNro>=14 and @RenoNro<18) then 75
				   when (@CliPropios>=6 or @CliPropios<8) and (@RenoNro>=10 and @RenoNro<14) then 50
				   else 0 end
end
if(@nivel=2)
begin
	--set @PorBono = case when @DifCASal=0 then 100 when @DifCASal<=50000 then 50 else 0 end
	set @PorBono = case when @DifCASal>=0 then 100 when @DifCASal>=-50000 then 50 else 0 end
end
if(@nivel=3)
begin
	--set @PorBono = case when @DifCASal=0 then 100 when @DifCASal<=50000 then 50 else 0 end
	set @PorBono = case when @DifCASal>=0 then 100 when @DifCASal>=-50000 then 50 else 0 end
end
if(@nivel=4)
begin
	--set @PorBono = case when @DifCASal<=50000 then 100 when @DifCASal>50000 and @DifCASal<=80000 then 50 else 0 end
	set @PorBono = case when @DifCASal>=-50000 then 100 
                        when @DifCASal<-50000 and @DifCASal>=-80000 then 50 
                        else 0 end
end

insert into #Ca (item,SCBM)
select 7, @PorBono e

declare @CAnrocre int
declare @CAsaldo money
select @CAnrocre=ncbm,@CAsaldo=scbm from #Ca where item=3
--select * from #Ca

create table #CAcuadro(
	item int,
	etiqueta varchar(20),
	InicioMes money,
	Hoy money,
	CreSalMay500 money,
	CrePropio money,
	CreHuefan money,
	MetaCre varchar(100),
	PorBono money null, -- decimal(8,2)
NumPasoAM int null
--PorBono varchar(20)  --PRUEBA
)

insert into #CAcuadro (item,etiqueta,InicioMes,Hoy,CreSalMay500,CrePropio,CreHuefan,MetaCre,PorBono)
select 1,'Saldo en CBM'
,sum(case when item=1 then SCBM else 0 end) I
,sum(case when item=2 then SCBM else 0 end) H
,sum(case when item=3 then SCBM else 0 end) C5
,sum(case when item=5 then SCBM else 0 end) CP
,sum(case when item=4 then SCBM else 0 end) CH
,max(case when item=6 then etiqueta else null end) MC
,sum(case when item=7 then SCBM else 0 end) PB
from #CA

insert into #CAcuadro (item,etiqueta,InicioMes,Hoy,CreSalMay500,CrePropio,CreHuefan,MetaCre,PorBono)
select 2,'# en CBM'
,sum(case when item=1 then NCBM else 0 end) I
,sum(case when item=2 then NCBM else 0 end) H
,sum(case when item=3 then NCBM else 0 end) C5
,sum(case when item=5 then NCBM else 0 end) CP
,sum(case when item=4 then NCBM else 0 end) CH
,max(case when item=6 then etiqueta else null end) MC
,sum(case when item=7 then SCBM else 0 end) PB
from #CA

select @ncreBM = sum(case when item=3 then NCBM else 0 end) from #CA

insert into #CAcuadro (item,etiqueta,InicioMes,Hoy)
select 3,'Saldo en AM'
,sum(case when item=1 then SCAM else 0 end) I
,sum(case when item=2 then SCAM else 0 end) H
from #CA

insert into #CAcuadro (item,etiqueta,InicioMes,Hoy)
select 4,'# en AM'
,sum(case when item=1 then NCAM else 0 end) I
,sum(case when item=2 then NCAM else 0 end) H
from #CA

select @ncreAM = sum(case when item=2 then NCAM else 0 end) from #CA

--actualiza el registro de Num creditos que pasa a AM 
update #CAcuadro set
NumPasoAM = Hoy - InicioMes
where 
item = 4

--select * from #CAcuadro --COMENTAR

--OSC
delete from tCsRptEMIPC_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_Cartera (Fecha, CodPromotor, CodOficina, Tipo, item, etiqueta, InicioMes, Hoy, CreSalMay500, CrePropio, CreHuefan, MetaCre, PorBono, NumPasoAM)    
select @fecha, @codpromotor, @codoficina, 'CARTERA', item, etiqueta, InicioMes, Hoy, CreSalMay500, CrePropio, CreHuefan, MetaCre, PorBono, NumPasoAM from #CAcuadro

drop table #CAcuadro
drop table #Ca

select * from tCsRptEMIPC_Cartera where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina

--###################################################

/* Liquidado en el mes */
create table #cnu(codprestamo varchar(25),codusuario varchar(15))
insert into #cnu
Select p.codprestamo,p.codusuario
from tcspadroncarteradet p with(nolock)
where p.desembolso>=@fecini--'20180501' 
and p.desembolso<=@fecha--'20180515'
and p.primerasesor=@codpromotor--'CGM891025M5RR3'
and p.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

/*
--COMENTAR
Select count(p.codprestamo) nroliqui,count(n.codprestamo) nroreno, round((count(n.codprestamo)/cast(count(p.codprestamo) as decimal(8,2)))*100,2) PorReno
from tcspadroncarteradet p with(nolock)
left outer join #cnu n with(nolock) on n.codusuario=p.codusuario
where p.cancelacion>=@fecini--'20180501'
and p.cancelacion<=@fecha--'20180515'
and p.primerasesor=@codpromotor--'CGM891025M5RR3'
*/

--OSC
delete from tCsRptEMIPC_LiquidadosMes where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_LiquidadosMes (Fecha, CodPromotor, CodOficina, Tipo, nroliqui, nroreno, PorReno )   
Select 
@fecha, @codpromotor, @codoficina, 'LIQUIDADOS MES',
count(p.codprestamo) as nroliqui,count(n.codprestamo) as nroreno, round((count(n.codprestamo)/cast(count(p.codprestamo) as decimal(8,2)))*100,2) as PorReno
from tcspadroncarteradet p with(nolock)
left outer join #cnu n with(nolock) on n.codusuario=p.codusuario
where p.cancelacion>=@fecini
and p.cancelacion<=@fecha
and p.primerasesor=@codpromotor
and p.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

drop table #cnu

select * from tCsRptEMIPC_LiquidadosMes where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina

--###################################################

/* Creditos con paso a alta mora */

/* Bono preliminar */
--declare @PorBono money --> viene de cuadro cartera
--set @PorBono=50
--declare @MetaPorBono money --> viene de cuadro cartera
--set @MetaPorBono=0
--declare @bonoSaldoCA decimal(8,2)--> se declaro en "cartera en riesgo"
--declare @bonoSaldoVF decimal(8,2)--> se declaro en "cartera en riesgo"
--set @bonoSaldoCA=120
--set @bonoSaldoVF=100

create table #bono(
	item tinyint,
	Tipo char(1),
	valor varchar(50),
	descripcion varchar(200),
	monto money
)

declare @ValorTbl money--decimal(8,2)
--select @ValorTbl = dbo.dfuCACartaTableroBono (208,3)
select @ValorTbl = dbo.dfuCACartaTableroBono (@ncreBM, @ncreAM)


insert into #bono
values(1,'A','$ '+convert(varchar(50),@ValorTbl,1),'Valor de tablero',@ValorTbl)
insert into #bono
values(2,'A','% alcanzado','Meta',0)
insert into #bono
--values(3,'A','%'+convert(varchar(50),@PorBono,1),'Crecimiento',@PorBono)
values(3,'A',convert(varchar(50),@PorBono,1) + '%','Crecimiento',@PorBono)
insert into #bono
--values(4,'A',case when @MetaPorBono=0 then 'NA' else convert(varchar(50),@MetaPorBono,1) end,'Colocación de créditos nuevos',@MetaPorBono)
values(4,'A',case when @MetaPorBono=0 and @nivel in (1,2) then '0%' 
                  when @MetaPorBono=0 and @nivel in (3,4) then 'NA'
                  else convert(varchar(50),@MetaPorBono,1) + '%' end,'Colocación de créditos nuevos',@MetaPorBono)

insert into #bono
values(5,'A',convert(varchar(50),@bonoSaldoCA,1)+'%','Calidad de Cartera propia',@bonoSaldoCA)
insert into #bono
values(6,'A',convert(varchar(50),@bonoSaldoVF,1)+'%','Calidad de Cartera Verificada',@bonoSaldoVF)

Declare @desempeno money
set @desempeno=@ValorTbl

--if(@PorBono<>0) set @desempeno=(@PorBono/100)*@desempeno
--if(@MetaPorBono<>0) set @desempeno=(@MetaPorBono/100)*@desempeno
--if(@bonoSaldoCA<>0) set @desempeno=(@bonoSaldoCA/100)*@desempeno
--if(@bonoSaldoVF<>0) set @desempeno=(@bonoSaldoVF/100)*@desempeno

set @desempeno=(@PorBono/100)*@desempeno
--if (@MetaPorBono<>0 and @nivel in (1,2)) set @desempeno=(@MetaPorBono/100)*@desempeno
if (@nivel in (1,2)) set @desempeno=(@MetaPorBono/100)*@desempeno
set @desempeno=(@bonoSaldoCA/100)*@desempeno
set @desempeno=(@bonoSaldoVF/100)*@desempeno

--select @desempeno
insert into #bono
values(7,'A','$'+convert(varchar(50),@desempeno,1),'Bono por desempeño',@desempeno)

--Viene de un cuadro anterior
--declare @CAnrocre int
--declare @CAsaldo money
--set @CAnrocre=209
--set @CAsaldo=1426451.4908

declare @gestionCA money
select @gestionCA=case when @CAsaldo>=140000 and @CAsaldo<280000 then
				case when @CAnrocre>=50 then 250 else 0 end
			when @CAsaldo>=280000 and @CAsaldo<360000 then
				case when @CAnrocre>=90 then 500 
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=360000 and @CAsaldo<450000 then
				case when @CAnrocre>=120 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=450000 and @CAsaldo<540000 then
				case when @CAnrocre>=150 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=540000 and @CAsaldo<640000 then
				case when @CAnrocre>=180 then 2000
					 when @CAnrocre>=150 and @CAnrocre<180 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=640000 and @CAsaldo<720000 then
				case when @CAnrocre>=210 then 2500
					 when @CAnrocre>=180 and @CAnrocre<210 then 2000
					 when @CAnrocre>=150 and @CAnrocre<180 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=720000 and @CAsaldo<800000 then
				case when @CAnrocre>=240 then 3000
					 when @CAnrocre>=210 and @CAnrocre<240 then 2500
					 when @CAnrocre>=180 and @CAnrocre<210 then 2000
					 when @CAnrocre>=150 and @CAnrocre<180 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=800000 then
				case when @CAnrocre>=270 then 3500
					 when @CAnrocre>=240 and @CAnrocre<240 then 3000
					 when @CAnrocre>=210 and @CAnrocre<240 then 2500
					 when @CAnrocre>=180 and @CAnrocre<210 then 2000
					 when @CAnrocre>=150 and @CAnrocre<180 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			else 0 --No esta en ninun rango
			end

insert into #bono
values(8,'B','$'+convert(varchar(50),@gestionCA,1),'Valor por gestión de cartera',@gestionCA)

insert into #bono
values(9,'B','% alcanzado','Meta',0)

--declare @CApstatus money --> se declaro en "cartera en riesgo"
--set @CApstatus=1.29

declare @CACalidad money
select @CACalidad = case when @CApstatus<=1 then 120
			when @CApstatus>1 and @CApstatus<=4 then 100
			when @CApstatus>4 and @CApstatus<=6 then 80
			when @CApstatus>6 then 70 end

insert into #bono
values(10,'B',convert(varchar(50),@CACalidad,1)+'%','Calidad de cartera propia',@CACalidad)

if(@CACalidad<>0) set @gestionCA=(@CACalidad/100)*@gestionCA

insert into #bono
values(11,'B','$'+convert(varchar(50),@gestionCA,1),'Calidad de cartera propia',@gestionCA)

declare @bonofinal money
select @bonofinal=sum(monto) from #bono where item in (7,11)

insert into #bono
values(12,'C','$'+convert(varchar(50),@bonofinal,1),'Bono total final',@bonofinal)

--select * from #bono  --COMENTAR

--OSC
delete from tCsRptEMIPC_Bono where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_Bono (Fecha, CodPromotor, CodOficina, Tipo, item, Tipo2, valor, descripcion, monto )
select @fecha, @codpromotor, @codoficina, 'BONO', item, Tipo, valor, descripcion, monto from #bono 

drop table #bono

select * from tCsRptEMIPC_Bono where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina


--############################################ Detalle creditos afectan calidad de cartera


create table #DetCredMora
(
item int,
Descripcion varchar(25),
Prestamos varchar(1000) default('')
)
--select * from #DetCredMora

insert into #DetCredMora (item, Descripcion, Prestamos ) values (1, '4 a 6 días en mora', '')
insert into #DetCredMora (item, Descripcion, Prestamos ) values (2, '7 a 29 días en mora', '')
insert into #DetCredMora (item, Descripcion, Prestamos ) values (3, '30 a 60 días en mora', '')
insert into #DetCredMora (item, Descripcion, Prestamos ) values (4, '61+ días en mora', '')

--insert into #PtmoCER (item,descripcion) values(1,'Cartera en riesgo')

declare @valores varchar(1000)
set @valores=''

select @valores= c.codprestamo+ ', '+@valores 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha=@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.NroDiasAtraso >=4 and c.NroDiasAtraso <= 6

if len(@valores)>0
begin
	update #DetCredMora
	set Prestamos = substring(@valores,1,len(@valores)-1)
	where item=1
end

set @valores=''

select @valores= c.codprestamo+ ', '+@valores 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha=@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.NroDiasAtraso >=7 and c.NroDiasAtraso <= 29

if len(@valores)>0
begin
	update #DetCredMora
	set Prestamos = substring(@valores,1,len(@valores)-1)
	where item=2
end

set @valores=''

select @valores= c.codprestamo+ ', '+@valores 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha=@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.NroDiasAtraso >=30 and c.NroDiasAtraso <= 60

if len(@valores)>0
begin
	update #DetCredMora
	set Prestamos = substring(@valores,1,len(@valores)-1)
	where item=3
end

set @valores=''

select @valores= c.codprestamo+ ', '+@valores 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha=@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.NroDiasAtraso > 60

if len(@valores)>0
begin
	update #DetCredMora
	set Prestamos = substring(@valores,1,len(@valores)-1)
	where item=4
end


--OSC
delete from tCsRptEMIPC_DetalleRiesgo where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_DetalleRiesgo (Fecha, CodPromotor, CodOficina, Tipo, item, Descripcion, Prestamos )
select @fecha, @codpromotor, @codoficina, 'DETALLECALIDAD', item, Descripcion, Prestamos from #DetCredMora

--select * from #DetCredMora
drop table #DetCredMora

select * from tCsRptEMIPC_DetalleRiesgo where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina
GO