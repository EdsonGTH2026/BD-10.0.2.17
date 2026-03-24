SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

---EXEC pvINTFCuentaSIC_CP '20230801','20230805'   
CREATE PROCEDURE [dbo].[pvINTFCuentaSIC_CP] @fecini smalldatetime ,@fecha smalldatetime     
AS    
  
SET NOCOUNT ON    
  
--Se agregan los registros depurados a tabla temporal, para no ser incluidos en la cinta --20230520 ZCCU  
--------Se agregan CLAVES DE OBSERVACION CC LIQUIDADOS --20230520 ZCCU  
--------Se agregan CLAVES DE OBSERVACION LC LIQUIDADOS CON QUITA O CONDONACION --20230520 ZCCU  
  
--------select getdate(), '1' --borrar    
--declare @fecha smalldatetime  --COMENTAR    
--set @fecha = '20230805'   --COMENTAR    
    
--declare @fecini smalldatetime    
--set @fecini='20230801'--dbo.fdufechaaperiodo(@fecha)+'01'  
    
--select @fecini    
declare @T1 datetime    
declare @T2 datetime    
set @T1 = getdate()   
  
/* CRÉDITOS DEPURADOS POR SIC'S*/ ---- ZCCU 2023.05  
CREATE TABLE #DEPURADOS(CODPRESTAMO VARCHAR(30))  
INSERT INTO #DEPURADOS  
select codcuenta   
from dbo.tcsCCDepurados2023 with(nolock)  
group by codcuenta    

INSERT INTO #DEPURADOS (CODPRESTAMO) VALUES ('098-174-06-00-00001');
INSERT INTO #DEPURADOS (CODPRESTAMO) VALUES ('098-174-06-00-00002');
INSERT INTO #DEPURADOS (CODPRESTAMO) VALUES ('098-174-06-01-00003');
INSERT INTO #DEPURADOS (CODPRESTAMO) VALUES ('098-174-06-02-00004');
INSERT INTO #DEPURADOS (CODPRESTAMO) VALUES ('098-170-06-00-00006');
INSERT INTO #DEPURADOS (CODPRESTAMO) VALUES ('098-170-06-01-00007');
  
set @T2 = getdate()    
print '1--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()   
  
/*DEFINIR LOS CREDITOS PARA PLAN CUOTAS*/    
create table #CA(codprestamo char(19),tipo varchar(20),codusuario varchar(20), codfondo int)    
insert into #CA    
select codprestamo,tipo,codusuario,codfondo    
from tCsBuroxTblReINomVr14CP with(nolock)    
where codprestamo not in (select CODPRESTAMO from #DEPURADOS with(nolock)) -------- Excluir los ptmos depurados por Sic´s --- ZCCU 2023.05  
and substring(codprestamo,1,3) not in ('999')  
  
set @T2 = getdate()    
print '2--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()   
  
/*CREDITOS EN TODA LA CARTERA*/  
--drop table #CA    
create table #Ca_unique(codprestamo char(19),codfondo int)    
insert into #Ca_unique    
select distinct codprestamo,codfondo from #CA with(nolock)    
where substring(codprestamo,1, 3) not in ('999')  
  
set @T2 = getdate()    
print '3--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()   
  
/*--CALCULA DIAS DE ATRASO MAXIMO POR CREDITO HASTA LA FECHA CORTE */  
create table #tblmop_tmp( codprestamo char(19),    
        codusuario varchar(15),    
        seccuota smallint,    
        DiasAtrCuota int)    
--00:01:19 509,142--> consulta  ----- usar Fecha, CodOficina, CodPrestamo, CodUsuario, NumeroPlan, SecCuota, CodConcepto  
insert into #tblmop_tmp    
SELECT CodPrestamo, CodUsuario,SecCuota,max(DiasAtrCuota) DiasAtrCuota    
FROM tCsPadronPlanCuotas with(nolock)     
where   
codprestamo in (select codprestamo from #Ca_unique)    
and numeroplan=0   
and seccuota>0    
and FechaVencimiento<=@fecha--'20200531' --    
group by CodPrestamo, CodUsuario,SecCuota    
  
set @T2 = getdate()    
print '4--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()   
  
/*--ASIGNA MOP POR CRÉDITO*/  
create table #tblmop( codprestamo char(19),    
       codusuario  varchar(15),    
       seccuota    smallint,    
       MOP         varchar(3))    
