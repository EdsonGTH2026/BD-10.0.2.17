SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SE OPTIMIZA SP 2023.10.16 

CREATE procedure [dbo].[pcsFNMGPromedioSaldo]    
as    
set nocount on      
  
declare @fecha smalldatetime  ---LA FECHA DE CORTE  
select @fecha= fechaconsolidacion from vcsfechaconsolidacion  
  
/*--SALDO CARTERA TOTAL*/  
CREATE table #ptmos  (codprestamo varchar(30),saldocapital money,nrodiasatraso int,rango varchar(12),codtipo int)  
insert into #ptmos  
select codprestamo,saldocapital,nrodiasatraso  
,case when c.montodesembolso<3000 then 'a.3mil-'   
      when c.montodesembolso>=3000 and c.montodesembolso<5000 then 'b.3mil+'  
      when c.montodesembolso>=5000 and c.montodesembolso<7500 then 'c.5mil+'  
      when c.montodesembolso>=7500 and c.montodesembolso<10000 then 'd.7.5mil+'  
      when c.montodesembolso>=10000 and c.montodesembolso<15000 then 'e.10mil+'  
      when c.montodesembolso>=15000 and c.montodesembolso<20000 then 'f.15mil+'  
      when c.montodesembolso>=20000 and c.montodesembolso<30000 then 'g.20mil+'  
      when c.montodesembolso>=30000 and c.montodesembolso<40000 then 'h.30mil+'  
      when c.montodesembolso>=40000 and c.montodesembolso<50000 then 'i.40mil+'  
      when c.montodesembolso>=50000 and c.montodesembolso<75000 then 'j.50mil+'  
      when c.montodesembolso>=75000 and c.montodesembolso<100000 then 'k.75mil+'  
      when c.montodesembolso>=100000 and c.montodesembolso<150000 then 'l.100mil+'  
      when c.montodesembolso>=150000  then 'm.150mil+'  
else 'otra' end rango  
,substring(codprestamo,5,3)codtipo  
from tcscartera c with(nolock)  
where fecha=@fecha  
and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
and codoficina not in('97','231','230','98','999')--sucursal 98 solicitado por Miriam  
and cartera='ACTIVA'   
  
CREATE TABLE  #carteraTotal(rango varchar(12),categoria varchar(15),saldo money,nroPtmos money)  
insert into #carteraTotal  
select rango  
,case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then 'vigente0a30'  
 when c.nrodiasatraso>=31 and c.nrodiasatraso<=89 then'atraso31a89'  
 when c.nrodiasatraso>=90  then  'vencido90' end Categoria  
,sum(c.saldocapital) saldo   
,count(codprestamo) nroPtmos  
from #ptmos c   with(nolock)
where codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by rango  
,case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then 'vigente0a30'  
 when c.nrodiasatraso>=31 and c.nrodiasatraso<=89 then'atraso31a89'  
 when c.nrodiasatraso>=90  then  'vencido90' end  
  
  
  
  
CREATE TABLE #productivo (rango varchar(12),categoria varchar(15),saldo170 money,nroPtmos170 money)  
insert into #productivo --170  
select rango  
,case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then 'vigente0a30'  
 when c.nrodiasatraso>=31 and c.nrodiasatraso<=89 then'atraso31a89'  
 when c.nrodiasatraso>=90  then  'vencido90' end Categoria  
,sum(c.saldocapital) saldo170   
,count(codprestamo) nroPtmos170  
from #ptmos c   with(nolock)
where codtipo in (170,168,172) and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by rango  
,case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then 'vigente0a30'  
 when c.nrodiasatraso>=31 and c.nrodiasatraso<=89 then'atraso31a89'  
 when c.nrodiasatraso>=90  then  'vencido90' end  
   
CREATE TABLE #consumo (rango varchar(12),categoria varchar(15),saldo370 money,nroPtmos370 money)  
insert into #consumo --370  
select rango  
,case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then 'vigente0a30'  
 when c.nrodiasatraso>=31 and c.nrodiasatraso<=89 then'atraso31a89'  
 when c.nrodiasatraso>=90  then  'vencido90' end Categoria  
,sum(c.saldocapital) saldo370   
,count(codprestamo) nroPtmos370  
from #ptmos c  with(nolock) 
where codtipo=370 and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by rango  
,case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then 'vigente0a30'  
 when c.nrodiasatraso>=31 and c.nrodiasatraso<=89 then'atraso31a89'  
 when c.nrodiasatraso>=90  then  'vencido90' end  
  
  
  
  
  
------------ COLUMNA DE IMOR X TIPO 170-370  
  
declare @carteraImor table(rango varchar(12),saldo money,saldo_imor money)  
insert into @carteraImor  
select rango  
,sum(c.saldocapital)saldo  
,sum(case when  nrodiasatraso>=31 then c.saldocapital else 0 end) saldo31  
from #ptmos c   with(nolock)
where codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by rango  
  
declare @productivoImor table(rango varchar(12),saldo170 money,saldo170_imor money)  
insert into @productivoImor --170  
select rango  
,sum(c.saldocapital) saldo170   
,sum(case when   nrodiasatraso>=31 then c.saldocapital else 0 end)saldo170_imor  
from #ptmos c  with(nolock) 
where codtipo in (170,168,172) and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by rango  
   
declare @consumoImor table(rango varchar(12),saldo370 money,saldo370_imor money)  
insert into @consumoImor --370  
select rango  
,sum(c.saldocapital) saldo370   
,sum(case when   nrodiasatraso>=31 then c.saldocapital else 0 end)saldo370_imor  
from #ptmos c  with(nolock) 
where codtipo=370 and codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by rango  
  
Declare @IMOR table (fecha smalldatetime,rango varchar(15),imor31 money,imor31_170 money,imor31_370 money)  
insert into @IMOR  
select @fecha fecha, c.rango  
,isnull((c.saldo_imor)/(c.saldo),0)*100 imor31  
,isnull((p.saldo170_imor)/(p.saldo170),0)*100 imor31_170   
,isnull((o.saldo370_imor)/(o.saldo370),0)*100 imor31_370   
from @carteraImor c   
left outer join @productivoImor p on p.rango=c.rango   
left outer join @consumoImor o on o.rango=c.rango   
  
  
  
  
  
/*CONSULTA FINAL*/  
  
delete from FNMGConsolidado.dbo.tCaPromedioSaldo where fecha=@fecha  --comentar para ejecutar ----Se comenta para modificar la tabla  
insert into FNMGConsolidado.dbo.tCaPromedioSaldo    
  
select @fecha fecha, c.rango,c.categoria  
,(c.saldo) saldoCtera    
,(c.nroPtmos)  ptmosCtera  
,isnull((c.saldo)/c.nroPtmos,0)promSaldo_Ctera  
,(p.saldo170) saldo170   
,(p.nroPtmos170) nroPtmos170  
,isnull((p.saldo170)/p.nroPtmos170,0)promSaldo_170  
,(o.saldo370) saldo370   
,(o.nroPtmos370)  nroPtmos370  
,isnull((o.saldo370)/o.nroPtmos370,0)promSaldo_370  
,imor31,imor31_170,imor31_370  
from #carteraTotal c with(nolock)  
left outer join #productivo p with(nolock) on p.rango=c.rango and p.categoria=c.categoria  
left outer join #consumo o with(nolock) on o.rango=c.rango and o.categoria=c.categoria  
left outer join @IMOR i on i.rango=c.rango 

DROP TABLE #ptmos
DROP TABLE #carteraTotal
DROP TABLE #productivo
DROP TABLE #consumo
GO