SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--antes 00:08:56  
CREATE PROCEDURE [dbo].[pvINTFCuentaSIC] @fecha smalldatetime   
AS  
SET NOCOUNT ON  
  
--------select getdate(), '1' --borrar  
--declare @fecha smalldatetime  --COMENTAR  
--set @fecha = '20201130'   --COMENTAR  
  
declare @fecini smalldatetime  
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'  
--select @fecini  
declare @T1 datetime  
declare @T2 datetime  
  
/*DEFINIR LOS CREDITOS PARA PLAN CUOTAS*/  
create table #CA(codprestamo char(19),tipo varchar(20),codusuario varchar(20), codfondo int)  
insert into #CA  
--select '004-170-06-07-01772','Cartera','BMA2509811     '  
select codprestamo,tipo,codusuario,codfondo  
from tCsBuroxTblReINomVr14 with(nolock)  
--where codprestamo='318-370-06-08-00791'  
  
--drop table #CA  
create table #Ca_unique(codprestamo char(19),codfondo int)  
insert into #Ca_unique  
select distinct codprestamo,codfondo from #CA with(nolock)  
  
set @T1 = getdate()  
create table #tblmop_tmp(  
  codprestamo char(19),  
  codusuario  varchar(15),  
  seccuota    smallint,  
  DiasAtrCuota int  
)  
--00:01:19 509,142--> consulta  
--00:00:05 insert  
insert into #tblmop_tmp  
SELECT CodPrestamo, CodUsuario,SecCuota,max(DiasAtrCuota) DiasAtrCuota  
FROM tCsPadronPlanCuotas with(nolock)   
where FechaVencimiento<=@fecha--'20200531' --  
and numeroplan=0 and seccuota>0  
and codprestamo in (select codprestamo from #Ca_unique)  
group by CodPrestamo, CodUsuario,SecCuota  
  
create table #tblmop(  
  codprestamo char(19),  
  codusuario  varchar(15),  
  seccuota    smallint,  
  MOP         varchar(3)  
)  
--00:00:03 --> insert  
insert into #tblmop  
SELECT DISTINCT PC.CodPrestamo, PC.CodUsuario,PC.SecCuota  
, CASE WHEN substring(PC.codprestamo, 5, 3) = '303' THEN '01' ELSE B.MOP END MOP  
FROM #tblmop_tmp PC with(nolock)   
INNER JOIN tCsBuroMOP B with(nolock)ON PC.DiasAtrCuota >= B.Inicio AND PC.DiasAtrCuota <= B.Fin  
  
drop table #tblmop_tmp  
  
set @T2 = getdate()  
print '1--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
---------------------------------------------------------------------------------------  
create table #tblmesgar(  
  fecha         smalldatetime,  
  codigo        varchar(25),  
  ImporteAvaluo money,  
  DescGarantia  varchar(300)  
)  
insert into #tblmesgar  
--00:00:00 insert  
SELECT Filtro.Fecha, Filtro.Codigo, sum(Filtro.Garantia) AS ImporteAvaluo ,'CREDITO GARANTIZADO' DescGarantia  
FROM (  
    SELECT Fecha, Codigo,codoficina, MAX(Garantia) AS Garantia  
    FROM (  
        SELECT Fecha, Codigo, codoficina, TipoGarantia, Round(SUM(Garantia), 0) AS Garantia  
        FROM tCsdiaGarantias with(nolock)  
        WHERE Estado in('ACTIVO','MODIFICADO') and fecha=@fecha--'20200531'--  
  --and codoficina not in ('230','231')   
  and codigo in(select codprestamo from #Ca_unique with(nolock))  
        GROUP BY Fecha, Codigo,codoficina, TipoGarantia  
    ) Datos  
    GROUP BY Fecha, Codigo,codoficina  
) Filtro   
group by Filtro.Fecha, Filtro.Codigo  
--drop table #tblmesgar  
  
set @T2 = getdate()  
print '2--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
--------------------------------------------------------------------------------------  
create table #tCsMesPlanCuotas(  
  fecha          smalldatetime,  
  codprestamo    char(19),  
  MontoDevengado money,  
  MontoPagado    money,  
  MontoCondonado money,  
  DiasAtrCuota   smallint,  
  codoficina varchar(4)  
)  
insert into #tCsMesPlanCuotas  
--00:00:11 --> revisar  
SELECT p.Fecha, p.CodPrestamo  
 ,case when u.codfondo=20 then 0.3*p.MontoDevengado else p.MontoDevengado end MontoDevengado  
 ,case when u.codfondo=20 then 0.3*p.MontoPagado else p.MontoPagado end MontoPagado  
 ,case when u.codfondo=20 then 0.3*p.MontoCondonado else p.MontoCondonado end MontoCondonado  
 ,CASE WHEN p.DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota  
 ,p.codoficina  
FROM tCsPlanCuotas p with(nolock)  
inner join #Ca_unique u with(nolock) on p.codprestamo=u.codprestamo  
WHERE --CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE') AND   
p.EstadoConcepto NOT IN ('ANULADO', 'CANCELADO')  
and p.fecha=@fecha--'20200531'--  
and p.numeroplan=0 and seccuota>0  
and p.codprestamo in(select codprestamo from #Ca_unique with(nolock))  
--drop table #tCsMesPlanCuotas  
  
--SELECT *  
--FROM tCsPlanCuotas p with(nolock)  
--inner join #Ca_unique u with(nolock) on p.codprestamo=u.codprestamo  
--WHERE p.EstadoConcepto NOT IN ('ANULADO', 'CANCELADO')  
--and p.fecha=@fecha--'20200531'--  
--and p.numeroplan=0 and seccuota>0  
--and p.codprestamo in(select codprestamo from #Ca_unique with(nolock))  
  
--select * from #tCsMesPlanCuotas  
  
--SELECT CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado) + 0.5, 0) AS SaldoVencido  
--from #tCsMesPlanCuotas with(nolock)  
--WHERE DiasAtrCuota = 1  
--GROUP BY CodPrestamo  
  
