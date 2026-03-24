SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsflujomiiomes]  
as    

declare @fecha smalldatetime    
set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion with(nolock))    
declare @fecini smalldatetime   
set @fecini =cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)   

declare @fecfin smalldatetime  
set @fecfin = cast(dbo.fdufechaaperiodo(DATEADD(m,1,@fecha))+'01' as smalldatetime)-1   

--insert into tcsCierremesMiio 
select c.fecha fecha 
,p.CodUsuario  
,p.CodPrestamo 
,p.Desembolso 
,c.NroDiasAtraso 
,c.SaldoCapital 
,@fecini as 'mes' 
,case when c.NroDiasAtraso >= 3 then 1 else 0 end as 'cer' 
,cast(dbo.fdufechaaperiodo(p.Desembolso)+'01' as smalldatetime) as 'mescosecha'  
into #tempCierremesMiio 
from tcscartera c with(nolock) 
--inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
--inner join tclzona z on z.zona=o.zona 
inner join tcspadroncarteradet p with(nolock) on p.CodPrestamo = c.CodPrestamo-- and c.fecha = p.fechacorte 
where c.codoficina = '999' 
and c.fecha>=@fecini 
and c.fecha<=@fecha  
and c.cartera='ACTIVA'  
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  

select  fecha periodo ,isnull(sum(SaldoCapital),0) as 'saldo' 
into #Saldocertres 
from #tempCierremesMiio with(nolock) 
where cer=1  
Group by fecha 
order by fecha ASC   

select  fecha+1 periodo ,isnull(sum(SaldoCapital),0) as 'saldo' 
into #Saldocerunion 
from #tempCierremesMiio with(nolock)
where cer=1 
Group by fecha+1 
order by fecha+1 ASC   

select a.periodo, b.saldo-a.saldo as delta 
into #delta 
from #Saldocerunion a 
inner join #Saldocertres b on a.periodo=b.periodo     
--cobranza miio
create table #Co (fecha smalldatetime,
codprestamo varchar(25)
,codoficina varchar(15)
,capital money
,interes money
--moratorios money
,moratorios2 money
--cargos money,
--seguros money,
,montoimpuestos money
,nrodiasatraso  int)

insert into #Co 

select t.fecha, t.codigocuenta
, t.codoficinacuenta 
,t.montocapitaltran capital 
,t.montointerestran interes 
--,t.MontoINVETran  
,t.MontoINPETran  
--,t.montocargos cargos 
--,t.MontoOtrosTran seguros 
,t.MontoImpuestos iva 
,isnull(c.nrodiasatraso,0) nrodiasatraso 
from tcstransacciondiaria t with(nolock) 
left outer join tcscartera c with(nolock) on c.fecha=(t.fecha-1) and c.codprestamo=t.codigocuenta 
where t.fecha>=@fecini and t.fecha<=@fecfin 
and t.codsistema='CA' 
and t.tipotransacnivel3 in(104,105) 
and t.extornado=0 and t.codoficina ='999'     

select t.fecha 
,t.codprestamo 
,t.nrodiasatraso 
,t.capital  
,t.interes  
--,t.moratorios 
,t.moratorios2 
--,t.cargos  
--,t.seguros 
--,t.cargos*0.16 cargosIVA 
,t.interes*0.16 IVAinteres 
,(t.capital +t.interes+t.moratorios2 + t.interes*0.16) pagoTotal 
,cast(dbo.fdufechaaperiodo(t.fecha)+'01' as smalldatetime) as 'mes' 
,t.interes +t.moratorios2 as 'interesT' 
into #flujo 
from #Co t with(nolock)
where (t.capital +t.interes+t.moratorios2 + t.interes*0.16) >0    


select fecha ,sum(interesT) as 'interes' 
into #flujomes 
from #flujo with(nolock)
group by fecha 
order by fecha    

select periodo
,interes-delta as 'flujo mes' 
from #delta d  with(nolock) 
inner join #flujomes f with(nolock) on d.periodo=f.fecha  

drop table #Co 
drop table #flujo 
drop table #tempCierremesMiio 
drop table #Saldocertres 
drop table #Saldocerunion 
drop table #delta 
drop table #flujomes --into tcscobranzaMiio
GO