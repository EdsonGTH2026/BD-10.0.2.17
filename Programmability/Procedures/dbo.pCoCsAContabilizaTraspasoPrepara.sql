SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCoCsAContabilizaTraspasoPrepara '20151103'
--drop procedure pCoCsAContabilizaTraspasoPrepara
CREATE procedure [dbo].[pCoCsAContabilizaTraspasoPrepara]	@fecha smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20151103'

--create table #tca(
--	codprestamo varchar(25),
--	prestamoid varchar(25),
--	codserviciop varchar(25)
--)
--insert into #tca (codprestamo,prestamoid,codserviciop)
--select codprestamo,codanterior,codserviciop from [10.0.2.14].finmas.dbo.tcaprestamos where codoficina>100

create table #CarDev(
	codoficina varchar(4),
	codprestamo varchar(25),
	estadoactual varchar(15),
	estadoanterior varchar(15),
	saldocapital decimal(16,2),
	interesvencido decimal(16,2),
	interesvigente decimal(16,2),
	moratorio decimal(16,2)
)

insert into #CarDev
--SELECT c.codoficina,c.codprestamo,c.nrodiasatraso,c.estado,sum(d.interesdevengado) interesdevengado,sum(d.moratoriodevengado) moratoriodevengado
--FROM tCsCartera c with(nolock)
--inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
--where c.fecha=@fecha and c.estado<>'CASTIGADO' and c.codoficina<>'97'
--and c.codprestamo not in (select codprestamo from #tca where codserviciop not in ('ALTA1','ALTA2','ALTA4'))
--group by c.codoficina,c.codprestamo,c.nrodiasatraso,c.estado
SELECT c.codoficina,c.codprestamo,c.estado,can.estado estadoanterior
,sum(case when c.codfondo=20 then (d.saldocapital)*0.3
		  when c.codfondo=21 then (d.saldocapital)*0.25
		  else d.saldocapital end) saldocapital
,sum(case when c.codfondo=20 then (d.interesvencido)*0.3 
		  when c.codfondo=21 then (d.interesvencido)*0.25
		  else d.interesvencido end) interesvencido
,sum(case when c.codfondo=20 then (d.interesvigente)*0.3 
		  when c.codfondo=21 then (d.interesvigente)*0.25
		  else d.interesvigente end) interesvigente
,sum(case when c.codfondo=20 then (d.moratoriovencido)*0.3
		  when c.codfondo=21 then (d.moratoriovencido)*0.25
		  else d.moratoriovencido end) moratoriovencido
--,sum(case when c.codfondo=20 then (d.interesdevengado+d.moratoriodevengado)*0.3 else d.interesdevengado+d.moratoriodevengado end)
FROM tCsCartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tCsCartera can with(nolock) on can.fecha=(c.fecha-1) and can.codprestamo=c.codprestamo
--where c.fecha=@fecha and c.estado<>'CASTIGADO' and c.codoficina<>97
--and c.estado<>can.estado
--and c.codprestamo not in (select codprestamo from #tca where codserviciop not in ('ALTA1','ALTA2','ALTA4'))
where c.fecha=@fecha and c.cartera='ACTIVA' and c.codoficina not in('97','230','231','999')
and c.estado<>can.estado
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
group by c.codoficina,c.codprestamo,c.estado,can.estado

drop table tCoTraspasoDiario
create table tCoTraspasoDiario(
	item int identity(1,1),
	fecha smalldatetime,
	codoficina varchar(4),
	codprestamo varchar(25),
	codcta varchar(15),
	debe money,
	haber money,
	glosagral varchar(200)
)

insert into tCoTraspasoDiario(fecha,codoficina,codprestamo,codcta,debe,haber,glosagral)
/*Traspaso capital a cartera vencida*/
select @fecha fecha,codoficina,codprestamo,'130210101' codcta,saldocapital debe,0 haber,'Traspaso capital a vencido Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estadoactual='VENCIDO' and saldocapital<>0
union
select @fecha fecha,codoficina,codprestamo,'130110101' codcta,0 debe,saldocapital haber,'Traspaso capital a vencido Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estadoactual='VENCIDO' and saldocapital<>0
union
/*Traspaso interes a cartera vencida*/
select @fecha fecha,codoficina,codprestamo,'139210101' codcta,interesvencido debe,0 haber,'Traspaso interes a vencido Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estadoactual='VENCIDO' and interesvencido<>0
union
select @fecha fecha,codoficina,codprestamo,'139110101' codcta,0 debe,interesvencido haber,'Traspaso interes a vencido Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estadoactual='VENCIDO' and interesvencido<>0
union
/*Traspaso capital a cartera vigente*/
select @fecha fecha,codoficina,codprestamo,'130210101' codcta,0 debe,saldocapital haber,'Traspaso capital a vigente Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estadoactual='VIGENTE' and saldocapital<>0
union
select @fecha fecha,codoficina,codprestamo,'130110101' codcta,saldocapital debe,0 haber,'Traspaso capital a vigente Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estadoactual='VIGENTE' and saldocapital<>0
union
/*Traspaso interes a cartera vigente*/
select @fecha fecha,codoficina,codprestamo,'139210101' codcta,0 debe,interesvigente haber,'Traspaso interes a vigente Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estadoactual='VIGENTE' and interesvigente<>0
union
select @fecha fecha,codoficina,codprestamo,'139110101' codcta,interesvigente debe,0 haber,'Traspaso interes a vigente Ptmo. [' + codprestamo + '] ' + ' a la fecha ' + dbo.fdufechaatexto(@fecha,'DD-MM-AAAA')  glosagral
from #CarDev
where estadoactual='VIGENTE' and interesvigente<>0


--drop table #tca
drop table #CarDev
GO