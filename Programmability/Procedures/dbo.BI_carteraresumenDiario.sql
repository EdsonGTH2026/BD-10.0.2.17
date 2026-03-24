SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--CARTERA POR CICLOS, consolidado--  
  
Create procedure [dbo].[BI_carteraresumenDiario] as  
--alter procedure BI_carteraresumenDiario as  
  
declare @fechacorte smalldatetime  
select @fechacorte = fechaconsolidacion from vcsfechaconsolidacion  
--set @fechacorte = '20240805'  
  
declare @fechaini smalldatetime  
--set @fechaini= dateadd(month,-2,dateadd(day,day(@fechacorte)*-1+1,@fechacorte))  
set @fechaini= dateadd(day,-98,dateadd(day,day(@fechacorte)*-1+1,@fechacorte))  
  
select DATEADD(DAY,DAY(T.Fecha)*-1+1,T.Fecha) Fecha  
,case when z.nombre in ('Bajio Norte','Bajio Occidente') then 'Bajio'  
   when z.nombre in ('Jalisco') then 'Jalisco'  
      when z.nombre in ('Centro','Estado','Costa Grande','Costa Chica') then 'Centro'  
      when z.nombre in ('Sur progreso','Sur tizimin') then 'Sur'  
   when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Veracruz'  
      else 'NA' end Division  
,z.Nombre region  
,o.NomOficina sucursal  
,count(t.codprestamo) nroCreditos  
,sum(t.SaldoCapital) saldoCapital  
,sum(t.interesVigente + t.interesVencido) saldoInteres   
,case   
      when c.NroDiasAtraso = 0 then 'a.bucket 0'  
      when c.NroDiasAtraso <= 7 then 'b.bucket 1-7'  
      when c.NroDiasAtraso <= 15 then 'c.bucket 8-15'  
   when c.NroDiasAtraso <= 21 then 'd.bucket 16-21'  
   when c.NroDiasAtraso <= 30 then 'e.bucket 22-30'  
      when c.NroDiasAtraso <= 60 then 'f.bucket 31-60'  
      when c.NroDiasAtraso <= 89 then 'g.bucket 61-89'  
      when c.NroDiasAtraso <= 120 then 'h.bucket 90-120'  
      when c.NroDiasAtraso <= 150 then 'i.bucket 121-150'  
      when c.NroDiasAtraso <= 180 then 'j.bucket 151-180'  
      when c.NroDiasAtraso <= 210 then 'k.bucket 181-210'  
      when c.NroDiasAtraso <= 240 then 'l.bucket 211-240'   
      when c.NroDiasAtraso > 240 then 'm.bucket 241+'  
      else '?' end bucketMora  
,case   
      when p.SecuenciaCliente >=11 then 'e.ciclo 11+'  
      when p.SecuenciaCliente >=4  then 'd.ciclo 4-10'  
      when p.SecuenciaCliente = 3  then 'c.ciclo 3'  
      when p.SecuenciaCliente = 2  then 'b.ciclo 2'  
      else 'a.ciclo 1' end rangoCiclo  
,case when t.MontoDesembolso > 100000 then 'c.+100k'   
      when t.MontoDesembolso > 30000 then 'b.+30k'  
   else 'a.-30k' end RangoMonto  
   ,t.Fecha FechaActual  
,case when c.NroDiasAtraso >= 23 and c.NroDiasAtraso <= 30 then c.NroDiasAtraso else 0 end EnRiesgo  
,0 Castigado  
from tcscarteradet t with(nolock)    
inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.Fecha = t.Fecha  
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
inner join tclzona z on z.zona=o.zona  
inner join tcspadroncarteradet p with(nolock) on p.CodPrestamo = c.CodPrestamo   
where  t.codoficina not in('97','98','231','230','999')   
and t.fecha >= @fechaini  
and c.cartera='ACTIVA'  
--and c.Cartera = 'CASTIGADO' and c.FechaCastigo >= '20221201' and c.FechaCastigo <= '20221231'  
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by   
t.Fecha   
,z.Nombre  
,case when z.nombre in ('Bajio Norte','Bajio Occidente') then 'Bajio'  
   when z.nombre in ('Jalisco') then 'Jalisco'  
      when z.nombre in ('Centro','Estado','Costa Grande','Costa Chica') then 'Centro'  
      when z.nombre in ('Sur progreso','Sur tizimin') then 'Sur'  
   when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Veracruz'  
      else 'NA' end  
