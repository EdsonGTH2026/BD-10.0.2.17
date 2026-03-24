SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pCsCruadroSaldosCA '20170101','20170131'
--drop procedure pCsCruadroSaldosCA
create procedure [dbo].[pCsCruadroSaldosCA] @fecini2 smalldatetime,@fecfin2 smalldatetime
as
declare @fecfin smalldatetime
declare @fecini smalldatetime
--set @fecfin='20170131'
--set @fecini='20170101'

set @fecfin=@fecfin2
set @fecini=@fecini2

declare @fecfin_a smalldatetime
set @fecfin_a = dateadd(day,-1,@fecini)

--drop table #tca
create table #tca(
	codprestamo varchar(25),
	prestamoid varchar(25),
	codserviciop varchar(25)
)
insert into #tca (codprestamo,prestamoid,codserviciop)
select codprestamo,codanterior,codserviciop
from [10.0.2.14].finmas.dbo.tcaprestamos --where codoficina>100
where cast(codoficina as int)>100 and cast(codoficina as int)<300
and codserviciop in ('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9')
--and estado not in ('ANULADO','CANCELADO')

--46,007
--42,435
--drop table #Cuadro
create table #Cuadro(
	item int,
	Nombre varchar(30),
	inicio money,
	cobranza money,
	colocacion money,
	final money,
	intcobrado money,
	intdevengado money
)

insert into #Cuadro
select 1,'Cartera FA',0,0,0,0,0,0 union
select 2,'Cartera Productiva',0,0,0,0,0,0 union
select 3,'Cartera Consumo',0,0,0,0,0,0 union
select 4,'Cartera Legado',0,0,0,0,0,0 union
select 5,'Total Cartera FA',0,0,0,0,0,0 union
select 6,'Cartera Progresemos',0,0,0,0,0,0 union
select 7,'Total cartera operación',0,0,0,0,0,0

--alter table #cuadro add intcobrado money
--alter table #cuadro add intdevengado money

Declare @CAProd money
Declare @CALega money
Declare @CAProg money

