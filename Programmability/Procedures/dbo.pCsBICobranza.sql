SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBICobranza] 
as

--sp_helptext [pCsBICobranza]
--exec [pCsBICobranza]


declare @Fecha smalldatetime
declare @FecIni smalldatetime
declare @FecFin smalldatetime


select @FecFin= fechaconsolidacion from vcsfechaconsolidacion
select @FecIni=(select primerdia from tclperiodo with(nolock) where primerdia<=@FecFin and ultimodia>=@FecFin)
select @fecha=dateadd(day,-1,@FecIni)

CREATE TABLE #Programada 
(Region varchar(50)
 ,Sucursal varchar(50)
 --,Codfondo int
 --,Nrodiasatraso int
 ,Codprestamo varchar(50)
 ,Fechavencimiento smalldatetime
 ,Capi money
 ,Inte money
 ,Inpe money
 ,Mora money
 ,Morad money
 ,sdv money
 ,MontoCuota money
 ,Intedev money
 --,RangoMora varchar(10)
 ,Finamigo money
 ,Progresemos money
 ,Faccorp money)
 
 Insert into #Programada

SELECT 
z.nombre Region, o.NomOficina AS sucursal--, c.codfondo
--, c.nrodiasatraso
,count(c.CodPrestamo) Codprestamo, a.FechaVencimiento
,Sum(a.CAPI) Capi, Sum(a.INTE) inte, Sum(a.INPE) inpe
,Sum(a.MORA) Mora, Sum(a.MORAD) Morad
, Sum(a.sdv) sdv, Sum(a.CAPI + a.INTE + a.INPE +a.sdv+a.MORA) MontoCuota, sum(a.INTEDEV) intedev
--,case when c.nrodiasatraso >=31 then '31+' else '0-30' end rangoMora
,Sum(case when c.codfondo=20 then (a.CAPI + a.INTE + a.INPE +a.sdv+a.MORA) *0.3 
      when c.CodFondo=21 then (a.CAPI + a.INTE + a.INPE +a.sdv+a.MORA) *.25
else (a.CAPI + a.INTE + a.INPE +a.sdv+a.MORA) end) Finamigo
,Sum(case when c.codfondo=20 then (a.CAPI + a.INTE + a.INPE +a.sdv+a.MORA) *0.7 else 0 end) Progresemos
,Sum(case when c.codfondo=21 then (a.CAPI + a.INTE + a.INPE +a.sdv+a.MORA) *0.75 else 0 end) Faccorp
FROM tCsCarteraDet d with(nolock)
INNER JOIN tCsCartera c with(nolock) ON d.Fecha = c.Fecha AND d.CodPrestamo = c.CodPrestamo
INNER JOIN tClOficinas o with(nolock) ON c.CodOficina=o.CodOficina
inner join tclzona z with(nolock) on z.zona=o.zona
LEFT OUTER JOIN tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
LEFT OUTER JOIN tcsempleadosfecha e on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano
INNER JOIN (
SELECT Fecha, FechaVencimiento, CodPrestamo, CodUsuario
,sum(CASE CodConcepto WHEN 'capi' THEN MontoCuota  ELSE 0 END) AS CAPI
,sum(CASE CodConcepto WHEN 'inte' THEN MontoCuota  ELSE 0 END) AS INTE
,sum(CASE CodConcepto WHEN 'inte' THEN MontoDevengado  ELSE 0 END) AS INTEDEV
,sum(CASE CodConcepto WHEN 'inpe' THEN MontoCuota  ELSE 0 END) AS INPE
,sum(CASE CodConcepto WHEN 'SDV' THEN MontoCuota  ELSE 0 END) AS SDV
,sum(CASE CodConcepto WHEN 'MORA' THEN MontoCuota  ELSE 0 END) AS MORA
,sum(CASE CodConcepto WHEN 'MORA' THEN MontoDevengado  ELSE 0 END) AS MORAD
FROM tCsPlanCuotas with(nolock)
WHERE fecha= @fecha and
   (EstadoCuota <> 'cancelado') AND 
(FechaVencimiento >=@FecIni) AND (FechaVencimiento <= @FecFin)
GROUP BY Fecha, FechaVencimiento, CodPrestamo, CodUsuario
) a ON d.CodPrestamo=a.CodPrestamo AND d.CodUsuario=a.CodUsuario 
WHERE (d.Fecha=@Fecha) AND (c.cartera='ACTIVA')
group by z.nombre,o.nomoficina,a.fechavencimiento 

