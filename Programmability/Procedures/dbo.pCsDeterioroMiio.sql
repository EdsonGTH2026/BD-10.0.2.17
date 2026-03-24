SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsDeterioroMiio]
as
set nocount on 

declare @fecha smalldatetime  
set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)  

------------------- DETERIORO  
declare @ptmos table(codprestamo varchar(20))  
insert into @ptmos  
select distinct pd.codprestamo  
from tcspadroncarteradet pd with(nolock)  
inner join [10.0.2.14].[finmas].[dbo].[tcaprestamos] c on c.CodPrestamo = pd.CodPrestamo and c.estado<>'ANULADO'
where pd.desembolso>='20221001'  -- A PARTIR DE QUE FECHA COSECHAS SE EVALUA  
and pd.desembolso<=@fecha       -- fecha corte  
and pd.codoficina  in('999')   
and pd.codprestamo not in (select codprestamo from tCsCarteraAlta)  

/*--- Mostrar un periodo de  12 cosechas */   
declare @deterioro table (zona varchar(4)  
  ,codoficina varchar(3)  
  ,montodesembolso money  
  ,recuperado money  
  ,cosecha varchar(6) ,ciclo varchar(13)
  ,D0saldo money  
  --,D2saldo money  
  ,D3saldo money  
  ,Castigadosaldo money,D3ptmos money,TotalPtmos money)  
insert into @deterioro       
select a.zona,a.codoficina  
,sum(montodesembolso) montodesembolso  
,sum(montodesembolso)-sum(D0saldo)-sum(Castigadosaldo) recuperado  
,cosecha cosecha ,ciclo --,sum(saldocapital)saldocapital
,sum(D0saldo)D0saldo  
-- ,sum(D2saldo)D2saldo  
,sum(D3saldo)D3saldo  
,sum(Castigadosaldo)Castigadosaldo  
,sum(D3ptmos)D3ptmos
,sum(D0ptmos)TotalPtmos
from (  
SELECT o.zona,
o.codoficina ,  
isnull(cd.saldocapital,0) saldocapital  
,pd.monto montodesembolso,clc.ciclo  
,dbo.fdufechaaperiodo(pd.Desembolso) cosecha    
,case when c.cartera= 'CASTIGADA' then   cd.saldocapital   else 0 end Castigadosaldo  
,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=3 then  cd.saldocapital  else 0 end else 0 end D3saldo  
,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=3 then  1 else 0 end else 0 end D3ptmos  
,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 then cd.saldocapital  else 0 end else 0 end D0saldo 
,case when c.cartera<>'CASTIGADA' then  case when c.NroDiasAtraso>=0 then 1  else 0 end else 0 end D0ptmos

FROM tcspadroncarteradet pd with(nolock)  
left outer join tcscarteradet cd with(nolock) on cd.fecha=@fecha and cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario  
left outer join tCsCartera c with(nolock) on cd.codprestamo=c.codprestamo and cd.fecha=c.fecha  
inner join tcloficinas o with(nolock) on o.codoficina=pd.codoficina  
inner join tcsCicloMIIO_230920 clc with(nolock) on pd.codprestamo=clc.codprestamo 
where pd.codprestamo in(select codprestamo from @ptmos)   
) a   
group by a.zona,a.codoficina,cosecha,ciclo
order by zona,codoficina,cosecha,ciclo 

select cosecha,
case when ciclo in (1) then 'ciclo 1' 
when ciclo in (2) then 'ciclo 2' 
when ciclo in (3,4) then 'ciclo 3-4' 
when ciclo in (5,6) then 'ciclo 5-6' 
when ciclo >= 7 then 'ciclo 7+' end
Rangociclo
,sum(montodesembolso)colocacion,sum(D3saldo)D3saldo,sum(recuperado)recuperado
,sum(recuperado/montodesembolso)porRecupera
,(sum(D3saldo)/sum(montodesembolso))*100 Deterioro
FROM  @deterioro 
group by  cosecha,
case when ciclo in (1) then 'ciclo 1' 
when ciclo in (2) then 'ciclo 2' 
when ciclo in (3,4) then 'ciclo 3-4' 
when ciclo in (5,6) then 'ciclo 5-6' 
when ciclo >= 7 then 'ciclo 7+' end
union
select cosecha,'TOTAL'
,sum(montodesembolso)colocacion,sum(D3saldo)D3saldo,sum(recuperado)recuperado
,(sum(recuperado)/sum(montodesembolso))*100 porRecupera
,(sum(D3saldo)/sum(montodesembolso))*100 Deterioro
FROM  @deterioro 
group by  cosecha



GO