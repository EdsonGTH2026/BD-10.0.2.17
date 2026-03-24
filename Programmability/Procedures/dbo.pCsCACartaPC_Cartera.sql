SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACartaPC_Cartera] @fecha smalldatetime,@codpromotor varchar(15),@codoficina varchar(4)
as
set nocount on

--COMENTAR
/*
Declare @fecha smalldatetime
declare @codpromotor varchar(15)
declare @codoficina varchar(4)

set @fecha='20180515'
set @codpromotor='CGM891025M5RR3'
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

print '###################################################################################################'
print '######################################### Cartera #################################################'
print '###################################################################################################'

--##############################################33

/*Cartera:*/
--OJO : comentar estas variables en producción porque son calculados en fragmentos anteriores
--declare @RenoNro int
--declare @RenoSal money
--declare @CliPropios int
--set @RenoNro=1
--set @RenoSal=8000
--set @CliPropios=15

declare @nivel int
select @nivel = Nivel from tCsRptEMIPC_Promotor where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina

declare @RenoNro int
declare @RenoSal2 money
declare @CliPropios int

--select @RenoNro=count(case when codasesor is not null then codprestamo else null end) --Hnro
--,@RenoSal=sum(case when codasesor is not null then monto else 0 end) --Hmonto
--,@CliPropios= count(codprestamo)-count(case when codasesor is not null then codprestamo else null end)
--,@RenoSal2=sum(case when codasesor is not null then saldo else 0 end) --Hmonto
--from #CADe

select @RenoNro = Rnro from tCsRptEMIPC_ColocacionMes where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
select @RenoSal2 = hmonto from tCsRptEMIPC_ColocacionMes where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina

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

--regresa los datos
--select * from tCsRptEMIPC_Cartera where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina

GO