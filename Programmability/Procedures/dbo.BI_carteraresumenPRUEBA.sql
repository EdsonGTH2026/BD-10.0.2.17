SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[BI_carteraresumenPRUEBA] as
--ALTER procedure BI_carteraresumen as          
             
declare @fechacorte smalldatetime              
select @fechacorte = fechaconsolidacion from vcsfechaconsolidacion              
--set @fechacorte = '20241013'              
         
declare @fechaini smalldatetime              
set @fechaini= dateadd(day,day(@fechacorte)*-1+1,@fechacorte)              
            
select c.codprestamo, dateadd(day,day(c.FechaCastigo)*-1+1,c.FechaCastigo) Fecha            
into #Castigados            
from tCsCartera c             
where  c.codoficina not in('97','98','231','230','999')               
and c.fecha = c.FechaCastigo            
and c.FechaCastigo >= '20230101' and c.FechaCastigo <= @fechacorte and day(c.FechaCastigo) in ('28','29','30','31')            
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))              
and MONTH(c.FechaCastigo) in ('3','6','9','12')            
              
select DATEADD(DAY,DAY(T.Fecha)*-1+1,T.Fecha) Fecha              
,case when z.nombre in ('Bajio Norte', 'Bajio Occidente') then 'Bajio'              
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
,case when c.NroDiasAtraso = 0 then 'a.bucket 0'              
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
,case when p.SecuenciaCliente >=11 then 'e.ciclo 11+'              
      when p.SecuenciaCliente >=4  then 'd.ciclo 4-10'              
      when p.SecuenciaCliente = 3  then 'c.ciclo 3'              
      when p.SecuenciaCliente = 2  then 'b.ciclo 2'              
      else 'a.ciclo 1' end rangoCiclo              
,case when t.MontoDesembolso > 100000 then 'c.+100k'               
      when t.MontoDesembolso > 30000 then 'b.+30k'              
      else 'a.-30k' end RangoMonto              
,t.Fecha              
,case when c.NroDiasAtraso >= 23 and c.NroDiasAtraso <= 30 then c.NroDiasAtraso 
      else 0 end EnRiesgo              
,0 Castigado              
,0 PlantillaAutorizada              
,0 Plantilla              
,0 Plantilla6Mas              
,0 Plantilla6Menos              
,0 gerentes              
,0 AntGerente              
,0 PlantillaInicial              
,SUM(case when w.codprestamo is not null then t.SaldoCapital else 0 end) CapitalWA              
from tcscarteradet t with(nolock)                
inner join tcscartera c with(nolock) on c.CodPrestamo = t.CodPrestamo and c.Fecha = t.Fecha              
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina              
inner join tclzona z on z.zona=o.zona              
inner join tcspadroncarteradet p with(nolock) on p.CodPrestamo = c.CodPrestamo               
left outer join (select * from FNMGConsolidado.dbo.tCaDesembAutoRenovacion               
				 WHERE codprestamo not in (select codprestamonuevo 
				 from tCsACaLIQUI_RR where nuevodesembolso >= '20240101' and atrasomaximo >= 17 and Estado = 'Renovado' )) w on t.CodPrestamo = w.codprestamo              
where  t.codoficina not in('97','98','231','230','999')               
and t.fecha in (@fechacorte,'20211231'              
                ,'20220131','20220228','20220331','20220430','20220531','20220630','20220731','20220831','20220930','20221031','20221130','20221231'              
				,'20230131','20230228','20230331','20230430','20230531','20230630','20230731','20230831','20230930','20231031','20231130','20231231'              
				,'20240131','20240229','20240331','20240430','20240531','20240630','20240731','20240831','20240930','20241031','20241130','20241231'
				,'20250131','20250228','20250331','20250430','20250531','20250630','20250731')              
and c.cartera='ACTIVA'              
and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))              
group by               
t.Fecha               
,z.Nombre              
,case when z.nombre in ('Bajio Norte', 'Bajio Occidente') then 'Bajio'              
	  when z.nombre in ('Jalisco') then 'Jalisco'              
      when z.nombre in ('Centro','Estado','Costa Grande','Costa Chica') then 'Centro'              
	  when z.nombre in ('Sur progreso','Sur tizimin') then 'Sur'              
	  when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Veracruz'              
      else 'NA' end              