set @T2 = getdate()  
print '3--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
--------------------------------------------------------------------------------------  
create table #PrimerIncumplimiento_tmp(  
  codprestamo char(19),  
  fechavencimiento     smalldatetime,  
  DiasAtrCuota int  
)  
insert into #PrimerIncumplimiento_tmp  
--00:00:02  
SELECT CodPrestamo, min(fechavencimiento) fechavencimiento,DiasAtrCuota  
--FROM tCsPadronPlanCuotas with(nolock)  
FROM tCsPlanCuotas with(nolock)  
WHERE --CodConcepto IN ('CAPI', 'INPE', 'INVE', 'INTE') and   
fecha =@fecha and   
fechavencimiento<=@fecha--'20200531'--  
and numeroplan=0 and seccuota>0  
and codprestamo in(select codprestamo from #Ca_unique with(nolock))  
group by CodPrestamo,DiasAtrCuota  
  
create table #PrimerIncumplimiento(  
  codprestamo char(19),  
  fechapi     smalldatetime  
)  
insert into #PrimerIncumplimiento  
--00:00:00  
select CodPrestamo, min(fechavencimiento) fechavencimiento  
from #PrimerIncumplimiento_tmp  
where DiasAtrCuota>0-->00:01:35  
group by CodPrestamo  
  
