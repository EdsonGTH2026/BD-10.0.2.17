SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsBICobranzaRecibida] 
as

--sp_helptext [pCsBICobranzaRecibida]
--exec [pCsBICobranzaRecibida]


declare @Fecha smalldatetime
declare @FecIni smalldatetime
declare @FecFin smalldatetime


select @FecFin= fechaconsolidacion from vcsfechaconsolidacion
select @FecIni='20200101'
select @fecha=dateadd(day,-1,@FecIni)


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
t.fecha--, day(t.fecha) dia, month(t.fecha) Mes 
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


Select *, day(fecha) dia
, Case when month(fecha)=1 then '1.Enero'
  when month(fecha)=2 then '2.Febrero'
  when month(fecha)=3 then '3.Marzo'
  when month(fecha)=4 then '4.Abril'
  when month(fecha)=5 then '5.Mayo'
  when month(fecha)=6 then 'Junio'
  when month(fecha)=7 then 'Julio'
  when month(fecha)=8 then 'Agosto'
  when month(fecha)=9 then 'Septiembre'
  when month(fecha)=10 then 'Octubre'
  when month(fecha)=11 then 'Noviembre'
  when month(fecha)=12 then 'Diciembre'
  else 'Na' end
 Mes from #Real

drop table #Co
drop table #Real 
GO