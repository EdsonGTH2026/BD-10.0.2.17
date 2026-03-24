SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----exec pCsCuadroCAAHFechas '20180401','20180430'
----drop procedure pCsCuadroCAAHFechas
CREATE procedure [dbo].[pCsCuadroCAAHFechas] @fecini2 smalldatetime,@fecfin2 smalldatetime
as
set nocount on
--declare @fecini2 smalldatetime
--declare @fecfin2 smalldatetime
--set @fecfin2='20180430'
--set @fecini2='20180401'

declare @fecfin smalldatetime
declare @fecini smalldatetime
set @fecfin=@fecfin2
set @fecini=@fecini2

declare @T1 datetime
declare @T2 datetime
set @T1 = getdate()
declare @fecfin_a datetime
set @fecfin_a = dateadd(day,-1,@fecini)
--select @fecfin_a
----drop table #tca
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

create table #cuadro(
	id decimal(6,2),
	descripcion varchar(100),
	monto money
)
insert into #cuadro (id,descripcion)
select 1 item,'Cartera Activa FinAmigo' descripcion union
select 2 item,'Capital Inicial Vigente' descripcion union
select 2.1 item,'Capital Inicial Vencido' descripcion union
select 2.2 item,'Interes Inicial Vigente' descripcion union
select 2.3 item,'Interes Inicial Vencido' descripcion union
select 2.4 item,'Moratorio Inicial Vigente' descripcion union
select 2.5 item,'Moratorio Inicial Vencido' descripcion union
select 3 item,'Cobranza Capital' descripcion union
select 4 item,'Colocacion' descripcion union
select 5 item,'Capital Final Vigente' descripcion union
select 5.1 item,'Capital Final Vencida' descripcion union
select 5.2 item,'Interes Final Vigente' descripcion union
select 5.3 item,'Interes Final Vencido' descripcion union
select 5.4 item,'Moratorio Final Vigente' descripcion union
select 5.5 item,'Moratorio Final Vencido' descripcion union

select 6 item,'Capital Activa Progresemos' descripcion union
select 7 item,'Capital Inicial' descripcion union
select 7.1 item,'Capital Inicial Vencido' descripcion union
select 7.2 item,'Interes Inicial Vigente' descripcion union
select 7.3 item,'Interes Inicial Vencido' descripcion union
select 7.4 item,'Moratorio Inicial Vigente' descripcion union
select 7.5 item,'Moratorio Inicial Vencido' descripcion union
select 8 item,'Cobranza Capital' descripcion union
select 9 item,'Colocacion' descripcion union
select 10 item,'Cartera Final' descripcion union
select 10.1 item,'Cartera Final Vencida' descripcion union
select 10.2 item,'Interes Final Vigente' descripcion union
select 10.3 item,'Interes Final Vencido' descripcion union
select 10.4 item,'Moratorio Final Vigente' descripcion union
select 10.5 item,'Moratorio Final Vencido' descripcion union

select 11 item,'Cartera Pasiva mayor a 500 mil' descripcion union
select 12 item,'Saldo Inicial' descripcion union
select 13 item,'Retiros' descripcion union
select 14 item,'Colocacion ' descripcion union
select 14.1 item,'Captacion nuevos' descripcion union
select 14.2 item,'Captacion renovados' descripcion union

select 15 item,'Saldo Final' descripcion union
select 16 item,'Cartera Pasiva menor a 500 mil' descripcion union
select 17 item,'Saldo Inicial' descripcion union
select 18 item,'Retiros' descripcion union
select 19 item,'Colocacion ' descripcion union
select 19.1 item,'Captacion nuevos' descripcion union
select 19.2 item,'Captacion renovados' descripcion union