create table #Co (
          fecha smalldatetime,
                                 codprestamo varchar(25),
          codoficina varchar(15),
          capital money,
          interes money,
          cargos money,
                                 seguros money,
                                 montoimpuestos money,
                                 --codorigenpago varchar(15)
)
insert into #Co
select fecha, codigocuenta, codoficina
,montocapitaltran capital
,montointerestran interes
,montocargos cargos
,MontoOtrosTran seguros
,MontoImpuestos iva
--,coddestino


from tcstransacciondiaria with(nolock)
where fecha>=@fecini and fecha<=@fecfin
and codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
and codoficina not in('97','231','230')

declare @Ca table(
          codprestamo varchar(25),
          sucursal varchar(25),
          nrodiasatraso int ,
          Codfondo int
 
)
insert into @Ca
select p.codprestamo, p.codoficina
,c.NroDiasAtraso, c.codfondo
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo --and c.codusuario=p.codusuario
where p.codprestamo in(select distinct codprestamo from #Co)

Create table #Real
(Fecha smalldatetime
,Region varchar(50)
,Sucursal varchar(50)
,Codprestamo varchar(50)
--,Fondo int 
,Capital money
,Interes money
,Cargos money
,Seguros money
,Iva money 
,Total money
,Finamigo money
,Progresemos money
,Faccorp money
,CapitalVig money
,CapitalVen money)

Insert into #Real

select 
t.fecha 
,z.nombre
, co.nomoficina Sucursal
,count(t.codprestamo) Codprestamo
--,c.codfondo Fondo
,sum(capital) capital
,sum(interes) interes
,sum(cargos) cargos
,sum(seguros) seguros
,Sum((interes+cargos)*0.16) IVA
,Sum((capital+interes+cargos+seguros+((interes+cargos)*0.16))) Total
,sum(case when c.codfondo=20 then (capital+interes+cargos+seguros+((interes+cargos)*0.16)) *0.3 
      when c.CodFondo=21 then (capital+interes+cargos+seguros+((interes+cargos)*0.16)) *.25
else (capital+interes+cargos+seguros+((interes+cargos)*0.16)) end) Finamigo
,Sum(case when c.codfondo=20 then (capital+interes+cargos+seguros+((interes+cargos)*0.16)) *0.7 else 0 end) Progresemos
,sum(case when c.codfondo=21 then (capital+interes+cargos+seguros+((interes+cargos)*0.16)) *0.75 else 0 end) Faccorp

,Sum(case when c.NroDiasAtraso<=30 then capital else 0 end) 'capital0-30'
,Sum(case when c.NroDiasAtraso>=31 then capital else 0 end) 'capital31+'
from #Co t
inner join @Ca c on t.codprestamo=c.codprestamo
inner join tcloficinas co on co.codoficina=c.sucursal
inner join tclzona z with(nolock) on z.zona=co.zona
group by t.fecha,z.nombre,co.nomoficina


--Select * from #Real

Select Isnull(p.Region,r.Region) Region, Isnull(p.Sucursal,r.sucursal) Sucursal
,Isnull( p.Fechavencimiento,r.fecha) Fecha
,(Isnull(p.montocuota,0)*1.18) MontoProgramado
,Isnull(r.total,0) TotalRec 
,Isnull(r.capital,0) Capital
,Isnull(r.Interes,0) Interes
,Isnull(r.Cargos,0) Cargos
,Isnull(r.seguros,0) Seguro
,Isnull(r.Iva,0) IVA
,Isnull(r.Finamigo,0) Finamigo
,Isnull(r.Progresemos,0) Progresemos
,Isnull(r.Faccorp,0) Faccorp
,(isnull(p.capi,0)*1.18) CapiProgramado
from #Programada p
full outer join #Real r on p.Sucursal = r.sucursal and p.fechavencimiento=r.fecha



Drop table #Programada
drop table #Co
drop table #Real 
GO