drop table #PrimerIncumplimiento_tmp  
--drop table #PrimerIncumplimiento  
set @T2 = getdate()  
print '4--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
-------------------------------------------------------------------------------------  
create table #CAMo(  
 codprestamo varchar(25),  
 FechaUltimoMovimiento smalldatetime  
)  
insert into #CAMo  
--00:00:03  
select codprestamo,FechaUltimoMovimiento  
from(  
 --select distinct c.codprestamo,c.FechaUltimoMovimiento   
 --from tcscartera c with(nolock)  
 --where c.fecha=@fecha--'20200531'--  
 --and c.codprestamo in(select codprestamo from #Ca_unique with(nolock))  
 --union   
 --select distinct c.codprestamo,c.cancelacion FechaUltimoMovimiento   
 --from tcspadroncarteradet c with(nolock)  
 --where c.cancelacion>=@fecini--'20200501'--  
 --and c.cancelacion<=@fecha--'20200531'--  
 --and c.codprestamo in(select codprestamo from #Ca_unique with(nolock))  
 SELECT max(t.Fecha) FechaUltimoMovimiento,t.CodigoCuenta codprestamo  
 --select *  
 FROM tCsTransaccionDiaria t with(nolock)  
 where t.fecha<=@fecha--'20201031'--  
 and t.codsistema = 'CA'   
 and t.TipoTransacNivel1 in('I','O')   
 and t.TipoTransacNivel3 in(104,105,2) -- not in(101,100,99)  
 and t.extornado = 0  
 and t.codigocuenta in(select codprestamo from #Ca_unique with(nolock))  
 and t.fraccioncta='0' and t.renovado=0  
 and t.nrotransaccion>=0  
 --and t.codigocuenta in(  
 --'015-370-06-03-00180'  
 --)  
 group by t.CodigoCuenta  
) a  
--select * FROM tCsTransaccionDiaria t with(nolock) where codsistema='CA' and fecha>'20201201'  
create table #MontoUltPago (  
 fecha   datetime,  
    codprestamo  char(19),  
    montoultpago money  
)  
insert into #MontoUltPago  
--00:00:07  
SELECT t.Fecha,t.CodigoCuenta codprestamo  
--,sum(t.MontoCapitalTran+t.MontoInteresTran+t.MontoINPETran) monto  
,sum(case when c.codfondo=20   
  then   
   0.3*(t.MontoCapitalTran+t.MontoInteresTran+t.MontoINPETran)  
  else   
   t.MontoCapitalTran+t.MontoInteresTran+t.MontoINPETran  
  end + (montocargos+montootrostran+montoimpuestos)) monto  
FROM tCsTransaccionDiaria t with(nolock)  
inner join #CAMo b with(nolock) on t.codigocuenta=b.codprestamo and t.fecha=b.FechaUltimoMovimiento  
inner join #Ca_unique c with(nolock) on t.codigocuenta=c.codprestamo  
where t.fecha<=@fecha--'20201031'--  
and t.codsistema = 'CA' and t.TipoTransacNivel1 in('I','O') and t.TipoTransacNivel3 in(104,105,2) -- not in(101,100,99)  
and t.extornado = 0  
and t.codigocuenta in(select codprestamo from #Ca_unique with(nolock))  
and t.fraccioncta='0' and t.renovado=0  
and t.nrotransaccion>=0  
--and t.codigocuenta in(  
--'015-370-06-03-00180'  
--)  
group by t.Fecha,t.CodigoCuenta  
  
--select t.Fecha,t.CodigoCuenta codprestamo, sum(t.MontoCapitalTran+t.MontoInteresTran+t.MontoINPETran) monto,t.TipoTransacNivel3  
--FROM tCsTransaccionDiaria t with(nolock)  
--where t.codigocuenta in(  
--'025-170-06-09-04109',  
--'028-170-06-02-04902',  
--'028-170-06-09-04817',  
--'037-170-06-02-07386',  
--'302-170-06-06-07341',  
--'309-170-06-02-04594',  
--'309-170-06-04-04508',  
--'325-370-06-05-00320',  
--'003-170-06-09-02594'  
--)  
--and t.fecha>='20200501'  
--and t.codsistema='CA'  
-- and t.TipoTransacNivel1 in('I')  
-- and t.TipoTransacNivel3 in(104,105)  
--group by t.Fecha,t.CodigoCuenta,t.TipoTransacNivel3  
  
--drop table #MontoUltPago  
set @T2 = getdate()  
print '5--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
----------------------------------------------------------------------------------------  
--<<<<<<<<<<<<<< OSC: Crea y llena la tabla de Plazo en Meses  
create table #PlazoMeses(  
    codprestamo varchar(25),  
    meses       decimal(16,2),  
    MontoDesembolso int  
)  
insert into #PlazoMeses  
--00:00:03  
select distinct CodPrestamo, cast((datediff(d, c.FechaDesembolso , c.FechaVencimiento) / 30.4) as decimal(18, 2) ) as m2  
,convert(int,case when c.codfondo=20 then 0.3*c.MontoDesembolso else c.MontoDesembolso end)  
from tcscartera c with(nolock)   
where c.fecha=@fecha--'20200531'--  
and c.codprestamo in(select codprestamo from #Ca_unique with(nolock))  
union  
select distinct c.CodPrestamo, cast((datediff(d, c.Desembolso , cc.FechaVencimiento) / 30.4) as decimal(18, 2) ) as m2  
,convert(int,case when cc.codfondo=20 then 0.3*cc.MontoDesembolso else cc.MontoDesembolso end)  
from tcspadroncarteradet c with(nolock)  
inner join tcscartera cc with(nolock) on c.codprestamo=cc.codprestamo and c.fechacorte=cc.fecha  
where c.cancelacion>=@fecini--'20200501'--  
and c.cancelacion<=@fecha--'20200531'--  
and c.codprestamo in(select codprestamo from #Ca_unique with(nolock))  
  
--drop table #PlazoMeses  
set @T2 = getdate()  
print '6--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
-->>>>>>>>>>>>>> OSC  
--<<<<<<<<<<<<<<<<<<<<<<<<<< --OSC 05-10-2019  
select c.fecha,c.codprestamo,c.montodesembolso,c.fechadesembolso,c.NroCuotas  
--,c.SaldoCapital,c.SaldoInteresCorriente,c.SaldoINVE,c.SaldoINPE  
,sum(case when c.codfondo=20 then 0.3*d.saldocapital else d.saldocapital end) saldocapital  
,sum(case when c.codfondo=20 then 0.3*(d.interesvigente+d.interesvencido+d.interesctaorden) else d.interesvigente+d.interesvencido+d.interesctaorden end) SaldoInteresCorriente  
,sum(case when c.codfondo=20 then 0.3*d.interesvencido else d.interesvencido end) SaldoINVE  
,sum(case when c.codfondo=20 then 0.3*(d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden) else d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden end) SaldoINPE  
,sum(d.otroscargos) otroscargos  
,sum(d.cargomora) cargomora  
,sum(case when c.codfondo=20   
 then   
  case when d.cargomora>0 then  
   0.3*(d.impuestos - (d.cargomora*0.16))  
  else 0.3*d.impuestos end --> No hay cargo por mora  
 else d.impuestos end) impuestos  
,c.FechaUltimoMovimiento  
,c.NrodiasAtraso  
,c.codproducto,c.ModalidadPlazo,c.CodMoneda,c.Judicial,c.Cartera,c.codoficina,c.CuotaActual,c.NroCuotasPagadas   
into #tCsCarteraFecha  
from tcscartera c with(nolock)  
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo  
where c.fecha = @fecha  
and c.codprestamo in(select codprestamo from #Ca_unique with(nolock))  
group by c.fecha,c.codprestamo,c.montodesembolso,c.fechadesembolso,c.NroCuotas  
,c.FechaUltimoMovimiento  
,c.NrodiasAtraso  
,c.codproducto,c.ModalidadPlazo,c.CodMoneda,c.Judicial,c.Cartera,c.codoficina,c.CuotaActual,c.NroCuotasPagadas   
  
set @T2 = getdate()  
print '7--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
create table #MoProxAmorAtraso(  
 codprestamo char(19),  
 montopagar money  
)  
insert into #MoProxAmorAtraso  
--00:00:10  
select p.codprestamo--,seccuota,fechavencimiento  
--,sum(p.montocuota) saldo  
,sum(case when c.codfondo=20 then 0.3*p.montocuota else p.montocuota end) saldo  
from tcsplancuotas p with(nolock)  
inner join #Ca_unique c with(nolock) on c.codprestamo=p.codprestamo  
where p.fecha=@fecha--'20200531' --  
and p.numeroplan=0 and p.codprestamo in (select codprestamo from #Ca_unique with(nolock))  
and p.estadocuota<>'CANCELADO'  
and p.fechavencimiento<=@fecha--'20200531'--  
group by p.codprestamo--,seccuota,fechavencimiento  
--drop table #MoProxAmorAtraso  
  
create table #MoProxAmor(  
 codprestamo char(19),  
 montopagar money  
)  
insert into #MoProxAmor  
--00:00:25  
select x.codprestamo,'Montocuota'=x.saldo  
from (  
 select codprestamo,nro,max(saldo) saldo  
 from(  
  select codprestamo,count(seccuota) nro,saldo  
  from (  
   select codprestamo,seccuota,sum(montocuota) saldo  
   --from tcspadronplancuotas with(nolock)  
   from tcsplancuotas  with(nolock)  
   --where fecha='20200531' and numeroplan=0 and codprestamo='003-170-06-04-02652'--'003-170-06-00-02515'--'447-170-06-02-00028'--'311-170-06-06-01248'  
   where fecha=@fecha and numeroplan=0 and codprestamo in (select codprestamo from #Ca_unique with(nolock))  
   and estadocuota<>'CANCELADO'  
   --and codprestamo='002-123-06-00-00185'  
   group by codprestamo,seccuota  
  ) a  
  group by codprestamo,saldo  
 ) y  
 group by codprestamo,nro  
) x  
inner join(  
 select codprestamo,max(nro) nro  
 from (  
  select codprestamo,saldo,count(seccuota) nro  
  from (  
   select codprestamo,seccuota,sum(montocuota) saldo  
   --from tcspadronplancuotas with(nolock)     
   from tcsplancuotas with(nolock)  
   --where codprestamo='336-370-06-03-00624'  
   where fecha=@fecha and numeroplan=0 and codprestamo in (select codprestamo from #Ca_unique with(nolock))  
   and estadocuota<>'CANCELADO'  
   --and codprestamo='002-123-06-00-00185'  
   group by codprestamo,seccuota  
  ) a  
  group by codprestamo,saldo  
 )b   
 group by codprestamo  
) c on x.nro=c.nro and x.codprestamo=c.codprestamo  
--drop table #MoProxAmor  
--select * from #MoProxAmor with(nolock) --where codprestamo='002-123-06-00-00185'  
  
set @T2 = getdate()  
print '8--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
-->>>>>>>>>>>>>>>>>>>>>>>>>>>  
--PRINT 'INICIO' --borrar  
------------------------------------------------------------------------------------  
  
truncate table tCsBuroxTblReICueVr14  
set @T2 = getdate()  
print '8.1--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
-- select top 1000 * from tCsBuroxTblReICueVr14 where mop = '01'  
/************************************CARTERA ACTIVA Y CASTIGADA****************************************/  
insert into tCsBuroxTblReICueVr14  
SELECT v.CodPrestamo, v.CodUsuario, vINTFCabecera.ClaveUsuario, vINTFCabecera.NombreUsuario  
,tCaClTecnologia.Responsabilidad as Responsabilidad  
,TipoCuenta = 'I'  
,case when c.codoficina='97' then 'PN' else 'SE' end as TipoContrato  
,UnidadMonetaria = tClMonedas.INTF  
,ImporteAvaluo   = CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END  
,NumeroPagos     = c.NroCuotas  
,FrecuenciaPagos = tCaClModalidadPlazo.INTF  
--,MontoPagar  = case when (  
--      case when MontoPagar.MontoPagar > ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + 0.5, 0)  
--      then ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0)  
--      else MontoPagar.MontoPagar end  
--     )=0 then  
--     ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + 0.5, 0)  
--      else  
--     case when MontoPagar.MontoPagar > ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + 0.5, 0)  
--      then ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0)  
--      else MontoPagar.MontoPagar end   
--      end  
,MontoPagar = case when cf.codfondo=20 then 0.3*MontoPagar.MontoPagar else MontoPagar.MontoPagar end  
,Apertura        = dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA')  
--,UltimoPago = CASE WHEN dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA') <> dbo.fduFechaATexto(c.FechaUltimoMovimiento,'DDMMAAAA')  
--               THEN  
--           dbo.fduFechaATexto(c.FechaUltimoMovimiento, 'DDMMAAAA')  
--            ELSE  
--                   ''--dbo.fduFechaATexto(isnull(Moultpago.Fecha,''), 'DDMMAAAA')  
--               END  
--,UltimoPago = CASE WHEN c.FechaUltimoMovimiento<>c.fechadesembolso THEN  
--     dbo.fduFechaATexto(c.FechaUltimoMovimiento, 'DDMMAAAA')  
--            ELSE  
--     dbo.fduFechaATexto(isnull(Moultpago.Fecha,''), 'DDMMAAAA')-->????? porque  
--               END  
,UltimoPago = CASE WHEN Moultpago.Fecha is null THEN  
     dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA')  
            ELSE  
     dbo.fduFechaATexto(Moultpago.Fecha, 'DDMMAAAA')  
               END  
,Disposicion     = dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA')  
,Cancelacion     = ''  
,Reporte         = vINTFCabecera.FechaReporte  
,Garantia        = CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END  
--,CreditoMaximo.CreditoMaximo CUM 2020.06.08  
,isnull(c.MontoDesembolso, 0) as CreditoMaximo -->Pag.49 Tipocred=PagosFijos(I) = Reportar monto autorizado del credito  
--,SaldoActual     = ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + 0.5, 0) -->Pag.50 Monto total de la deuda OJO  
,SaldoActual     = ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + c.otroscargos + c.cargomora + c.impuestos + 0.5, 0) -->CUM 2020.11.25  
,LimiteCredito   = ''  
,SaldoVencido    = case when c.codoficina='97' --then 0  
                        then   
       case when c.codprestamo in ('097-303-06-02-00580', '097-303-06-04-00463',  
                                                          '097-303-06-04-00544', '097-303-06-06-00528',  
                                                          '097-303-06-08-00609', '097-303-06-08-00744',  
                                                          '097-303-06-09-00628')  
                          then Vencido.SaldoVencido else 0   
                            end  
                        else  
       case when c.Cartera = 'CASTIGADA' then   
        case when Vencido.SaldoVencido is null then --Si es castigada lleva todo el saldo si o tiene saldo vencido CUM 2020.12.09  
         ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + c.otroscargos + c.cargomora + c.impuestos + 0.5, 0)  
        else Vencido.SaldoVencido end  
       else   
        CASE When c.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END   
       end   
                        end  