select 20 item,'Saldo Final' descripcion union
select 21 item,'Pasivos' descripcion union
select 22 item,'Saldo Inicial' descripcion union
select 23 item,'Pagos' descripcion union
select 24 item,'Captacion total' descripcion union
select 25 item,'Captacion nuevos' descripcion union
select 26 item,'Captacion renovados' descripcion union
select 27 item,'Saldo Final' descripcion union
select 28 item,'Flujo Operativo' descripcion union
select 29 item,'Gasto por Intereses AH' descripcion union
select 30 item,'Ingresos por Intereses CA' descripcion union
select 31 item,'Ingresos por Intereses CA Progresemos' descripcion union
select 32 item,'Ingresos efectivamente cobrados CA' descripcion union
select 33 item,'Ingresos efectivamente cobrados CA Progresemos' descripcion union
select 34 item,'Ingresos Iva' descripcion union
select 35 item,'Ingresos Comisiones (moratorios)' descripcion union
select 36 item,'Ingresos Seguros' descripcion union
select 37 item,'Ingresos Comercializadora (Comisiones)' descripcion union
select 38 item,'Saldo Comisión de pago tardío' descripcion union
select 39 item,'Comisiones pago tardío generadas en el periodo' descripcion union
select 40 item,'Comisiones pago tardío efectivamente cobradas' descripcion

declare @m1 as money
declare @m2 as money
declare @m3 as money
declare @m4 as money
declare @m5 as money
declare @m6 as money

