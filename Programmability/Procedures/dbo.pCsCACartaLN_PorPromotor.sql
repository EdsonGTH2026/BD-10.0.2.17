SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCACartaLN_PorPromotor] @fecha smalldatetime, @codoficina varchar(4)
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

--################################################### POR PROMOTOR
PRINT '##############################################################'
PRINT '####################### POR PROMOTOR #########################'
--Borralos datos anteriores
delete from tCsRptEMI_LS_PorPromotor where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina

/*Cartera en riesgo 4 días (CER@4):*/
create table #PeriodosPromotores(
	periodo varchar(6),
	CodPromotor varchar(20),
	Promotor varchar(30),
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

insert into #PeriodosPromotores (periodo, CodPromotor, Promotor)
select x.periodo, y.CodPromotor, y.Promotor 
from
(
	select dbo.fdufechaatexto(@fecha,'AAAAMM') as periodo --fecha
	union
	select periodo
	from tclperiodo with(nolock)
	where ultimodia<=@fecha--'20180515'
	and ultimodia>=dateadd(month,-12,@fecha)--'20180515')
) as x
,
(
	select distinct primerasesor as CodPromotor, u.nombrecompleto as Promotor
	from tcspadroncarteradet as c
	inner join tCsUsuarios as u on u.codusuario = c.primerasesor
	where 
	c.codoficina = @codoficina
	and c.desembolso>=dateadd(month,-12,@fecha)--'20180515')
	and u.activo = 1
) as y 

--select '1', * from #PeriodosPromotores --comentar

update #PeriodosPromotores set 
CO_desembolso=isnull(a.monto,-1), CO_nro=isnull(a.nro,-1), CodPromotor = a.CodPromotor
from #PeriodosPromotores p 
left join
(
	select dbo.fdufechaatexto(desembolso,'AAAAMM') periodo, sum(monto) monto,count(codprestamo) nro
    ,primerasesor as CodPromotor
	from tcspadroncarteradet
	where 
--primerasesor=@codpromotor--'CGM891025M5RR3'
codoficina = @codoficina
	and desembolso>=@fecano--'20170501'
and codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	group by dbo.fdufechaatexto(desembolso,'AAAAMM'), primerasesor
) a on a.periodo=p.periodo and a.CodPromotor = p.CodPromotor

--select '2', * from #PeriodosPromotores --comentar

update #PeriodosPromotores
set CO_Cer4nro=nrocer,CO_Cer4saldo=saldocer
from #PeriodosPromotores p inner join 
(
	select dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM') periodo, c.codasesor
	,count(c.codprestamo) nro
	,sum(d.saldocapital+d.interesvigente+d.interesvencido) saldo--+d.interesctaorden
	,count(case when c.nrodiasatraso>=4 then c.codprestamo else null end) nrocer
	,sum(case when c.nrodiasatraso>=4 then d.saldocapital+ ((d.interesvigente+d.interesvencido)* 1.16) else 0 end) saldocer
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
	where c.fecha=@fecha--'20180515'
	--and c.codasesor=@codpromotor--'CGM891025M5RR3'
	and c.codoficina= @codoficina
	--and c.fechadesembolso>='20180501'
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	group by dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM'), c.codasesor
) a on a.periodo=p.periodo and a.codasesor = p.CodPromotor

--select '3', * from #PeriodosPromotores --comentar


DECLARE @STRG_2 AS VARCHAR(8000)
DECLARE @SQL_2 AS VARCHAR(8000)
CREATE TABLE #PIVOT_PROMOTORES ( PIVOT VARCHAR (8000) )
SET @STRG_2='' SET @SQL_2=''

/*Agrupacion para el saldo*/
--Se calculan las columnas segun el filtro de fechas
INSERT INTO #PIVOT_PROMOTORES 
SELECT DISTINCT 'sum(CASE WHEN periodo='''+ RTRIM(CAST(periodo AS VARCHAR(500))) + ''' THEN CO_Psaldo ELSE 0 END) AS ''S' + RTRIM(CAST(periodo AS VARCHAR(500))) + ''', ' AS PIVOT
FROM #PeriodosPromotores