,PagosVencidos   = case when c.codoficina='97' then 0  
                              else   
        case when c.NroCuotas = c.CuotaActual and c.NroDiasAtraso > 0   
                                    then c.CuotaActual - c.NroCuotasPagadas   
                                    else   
         case when c.CuotaActual - 1 - c.NroCuotasPagadas < 0   
                                            then 0  
                                            else c.CuotaActual - 1 - c.NroCuotasPagadas end  
                                   end  
                         end  
----MOP: Manner Of Payment  
,MOP = CASE WHEN dbo.fdufechaatexto(c.FechaDesembolso, 'AAAAMM') = dbo.fdufechaatexto(c.Fecha, 'AAAAMM') AND   
                       c.FechaDesembolso = c.FechaUltimoMovimiento THEN '00'   
         WHEN Tipo = 'Cancelados' Then '01'   
                  WHEN c.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'  
                  WHEN c.Judicial = 'Judicial' Then tCsBuroMOP.MOP  
                  WHEN c.Cartera = 'CASTIGADA' Then '97'  
                  WHEN substring(c.codprestamo,5, 3) = '303'   
                  THEN --'01'  
                       case when c.codprestamo in ('097-303-06-02-00580', '097-303-06-04-00463',  
                                                            '097-303-06-04-00544', '097-303-06-06-00528',  
                                                            '097-303-06-08-00609', '097-303-06-08-00744',  
                                                            '097-303-06-09-00628')   
                            then tCsBuroMOP.MOP else '01'   
                       end  
                  ELSE tCsBuroMOP.MOP   
             END  