select 
@m1=sum(case when c.codfondo<>'20' then cd.saldocapital else 0 end) + sum(case when c.codfondo='20' then cd.saldocapital*0.3 else 0 end) --capitalFinamigo
,@m2=sum(case when c.codfondo='20' then cd.saldocapital*0.7 else 0 end) --capitalProgresemos
,@m3=sum(case when c.codfondo<>'20' then cd.interesvigente+cd.interesvencido else 0 end) + sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.3 else 0 end) --interesFinamigo
,@m4=sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.7 else 0 end) --interesProgresemos
,@m5=sum(case when c.codfondo<>'20' then cd.moratoriovigente+cd.moratoriovencido else 0 end) + sum(case when c.codfondo='20' then (cd.moratoriovigente+cd.moratoriovencido)*0.3 else 0 end) --moratorioFinamigo
,@m6=sum(case when c.codfondo='20' then (cd.moratoriovigente+cd.moratoriovencido)*0.7 else 0 end) --moratorioProgresemos
FROM tCsCartera c with(nolock) 
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
--left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
--inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
where c.cartera='ACTIVA' and c.fecha=@fecfin_a--'20161231' --
and c.codoficina<>'97' and c.estado<>'VENCIDO'
and c.codprestamo not in (select codprestamo from #tca)

update #Cuadro set monto=@m1 where id=2--Capital inicial vigente finamigo
update #Cuadro set monto=@m2 where id=7--Capital inicial vigente progresemos
update #Cuadro set monto=@m3 where id=2.2--Interes Inicial Vigente finamigo
update #Cuadro set monto=@m4 where id=7.2--Interes Inicial Vigente progresemos
update #Cuadro set monto=@m5 where id=2.4--Moratorio Inicial Vigente finamigo
update #Cuadro set monto=@m6 where id=7.4--Moratorio Inicial Vigente progresemos

set @m1=0
set @m2=0
set @m3=0
set @m4=0
set @m5=0
set @m6=0

select 
@m1=sum(case when c.codfondo<>'20' then cd.saldocapital else 0 end) + sum(case when c.codfondo='20' then (cd.saldocapital)*0.3 else 0 end) --capitalFinamigo
,@m2=sum(case when c.codfondo='20' then (cd.saldocapital)*0.7 else 0 end) --capitalProgresemos
,@m3=sum(case when c.codfondo<>'20' then cd.interesvigente+cd.interesvencido else 0 end) + sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.3 else 0 end) --interesFinamigo
,@m4=sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.7 else 0 end) --interesProgresemos
,@m5=sum(case when c.codfondo<>'20' then cd.moratoriovigente+cd.moratoriovencido else 0 end) + sum(case when c.codfondo='20' then (cd.moratoriovigente+cd.moratoriovencido)*0.3 else 0 end) --moratorioFinamigo
,@m6=sum(case when c.codfondo='20' then (cd.moratoriovigente+cd.moratoriovencido)*0.7 else 0 end) --moratorioProgresemos
FROM tCsCartera c with(nolock) 
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
--left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
--inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
where c.cartera='ACTIVA' and c.fecha=@fecfin_a--'20161231' --
and c.codoficina<>'97' and c.estado='VENCIDO'
and c.codprestamo not in (select codprestamo from #tca)

update #Cuadro set monto=@m1 where id=2.1
update #Cuadro set monto=@m2 where id=7.1
update #Cuadro set monto=@m3 where id=2.3--Interes Inicial Vencido finamigo
update #Cuadro set monto=@m4 where id=7.3--Interes Inicial Vencido progresemos
update #Cuadro set monto=@m5 where id=2.5--Moratorio Inicial Vencido finamigo
update #Cuadro set monto=@m6 where id=7.5--Moratorio Inicial Vencido progresemos

set @T2 = getdate()
print 'Tiempo 1- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()

set @m1=0
set @m2=0
set @m3=0
set @m4=0
set @m5=0
set @m6=0

select @m1=sum(case when c.codfondo<>'20' then cd.saldocapital else 0 end) + sum(case when c.codfondo='20' then (cd.saldocapital)*0.3 else 0 end) --capitalFinamigo
,@m2=sum(case when c.codfondo='20' then (cd.saldocapital)*0.7 else 0 end) --capitalProgresemos
,@m3=sum(case when c.codfondo<>'20' then cd.interesvigente+cd.interesvencido else 0 end) + sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.3 else 0 end) --interesFinamigo
,@m4=sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.7 else 0 end) --interesProgresemos
,@m5=sum(case when c.codfondo<>'20' then cd.moratoriovigente+cd.moratoriovencido else 0 end) + sum(case when c.codfondo='20' then (cd.moratoriovigente+cd.moratoriovencido)*0.3 else 0 end) --moratorioFinamigo
,@m6=sum(case when c.codfondo='20' then (cd.moratoriovigente+cd.moratoriovencido)*0.7 else 0 end) --moratorioProgresemos
FROM tCsCartera c with(nolock) 
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
--left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
--inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
where c.cartera='ACTIVA' and c.fecha=@fecfin--'20161231' --
and c.codoficina<>'97' and c.estado<>'VENCIDO'
and c.codprestamo not in (select codprestamo from #tca)

update #Cuadro set monto=@m1 where id=5
update #Cuadro set monto=@m2 where id=10
update #Cuadro set monto=@m3 where id=5.2 --Interes Final Vigente finamigo
update #Cuadro set monto=@m4 where id=10.2--Interes Final Vigente progresemos
update #Cuadro set monto=@m5 where id=5.4--Moratorio Final Vigente finamigo
update #Cuadro set monto=@m6 where id=10.4--Moratorio Final Vigente progresemos

set @m1=0
set @m2=0
set @m3=0
set @m4=0
set @m5=0
set @m6=0

select 
@m1=sum(case when c.codfondo<>'20' then cd.saldocapital else 0 end) + sum(case when c.codfondo='20' then (cd.saldocapital)*0.3 else 0 end) --capitalFinamigo
,@m2=sum(case when c.codfondo='20' then (cd.saldocapital)*0.7 else 0 end) --capitalProgresemos
,@m3=sum(case when c.codfondo<>'20' then cd.interesvigente+cd.interesvencido else 0 end) + sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.3 else 0 end) --interesFinamigo
,@m4=sum(case when c.codfondo='20' then (cd.interesvigente+cd.interesvencido)*0.7 else 0 end) --interesProgresemos
,@m5=sum(case when c.codfondo<>'20' then cd.moratoriovigente+cd.moratoriovencido else 0 end) + sum(case when c.codfondo='20' then (cd.moratoriovigente+cd.moratoriovencido)*0.3 else 0 end) --moratorioFinamigo
,@m6=sum(case when c.codfondo='20' then (cd.moratoriovigente+cd.moratoriovencido)*0.7 else 0 end) --moratorioProgresemos
FROM tCsCartera c with(nolock) 
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
--left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
--inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
where c.cartera='ACTIVA' and c.fecha=@fecfin--'20161231' --
and c.codoficina<>'97' and c.estado='VENCIDO'
and c.codprestamo not in (select codprestamo from #tca)

update #Cuadro set monto=@m1 where id=5.1
update #Cuadro set monto=@m2 where id=10.1
update #Cuadro set monto=@m3 where id=5.3 --Interes Final Vencido finamigo
update #Cuadro set monto=@m4 where id=10.3--Interes Final Vencido progresemos
update #Cuadro set monto=@m5 where id=5.5--Moratorio Final Vencido finamigo
update #Cuadro set monto=@m6 where id=10.5--Moratorio Final Vencido progresemos

set @T2 = getdate()
print 'Tiempo 2- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()

/*COLOCACION*/
set @m1=0
set @m2=0
select @m1=sum(case when c.codfondo<>'20' then pc.monto else 0 end) 
+ sum(case when c.codfondo='20' then pc.monto*0.3 else 0 end) --capitalFinamigo
,@m2=sum(case when c.codfondo='20' then pc.monto*0.7 else 0 end) --capitalProgresemos
FROM tcspadroncarteradet pc
inner join tCsCartera c with(nolock) on pc.desembolso=c.fecha and pc.codprestamo=c.codprestamo	
where c.cartera='ACTIVA' and pc.desembolso>=@fecini--'20170101' --
and pc.desembolso<=@fecfin--'20170131' --
and c.codoficina<>'97'
--and c.codprestamo not in (select codprestamo from #tca)

update #Cuadro set monto=@m1 where id=4
update #Cuadro set monto=@m2 where id=9

set @T2 = getdate()
print 'Tiempo 3- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()

/*Calcular en 2.14*/
--Declare @Prod_CAPI money
--Declare @Lega_CAPI money
--Declare @Prog_CAPI money
--Declare @Prod_INTE money
--Declare @Lega_INTE money
--Declare @Prog_INTE money
--pCsAAdmPagosSaldos --> este puede ser 2.14
----exec [10.0.2.14].finmas.dbo.pCsPagosCapInt '20170101','20170131' ,@Prod_CAPI out,@Lega_CAPI out,@Prog_CAPI out
--exec [10.0.2.14].finmas.dbo.pCsPagosCapInt @fecini,@fecfin ,@Prod_CAPI out,@Lega_CAPI out,@Prog_CAPI out
--,@Prod_INTE out,@Lega_INTE out,@Prog_INTE out
set @m1=0
set @m2=0
set @m3=0
set @m4=0

select @m1=sum(case when c.codfondo<>'20' then t.montocapitaltran else 0 end) + sum(case when c.codfondo='20' then t.montocapitaltran*0.3 else 0 end) --capitalFinamigo
,@m2=sum(case when c.codfondo='20' then t.montocapitaltran*0.7 else 0 end) --capitalProgresemos
,@m3=sum(case when c.codfondo<>'20' then (t.montointerestran+t.montoinpetran) else 0 end) + sum(case when c.codfondo='20' then (t.montointerestran+t.montoinpetran)*0.3 else 0 end) --capitalFinamigo
,@m4=sum(case when c.codfondo='20' then (t.montointerestran+t.montoinpetran)*0.7 else 0 end) --capitalProgresemos
from tcstransacciondiaria t with(nolock)
inner join (select codprestamo, fechacorte 
			from tcspadroncarteradet with(nolock)
			group by codprestamo, fechacorte
			) p on p.codprestamo=t.codigocuenta
inner join tcscartera c with(nolock) on c.codprestamo=p.codprestamo and c.fecha=p.fechacorte
where t.fecha>=@fecini and t.fecha<=@fecfin--'20170813'
and t.codsistema='CA' and t.tipotransacnivel3 in(104,105) and t.extornado=0
and t.codigocuenta not in(select codprestamo from #tca)
and t.codoficina<>'97'

update #Cuadro set monto=@m1 where id=3
update #Cuadro set monto=@m2 where id=8
update #Cuadro set monto=@m3 where id=32
update #Cuadro set monto=@m4 where id=33

set @T2 = getdate()
print 'Tiempo 4- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()

/*interes devengado*/
set @m1=0
set @m2=0
--select '@m1'=sum(case when c.codfondo<>'20' then cd.interesdevengado else 0 end) 
--+ sum(case when c.codfondo='20' then cd.interesdevengado*0.3 else 0 end) 
--FROM tCsCartera c with(nolock) 
--inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
--where c.cartera='ACTIVA' 
--and (c.fecha>='20170807' --@fecini--
--and c.fecha<='20170813'--@fecfin--
--)
--and c.codoficina<>'97'
--and c.estado='VIGENTE'
--and c.codprestamo not in (select codprestamo from #tca)

--declare @fecini datetime
--declare @fecfin datetime
--set @fecfin='20170813'
--set @fecini='20170807'
--declare @T1 datetime
--declare @T2 datetime
--set @T1 = getdate()
--19,013 -->
--declare @m1 money
--drop table #c
create table #c(fecha datetime,codprestamo varchar(25),codfondo int,fechadesembolso smalldatetime)
insert into #c
--declare @c table(fecha datetime,codprestamo varchar(25),codfondo int)
--insert into @c
select c.fecha,c.codprestamo,c.codfondo,c.fechadesembolso
FROM tCsCartera c with(nolock) 
where c.cartera='ACTIVA' 
and (c.fecha>=@fecini--'20170807'--
and c.fecha<=@fecfin--'20170813'--
)
and c.codoficina<>'97'
and c.estado='VIGENTE'
and c.codprestamo not in (select codprestamo from #tca)

set @T2 = getdate()
print 'Tiempo 5- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()

--select codprestamo,interesdevengado
select @m1=sum(case when c.codfondo<>'20' then d.interesdevengado+(case when c.fechadesembolso>='20160720' then d.moratoriodevengado else 0 end) else 0 end) 
+ sum(case when c.codfondo='20' then (d.interesdevengado+(case when c.fechadesembolso>='20160720' then d.moratoriodevengado else 0 end))*0.3 else 0 end) 
,@m2=sum(case when c.codfondo='20' then (d.interesdevengado+(case when c.fechadesembolso>='20160720' then d.moratoriodevengado else 0 end))*0.7 else 0 end) 
from tcscarteradet d with(nolock)
inner join #c c on c.codprestamo=d.codprestamo and c.fecha=d.fecha
where d.codprestamo in(select codprestamo from #c)
and d.fecha>=@fecini--'20170807'--
and d.fecha<=@fecfin--'20170813'--

update #Cuadro set monto=@m1 where id=30
update #Cuadro set monto=@m2 where id=31

set @T2 = getdate()
print 'Tiempo 6- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()

drop table #c

/*Ahorro saldo inicial y final*/
set @m1=0
set @m2=0
set @m3=0

select @m1=sum(SaldoCuenta) --SaldoCuenta
,@m2=sum(case when SaldoCuenta>=500000 then SaldoCuenta else 0 end) --ma500
,@m3=sum(case when SaldoCuenta<500000 then SaldoCuenta else 0 end) --me500
from tcsahorros
where fecha=@fecfin_a and substring(codcuenta,5,1)='2'

update #Cuadro set monto=@m2 where id=12
update #Cuadro set monto=@m3 where id=17
update #Cuadro set monto=@m1 where id=22

set @T2 = getdate()
print 'Tiempo 7- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()

set @m1=0
set @m2=0
set @m3=0

select @m1=sum(SaldoCuenta) --SaldoCuenta
,@m2=sum(case when SaldoCuenta>=500000 then SaldoCuenta else 0 end) --ma500
,@m3=sum(case when SaldoCuenta<500000 then SaldoCuenta else 0 end) --me500
from tcsahorros
where fecha=@fecfin and substring(codcuenta,5,1)='2'

update #Cuadro set monto=@m2 where id=15
update #Cuadro set monto=@m3 where id=20
update #Cuadro set monto=@m1 where id=27

set @T2 = getdate()
print 'Tiempo 8- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()
/*Ahorros retiros y depositos*/
set @m1=0
set @m2=0
set @m3=0
--select sum(montototaltran) monto --fecha,codigocuenta,fraccioncta,renovado,tipotransacnivel2,tipotransacnivel3,descripciontran,montototaltran
select @m1=sum(montototaltran) --SaldoCuenta
,@m2=sum(case when montototaltran>=500000 then montototaltran else 0 end) --ma500
,@m3=sum(case when montototaltran<500000 then montototaltran else 0 end) --me500
from tcstransacciondiaria with(nolock)
where fecha>=@fecini and fecha<=@fecfin
and codsistema='AH' and tipotransacnivel1='E' and extornado=0
and substring(codigocuenta,5,1)='2' and tipotransacnivel3 not in(63,62)

update #Cuadro set monto=@m2 where id=13
update #Cuadro set monto=@m3 where id=18
update #Cuadro set monto=@m1 where id=23

set @T2 = getdate()
print 'Tiempo 8- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()
set @m1=0
set @m2=0
set @m3=0
--select sum(montototaltran) monto --fecha,codigocuenta,fraccioncta,renovado,codusuario,tipotransacnivel2,tipotransacnivel3,descripciontran,montototaltran--
select @m1=sum(montototaltran) --SaldoCuenta
,@m2=sum(case when montototaltran>=500000 then montototaltran else 0 end) --ma500
,@m3=sum(case when montototaltran<500000 then montototaltran else 0 end) --me500
from tcstransacciondiaria with(nolock)
where fecha>=@fecini and fecha<=@fecfin
and codsistema='AH' and tipotransacnivel1='I' and extornado=0
and substring(codigocuenta,5,1)='2' and tipotransacnivel3 not in(15,7)

update #Cuadro set monto=@m2 where id=14
update #Cuadro set monto=@m3 where id=19
update #Cuadro set monto=@m1 where id=24

/*Ahorro nuevos renovados*/
set @m1=0
set @m2=0
select --pa.codcuenta,a.saldocuenta,cta.codusuario
@m1 = sum(case when cta.codusuario is null then a.saldocuenta else 0 end) --ahnuevo
,@m2 = sum(case when cta.codusuario is not null then a.saldocuenta else 0 end)-- ahrenovado
from tcspadronahorros pa with(nolock)
inner join tcsahorros a with(nolock) 
on a.codcuenta=pa.codcuenta and a.fraccioncta=pa.fraccioncta and a.renovado=pa.renovado and a.fecha=pa.fecapertura
left outer join (
	select distinct codusuario
	from tcspadronahorros with(nolock)
	where substring(codproducto,1,1)='2'
	and fecapertura<@fecini 
	and feccancelacion>dateadd(day,-5,@fecini)
) cta on cta.codusuario=pa.codusuario
where substring(pa.codproducto,1,1)='2'
and pa.fecapertura>=@fecini and pa.fecapertura<=@fecfin

update #Cuadro set monto=@m1 where id=25
update #Cuadro set monto=@m2 where id=26

/*por montos*/
set @m1=0
set @m2=0
set @m3=0
set @m4=0
select --pa.codcuenta,a.saldocuenta,cta.codusuario
--@m1 = sum(case when cta.codusuario is null then a.saldocuenta else 0 end) --ahnuevo
--,@m2 = sum(case when cta.codusuario is not null then a.saldocuenta else 0 end)-- ahrenovado
@m1 = sum(case when cta.codusuario is null then 
					case when a.saldocuenta>=500000 then a.saldocuenta else 0 end
				else 0 end) --ahnuevo
,@m2 = sum(case when cta.codusuario is not null then 
					case when a.saldocuenta>=500000 then a.saldocuenta else 0 end
				else 0 end)-- ahrenovado
				
,@m3 = sum(case when cta.codusuario is null then 
					case when a.saldocuenta<500000 then a.saldocuenta else 0 end
				else 0 end) --ahnuevo
,@m4 = sum(case when cta.codusuario is not null then 
					case when a.saldocuenta<500000 then a.saldocuenta else 0 end
				else 0 end)-- ahrenovado
from tcspadronahorros pa with(nolock)
inner join tcsahorros a with(nolock) 
on a.codcuenta=pa.codcuenta and a.fraccioncta=pa.fraccioncta and a.renovado=pa.renovado and a.fecha=pa.fecapertura
left outer join (
	select distinct codusuario
	from tcspadronahorros with(nolock)
	where substring(codproducto,1,1)='2'
	and fecapertura<@fecini 
	and feccancelacion>dateadd(day,-5,@fecini)
) cta on cta.codusuario=pa.codusuario
where substring(pa.codproducto,1,1)='2'
and pa.fecapertura>=@fecini and pa.fecapertura<=@fecfin

update #Cuadro set monto=@m1 where id=14.1
update #Cuadro set monto=@m2 where id=14.2
update #Cuadro set monto=@m3 where id=19.1
update #Cuadro set monto=@m4 where id=19.2

/*Ahorros interes devengado*/
set @m1=0
select @m1=sum(case when interescalculado<0 then 0 else interescalculado end) --interescalculado
from tcsahorros
where fecha>=@fecini and fecha<=@fecfin 
and substring(codcuenta,5,1)='2'

update #Cuadro set monto=@m1 where id=29

set @T2 = getdate()
print 'Tiempo 8- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()

update #Cuadro set monto=(select monto*0.16 from #Cuadro where id=30) where id=34

/*ingresos comisiones*/
--declare @m1 money
--declare @m2 money
--declare @m3 money
set @m1=0
set @m2=0
set @m3=0
select @m1=sum(montoinpetran+montocargos),@m2=sum(MontoOtrosTran),@m3=sum(montocargos)
from tcstransacciondiaria t with(nolock)
where t.fecha>=@fecini and t.fecha<=@fecfin
and t.codsistema='CA' and t.tipotransacnivel3 in(104,105) and t.extornado=0
and t.codigocuenta not in(select codprestamo from #tca)
and t.codoficina<>'97'

update #Cuadro set monto=@m1 where id=35
update #Cuadro set monto=@m2 where id=36
update #Cuadro set monto=@m3 where id=40

set @T2 = getdate()
print 'Tiempo 8- '+ cast( datediff(millisecond, @T1, @T2) as char(10)) + ' mseg.'
set @T1 = getdate()

/*Pago tardio*/
set @m1=0
set @m2=0
select @m1 = sum(cd.cargomora)
FROM tCsCartera c with(nolock) 
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
--left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
--inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
where c.cartera='ACTIVA' and c.fecha=@fecfin--'20161231' --
and c.codoficina<>'97' --and c.estado<>'VENCIDO'
and c.codprestamo not in (select codprestamo from #tca)

--select @m2 = sum(cd.cargomora)
--FROM tCsCartera c with(nolock) 
--inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
----left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
----inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)  
--where c.cartera='ACTIVA' and c.fecha=@fecfin_a--'20161231' --
--and c.codoficina<>'97' --and c.estado<>'VENCIDO'
--and c.codprestamo not in (select codprestamo from #tca)

select @m2=isnull(sum(montodevengado),0)
from tcspadronplancuotas p with(nolock)
inner join tCsCartera c with(nolock) on p.codprestamo=c.codprestamo
where  c.cartera='ACTIVA' and c.fecha=@fecfin_a--'20161231' --
and c.codoficina<>'97' --and c.estado<>'VENCIDO'
and c.codprestamo not in (select codprestamo from #tca)
and p.codconcepto='MORA'
and p.fechavencimiento>=@fecini
and p.fechavencimiento<=@fecfin

update #Cuadro set monto=@m1 where id=38
--update #Cuadro set monto=@m1-@m2 where id=39
update #Cuadro set monto=@m2 where id=39

select * from #Cuadro

drop table #Cuadro
drop table #tca
GO

GRANT EXECUTE ON [dbo].[pCsCuadroCAAHFechas] TO [marista]
GO