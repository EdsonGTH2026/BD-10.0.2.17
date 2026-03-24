SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[BI_Deterioro] as  
--alter procedure BI_Deterioro as  
declare @fecha smalldatetime  
select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
declare @fechaini smalldatetime  
set @fechaini=dateadd(month,-12,DATEADD(day,day(@fecha)*-1+1,@fecha))  
  
  
select p.CodPrestamo, p.Desembolso,  
DATEADD(day, -((DATEPART(weekday, p.Desembolso) + @@DATEFIRST - 1) % 7), p.Desembolso) AS InicioSemana,  
dbo.fdufechaaperiodo(p.Desembolso) Desembolso1, p.Monto,  
p.PrimerAsesor,  
e.Ingreso,  
--SE CALCULA LA ANTIGUEDAD DEL PROMOTOR ORIGEN DESDE SU FECHA DE INGRESO HASTA LA FECHA EN QUE COLOCO  
CASE WHEN DATEDIFF(DAY, e.Ingreso, p.Desembolso) <= 90 THEN '0-3'  
     WHEN DATEDIFF(DAY, e.Ingreso, p.Desembolso) <= 180 THEN '3-6'  
  WHEN DATEDIFF(DAY, e.Ingreso, p.Desembolso) <= 270 THEN '6-9'  
  WHEN DATEDIFF(DAY, e.Ingreso, p.Desembolso) <= 360 THEN '9-12'  
  ELSE '12+' END AntPromotor  
,case when s.score_valor < 500 then 'a.0-499'
	  when s.score_valor < 600 then 'b.500-599'
	  else 'c.+600' end RangoScore
into #desembolso  
from tcspadroncarteradet p with (nolock)   
LEFT OUTER JOIN tCsempleados e with(nolock) on e.CodUsuario=p.PrimerAsesor  
left outer join [FNMGConsolidado].dbo.[tCaDesembEval] s on s.codprestamo=p.codprestamo
where p.desembolso>=@fechaini--'20240801'  
and p.codoficina not in('97','231','230','98','999')  
--SELECT * FROM #desembolso   
  
  
select z.nombre region, o.NomOficina sucursal,c.CodPrestamo,   
c.SaldoCapital, c.NroDiasAtraso, c.fecha  
,case   
      when t.SecuenciaCliente >=11 then 'e.ciclo 11+'  
      when t.SecuenciaCliente >=4  then 'd.ciclo 4-10'  
      when t.SecuenciaCliente = 3  then 'c.ciclo 3'  
      when t.SecuenciaCliente = 2  then 'b.ciclo 2'  
      else 'a.ciclo 1' end rangoCiclo  
  
,case when c.codprestamo in (select codPrestamo  
from FNMGConsolidado.dbo.tCaDesembAutoRenovacion   
WHERE codprestamo not in (select codprestamonuevo   
                          from tCsACaLIQUI_RR where nuevodesembolso >= '20240101' and atrasomaximo >= 17 and Estado = 'Renovado' )) then 'Anticipado WA'  
   when t.TipoReprog = 'RENOV' then 'Anticipado'   
   when t.SecuenciaCliente =1 then 'Nuevo'  
      when DATEDIFF(MM,l.cancelacion,t.desembolso) >= 1 then 'Reactivado'   
      when l.cancelacion is null and t.SecuenciaCliente > 1 then 'Reactivado'  
      else l.estado end tipoCredito  
,ROW_NUMBER() over (partition by c.codprestamo order by c.fecha) SecCuota  
--,d.AntPromotor  
into #Periodos  
from tcscartera c  
--inner join tcscartera c on p.CodPrestamo = c.CodPrestamo and datename(weekday,c.Fecha) = 'Sunday'  
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina  
inner join tclzona z on z.zona=o.Zona   
inner join tcspadroncarteradet t with (nolock) on t.CodPrestamo=c.CodPrestamo  
left outer join tCsACaLIQUI_RR l on l.codprestamonuevo = c.CodPrestamo  
--left outer join #desembolso d on  d.CodPrestamo=c.CodPrestamo  
where c.CodPrestamo in (select CodPrestamo from #desembolso)  
and datename(weekday,c.Fecha) = 'Sunday'  
--SELECT * FROM #Periodos  
  
select   
p.Region, p.sucursal, p.SecCuota, p.rangoCiclo  
, p.tipoCredito  
, COUNT(distinct p.codprestamo) Ptmos  
,sum(case when NroDiasAtraso >= 8 then SaldoCapital else 0 end) Deterioro8  
,sum(case when NroDiasAtraso >= 15 then SaldoCapital else 0 end) Deterioro15  
,sum(case when NroDiasAtraso >= 31 then SaldoCapital else 0 end) Deterioro31  
,sum(case when NroDiasAtraso < 8 then SaldoCapital else 0 end) Vigente8  
,sum(case when NroDiasAtraso < 15 then SaldoCapital else 0 end) Vigente15  
,sum(case when NroDiasAtraso < 31 then SaldoCapital else 0 end) Vigente31  
,sum(d.Monto) Monto  
,d.Desembolso, d.InicioSemana,  
d.AntPromotor
,d.RangoScore
INTO #tabla  
from #desembolso d  
inner join #Periodos p on d.CodPrestamo = p.CodPrestamo  
group by p.Region, p.sucursal,p.rangoCiclo  
,p.tipocredito  
,p.SecCuota, d.Desembolso, d.InicioSemana, d.AntPromotor, d.RangoScore
order by d.Desembolso  
--select * from #tabla  
  
  
SELECT Region, Sucursal, SecCuota, rangoCiclo, tipoCredito,SUM(Ptmos) Ptmos, SUM(Deterioro8) Deterioro8, SUM(Deterioro15) Deterioro15, SUM(Deterioro31) Deterioro31,  
SUM(Vigente8) Vigente8, SUM(Vigente15) Vigente15, SUM(Vigente31) Vigente31, SUM(Monto) Monto, InicioSemana,AntPromotor,RangoScore
FROM #tabla  
GROUP BY Region, Sucursal, SecCuota, rangoCiclo, tipoCredito, InicioSemana,AntPromotor, RangoScore
ORDER BY InicioSemana, Region, Sucursal, SecCuota, rangoCiclo, tipoCredito  
  
  
drop table #desembolso  
drop table #Periodos  
drop table #tabla
GO