,HistoricoPagos = ''  
,Observacion    = CASE WHEN c.Judicial = 'Judicial' Then 'SG'   
                             WHEN c.Cartera = 'CASTIGADA' THEN 'UP'   
                             ELSE '' END  
,Historico.PagosReportados  
,Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta  
--,FprimerIncum    = case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end  
--CUM 2020.11.23 se comenta por:  
-- se alinea a saldo vencido, es decir si tiene saldo enviaremos la fecha  
-- se cambia a que la fecha de primer incumplimiento es la primera fecha que incumplio de los pagos que tiene vigentes en este momento  
,FprimerIncum    = case when c.codoficina='97'  
                              then   
        case when c.codprestamo in ('097-303-06-02-00580', '097-303-06-04-00463',  
                                                      '097-303-06-04-00544', '097-303-06-06-00528',  
                                                      '097-303-06-08-00609', '097-303-06-08-00744','097-303-06-09-00628')  
                                  then dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') --Vencido.SaldoVencido   
          else '01011900'  
                                end  
                              else   
        CASE When c.NrodiasAtraso > 0   
         THEN dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA')--Vencido.SaldoVencido  
         ELSE '01011900' END   
                         end  
  
,SaldoInsoluto   = ROUND(isnull(c.SaldoCapital,0), 0)  
,FinSegmento     = 'FIN'  
,Montoultpago    = isnull(Moultpago.Montoultpago,0)  
,PlazoMeses      = isnull(PlazoM.meses,0.00)  
,MontoDesembolso = isnull(PlazoM.MontoDesembolso, 0)  
,NrodiasAtraso   = isnull(c.NrodiasAtraso,0)  
/*FROM <----------*/  
--select c.*  
FROM #tCsCarteraFecha c with(nolock)   
inner join #CA v ON v.CodPrestamo=c.CodPrestamo and v.tipo='Cartera'  
left outer join (  
        SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04)   
        AS MOP04, SUM(MOP05) AS MOP05  
        FROM (  
            SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01,   
                   CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03,   
                   CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05  
            FROM #tblmop Datos with(nolock)  
        ) Datos  
        GROUP BY CodPrestamo  
) Historico ON Historico.CodPrestamo = c.CodPrestamo  
  
left outer join #MoProxAmor MontoPagar with(nolock) ON MontoPagar.CodPrestamo=c.CodPrestamo  
LEFT outer JOIN (  
        SELECT CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado) + 0.5, 0) AS SaldoVencido  
        from #tCsMesPlanCuotas with(nolock)  
        WHERE DiasAtrCuota = 1  
        GROUP BY CodPrestamo  
) Vencido ON c.CodPrestamo=Vencido.CodPrestamo  
  
inner join tCaProducto with(nolock) ON c.codproducto=tCaProducto.CodProducto   
inner join tCaClModalidadPlazo with(nolock) ON c.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo   
inner join tClMonedas with(nolock) ON c.CodMoneda = tClMonedas.CodMoneda  
LEFT OUTER JOIN tCsBuroMOP with(nolock) ON c.NroDiasAtraso >= tCsBuroMOP.Inicio AND c.NroDiasAtraso <= tCsBuroMOP.Fin   
LEFT OUTER JOIN (  
     select codigo, ImporteAvaluo, DescGarantia from #tblmesgar with(nolock)  
) Avaluo ON v.CodPrestamo = Avaluo.Codigo  
inner join tCaClTecnologia with(nolock) ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia   
LEFT OUTER JOIN #PrimerIncumplimiento prin with(nolock) on  prin.codprestamo=c.CodPrestamo  
LEFT OUTER JOIN #MontoUltPago Moultpago with(nolock) on  Moultpago.codprestamo=c.CodPrestamo  
left outer join #PlazoMeses as PlazoM with(nolock) on PlazoM.codprestamo=c.CodPrestamo  
CROSS JOIN [FinAmigoBasesSic].dbo.vINTFCabeceraVr14 vINTFCabecera with(nolock)  
inner join #Ca_unique cf with(nolock) on cf.codprestamo=c.codprestamo  
  