,o.NomOficina               
,case when c.NroDiasAtraso = 0 then 'a.bucket 0'              
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
,case when p.SecuenciaCliente >=11 then 'e.ciclo 11+'              
      when p.SecuenciaCliente >=4  then 'd.ciclo 4-10'              
      when p.SecuenciaCliente = 3  then 'c.ciclo 3'              
      when p.SecuenciaCliente = 2  then 'b.ciclo 2'              
      else 'a.ciclo 1' end               
,case when t.MontoDesembolso > 100000 then 'c.+100k'               
      when t.MontoDesembolso > 30000 then 'b.+30k'              
      else 'a.-30k' end              
,case when c.NroDiasAtraso >= 23 and c.NroDiasAtraso <= 30 then c.NroDiasAtraso else 0 end              
              
UNION ALL              
              
select c.Fecha,             
case when z.nombre in ('Bajio Norte', 'Bajio Occidente') then 'Bajio'              
     when z.nombre in ('Jalisco') then 'Jalisco'              
     when z.nombre in ('Centro','Estado','Costa Grande','Costa Chica') then 'Centro'              
     when z.nombre in ('Sur progreso','Sur tizimin') then 'Sur'              
     when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Veracruz'              
     else 'NA' end Division              
,z.Nombre region              
,o.NomOficina sucursal            
,count(ca.codprestamo) nroCreditos            
,0 saldoCapital            
,0 saldoInteres            
,'Castigado' bucketMora            
,case when p.SecuenciaCliente >=11 then 'e.ciclo 11+'              
      when p.SecuenciaCliente >=4  then 'd.ciclo 4-10'              
      when p.SecuenciaCliente = 3  then 'c.ciclo 3'              
      when p.SecuenciaCliente = 2  then 'b.ciclo 2'              
      else 'a.ciclo 1' end rangoCiclo              
,case when t.MontoDesembolso > 100000 then 'c.+100k'               
      when t.MontoDesembolso > 30000 then 'b.+30k'              
      else 'a.-30k' end rangoMonto            
,c.Fecha            
,0 EnRiesgo            
,sum(ca.SaldoCapital) Castigado            
,0 PlantillaAutorizada              
,0 Plantilla              
,0 Plantilla6Mas              
,0 Plantilla6Menos              
,0 gerentes              
,0 AntGerente              
,0 PlantillaInicial              
,0 CapitalWA              
from #Castigados c            
inner join tCsCartera ca with(nolock) on ca.CodPrestamo = c.CodPrestamo and ca.Fecha = c.Fecha            
inner join tcscarteradet t with(nolock) on t.CodPrestamo = c.CodPrestamo and t.Fecha = c.Fecha            
inner join tcloficinas o with(nolock) on o.codoficina=ca.codoficina            
inner join tclzona z on z.zona=o.zona              
inner join tcspadroncarteradet p with(nolock) on p.CodPrestamo = c.CodPrestamo            
            
group by c.Fecha            
,case when z.nombre in ('Bajio Norte', 'Bajio Occidente') then 'Bajio'              
	  when z.nombre in ('Jalisco') then 'Jalisco'              
      when z.nombre in ('Centro','Estado','Costa Grande','Costa Chica') then 'Centro'              
      when z.nombre in ('Sur progreso','Sur tizimin') then 'Sur'              
	  when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Veracruz'              
      else 'NA' end            
,z.Nombre            
,o.NomOficina            
,case when p.SecuenciaCliente >=11 then 'e.ciclo 11+'              
      when p.SecuenciaCliente >=4  then 'd.ciclo 4-10'              
      when p.SecuenciaCliente = 3  then 'c.ciclo 3'              
      when p.SecuenciaCliente = 2  then 'b.ciclo 2'              
      else 'a.ciclo 1' end            
,case when t.MontoDesembolso > 100000 then 'c.+100k'               
      when t.MontoDesembolso > 30000 then 'b.+30k'              
      else 'a.-30k' end            
              
UNION ALL              
              
SELECT DATEADD(DAY,DAY(@fechacorte)*-1+1,@fechacorte) Fecha              
,case when z.nombre in ('Bajio Norte', 'Bajio Occidente') then 'Bajio'              
      when z.nombre in ('Jalisco') then 'Jalisco'              
      when z.nombre in ('Centro','Estado','Costa Grande','Costa Chica') then 'Centro'              
      when z.nombre in ('Sur progreso','Sur tizimin') then 'Sur'              
      when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Veracruz'              
      else 'NA' end Division              