--select '#PeriodosPromotores', * from #PeriodosPromotores  --borrar

SET @SQL_2 ='SELECT Promotor, 0 as Saldo500, 1 as Item,''Saldo'' Etiqueta, ' --periodo,
SELECT @SQL_2= @SQL_2 + RTRIM(convert(varchar(500), pivot))
FROM #PIVOT_PROMOTORES 
ORDER BY PIVOT

SET @SQL_2 = SUBSTRING(@SQL_2,1,LEN(@SQL_2)-1)
SET @SQL_2=@SQL_2 + ' FROM #PeriodosPromotores group by Promotor ' --GROUP BY periodo

--print '@SQL_2= ' + @SQL_2  --borrar
--EXECUTE (@SQL_2)

create table #TblPromotores(
	item int,
	etiqueta varchar(10),
	Promotor varchar(40),
	Saldo500 decimal(8,2),
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

SET @SQL_2 = 'insert into #TblPromotores(promotor, Saldo500, item,etiqueta ,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13) select * from(' + @SQL_2 + ') a '
--print @SQL_2  --comentar
EXECUTE (@SQL_2) 

--select '#TblPromotores',* from #TblPromotores --borrar

--<<<<<<<<<<<<<<< TITULOS CARTERA RIESGO  <<<<<<<<<<<<<<<<<
CREATE TABLE #PIVOT_PROMOTORES_2 (id integer identity, PIVOT VARCHAR (8000) )
declare @SQL_22 as varchar(2000)
set @SQL_22 = ''

INSERT INTO #PIVOT_PROMOTORES_2 (PIVOT) 
select  ' '''+ substring( RTRIM(CAST(periodo AS VARCHAR(50))) ,5, 2) + 'M ' + substring( RTRIM(CAST(periodo AS VARCHAR(50))) ,1, 4) +  ''' ' AS PIVOT
from
(
	select dbo.fdufechaatexto(@fecha,'AAAAMM') as periodo --fecha
	union
	select periodo
	from tclperiodo with(nolock)
	where ultimodia<=@fecha--'20180515'
	and ultimodia>=dateadd(month,-12,@fecha)--'20180515')
) as x

--SET @SQL_22 ='SELECT ''' + convert(varchar,@fecha,112) + ''',''' + '@codpromotor' + ''','''+ @codoficina + ''', ''CarteraRiesgoTit'', 0 as Item, ''%CER@4'' as Etiqueta ' 
SET @SQL_22 ='SELECT ''' + convert(varchar,@fecha,112) + ''', '''+ @codoficina + ''', 0 as Item, ''%CER@4'' as Etiqueta , ''' + 'PROMOTOR' + ''', ''0''' 
SELECT @SQL_22= @SQL_22 + ',' + RTRIM(convert(varchar(15), pivot)) + ''
FROM #PIVOT_PROMOTORES_2 
ORDER BY id -- PIVOT

SET @SQL_22 = @SQL_22 + ', ''Estatus'', ''% de Bono'' '

--print @SQL_22

--SET @SQL_2 = 'insert into #TblPromotoresText(item,etiqueta,Promotor,Saldo500,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,PEstatus,NEstatus) ' + @SQL_22 + '  '
SET @SQL_2 = 'insert into tCsRptEMI_LS_PorPromotor(Fecha,Codoficina,item,etiqueta,Promotor,Saldo500,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,PEstatus,NEstatus) ' + @SQL_22 + '  '

--print @SQL_2
EXECUTE (@SQL_2) 

--select * from #TblPromotoresText

drop table #PIVOT_PROMOTORES_2

-->>>>>>>>>>>>>>>>>>>>>>>>