set @T2 = getdate()  
print '8.2--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
insert into tCsBuroxTblReICueVr14  
----************************************ AVALES ****************************************  
SELECT v.CodPrestamo, v.CodUsuario, vINTFCabecera.ClaveUsuario, vINTFCabecera.NombreUsuario  
,'C' AS Responsabilidad  
,'I' AS TipoCuenta  
,'SE' as TipoContrato  
,tClMonedas.INTF AS UnidadMonetaria  
,CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo  
,c.NroCuotas AS NumeroPagos  
,tCaClModalidadPlazo.INTF AS FrecuenciaPagos  
--,MontoPagar  = case when MontoPagar.MontoPagar > ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + 0.5, 0)  
--         then ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE, 0)  
--         else MontoPagar.MontoPagar  
--      end  
,MontoPagar = case when cf.codfondo=20 then 0.3*MontoPagar.MontoPagar else MontoPagar.MontoPagar end  
,dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA') AS Apertura  
  
--,UltimoPago = CASE WHEN c.FechaUltimoMovimiento<>c.fechadesembolso then  
--    dbo.fduFechaATexto(c.FechaUltimoMovimiento, 'DDMMAAAA')  
--            ELSE  
--    dbo.fduFechaATexto(isnull(Moultpago.Fecha,''), 'DDMMAAAA')-->????? porque  
--               END  
,UltimoPago = CASE WHEN Moultpago.Fecha is null THEN  
     dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA')  
            ELSE  
     dbo.fduFechaATexto(Moultpago.Fecha, 'DDMMAAAA')  
               END  
  
,dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA') AS Disposicion   
,'' AS Cancelacion  
,vINTFCabecera.FechaReporte AS Reporte  
,CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia  
,isnull(c.MontoDesembolso, 0) as CreditoMaximo -->Pag.49 Tipocred=PagosFijos(I) = Reportar monto autorizado del credito  
--,ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE+ c.SaldoINPE, 0) AS SaldoActual  
,SaldoActual    = ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + c.otroscargos + c.cargomora + c.impuestos + 0.5, 0) -->CUM 2020.11.25  
, '' AS LimiteCredito  
,CASE When c.NrodiasAtraso > 0 THEN Vencido.SaldoVencido ELSE 0 END AS SaldoVencido  
,PagosVencidos = case when c.NroCuotas = c.CuotaActual and c.NroDiasAtraso > 0   
                                       then c.CuotaActual - c.NroCuotasPagadas   
                                       else case when c.CuotaActual - 1 - c.NroCuotasPagadas < 0   
                                                 then 0  
                                                 else c.CuotaActual - 1 - c.NroCuotasPagadas  
                                            end  
                                  end  
----MOP: Manner Of Payment  
,CASE   
 WHEN c.FechaDesembolso=c.FechaUltimoMovimiento THEN '00'   
 WHEN Tipo = 'Cancelados' Then '01'   
 WHEN c.Judicial = 'Judicial' and tCsBuroMOP.MOP = '01' Then '02'  
 WHEN c.Judicial = 'Judicial' Then tCsBuroMOP.MOP  
 WHEN c.Cartera = 'CASTIGADA' Then '97'  
 ELSE tCsBuroMOP.MOP  
 END AS MOP  
, '' AS HistoricoPagos  
,CASE WHEN c.Judicial = 'Judicial' Then 'SG'   
   WHEN c.Cartera = 'CASTIGADA' THEN 'UP'   
   ELSE '' END AS Observacion  
,Historico.PagosReportados  
,Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta  
--,case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end FprimerIncum  
--CUM 2020.11.23 se comenta por:  
-- se alinea a saldo vencido, es decir si tiene saldo enviaremos la fecha  
-- se cambia a que la fecha de primer incumplimiento es la primera fecha que incumplio de los pagos que tiene vigentes en este momento  
,FprimerIncum    = case when c.codoficina='97'  
                              then   
        case when c.codprestamo in ('097-303-06-02-00580', '097-303-06-04-00463',  
                                                      '097-303-06-04-00544', '097-303-06-06-00528',  
                                                      '097-303-06-08-00609', '097-303-06-08-00744','097-303-06-09-00628')  
                                  then dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') --Vencido.SaldoVencido   
          else '01011900'  
                                end  
                              else   
        CASE When c.NrodiasAtraso > 0   
         THEN dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA')--Vencido.SaldoVencido  
         ELSE '01011900' END   
                         end  
,ROUND(isnull(c.SaldoCapital,0), 0) AS SaldoInsoluto  
,'FIN' AS FinSegmento  
,isnull(Moultpago.Montoultpago,0) Montoultpago  
,isnull(PlazoM.meses, 0.00) as PlazoMeses  
,isnull(PlazoM.MontoDesembolso, 0) as MontoDesembolso  
,NrodiasAtraso = isnull(c.NrodiasAtraso,0)  --OSC  
--*FROM <----------  
FROM #tCsCarteraFecha c with(nolock)   
inner join #CA v ON v.CodPrestamo=c.CodPrestamo and v.tipo='Aval'  
LEFT OUTER JOIN  
 (SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04)   
  AS MOP04, SUM(MOP05) AS MOP05  
  FROM (SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01,   
   CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03,   
   CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05  
   FROM (select codprestamo,codusuario,seccuota,MOP from #tblmop with(nolock)) Datos  
   ) Datos  
  GROUP BY CodPrestamo) Historico ON Historico.CodPrestamo=c.CodPrestamo  
  