,z.Nombre region              
,o.nomoficina sucursal              
,0 nroCreditos              
,0 saldoCapital              
,0 saldoInteres              
,'a.bucket 0' bucketMora              
,'a.ciclo 1' rangoCiclo              
,'a.-30k' RangoMonto              
,@fechacorte Fecha              
,0 EnRiesgo              
,0 Castigado              
,MAX(m.monto) AS PlantillaAutorizada              
,COUNT(DISTINCT p.PROMOTOR) AS Plantilla              
,COUNT (DISTINCT(CASE WHEN DATEDIFF(MONTH, p.Fecha_Ingreso, @fechacorte) >= 6 THEN p.promotor END)) AS Plantilla6Mas          
,COUNT (DISTINCT(CASE WHEN DATEDIFF(MONTH, p.Fecha_Ingreso, @fechacorte) < 6 THEN p.promotor END)) AS Plantilla6Menos              
--INTO #Plantilla               
,COUNT(DISTINCT GERENTE) as gerentes              
,DATEDIFF(day,isnull(MIN(g.FECHA_INGRESO),@fechacorte),@fechacorte) AntGerente              
,COUNT(DISTINCT i.PROMOTOR) AS PlantillaInicial              
,0 CapitalWA              
        
FROM FNMGConsolidado.dbo.tCaCartaGerente3APP g WITH (NOLOCK)            
left outer join (select * from tcscametas where tipocodigo = 1 and meta = 3 and descripcion = 'Activo') m on m.codigo = g.codoficina         
left outer join FNMGCONSOLIDADO.DBO.TCACARTAPROMOTOR3APP p ON p.CODOFICINA = m.codigo AND p.FECHACONSULTA = @fechacorte              
left outer join FNMGCONSOLIDADO.DBO.TCACARTAPROMOTOR3APP i ON i.CODOFICINA = m.codigo AND i.FECHACONSULTA = dateadd(day,day(@fechacorte)*-1,@fechacorte)              
--left outer join FNMGConsolidado.dbo.tCaCartaGerente3APP g with(nolock) on g.CODOFICINA = m.Codigo and g.FechaConsulta = @fechacorte and g.GERENTE not in ('SIN GERENTE ASIGNADO')              
inner join tcloficinas o with(nolock) on o.codoficina=m.Codigo              
inner join tclzona z on z.zona=o.zona              
        
WHERE             
 g.FechaConsulta = @fechacorte        
--AND m.descripcion = 'Activo' and m.fecha = '20240930'              
and p.PROMOTOR not in ('HERNANDEZ VARGAS V CESAR ALEXANDER',
'MARQUEZ LEON V RENE YAMANI',
'MOJICA RUIZ V JOSE ALBERTO',
'RODRIGUEZ DOMINGUEZ VCITLALLY',
'TADEO RICO V EDGAR GUSTAVO',
'VILLA SALAZAR V MARISELA',
'VILLANUEVA RAMIREZ V PEDRO')              
and i.PROMOTOR not in ('HERNANDEZ VARGAS V CESAR ALEXANDER',
'MARQUEZ LEON V RENE YAMANI',
'MOJICA RUIZ V JOSE ALBERTO',
'RODRIGUEZ DOMINGUEZ VCITLALLY',
'TADEO RICO V EDGAR GUSTAVO',
'VILLA SALAZAR V MARISELA',
'VILLANUEVA RAMIREZ V PEDRO')              
GROUP BY 
case when z.nombre in ('Bajio Norte', 'Bajio Occidente') then 'Bajio'              
	 when z.nombre in ('Jalisco') then 'Jalisco'              
     when z.nombre in ('Centro','Estado','Costa Grande','Costa Chica') then 'Centro'              
     when z.nombre in ('Sur progreso','Sur tizimin') then 'Sur'              
	 when z.nombre in ('Veracruz norte','Veracruz sur','Tabasco - Chiapas') then 'Veracruz'              
     else 'NA' end              
,z.Nombre              
,o.nomoficina            
            
 drop table #Castigados
GO