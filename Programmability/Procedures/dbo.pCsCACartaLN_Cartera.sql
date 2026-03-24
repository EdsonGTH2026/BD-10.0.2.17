SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACartaLN_Cartera] @fecha smalldatetime, @codoficina varchar(4)
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

--############################################################################## CARTERA
/*Cartera:*/
PRINT '#####################################################################################'
PRINT '##################################### CARTERA ######################################'

--Limpia la tabla Final
delete from tCsRptEMI_LS_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina

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
,count(case when c.nrodiasatraso<=29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then c.codprestamo else null end) NCBM
,sum(case when c.nrodiasatraso<=29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCBM
,count(case when c.nrodiasatraso>29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then c.codprestamo else null end) NCAM
,sum(case when c.nrodiasatraso>29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCAM
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.cartera='ACTIVA'
--and c.codasesor=@codpromotor
and c.codoficina = @codoficina
and c.fecha=@fecini2 
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

--Actualiza los campos AM de la etiqueta INICIO, pero ahora considerando la cartera diferente a CANCELADA y sin importar que se el saldo sea mayor a 500
print 'REVISAR REVISAR'
--update #Ca set
--#Ca.NCAM = x.NCAM,
--#Ca.SCAM = x.SCAM
--select *
select 
x.CodProducto, count(x.CodProducto) as '#'
--x.codprestamo, x.estado
--x.NCAM, x.SCAM
from #Ca
inner join (
	select 
1 as item,'Inicio' as etiqueta
	--,count(case when c.nrodiasatraso>29 then c.codprestamo else null end) NCAM
	--,sum(case when c.nrodiasatraso>29  then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCAM
,c.codprestamo,c.estado, CodProducto
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	where 1= 1
    --and c.cartera not in ('CASTIGADA') --= 'ACTIVA' --<>'CANCELADA'
--and c.estado not in ('CANCELADO') -- in ('VENCIDO','CASTIGADO' )
	--and c.codasesor=@codpromotor
and c.codoficina = @codoficina
and c.nrodiasatraso > 29
	and c.fecha=@fecini2 
	and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
) as x on x.item = #Ca.item and x.etiqueta = #Ca.etiqueta
--group by x.estado
group by x.CodProducto

insert into #Ca (item,etiqueta,NCBM,SCBM,NCAM,SCAM)
select 2,'Hoy' etiqueta
,count(case when c.nrodiasatraso<=29 then c.codprestamo else null end) NCBM
,sum(case when c.nrodiasatraso<=29 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCBM
,count(case when c.nrodiasatraso>29 then c.codprestamo else null end) NCAM
,sum(case when c.nrodiasatraso>29 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCAM
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.cartera='ACTIVA'
--and c.codasesor=@codpromotor
and c.codoficina = @codoficina
and c.fecha=@fecha
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
	--and c.codasesor=@codpromotor--'CGM891025M5RR3'
and c.codoficina = @codoficina
	and c.fecha=@fecha --@fecini--'20180501'
	and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
) as x on x.item = #Ca.item and x.etiqueta = #Ca.etiqueta



insert into #Ca (item,etiqueta,NCBM,SCBM)
select 3,'Cre500' etiqueta
,count(case when c.nrodiasatraso<=29 then (case when (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16)>=500 then c.codprestamo else null end) else null end) NCBM500
,sum(case when c.nrodiasatraso<=29 then (case when (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16)>=500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) else 0 end) SCBM500
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.cartera='ACTIVA'
--and c.codasesor=@codpromotor
and c.codoficina = @codoficina 
and c.fecha=@fecha
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



--insert into #Ca (item,etiqueta)
--select 6, @MetaCredito e

--Se utiliza la misma forma de calculo de crecimiento propio y crecimiento huerfano
--set @CliPropios = @num2-@num1-@RenoNro 
--set @RenoNro = @num2-@num1 


declare @CAnrocre int
declare @CAsaldo money
select @CAnrocre=ncbm,@CAsaldo=scbm from #Ca where item=3
--select * from #Ca

create table #CAcuadro(
	item int,
	etiqueta varchar(20),
	InicioMes money,
	Hoy money,
	CreSalMay500 money
)
insert into #CAcuadro (item,etiqueta,InicioMes,Hoy,CreSalMay500)
select 1,'Saldo en CBM'
,sum(case when item=1 then SCBM else 0 end) I
,sum(case when item=2 then SCBM else 0 end) H
,sum(case when item=3 then SCBM else 0 end) C5
from #CA

insert into #CAcuadro (item,etiqueta,InicioMes,Hoy,CreSalMay500)
select 3,'# en CBM'
,sum(case when item=1 then NCBM else 0 end) I
,sum(case when item=2 then NCBM else 0 end) H
,sum(case when item=3 then NCBM else 0 end) C5
from #CA

select @ncreBM = sum(case when item=3 then NCBM else 0 end) from #CA

insert into #CAcuadro (item,etiqueta,InicioMes,Hoy)
select 2,'Saldo en CAM'
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
--update #CAcuadro set
--NumPasoAM = Hoy - InicioMes
--where 
--item = 4

--select 'CARTERA', * from #CAcuadro --COMENTAR

insert into tCsRptEMI_LS_Cartera (Fecha, CodOficina, item, etiqueta, InicioMes, Hoy, CreSalMay500 )
select @fecha, @codoficina, item, etiqueta, InicioMes, Hoy, CreSalMay500 from #CAcuadro  

--regresa los datos
--select * from tCsRptEMI_LS_Cartera where Fecha = @fecha and CodOficina = @codoficina order by item

--Borra las tablas temporales
drop table #CAcuadro
drop table #Ca


GO