left outer join #MoProxAmor MontoPagar with(nolock) ON MontoPagar.CodPrestamo=c.CodPrestamo  
LEFT outer JOIN (  
        SELECT CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado) + 0.5, 0) AS SaldoVencido  
        from #tCsMesPlanCuotas with(nolock)  
        WHERE DiasAtrCuota = 1  
        GROUP BY CodPrestamo  
) Vencido ON c.CodPrestamo=Vencido.CodPrestamo  
  
LEFT OUTER JOIN tCaProducto with(nolock) ON c.codproducto=tCaProducto.CodProducto   
LEFT OUTER JOIN tCsBuroMOP with(nolock) ON c.NroDiasAtraso>=tCsBuroMOP.Inicio AND c.NroDiasAtraso<=tCsBuroMOP.Fin  
LEFT OUTER JOIN tClMonedas with(nolock) ON c.CodMoneda=tClMonedas.CodMoneda  
LEFT OUTER JOIN tCaClModalidadPlazo with(nolock) ON c.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo   
  
LEFT OUTER JOIN (select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar with(nolock)) Avaluo ON c.CodPrestamo = Avaluo.Codigo   
  
LEFT OUTER JOIN tCaClTecnologia with(nolock) ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia   
LEFT OUTER JOIN #PrimerIncumplimiento prin with(nolock) on  prin.codprestamo=c.CodPrestamo  
LEFT OUTER JOIN #MontoUltPago Moultpago with(nolock) on  Moultpago.codprestamo=c.CodPrestamo  
left outer join #PlazoMeses as PlazoM with(nolock) on PlazoM.codprestamo=c.CodPrestamo  
CROSS JOIN [FinAmigoBasesSic].dbo.vINTFCabeceraVr14 vINTFCabecera with(nolock)  
inner join #Ca_unique cf with(nolock) on cf.codprestamo=c.codprestamo  
  
set @T2 = getdate()  
print '8.3--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
----************************************ LIQUIDADOS ****************************************  
insert into tCsBuroxTblReICueVr14  
SELECT v.CodPrestamo, v.CodUsuario, vINTFCabecera.ClaveUsuario, vINTFCabecera.NombreUsuario  
,case when pd.desembolso>='20130101' then  
          CASE Tipo WHEN 'CanceladosT' THEN tCaClTecnologia.Responsabilidad WHEN 'CanceladosA' THEN 'C' WHEN 'CanceladosC' THEN 'C' ELSE '' END  
        else  
          CASE Tipo WHEN 'CanceladosT' THEN tCaClTecnologia.Responsabilidad WHEN 'CanceladosA' THEN 'C' WHEN 'CanceladosC' THEN 'J' ELSE '' END  
        end AS Responsabilidad  
,'I' AS TipoCuenta  
,case when pd.desembolso>='20130101' then  
    case when pd.codoficina='97' then 'PN' else 'SE' end  