--00:00:03 --> insert    
insert into #tblmop    
SELECT DISTINCT PC.CodPrestamo, PC.CodUsuario,PC.SecCuota    
, CASE WHEN substring(PC.codprestamo, 5, 3) = '303' THEN '01' ELSE B.MOP END MOP    
FROM #tblmop_tmp PC with(nolock)     
INNER JOIN tCsBuroMOP B with(nolock)ON PC.DiasAtrCuota >= B.Inicio AND PC.DiasAtrCuota <= B.Fin    
    
--drop table #tblmop_tmp    
    
set @T2 = getdate()    
print '5--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()   
  
--------------------------------------------------------------  CREDITOS GARANTIZADOS -------------------------    
----usar Fecha, Referencia, Codigo, CodOficina, TipoGarantia, DocPropiedad  
/*GARANTIAS ACTIVAS A LA FECHA DE CORTE*/  
SELECT Fecha, Codigo, codoficina, TipoGarantia, Round(SUM(Garantia), 0) AS Garantia   
into #garantias   
FROM tCsdiaGarantias with(nolock)    
WHERE fecha=@fecha  
and codigo in(select codprestamo from #Ca_unique with(nolock))  
and Estado in('ACTIVO','MODIFICADO')   
GROUP BY Fecha, Codigo,codoficina, TipoGarantia    
  
set @T2 = getdate()    
print '6.1--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()   
  
/*GARANTÍA MAXIMA POR CRÉDITO*/  
SELECT Fecha, Codigo,codoficina, MAX(Garantia) AS Garantia    
into #maxGarantia  
FROM #garantias WITH (NOLOCK)  
-- (SELECT Fecha, Codigo, codoficina, TipoGarantia, Round(SUM(Garantia), 0) AS Garantia    
-- FROM tCsdiaGarantias with(nolock)    
-- WHERE Estado in('ACTIVO','MODIFICADO') and fecha=@fecha--'20200531'--    
----and codoficina not in ('230','231')     
--and codigo in(select codprestamo from #Ca_unique with(nolock))    
GROUP BY Fecha, Codigo,codoficina  
  
set @T2 = getdate()    
print '6.2--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()   
  
  
create table #tblmesgar(  fecha         smalldatetime,    
        codigo        varchar(25),    
        ImporteAvaluo money,    
        DescGarantia  varchar(300))    
insert into #tblmesgar    
SELECT Filtro.Fecha, Filtro.Codigo, sum(Filtro.Garantia) AS ImporteAvaluo ,'CREDITO GARANTIZADO' DescGarantia   
FROM  #maxGarantia FILTRO WITH(NOLOCK)  
--FROM (    
--    SELECT Fecha, Codigo,codoficina, MAX(Garantia) AS Garantia    
--    FROM (    
--        SELECT Fecha, Codigo, codoficina, TipoGarantia, Round(SUM(Garantia), 0) AS Garantia    
--        FROM tCsdiaGarantias with(nolock)    
--        WHERE Estado in('ACTIVO','MODIFICADO') and fecha=@fecha--'20200531'--    
--  --and codoficina not in ('230','231')     
--  and codigo in(select codprestamo from #Ca_unique with(nolock))    
--        GROUP BY Fecha, Codigo,codoficina, TipoGarantia    
--    ) Datos    
--    GROUP BY Fecha, Codigo,codoficina    
--) Filtro     
group by Filtro.Fecha, Filtro.Codigo    
--drop table #tblmesgar   
  
  
--DROP TABLE #garantias  
--DROP TABLE #maxGarantia  
   
    
set @T2 = getdate()    
print '6.3--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()   
   
--------------------------------------------------------------------------------------    
  
  
--------------------------------------------------------------------------------------    
  
---Fecha, CodOficina, CodPrestamo, CodUsuario, NumeroPlan, SecCuota, CodConcepto  
  
---PRESTAMOS CON DIAS DE ATRASO,MONTO DEVENGADO,PAGADO Y CONDONADO ---  
create table #tCsMesPlanCuotas(fecha          smalldatetime,    
         codprestamo    char(19),    
         MontoDevengado money,    
         MontoPagado    money,    
         MontoCondonado money,    
         DiasAtrCuota   smallint,    
         codoficina varchar(4))    
insert into #tCsMesPlanCuotas    
SELECT p.Fecha, p.CodPrestamo    
 ,case when u.codfondo=20 then 0.3*p.MontoDevengado else p.MontoDevengado end MontoDevengado    
 ,case when u.codfondo=20 then 0.3*p.MontoPagado else p.MontoPagado end MontoPagado    
 ,case when u.codfondo=20 then 0.3*p.MontoCondonado else p.MontoCondonado end MontoCondonado    
 ,CASE WHEN p.DiasAtrCuota > 0 THEN 1 ELSE 0 END AS DiasAtrCuota    
 ,p.codoficina    
FROM tCsPlanCuotas p with(nolock)    
inner join #Ca_unique u with(nolock) on p.codprestamo=u.codprestamo    
WHERE   
p.fecha=@fecha--'20200531'--   
and p.codprestamo in(select codprestamo from #Ca_unique with(nolock))    
and p.numeroplan=0   
and seccuota>0    
and p.EstadoConcepto NOT IN ('ANULADO', 'CANCELADO')    
  
--drop table #tCsMesPlanCuotas    
  
set @T2 = getdate()    
print '7--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
--------------------------------------------------------------------------------------    
  
-----------------------------------------PRIMER INCUMPLIMIENTO   
  
------Fecha, CodOficina, CodPrestamo, CodUsuario, NumeroPlan, SecCuota, CodConcepto  
create table #PrimerIncumplimiento_tmp(codprestamo char(19),    
            fechavencimiento smalldatetime,    
            DiasAtrCuota int)    
insert into #PrimerIncumplimiento_tmp    
SELECT CodPrestamo, min(fechavencimiento) fechavencimiento,DiasAtrCuota    
FROM tCsPlanCuotas with(nolock)    
WHERE    fecha=@fecha   
and codprestamo in(select codprestamo from #Ca_unique with(nolock))      
and numeroplan=0   
and seccuota>0    
and fechavencimiento<=@fecha--'20200531'  
and DiasAtrCuota>0------------------------------------------------ ojo: se aplica filtro desde la temporal  
group by CodPrestamo,DiasAtrCuota    
    
set @T2 = getdate()    
print '8--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
create table #PrimerIncumplimiento(codprestamo char(19),    
         fechapi smalldatetime)    
insert into #PrimerIncumplimiento    
select CodPrestamo, min(fechavencimiento) fechavencimiento    
from #PrimerIncumplimiento_tmp    
where DiasAtrCuota>0-->00:01:35    
group by CodPrestamo    
    
--drop table #PrimerIncumplimiento_tmp    
--drop table #PrimerIncumplimiento   
   
set @T2 = getdate()    
print '8.1--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
    
-------------------------------------------------------------------------------------  
-------------------------------------------------------------------------------------    
  
----Fecha, CodigoCuenta, FraccionCta, Renovado, CodSistema, CodOficina, NroTransaccion, TipoTransacNivel1, TipoTransacNivel2  
---, TipoTransacNivel3, CodUsuario  
  
-----se consulta los ultimos movimientos en una temporal.  
 SELECT max(t.Fecha) FechaUltimoMovimiento,t.CodigoCuenta codprestamo    
 into #ultimoMovTmp  
 FROM tCsTransaccionDiaria t with(nolock)    
 --where t.fecha<=@fecha--'20201031'--   
 where t.fecha>=@fecini  
 and t.fecha<=@fecha--'20201031'--         
 and t.codigocuenta in(select codprestamo from #Ca_unique with(nolock))    
 and t.fraccioncta='0' and t.renovado=0    
 and t.codsistema = 'CA'   
 and t.nrotransaccion>=0      
 and t.TipoTransacNivel1 in('I','O')     
 and t.TipoTransacNivel3 in(104,105,2) -- not in(101,100,99)    
 and t.extornado = 0    
 group by t.CodigoCuenta    
  
set @T2 = getdate()    
print '9--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
  
  
  
create table #CAMo(  codprestamo varchar(25),    
      FechaUltimoMovimiento smalldatetime)    
insert into #CAMo    
select codprestamo,FechaUltimoMovimiento    
from #ultimoMovTmp a with(nolock)    
--from(  --------------------------------------------------------------se saca a temporal para usar una subconsulta ZCCU  
-- SELECT max(t.Fecha) FechaUltimoMovimiento,t.CodigoCuenta codprestamo    
-- --select *    
-- FROM tCsTransaccionDiaria t with(nolock)    
-- where t.fecha<=@fecha--'20201031'--    
-- and t.codigocuenta in(select codprestamo from #Ca_unique with(nolock))    
-- and t.fraccioncta='0' and t.renovado=0    
-- and t.codsistema = 'CA'   
-- and t.nrotransaccion>=0      
-- and t.TipoTransacNivel1 in('I','O')     
-- and t.TipoTransacNivel3 in(104,105,2) -- not in(101,100,99)    
-- and t.extornado = 0    
-- group by t.CodigoCuenta    
--) a    
  
set @T2 = getdate()    
print '9.1--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
  
create table #MontoUltPago (    fecha   datetime,    
        codprestamo  char(19),    
        montoultpago money )    
insert into #MontoUltPago    
SELECT t.Fecha,t.CodigoCuenta codprestamo    
,sum(case when c.codfondo=20     
  then 0.3*(t.MontoCapitalTran+t.MontoInteresTran+t.MontoINPETran)    
  else  t.MontoCapitalTran+t.MontoInteresTran+t.MontoINPETran end + (montocargos+montootrostran+montoimpuestos))monto    
FROM tCsTransaccionDiaria t with(nolock)    
inner join #CAMo b with(nolock) on t.codigocuenta=b.codprestamo and t.fecha=b.FechaUltimoMovimiento    
inner join #Ca_unique c with(nolock) on t.codigocuenta=c.codprestamo    
--where t.fecha<=@fecha--'20201031'--   
where t.fecha>=@fecini  
and t.fecha<=@fecha--'20201031'--         
and t.codigocuenta in(select codprestamo from #Ca_unique with(nolock))    
and t.fraccioncta='0' and t.renovado=0    
and t.codsistema = 'CA'  
and t.nrotransaccion>=0    
and t.TipoTransacNivel1 in('I','O')   
and t.TipoTransacNivel3 in(104,105,2)   
and t.extornado = 0    
group by t.Fecha,t.CodigoCuenta    
    
-- #ultimoMovTmp   
----drop table #MontoUltPago    
set @T2 = getdate()    
print '9.2--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
----------------------------------------------------------------------------------------    
  
----------------------------------------------------------------------------------------    
--<<<<<<<<<<<<<< OSC: Crea y llena la tabla de Plazo en Meses    
create table #PlazoMeses(   codprestamo varchar(25),    
       meses       decimal(16,2),    
       MontoDesembolso int )    
insert into #PlazoMeses    
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
print '10--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
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
,c.FechaUltimoMovimiento ,c.NrodiasAtraso    
,c.codproducto,c.ModalidadPlazo,c.CodMoneda,c.Judicial,c.Cartera,c.codoficina,c.CuotaActual,c.NroCuotasPagadas     
    
set @T2 = getdate()    
print '11--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
    
    
  ---Fecha, CodOficina, CodPrestamo, CodUsuario, NumeroPlan, SecCuota, CodConcepto  
create table #MoProxAmorAtraso(  codprestamo char(19),    
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
and p.codprestamo in (select codprestamo from #Ca_unique with(nolock))     
and p.numeroplan=0   
and p.estadocuota<>'CANCELADO'    
and p.fechavencimiento<=@fecha--'20200531'--    
group by p.codprestamo--,seccuota,fechavencimiento    
--drop table #MoProxAmorAtraso    
   
   
set @T2 = getdate()    
print '12--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
  
create table #MoProxAmor(codprestamo char(19),    
       montopagar money)    
insert into #MoProxAmor    
select x.codprestamo,'Montocuota'=x.saldo    
from( select codprestamo,nro,max(saldo) saldo   
 from( select codprestamo,count(seccuota) nro,saldo    
  from( select codprestamo,seccuota,sum(montocuota) saldo    
     --from tcspadronplancuotas with(nolock)    
     from tcsplancuotas  with(nolock)    
     --where fecha='20200531' and numeroplan=0 and codprestamo='003-170-06-04-02652'--'003-170-06-00-02515'--'447-170-06-02-00028'--'311-170-06-06-01248'    
     where fecha=@fecha  
     and codprestamo in (select codprestamo from #Ca_unique with(nolock))    
     and numeroplan=0   
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
 from (select codprestamo,saldo,count(seccuota) nro    
  from ( select codprestamo,seccuota,sum(montocuota) saldo    
     --from tcspadronplancuotas with(nolock)       
     from tcsplancuotas with(nolock)    
     --where codprestamo='336-370-06-03-00624'    
     where fecha=@fecha    
     and codprestamo in (select codprestamo from #Ca_unique with(nolock))  
     and numeroplan=0  
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
print '13--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
    
-->>>>>>>>>>>>>>>>>>>>>>>>>>>    
    
--truncate table tCsBuroxTblReICueVr14CP    
    
-- select top 1000 * from tCsBuroxTblReICueVr14CP where mop = '01'    
  
--------------------------------CONSULTAS TEMPORALES PARA CARTERA ACTIVA Y CASTIGADA ---ZCCU  
  
SELECT CodPrestamo, CodUsuario, SecCuota,  
    CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01,     
       CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03,     
       CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05   
INTO #TEMPmops   
FROM #tblmop Datos with(nolock)    
  
SELECT CodPrestamo, COUNT(*) AS PagosReportados, SUM(MOP01) AS MOP01, SUM(MOP02) AS MOP02, SUM(MOP03) AS MOP03, SUM(MOP04)     
AS MOP04, SUM(MOP05) AS MOP05    
INTO #TEMPtblmop  
FROM #TEMPmops WITH(NOLOCK)  
--FROM (  --------------------------------------------------------------se saca a temporal para NO usar una subconsulta ZCCU  
--    SELECT CodPrestamo, CodUsuario, SecCuota, CASE MOP WHEN '01' THEN 1 ELSE 0 END AS MOP01,     
--           CASE MOP WHEN '02' THEN 1 ELSE 0 END AS MOP02, CASE MOP WHEN '03' THEN 1 ELSE 0 END AS MOP03,     
--           CASE MOP WHEN '04' THEN 1 ELSE 0 END AS MOP04, CASE WHEN MOP >= '05' THEN 1 ELSE 0 END AS MOP05    
--    FROM #tblmop Datos with(nolock)    
--) Datos    
GROUP BY CodPrestamo    
  
SELECT CodPrestamo, Round(SUM( MontoDevengado- MontoPagado - MontoCondonado) + 0.5, 0) AS SaldoVencido   
into #TEMPSaldoVencido   
from #tCsMesPlanCuotas with(nolock)    
WHERE DiasAtrCuota = 1    
GROUP BY CodPrestamo    
  
select codigo, ImporteAvaluo, DescGarantia   
INTO #TEMPAvaluo  
from #tblmesgar with(nolock)    
  
set @T2 = getdate()    
print '14--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
  
truncate table tCsBuroxTblReICueVr14CP  
  
  
/************************************CARTERA ACTIVA Y CASTIGADA****************************************/    
insert into tCsBuroxTblReICueVr14CP --------------------------------------------------------------------------------------------OJO  
SELECT v.CodPrestamo, v.CodUsuario, 'MI25570001', 'SERV RURALES'   
,tCaClTecnologia.Responsabilidad as Responsabilidad    
,TipoCuenta = 'I'    
,case when c.codoficina='97' then 'PN' else 'SE' end as TipoContrato    
,UnidadMonetaria = tClMonedas.INTF    
,ImporteAvaluo   = CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.ImporteAvaluo END    
,NumeroPagos     = c.NroCuotas    
,FrecuenciaPagos = tCaClModalidadPlazo.INTF    
,MontoPagar = case when cf.codfondo=20 then 0.3*MontoPagar.MontoPagar else MontoPagar.MontoPagar end    
,Apertura        = dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA')    
,UltimoPago = CASE WHEN Moultpago.Fecha is null THEN    
     dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA')    
            ELSE    
     dbo.fduFechaATexto(Moultpago.Fecha, 'DDMMAAAA')    
               END    
,Disposicion     = dbo.fduFechaATexto(c.FechaDesembolso, 'DDMMAAAA')    
,Cancelacion     = '' -----------------------------------------------------------------ojo   
,Reporte         = dbo.fduFechaATexto(@fecha, 'DDMMAAAA') --vINTFCabecera.FechaReporte    
,Garantia        = CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END    
--,CreditoMaximo.CreditoMaximo CUM 2020.06.08    
,isnull(c.MontoDesembolso, 0) as CreditoMaximo -->Pag.49 Tipocred=PagosFijos(I) = Reportar monto autorizado del credito    
--,SaldoActual     = ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + 0.5, 0) -->Pag.50 Monto total de la deuda OJO    
,SaldoActual     = ROUND(c.SaldoCapital + c.SaldoInteresCorriente + c.SaldoINVE + c.SaldoINPE + c.otroscargos + c.cargomora + c.impuestos + 0.5, 0) -->CUM 2020.11.25    
,LimiteCredito   = ''  -----------------------------------------------------------------ojo   
,SaldoVencido    = case when c.codoficina='97' then case when c.codprestamo in ('097-303-06-02-00580', '097-303-06-04-00463',    
                      '097-303-06-04-00544', '097-303-06-06-00528',    
                      '097-303-06-08-00609', '097-303-06-08-00744',    
                      '097-303-06-09-00628')  
                      then Vencido.SaldoVencido else 0 end    
                   else case when c.Cartera = 'CASTIGADA' then   
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
,HistoricoPagos = ''  -----------------------------------------------------------------ojo   
,Observacion    = CASE WHEN c.Judicial = 'Judicial' Then 'SG'     
                             WHEN c.Cartera = 'CASTIGADA' THEN 'UP'     
                             ELSE '' END    
,Historico.PagosReportados    
,Historico.MOP02, Historico.MOP03  
, Historico.MOP04, Historico.MOP05 AS MOP05mas  
, '' AS AOClave   -----------------------------------------------------------------ojo   
, '' AS AONombre  -----------------------------------------------------------------ojo   
, '' AS AOCuenta  -----------------------------------------------------------------ojo   
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
--into #TEMPtCsBuroxTblReICueVr14cp --------------------------------------------------------------------------------------------OJO  
FROM #tCsCarteraFecha c with(nolock)     
inner join #CA v with(nolock) ON v.CodPrestamo=c.CodPrestamo and v.tipo='Cartera'    
LEFT OUTER JOIN #TEMPtblmop Historico with(nolock) ON Historico.CodPrestamo = c.CodPrestamo    
left outer join #MoProxAmor MontoPagar with(nolock) ON MontoPagar.CodPrestamo=c.CodPrestamo    
LEFT OUTER JOIN #TEMPSaldoVencido Vencido with(nolock) ON c.CodPrestamo=Vencido.CodPrestamo    
inner join tCaProducto with(nolock) ON c.codproducto=tCaProducto.CodProducto     
inner join tCaClModalidadPlazo with(nolock) ON c.ModalidadPlazo = tCaClModalidadPlazo.ModalidadPlazo     
inner join tClMonedas with(nolock) ON c.CodMoneda = tClMonedas.CodMoneda    
LEFT OUTER JOIN tCsBuroMOP with(nolock)ON c.NroDiasAtraso >= tCsBuroMOP.Inicio AND c.NroDiasAtraso <= tCsBuroMOP.Fin     
LEFT OUTER JOIN #TEMPAvaluo Avaluo with(nolock) ON v.CodPrestamo = Avaluo.Codigo   
inner join tCaClTecnologia with(nolock) ON tCaProducto.Tecnologia = tCaClTecnologia.Tecnologia     
LEFT OUTER JOIN #PrimerIncumplimiento prin with(nolock) on  prin.codprestamo=c.CodPrestamo    
INNER JOIN #MontoUltPago Moultpago with(nolock) on  Moultpago.codprestamo=c.CodPrestamo    
left outer join #PlazoMeses as PlazoM with(nolock) on PlazoM.codprestamo=c.CodPrestamo    
--CROSS JOIN [FinAmigoBasesSic].dbo.vINTFCabeceraVr14 vINTFCabecera with(nolock)    
inner join #Ca_unique cf with(nolock) on cf.codprestamo=c.codprestamo    
    
set @T2 = getdate()    
print '15--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
  
  
insert into tCsBuroxTblReICueVr14CP--------------------------------------------------------------------------------------------OJO  
--INSERT INTO #TEMPtCsBuroxTblReICueVr14CP  --------------------------------------------------------------------------------------------OJO  
----************************************ AVALES ****************************************    
SELECT v.CodPrestamo, v.CodUsuario,  'MI25570001', 'SERV RURALES'  
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
--,vINTFCabecera.FechaReporte AS Reporte   
,dbo.fduFechaATexto(@fecha, 'DDMMAAAA') AS Reporte    
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
INNER JOIN #MontoUltPago Moultpago with(nolock) on  Moultpago.codprestamo=c.CodPrestamo    
left outer join #PlazoMeses as PlazoM with(nolock) on PlazoM.codprestamo=c.CodPrestamo    
--CROSS JOIN [FinAmigoBasesSic].dbo.vINTFCabeceraVr14 vINTFCabecera with(nolock)    
inner join #Ca_unique cf with(nolock) on cf.codprestamo=c.codprestamo    
    
set @T2 = getdate()    
print '16--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
-----------------------------------------------------------------------------  
--------------------------- CRÉDITOS LIQUIDADOS CON CONDONACIONES O QUITA ----------------------------    
  
--Fecha, CodigoCuenta, FraccionCta, Renovado, CodSistema, CodOficina, NroTransaccion, TipoTransacNivel1, TipoTransacNivel2  
---, TipoTransacNivel3, CodUsuario  
  
 --SELECT max(t.Fecha) FechaUltimoMovimiento,t.CodigoCuenta codprestamo    
 --into #ConQuita  
 --FROM tCsTransaccionDiaria t with(nolock)    
 --where t.fecha<=@fecha--'20201031'--    
 --and t.codigocuenta in(select codprestamo from #Ca_unique with(nolock))    
 --and t.fraccioncta='0' and t.renovado=0    
 --and t.codsistema = 'CA'   
 --and t.nrotransaccion>=0      
 --and t.TipoTransacNivel1 in('I','O')     
 --and t.TipoTransacNivel3 in(104,105,2) -- not in(101,100,99)    
 --and t.extornado = 0    
 --group by t.CodigoCuenta    
   
  
create table #ConQuita(  
 codigocuenta varchar(25),  
 quita money,  
 condonacion money,  
 monto money  
)  
insert into #ConQuita  
select codigocuenta,sum(montocapitaltran) quita,sum(montointerestran+montoinpetran) condonacion,sum(montototaltran) monto  
from tcstransacciondiaria t with(nolock)  
inner join #CA v ON v.CodPrestamo=t.codigocuenta and v.tipo in('CanceladosT','CanceladosC','CanceladosA')    
where fecha>=@fecini and fecha<=@fecha   
and codigocuenta in(select codprestamo from #CA)  
and t.fraccioncta='0' and t.renovado=0    
and codsistema='CA'   
and tipotransacnivel1='O'   
and tipotransacnivel3=2  
and extornado=0  
group by codigocuenta  
--341-170-06-09-06288  
  
set @T2 = getdate()    
print '17--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
  
  
  
  
  
----************************************ LIQUIDADOS ****************************************    
insert into tCsBuroxTblReICueVr14CP  --------------------------------------------------------------------------------------------OJO  
--INSERT INTO #TEMPtCsBuroxTblReICueVr14CP--------------------------------------------------------------------------------------------OJO  
SELECT v.CodPrestamo, v.CodUsuario,  'MI25570001', 'SERV RURALES'    
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
--,vINTFCabecera.FechaReporte AS Reporte   
,dbo.fduFechaATexto(@fecha, 'DDMMAAAA') AS Reporte   
,CASE Avaluo.ImporteAvaluo WHEN 0 THEN NULL ELSE Avaluo.DescGarantia END AS Garantia    
,isnull(c.MontoDesembolso, 0) as CreditoMaximo -->Pag.49 Tipocred=PagosFijos(I) = Reportar monto autorizado del credito    
,SaldoActual = 0     
,'' AS LimiteCredito    
,SaldoVencido=0    
,PagosVencidos= 0    
----MOP: Manner Of Payment    
,'01' AS MOP    
,'' AS HistoricoPagos    
--,CASE WHEN c.Judicial = 'Judicial' Then 'SG'     
--           WHEN c.Cartera = 'CASTIGADA' THEN 'UP'     
--           ELSE '' END AS Observacion    
--,'' AS Observacion -->CUM 2020.11.24 se quita xq al ser liquidado va vacio  
,'CC' AS Observacion -->ZCCU 2023.05.31 se asigna CC al ser liquidado -- ajuste solicitado por Auditoria y Cumplimiento   
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
INNER JOIN #MontoUltPago Moultpago with(nolock) on Moultpago.codprestamo=c.CodPrestamo    
left outer join #PlazoMeses as PlazoM with(nolock) on PlazoM.codprestamo=c.CodPrestamo    
--CROSS JOIN [FinAmigoBasesSic].dbo.vINTFCabeceraVr14 vINTFCabecera with(nolock)    
    
    
set @T2 = getdate()    
print '18--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
  

-------------------------------------------ASIGNA CLAVE DE OBSERVACION PARA LIQUIDACIONES CON QUITA O CONDONACIONES

update tCsBuroxTblReICueVr14CP-----#TEMPtCsBuroxTblReICueVr14             
set  Observacion = 'LC',SaldoVencido = cod.quita+cod.condonacion, MOP='97'  ---SE AGREGA MOP 97      
--from #TEMPtCsBuroxTblReICueVr14 as cue with(nolock)  ------------------------------------------------------------------------------OJO     
from tCsBuroxTblReICueVr14CP as cue with(nolock)  ------------------------------------------------------------------------------OJO            
inner join tCsPadronCarteraDet as pcd with(nolock) on pcd.CodPrestamo = cue.CodPrestamo              
inner join #ConQuita as cod with(nolock) on cod.codigocuenta= cue.CodPrestamo              
where pcd.cancelacion>=@fecini and pcd.cancelacion<=@fecha            
and pcd.codoficina not in ('97','230','231','999')   
and cod.quita+cod.condonacion>=1 --condicion para no reportar saldo vencido 0           
and pcd.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))            
and not (cod.quita=0 and cod.condonacion=0)            
and pcd.carteraactual<>'CASTIGADA'   
--select * from #ConQuita  with(nolock)  
  
--select * from #TEMPtCsBuroxTblReICueVr14CP with(nolock)  
--where   Observacion = 'LC'  
  
----------------------------ACTIVAR CUANDO ACTUALIZAS EL SP ------------------------------------------------------------------------------OJO  
------Actualiza MOP error    
update tCsBuroxTblReICueVr14CP set    
MOP = '02'    
where SaldoVencido > 0     
and MOP in ('00','UR', '01' )     
and Cancelacion = ''    
  
------Actualiza saldo actual > credito maximo --04/06/2018    
update tCsBuroxTblReICueVr14CP set    
CreditoMaximo = SaldoActual     
where SaldoActual > CreditoMaximo  

----Actualiza el monto a pagar --15.09.2023
--select CodPrestamo,MontoPagar,SaldoActual,OBSERVACION,CANCELACION
update tCsBuroxTblReICueVr14CP 
set MontoPagar = SaldoActual               
from tCsBuroxTblReICueVr14CP
where  MontoPagar>SaldoActual  

   
  
--------------------------------DESCOMENTAR Y USAR PARA PRUEBAS--------------------------------------------------------------------------OJO  
  --#TEMPtCsBuroxTblReICueVr14CP   
--update #TEMPtCsBuroxTblReICueVr14CP  
-- set  MOP = '02'    
--where SaldoVencido > 0     
--and MOP in ('00','UR', '01' )     
--and Cancelacion = ''   
  
-- --Actualiza saldo actual > credito maximo --04/06/2018    
--update #TEMPtCsBuroxTblReICueVr14CP  
-- set CreditoMaximo = SaldoActual     
--where SaldoActual > CreditoMaximo       
   
-------------------------------------------------------------------------------------------------------------------------------------  
set @T2 = getdate()    
print '19--> '+ cast( datediff(millisecond, @T1, @T2) as char(10))    
set @T1 = getdate()    
  
  
--DROP TABLE #TEMPtCsBuroxTblReICueVr14CP --- OJO  
DROP TABLE #tblmop_tmp  
DROP TABLE #Ca_unique  
DROP TABLE #CA  
DROP TABLE #DEPURADOS  
DROP TABLE #tblmop  
DROP TABLE #garantias  
DROP TABLE #maxGarantia  
DROP TABLE #tblmesgar  
DROP TABLE #tCsMesPlanCuotas  
DROP TABLE #PrimerIncumplimiento_tmp  
DROP TABLE #PrimerIncumplimiento  
DROP TABLE #ultimoMovTmp  
DROP TABLE #CAMo  
DROP TABLE #MontoUltPago  
DROP TABLE #PlazoMeses  
DROP TABLE #tCsCarteraFecha  
DROP TABLE #MoProxAmorAtraso  
DROP TABLE #MoProxAmor  
DROP TABLE #TEMPmops  
DROP TABLE #TEMPtblmop  
DROP TABLE #TEMPAvaluo  
DROP TABLE #TEMPSaldoVencido  
DROP TABLE #ConQuita  
  
/*  
--------------------------------------- VALIDAR AJUSTE -- SIN DEPURADOS-----  
------DESCOMENTAR Y USAR PARA PRUEBAS  
SELECT COUNT(*) FROM tCsBuroxTblReICueVr14CP WITH (NOLOCK) ------------------------OJO  
SELECT * FROM tCsBuroxTblReICueVr14CP WITH (NOLOCK)     -------------------------OJO  
  
  
--56,090  ----54,804  
SELECT  COUNT(distinct CODPRESTAMO) FROM #TEMPtCsBuroxTblReICueVr14CP WITH (NOLOCK) --------------------------------------------------------------------------------------------OJO  
SELECT  COUNT(distinct CODPRESTAMO) FROM #TEMPtCsBuroxTblReICueVr14CP WITH (NOLOCK) --------------------------------------------------------------------------------------------OJO  
  
  
--60710--////55,965 2023.05///-------------------58,813  
SELECT COUNT(distinct CODPRESTAMO) --select *   
FROM tCsBuroxTblReICueVr14CP WITH (NOLOCK) where substring(codprestamo,1,3)<>'500' --------------------------------------------------------------------------------------------OJO  
--inner join (select codcuenta  from dbo.tcsCCDepurados2023 dd with(nolock)  
--and Responsabilidad = 'I'  
--where Responsabilidad = 'I'  
  
  
---------------------4,009  
SELECT COUNT(distinct CODPRESTAMO) --select *   
FROM tCsBuroxTblReICueVr14CP c WITH (NOLOCK)  --------------------------------------------------------------------------------------------OJO  
inner join dbo.tcsCCDepurados2023 dd with(nolock)on dd.codcuenta=c.codprestamo  
where substring(codprestamo,1,3)<>'500'  
  
58,813 --- INICIO  
54,804 --- SIN DEPURADOS  
  
4,009 --- FALTANTES  
*/
GO