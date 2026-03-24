SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBIAntiguedadCartera] 
as

--sp_helptext [pCsBIAntiguedadCartera]
--exec [pCsBIAntiguedadCartera]

declare @fecini smalldatetime
set @fecini='20190101'
declare @fecfin smalldatetime
select @fecfin =fechaconsolidacion from vcsfechaconsolidacion  

declare @fecha smalldatetime
select @fecha = @fecini



CREATE TABLE #Desembolsos
(Region varchar(200)
,Sucursal varchar(200)
,Promotor varchar(200)
,Cosecha smalldatetime
,MontoDesembolsado money
,NroCreditos varchar(200)
,estatus varchar(100)
,puesto varchar(100) 
,Rangoantiguedad varchar(50))

INSERT INTO #desembolsos

select z.Nombre region, o.NomOficina sucursal, co.NombreCompleto promotor
,(select primerdia from tclperiodo with(nolock) where primerdia<=p.desembolso and ultimodia>=p.desembolso) cosecha
, p.Monto montoDesembolsado, p.CodPrestamo nroCreditos
,case when e.CodPuesto is null  then 'BAJA' else 'ACTIVO' end estatus
,case when e.CodPuesto is null  then 'BAJA' when e.CodPuesto='66' then 'PROMOTOR' else 'OTRO' end puesto
,case when (datediff (day, co.FechaIngreso, pe.PrimerDia)/30) >=12 then 'e12+meses'
                  when (datediff (day, co.FechaIngreso, pe.PrimerDia)/30) >=9 then 'd9-12meses'
                  when (datediff (day, co.FechaIngreso, pe.PrimerDia)/30) >=6 then 'c6-9meses'
                  when (datediff (day, co.FechaIngreso, pe.PrimerDia)/30) >=3 then 'b3-6meses'
                  else 'a1-3meses' end rangoAntiguedad

from tcspadroncarteradet p with(nolock)
inner join tcloficinas o on o.codoficina=p.codoficina
inner join tclzona z on z.zona=o.zona
left outer join tcspadronclientes co on co.codusuario=p.primerasesor 
inner join tclperiodo pe with(nolock) on pe.PrimerDia <= p.Desembolso and pe.UltimoDia >=p.Desembolso
left outer join tCsempleadosfecha e on e.CodUsuario=p.PrimerAsesor and e.Fecha=(select primerdia from tclperiodo with(nolock) where primerdia<=p.desembolso and ultimodia>=p.desembolso)
where Desembolso>=@fecini and Desembolso<=@fecfin and p.CodOficina<>97 and (p.tiporeprog<>'REEST' or p.tiporeprog is null)

CREATE TABLE #CosechaRangos
(Cosecha smalldatetime 
,Promotor varchar(200)
,Rango varchar(100))

while @fecha < @fecfin
begin
 
 set @fecha=dateadd(day,(-1),@fecha)
 
create table #ptmos (codprestamo varchar(25))  
insert into #ptmos  
select distinct codprestamo   
from tcscartera with(nolock)  
where fecha=@fecha
and cartera='ACTIVA' and codoficina not in('97','230','231')  
and codprestamo not in (select codprestamo from tCsCarteraAlta)  



create table #Actual  
( Promotor varchar(200)  
 ,Rango varchar(200))
   
 Insert into #Actual  
    
  SELECT    
  case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pc.nombrecompleto end promotor  
  ,case when (sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end)) >= 1500000 then 'f1500+'
    when (sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end)) >= 1200000 then 'e1200-1500'
    when (sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end)) >= 900000 then 'd900-1200'
    when (sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end)) >= 600000 then 'c600-900'
    when (sum(case when c.cartera<>'CASTIGADA' then case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end else 0 end)) >= 300000 then 'b300-600'
    else 'a0-300' end Rango
    
    FROM tCsCartera c with(nolock)  
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo  
  inner join tcspadroncarteradet pd with(nolock) on cd.codprestamo=pd.codprestamo and cd.codusuario=pd.codusuario  
  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
  inner join tclzona z on z.zona=o.zona  
  inner join tCsPadronClientes pc with(nolock) on pc.CodUsuario=c.CodAsesor  
  left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha  
  left outer join tcsempleados emp with(nolock) on c.codasesor = emp.codusuario 
  where c.fecha=@fecha
  and c.codprestamo in(select codprestamo from #ptmos)  
group by 
case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else pc.nombrecompleto end   --, emp.ingreso


INSERT INTO #CosechaRangos

select dateadd(day,1,@fecha) Cosecha,a.promotor,a.rango 
from #Actual a

drop table #Actual
drop table #ptmos

set @fecha=dateadd(day,1,@fecha)

set @fecha=dateadd(month,1,@fecha)

end

select d.Region, d.Sucursal, d.promotor, d.cosecha,d.montodesembolsado, d.nrocreditos, d.rangoantiguedad,isnull(c.rango,'a0-300') RangoCartera
 from #desembolsos d 
 left outer join #cosechaRangos c on d.promotor=c.promotor and d.cosecha=c.cosecha
 where d.puesto = 'Promotor' 
 
 
drop table #Desembolsos

drop table #CosechaRangos
GO