select --sum(saldocapital) saldocapital,
@CAProd=sum(carteraFAProductivo) --carteraFAProductivo
,@CALega=sum(carteraFALegado) --carteraFALegado
,@CAProg=sum(carteraProgresemos) --carteraProgresemos
from (
	select c.codprestamo
	,cd.saldocapital
	,case when c.codfondo<>'20' then
			case when c.codproducto in ('169','170') then cd.saldocapital else 0 end
		  else 0 end carteraFAProductivo
	,case when c.codfondo<>'20' then
			case when c.codproducto not in ('169','170') then cd.saldocapital else 0 end
		  else 0 end carteraFALegado
	,case when c.codfondo='20' then cd.saldocapital*0.3
		  else 0 end carteraProgresemos
	FROM tCsCartera c with(nolock) 
	inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
	left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
	inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
	where c.cartera='ACTIVA' and c.fecha=@fecfin_a--'20161231' --
	and c.codoficina<>'97'
	and c.codprestamo not in (select codprestamo from #tca)
) i
--update #Cuadro set inicio=0 --inicializa
update #Cuadro set inicio=@CAProd where item=2
update #Cuadro set inicio=@CALega where item=4
update #Cuadro set inicio=@CAProg where item=6

update #Cuadro set inicio=(select sum(inicio) from #Cuadro where item in(2,3,4)) where item=5
update #Cuadro set inicio=(select sum(inicio) from #Cuadro where item in(5,6)) where item=7

/*COLOCACION*/
--Declare @CAProd money
--Declare @CALega money
--Declare @CAProg money

set @CAProd=0
set @CALega=0
set @CAProg=0

select --sum(saldocapital) saldocapital,
@CAProd=sum(carteraFAProductivo) --carteraFAProductivo
,@CALega=sum(carteraFALegado) --carteraFALegado
,@CAProg=sum(carteraProgresemos) --carteraProgresemos
from (
	select c.codprestamo
	,pc.monto
	,case when c.codfondo<>'20' then
			case when c.codproducto in ('169','170') then pc.monto else 0 end
		  else 0 end carteraFAProductivo
	,case when c.codfondo<>'20' then
			case when c.codproducto not in ('169','170') then pc.monto else 0 end
		  else 0 end carteraFALegado
	,case when c.codfondo='20' then pc.monto*0.3
		  else 0 end carteraProgresemos
	FROM tcspadroncarteradet pc
	inner join tCsCartera c with(nolock) on pc.desembolso=c.fecha and pc.codprestamo=c.codprestamo	
	where c.cartera='ACTIVA' and pc.desembolso>=@fecini--'20170101' --
	and pc.desembolso<=@fecfin--'20170131' --
	and c.codoficina<>'97'
	and c.codprestamo not in (select codprestamo from #tca)
) i

update #Cuadro set colocacion=@CAProd where item=2
update #Cuadro set colocacion=@CALega where item=4
update #Cuadro set colocacion=@CAProg where item=6

update #Cuadro set colocacion=(select sum(colocacion) from #Cuadro where item in(2,3,4)) where item=5
update #Cuadro set colocacion=(select sum(colocacion) from #Cuadro where item in(5,6)) where item=7

/*Calcular en 2.14*/
Declare @Prod_CAPI money
Declare @Lega_CAPI money
Declare @Prog_CAPI money
Declare @Prod_INTE money
Declare @Lega_INTE money
Declare @Prog_INTE money

--exec [10.0.2.14].finmas.dbo.pCsPagosCapInt '20170101','20170131' ,@Prod_CAPI out,@Lega_CAPI out,@Prog_CAPI out
exec [10.0.2.14].finmas.dbo.pCsPagosCapInt @fecini,@fecfin ,@Prod_CAPI out,@Lega_CAPI out,@Prog_CAPI out
,@Prod_INTE out,@Lega_INTE out,@Prog_INTE out

update #Cuadro set cobranza=@Prod_CAPI where item=2
update #Cuadro set cobranza=@Lega_CAPI where item=4
update #Cuadro set cobranza=@Prog_CAPI where item=6

update #Cuadro set intcobrado=@Prod_INTE where item=2
update #Cuadro set intcobrado=@Lega_INTE where item=4
update #Cuadro set intcobrado=@Prog_INTE where item=6

update #Cuadro set cobranza=(select sum(cobranza) from #Cuadro where item in(2,3,4)) where item=5
update #Cuadro set cobranza=(select sum(cobranza) from #Cuadro where item in(5,6)) where item=7

update #Cuadro set intcobrado=(select sum(intcobrado) from #Cuadro where item in(2,3,4)) where item=5
update #Cuadro set intcobrado=(select sum(intcobrado) from #Cuadro where item in(5,6)) where item=7
--update #Cuadro set cobranza=0,intcobrado=0,intdevengado=0
--02:45 seg

/*cartera final*/
--Declare @CAProd money
--Declare @CALega money
--Declare @CAProg money

set @CAProd=0
set @CALega=0
set @CAProg=0

select --sum(saldocapital) saldocapital,
@CAProd=sum(carteraFAProductivo) --carteraFAProductivo
,@CALega=sum(carteraFALegado) --carteraFALegado
,@CAProg=sum(carteraProgresemos) --carteraProgresemos
from (
	select c.codprestamo
	,cd.saldocapital
	,case when c.codfondo<>'20' then
			case when c.codproducto in ('169','170') then cd.saldocapital else 0 end
		  else 0 end carteraFAProductivo
	,case when c.codfondo<>'20' then
			case when c.codproducto not in ('169','170') then cd.saldocapital else 0 end
		  else 0 end carteraFALegado
	,case when c.codfondo='20' then cd.saldocapital*0.3
		  else 0 end carteraProgresemos
	FROM tCsCartera c with(nolock) 
	inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
	left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
	inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
	where c.cartera='ACTIVA' and c.fecha=@fecfin--'20170131' --
	and c.codoficina<>'97'
	and c.codprestamo not in (select codprestamo from #tca)
) i

update #Cuadro set final=@CAProd where item=2
update #Cuadro set final=@CALega where item=4
update #Cuadro set final=@CAProg where item=6

update #Cuadro set final=(select sum(final) from #Cuadro where item in(2,3,4)) where item=5
update #Cuadro set final=(select sum(final) from #Cuadro where item in(5,6)) where item=7

/*interes devengado*/
--Declare @CAProd money
--Declare @CALega money
--Declare @CAProg money

set @CAProd=0
set @CALega=0
set @CAProg=0

select --sum(saldocapital) saldocapital,
@CAProd=sum(carteraFAProductivo) --carteraFAProductivo
,@CALega=sum(carteraFALegado) --carteraFALegado
,@CAProg=sum(carteraProgresemos) --carteraProgresemos
from (
	select c.codprestamo
	,case when c.codfondo<>'20' then
			case when c.codproducto in ('169','170') then cd.interesdevengado else 0 end
		  else 0 end carteraFAProductivo
	,case when c.codfondo<>'20' then
			case when c.codproducto not in ('169','170') then cd.interesdevengado else 0 end
		  else 0 end carteraFALegado
	,case when c.codfondo='20' then cd.interesdevengado*0.3
		  else 0 end carteraProgresemos
	FROM tCsCartera c with(nolock) 
	inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
	--left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
	--inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
	where c.cartera='ACTIVA' 
	and (c.fecha>=@fecini--'20170101' --
	and c.fecha<=@fecfin--'20170131'--
	)
	and c.codoficina<>'97'
	and c.estado='VIGENTE'
	and c.codprestamo not in (select codprestamo from #tca)
) i

--select --sum(saldocapital) saldocapital,
--@CAProd=@CAProd+sum(carteraFAProductivo) --carteraFAProductivo
--,@CALega=@CALega+sum(carteraFALegado) --carteraFALegado
--,@CAProg=@CAProg+sum(carteraProgresemos) --carteraProgresemos
--from(
--	select c.codprestamo
--		,case when c.codfondo<>'20' then
--				case when c.codproducto in ('169','170') then cd.interesdevengado else 0 end
--			  else 0 end carteraFAProductivo
--		,case when c.codfondo<>'20' then
--				case when c.codproducto not in ('169','170') then cd.interesdevengado else 0 end
--			  else 0 end carteraFALegado
--		,case when c.codfondo='20' then cd.interesdevengado*0.3
--			  else 0 end carteraProgresemos
--	FROM tCsCartera c with(nolock) 
--	inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
--	where c.cartera='ACTIVA' 
--		and (c.fecha>='20170101' --@fecini--
--		and c.fecha<='20170131'--@fecfin--
--		)
--		and c.codoficina<>'97'
--		and c.estado='VIGENTE'
--		and c.codprestamo in(
--			select codprestamo from tcspadroncarteradet with(nolock)
--			where cancelacion>='20170101' --@fecini--
--			and cancelacion<='20170131' --@fecfin--
--			and codprestamo not in (select codprestamo from #tca)
--		)
--) i

update #Cuadro set intdevengado=@CAProd where item=2
update #Cuadro set intdevengado=@CALega where item=4
update #Cuadro set intdevengado=@CAProg where item=6

update #Cuadro set intdevengado=(select sum(intdevengado) from #Cuadro where item in(2,3,4)) where item=5
update #Cuadro set intdevengado=(select sum(intdevengado) from #Cuadro where item in(5,6)) where item=7
--07:11seg

select * from #Cuadro

drop table #tca
drop table #Cuadro


GO

GRANT EXECUTE ON [dbo].[pCsCruadroSaldosCA] TO [marista]
GO