--Actualiza el estatus por promotor
update #TblPromotores set
PEstatus = (case 
            when ((case m1 when -1 then 0 else 1 end)+(case m2 when -1 then 0 else 1 end)+(case m3 when -1 then 0 else 1 end)+
				  (case m4 when -1 then 0 else 1 end)+(case m5 when -1 then 0 else 1 end)+(case m6 when -1 then 0 else 1 end)+
				  (case m7 when -1 then 0 else 1 end)+(case m8 when -1 then 0 else 1 end)+(case m9 when -1 then 0 else 1 end)+
				  (case m10 when -1 then 0 else 1 end)+(case m11 when -1 then 0 else 1 end)+(case m12 when -1 then 0 else 1 end)
				 )> 0 then
					isnull(
						(case m1 when -1 then 0 else m1 end)+(case m2 when -1 then 0 else m2 end)+(case m3 when -1 then 0 else m3 end)+
						(case m4 when -1 then 0 else m4 end)+(case m5 when -1 then 0 else m5 end)+(case m6 when -1 then 0 else m6 end)+
						(case m7 when -1 then 0 else m7 end)+(case m8 when -1 then 0 else m8 end)+(case m9 when -1 then 0 else m9 end)+
						(case m10 when -1 then 0 else m10 end)+(case m11 when -1 then 0 else m11 end)+(case m12 when -1 then 0 else m12 end)
						/
						nullif(  --para evitar error en division x cero
								(case m1 when -1 then 0 else 1 end)+(case m2 when -1 then 0 else 1 end)+(case m3 when -1 then 0 else 1 end)+
								(case m4 when -1 then 0 else 1 end)+(case m5 when -1 then 0 else 1 end)+(case m6 when -1 then 0 else 1 end)+
								(case m7 when -1 then 0 else 1 end)+(case m8 when -1 then 0 else 1 end)+(case m9 when -1 then 0 else 1 end)+
								(case m10 when -1 then 0 else 1 end)+(case m11 when -1 then 0 else 1 end)+(case m12 when -1 then 0 else 1 end)
								,0)
						, 0)
			else
				0
			end
			)

--Actualiza el NEstatus por promotor
update #TblPromotores set NEstatus=(case when PEstatus<=4 then 'EXCELENTE' when PEstatus>4 and PEstatus<=6 then 'ACEPTABLE' else 'NO ACEPTABLE' end) where etiqueta='Saldo'

--select 'CarteraRiesgoPorPromotor',* from #TblPromotores  --COMENTAR e insertar en tabla con titulos

insert into tCsRptEMI_LS_PorPromotor (Fecha,Codoficina, item, etiqueta, Promotor, Saldo500, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, PEstatus, NEstatus, Estatus)
select convert(varchar,@fecha,112), @codoficina, item, etiqueta, Promotor, Saldo500, (case when m1 > -1 then convert(varchar,m1) else 'NA' end), (case when m2 > -1 then convert(varchar,m2) else 'NA' end), (case when m3 > -1 then convert(varchar,m3) else 'NA' end), (case when m4 > -1 then convert(varchar,m4) else 'NA' end), (case when m5 > -1 then convert(varchar,m5) else 'NA' end), (case when m6> -1 then convert(varchar,m6) else 'NA' end), (case when m7 > -1 then convert(varchar,m7) else 'NA' end), (case when m8 > -1 then convert(varchar,m8) else 'NA' end), (case when m9 > -1 then convert(varchar,m9) else 'NA' end), (case when m10 > -1 then convert(varchar,m10) else 'NA' end), (case when m11 > -1 then convert(varchar,m11) else 'NA' end), (case when m12 > -1 then convert(varchar,m12) else 'NA' end), (case when m13 > -1 then convert(varchar,m13) else 'NA' end), PEstatus, NEstatus, Estatus from #TblPromotores

drop table #PIVOT_PROMOTORES
drop table #PeriodosPromotores
drop table #TblPromotores

--regresa resultado
--select * from tCsRptEMI_LS_PorPromotor where Fecha = @fecha and CodOficina = @codoficina


GO