else tCaProducto.TipoContrato end as TipoContrato  
,tClMonedas.INTF AS UnidadMonetaria  
,CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END AS ImporteAvaluo  
,c.NroCuotas AS NumeroPagos  
,tCaClModalidadPlazo.INTF AS FrecuenciaPagos  
,0 as MontoPagar   
,dbo.fduFechaATexto(pd.Desembolso, 'DDMMAAAA') AS Apertura  
,UltimoPago = dbo.fduFechaATexto(pd.cancelacion, 'DDMMAAAA')  
,dbo.fduFechaATexto(pd.Desembolso, 'DDMMAAAA') AS Disposicion  
,dbo.fduFechaATexto(pd.Cancelacion, 'DDMMAAAA') AS Cancelacion  
,vINTFCabecera.FechaReporte AS Reporte  
,CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia  
,isnull(c.MontoDesembolso, 0) as CreditoMaximo -->Pag.49 Tipocred=PagosFijos(I) = Reportar monto autorizado del credito  
,SaldoActual = 0   
,'' AS LimiteCredito  
,SaldoVencido=0  
,PagosVencidos= 0  
----MOP: Manner Of Payment  
,'01' AS MOP  
, '' AS HistoricoPagos  
--,CASE WHEN c.Judicial = 'Judicial' Then 'SG'   
--           WHEN c.Cartera = 'CASTIGADA' THEN 'UP'   
--           ELSE '' END AS Observacion  
,'CC' AS Observacion -->CUM 2020.11.24 se quita xq al ser liquidado va vacio --> 20230608 SE COLOCA CLAVE COMO CC 
,Historico.PagosReportados,Historico.MOP02, Historico.MOP03, Historico.MOP04, Historico.MOP05 AS MOP05mas, '' AS AOClave, '' AS AONombre, '' AS AOCuenta  
--,case when prin.fechapi is null then '01011900' else dbo.fduFechaATexto(prin.fechapi, 'DDMMAAAA') end FprimerIncum -- CUM 2020.11.23 se comenta xq si es liquidado este ya no se envia  
,'01011900' FprimerIncum  
,0 AS SaldoInsoluto  
,'FIN' AS FinSegmento  
,isnull(Moultpago.Montoultpago,0) Montoultpago  
,isnull(PlazoM.meses, 0.00) as PlazoMeses  
,isnull(PlazoM.MontoDesembolso, 0) as MontoDesembolso  
,NrodiasAtraso   = isnull(c.NrodiasAtraso,0)  
FROM tcspadroncarteradet pd with(nolock)   
inner join #CA v ON v.CodPrestamo=pd.CodPrestamo and v.tipo in('CanceladosT','CanceladosC','CanceladosA')  
inner join tcscartera c with(nolock) on pd.codprestamo=c.codprestamo and pd.fechacorte=c.fecha  
LEFT OUTER JOIN (  
 SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04) AS MOP04, SUM(MOP05) AS MOP05  
 FROM (SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01,   
 CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03,   
 CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05  
 FROM (select codprestamo,codusuario,seccuota,MOP from #tblmop with(nolock)) Datos  
 ) Datos  
 GROUP BY CodPrestamo  
) Historico  ON Historico.CodPrestamo=c.CodPrestamo   
LEFT OUTER JOIN tCaProducto ON c.codproducto=tCaProducto.CodProducto   
LEFT OUTER JOIN tCsBuroMOP with(nolock) ON c.NroDiasAtraso >= tCsBuroMOP.Inicio AND c.NroDiasAtraso <= tCsBuroMOP.Fin   
LEFT OUTER JOIN tClMonedas with(nolock) ON tClMonedas.CodMoneda = c.CodMoneda   
LEFT OUTER JOIN tCaClModalidadPlazo with(nolock) ON c.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo   
LEFT OUTER JOIN (select fecha, codigo, ImporteAvaluo, DescGarantia from #tblmesgar with(nolock)) Avaluo ON c.CodPrestamo=Avaluo.Codigo   
LEFT OUTER JOIN tCaClTecnologia with(nolock) ON tCaProducto.Tecnologia=tCaClTecnologia.Tecnologia   
LEFT OUTER JOIN #PrimerIncumplimiento prin with(nolock) on  prin.codprestamo=c.CodPrestamo  
LEFT OUTER JOIN #MontoUltPago Moultpago with(nolock) on Moultpago.codprestamo=c.CodPrestamo  
left outer join #PlazoMeses as PlazoM with(nolock) on PlazoM.codprestamo=c.CodPrestamo  
CROSS JOIN [FinAmigoBasesSic].dbo.vINTFCabeceraVr14 vINTFCabecera with(nolock)  
  
  
set @T2 = getdate()  
print '9--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
--CUM 2020.11.24 se quito  
--Actualiza las observaciones de creditos canceldados con condonación  
--update cue set  
--Observacion = 'LC',  
--SaldoActual = 0,  
--SaldoVencido = 0,  
--MOP = '01', --22-05-2020, se cambio por rechazo de cc  
----MOP = '97',  --22-05-2020, se cambio por rechazo de cc  
--MontoPagar = 0,   
--Cancelacion = replace(convert(varchar(10), pcd.Cancelacion,104),'.','')   
--from tCsBuroxTblReICueVr14 as cue with(nolock)  
--inner join tCsTransaccionDiaria as td with(nolock) on td.CodigoCuenta = cue.CodPrestamo and year(td.Fecha) = substring(cue.Reporte,5,4) and month(td.Fecha) = substring(cue.Reporte,3,2)  
--inner join tCsPadronCarteraDet as pcd with(nolock) on pcd.CodPrestamo = cue.CodPrestamo  
--where td.DescripcionTran like '%condonacion%'  
--and pcd.Cancelacion = td.Fecha  
  
set @T2 = getdate()  
print '10--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
--OJO ACTIVAR CUANDO ACTUALIZAS EL SP  
--Actualiza MOP error  
update tCsBuroxTblReICueVr14 set  
MOP = '02'  
where SaldoVencido > 0   
and MOP in ('00','UR', '01' )   
and Cancelacion = ''  
  
set @T2 = getdate()  
print '11--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
drop table #CA  
drop table #Ca_unique  
drop table #CAMo  
drop table #tblmop  
drop table #tblmesgar  
drop table #tCsMesPlanCuotas  
drop table #PrimerIncumplimiento  
drop table #MontoUltPago  
drop table #PlazoMeses  
drop table #tCsCarteraFecha --New  
drop table #MoProxAmorAtraso  
drop table #MoProxAmor  
  
set @T2 = getdate()  
print '12--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
--OJO ACTIVAR CUANDO ACTUALIZAS EL SP  
--Actualiza saldo actual > credito maximo --04/06/2018  
update tCsBuroxTblReICueVr14 set  
CreditoMaximo = SaldoActual   
where SaldoActual > CreditoMaximo     
  
set @T2 = getdate()  
print '13--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))  
set @T1 = getdate()  
  
  
----select getdate() --borrar  
--/*  
--SaldoVencido > 0 y PagosVencidos = 0   --> 3 reg  
--SaldoVencido = 0 y PagosVencidos = 1   --> 12891 reg  
--SaldoVencido = 0 y PagosVencidos > 1   --> 3 reg  
--*/  
--/*  
--select CuotaActual, NroCuotasPagadas, nrodiasatraso,*  
--from tCsCartera  
--where codprestamo = '075-166-06-00-00294'  
--and fecha = '20151231'  
----insert into #tCsMesPlanCuotas  
----select * from tCsMesPlanCuotas where codprestamo = '026-166-06-09-00100'  
--select CodPrestamo, SaldoVencido, PagosVencidos from tcsburoxtblreicuevr14 where codprestamo = '075-166-06-00-00294'  
  
--exec pvINTFCuentaVr14 '20151231'  
  
--select CodPrestamo, SaldoVencido, SaldoActual, * from tcsburoxtblreicuevr14  
--where   
----   (SaldoVencido > 0 and PagosVencidos = 0)  
----or (SaldoVencido = 0 and PagosVencidos = 1)  
----or (SaldoVencido = 0 and PagosVencidos > 1)  
--   (SaldoVencido > SaldoActual)  
--*/  
  
--/*  
--select count(*) from tCsBuroxTblReICueVr14  --40683,  34465, 40683  
--select top 1000 * from tCsPlanCuotas where fecha = '20190930' and CodPrestamo = '321-370-06-01-00025'   --82 reg  
--select top 1000 * from tCsPadronPlanCuotas where CodPrestamo = '321-370-06-01-00025'   
--*/  
  
GO