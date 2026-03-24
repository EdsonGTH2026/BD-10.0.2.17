SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCACartaLN_CarteraProd370] @fecha smalldatetime, @codoficina varchar(4)
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

--############################################################################## CARTERA PRODUCTO 370
PRINT '#####################################################################'
PRINT '######################### CARTERA PRODUCTO 370 ######################'

--Borralos datos anteriores
delete from tCsRptEMI_LS_CarteraProd370 where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina

create table #Ca370(
	item int,
	etiqueta varchar(300),
	NCBM int,
	SCBM money,
	NCAM int,
	SCAM money,
	NCER@4 money,
	SCER@4 money
)

insert into #Ca370 (item,etiqueta,NCBM,SCBM,NCAM,SCAM)
select 0,'Hoy370' etiqueta
,count(case when c.nrodiasatraso<=29 then c.codprestamo else null end) NCBM
,sum(case when c.nrodiasatraso<=29 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCBM
,count(case when c.nrodiasatraso>29 then c.codprestamo else null end) NCAM
,sum(case when c.nrodiasatraso>29 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) SCAM
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.cartera='ACTIVA'
and c.codoficina = @codoficina
and c.fecha=@fecha
and c.CodProducto = '370'
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

--++++++++++++++++++++++ @CER4
/*
create table #Periodos370(
	periodo varchar(6),
	CO_nro int default(0),
	CO_desembolso money default(0),
	CO_Cer4nro int default(0),
	CO_Cer4saldo money default(0),
	CO_Psaldo as (case when CO_desembolso=0.000 then 0.000 when CO_desembolso=-1 then -1  else (CO_Cer4saldo/CO_desembolso)*100 end),
	CO_Pnro as cast((case when CO_nro=0.000 then 0.00 when CO_desembolso=-1 then -1 else (CO_Cer4nro/cast(CO_nro as money))*100 end) as money)
)
insert into #Periodos370 (periodo)
select dbo.fdufechaatexto(@fecha,'AAAAMM') fecha
union
select periodo
from tclperiodo with(nolock)
where ultimodia<=@fecha
and ultimodia>=dateadd(month,-12,@fecha)

update #Periodos370 set 
CO_desembolso=isnull(a.monto,-1), CO_nro=isnull(a.nro,-1)
from #Periodos370 p 
left join
(
	select dbo.fdufechaatexto(desembolso,'AAAAMM') periodo, sum(monto) monto,count(codprestamo) nro
	from tcspadroncarteradet
	where 
	codoficina = @codoficina
	and desembolso>=@fecano
and codproducto = '370'
and codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	group by dbo.fdufechaatexto(desembolso,'AAAAMM')
) a on a.periodo=p.periodo

update #Periodos370
set CO_Cer4nro=nrocer,CO_Cer4saldo=saldocer
from #Periodos370 p inner join 
(
	select dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM') periodo
	,count(c.codprestamo) nro
	,sum(d.saldocapital+d.interesvigente+d.interesvencido) saldo
	,count(case when c.nrodiasatraso>=4 then c.codprestamo else null end) nrocer
	,sum(case when c.nrodiasatraso>=4 then d.saldocapital+ ((d.interesvigente+d.interesvencido)* 1.16) else 0 end) saldocer
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
	where c.fecha=@fecha
	and c.codoficina= @codoficina
and codproducto = '370'
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	group by dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM')
) a on a.periodo=p.periodo

select * from #Periodos370
drop table #Periodos370
*/

--select '@CER4' ----------------
declare @CO_desembolso money 
declare @CO_Cer4saldo money
declare @CO_nro integer
declare @CO_Cer4nro integer

select 
@CO_desembolso = isnull(a.monto,-1), --as CO_desembolso, 
@CO_nro = isnull(a.nro,-1) --as CO_nro
from
(
	select 
    --dbo.fdufechaatexto(desembolso,'AAAAMM') periodo, 
    sum(monto) as monto,count(codprestamo) as nro
	from tcspadroncarteradet
	where 
	codoficina = @codoficina
	and desembolso>=@fecano
	and desembolso<=@fecha
	and codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	and codproducto = '370'
	--group by dbo.fdufechaatexto(desembolso,'AAAAMM')
) a 

select
@CO_Cer4nro = nrocer, -- as CO_Cer4nro, 
@CO_Cer4saldo = saldocer --as CO_Cer4saldo
from 
(
	select 
    --dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM') periodo,
	count(c.codprestamo) as nro
	,sum(d.saldocapital+d.interesvigente+d.interesvencido) as saldo
	,count(case when c.nrodiasatraso>=4 then c.codprestamo else null end) as nrocer
	,sum(case when c.nrodiasatraso>=4 then d.saldocapital+ ((d.interesvigente+d.interesvencido)* 1.16) else 0 end) as saldocer
	from tcscartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
	where c.fecha=@fecha
	and c.codoficina= @codoficina
	and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
	and codproducto = '370'
	--group by dbo.fdufechaatexto(c.fechadesembolso,'AAAAMM')
) a

--select
--(case when @CO_desembolso=0.000 then 0.000 when @CO_desembolso=-1 then -1  else (@CO_Cer4saldo/@CO_desembolso)*100 end) as 'CO_Psaldo',
-- cast((case when @CO_nro=0.000 then 0.00 when @CO_desembolso=-1 then -1 else (@CO_Cer4nro/cast(@CO_nro as money))*100 end) as money) as 'CO_Pnro'

update #Ca370 set
NCER@4 = cast((case when @CO_nro=0.000 then 0.00 else (@CO_Cer4nro/cast(@CO_nro as money))*100 end) as money),
SCER@4 = (case when @CO_desembolso=0.000 then 0.000 else (@CO_Cer4saldo/@CO_desembolso)*100 end)
where item = 0

--++++++++++++++++++++++
--select 'CARTERA 370', * from #Ca370
--select * from #Periodos370

insert into tCsRptEMI_LS_CarteraProd370 (Fecha, CodOficina, item, etiqueta, NCBM, SCBM, NCAM, SCAM, NCER@4, SCER@4 )
select convert(varchar,@fecha,112), @codoficina, item, etiqueta, NCBM, SCBM, NCAM, SCAM, NCER@4, SCER@4 from #Ca370

--Regresa los datos
--select * from tCsRptEMI_LS_CarteraProd370

drop table #Ca370
--drop table #Periodos370



GO