,o.NomOficina   
,case   
      when c.NroDiasAtraso = 0 then 'a.bucket 0'  
      when c.NroDiasAtraso <= 7 then 'b.bucket 1-7'  
      when c.NroDiasAtraso <= 15 then 'c.bucket 8-15'  
   when c.NroDiasAtraso <= 21 then 'd.bucket 16-21'  
   when c.NroDiasAtraso <= 30 then 'e.bucket 22-30'  
      when c.NroDiasAtraso <= 60 then 'f.bucket 31-60'  
      when c.NroDiasAtraso <= 89 then 'g.bucket 61-89'  
      when c.NroDiasAtraso <= 120 then 'h.bucket 90-120'  
      when c.NroDiasAtraso <= 150 then 'i.bucket 121-150'  
      when c.NroDiasAtraso <= 180 then 'j.bucket 151-180'  
      when c.NroDiasAtraso <= 210 then 'k.bucket 181-210'  
      when c.NroDiasAtraso <= 240 then 'l.bucket 211-240'   
      when c.NroDiasAtraso > 240 then 'm.bucket 241+'  
      else '?' end  
,case   
      when p.SecuenciaCliente >=11 then 'e.ciclo 11+'  
      when p.SecuenciaCliente >=4  then 'd.ciclo 4-10'  
      when p.SecuenciaCliente = 3  then 'c.ciclo 3'  
      when p.SecuenciaCliente = 2  then 'b.ciclo 2'  
      else 'a.ciclo 1' end   
   ,case when t.MontoDesembolso > 100000 then 'c.+100k'   
      when t.MontoDesembolso > 30000 then 'b.+30k'  
   else 'a.-30k' end  
      ,case when c.NroDiasAtraso >= 23 and c.NroDiasAtraso <= 30 then c.NroDiasAtraso else 0 end  
  
   UNION ALL  
  
   select DATEADD(DAY,DAY(T.Fecha)*-1+1,T.Fecha) Fecha  
,case when z.nombre in ('Bajio Norte','Bajio Occidente') then 'Bajio'  
   when z.nombre in ('Jalisco') then 'Jalisco'  
      when z.nombre in ('Centro','Estado','Costa Grande','Costa Chica') then 'Centro'  
      when z.nombre in ('Sur progreso','Sur tizimin') then 'Sur'  
   when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Veracruz'  
      else 'NA' end Division  
,z.Nombre region  
,o.NomOficina sucursal  
,count(t.codprestamo) nroCreditos  
,0 saldoCapital  
,0 saldoInteres   
,'Castigado' bucketMora  
,case   
      when p.SecuenciaCliente >=11 then 'e.ciclo 11+'  
      when p.SecuenciaCliente >=4  then 'd.ciclo 4-10'  
      when p.SecuenciaCliente = 3  then 'c.ciclo 3'  
      when p.SecuenciaCliente = 2  then 'b.ciclo 2'  
      else 'a.ciclo 1' end rangoCiclo  
,case when t.MontoDesembolso > 100000 then 'c.+100k'   
      when t.MontoDesembolso > 30000 then 'b.+30k'  
   else 'a.-30k' end  
   ,t.Fecha FechaActual  
,0 EnRiesgo  
,sum(t.saldocapital) Castigado  
from tcscarteradet t with(nolock)    
inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.Fecha = t.Fecha  
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
inner join tclzona z on z.zona=o.zona  
inner join tcspadroncarteradet p with(nolock) on p.CodPrestamo = c.CodPrestamo   
where  t.codoficina not in('97','98','231','230','999')   
and t.fecha = c.FechaCastigo  
--and c.cartera='ACTIVA'  
and c.FechaCastigo >= @fechaini and c.FechaCastigo <= @fechacorte  
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))  
group by   
t.Fecha   
,z.Nombre  
,case when z.nombre in ('Bajio Norte','Bajio Occidente') then 'Bajio'  
   when z.nombre in ('Jalisco') then 'Jalisco'  
      when z.nombre in ('Centro','Estado','Costa Grande','Costa Chica') then 'Centro'  
      when z.nombre in ('Sur progreso','Sur tizimin') then 'Sur'  
   when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Veracruz'  
      else 'NA' end  
,o.NomOficina   
,case   
      when p.SecuenciaCliente >=11 then 'e.ciclo 11+'  
      when p.SecuenciaCliente >=4  then 'd.ciclo 4-10'  
      when p.SecuenciaCliente = 3  then 'c.ciclo 3'  
      when p.SecuenciaCliente = 2  then 'b.ciclo 2'  
      else 'a.ciclo 1' end   
,case when t.MontoDesembolso > 100000 then 'c.+100k'   
      when t.MontoDesembolso > 30000 then 'b.+30k'  
   else 'a.-30k' end
GO