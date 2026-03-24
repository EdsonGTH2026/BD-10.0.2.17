SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsSaldoPromedioxCiclo] @fecha smalldatetime  
as     
set nocount on   
  
--declare @fecha smalldatetime  
--set @fecha='20220805'  
  
  
/*--SALDO CARTERA TOTAL*/  
declare @ptmos table (codprestamo varchar(30),saldocapital money,nrodiasatraso int,rango varchar(12))  
insert into @ptmos  
select c.codprestamo,cd.saldocapital,nrodiasatraso  
  
,case when pd.secuenciacliente >= 15 then 'Ciclo 15+'  
   when pd.secuenciacliente >= 10 then 'Ciclo 10-14'  
  when pd.secuenciacliente >= 5 then 'Ciclo 5-9'  
  when pd.secuenciacliente >= 3 then 'Ciclo 3-4'  
  when pd.secuenciacliente = 2  then 'Ciclo 2'  
  else 'Ciclo 1' end rangoCiclo  
  
--,substring(c.codprestamo,5,3)codtipo  
--from tcscartera c with(nolock)  
FROM tcspadroncarteradet pd with(nolock)  
left outer join tcscarteradet cd with(nolock) on  cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario  
left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha  
where c.fecha=@fecha 
and pd.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
and c.codoficina not in('97','231','230','98','999')--sucursal 98 solicitado por Miriam  
and cartera='ACTIVA'  
  
declare @carteraTotal table(rango varchar(12),categoria varchar(15),saldo money,nroPtmos money)  
insert into @carteraTotal  
select rango  
,case when c.nrodiasatraso>=0 and c.nrodiasatraso<=30 then 'vigente0a30'  
 when c.nrodiasatraso>=31 and c.nrodiasatraso<=89 then'atraso31a89'  
 when c.nrodiasatraso>=90  then  'vencido90' end Categoria  
,sum(c.saldocapital) saldo   
,count(codprestamo) nroPtmos  
from @ptmos c   
where codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
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
from @ptmos c   
where codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by rango  
  
Declare @IMOR table (fecha smalldatetime,rango varchar(15),imor31 money)  
insert into @IMOR  
select @fecha fecha, c.rango  
,isnull((c.saldo_imor)/(c.saldo),0)*100 imor31  
from @carteraImor c   
  
/*CONSULTA FINAL*/  
select @fecha fecha, c.rango,c.categoria  
,(c.saldo) saldoCtera    
,(c.nroPtmos)  ptmosCtera  
,isnull((c.saldo)/c.nroPtmos,0)promSaldo_Ctera  
,imor31  
--into FNMGConsolidado.dbo.tCaPromedioSaldo  
from @carteraTotal c   
left outer join @IMOR i on i.rango=c.rango 
GO