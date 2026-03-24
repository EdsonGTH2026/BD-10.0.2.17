SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACAPagosDia] @fecini smalldatetime,@fecfin smalldatetime
as
--declare @fecini smalldatetime
--set @fecini ='20201113'
--declare @fecfin smalldatetime
--set @fecfin ='20201113'
set nocount on
create table #Co (
        fecha smalldatetime,
        codprestamo varchar(25),
        codusuario varchar(15),
        capital money,
        interes money,
        cargos money,
        seguros money,
        montoimpuestos money,
        codorigenpago varchar(15)
)
insert into #Co
select fecha, codigocuenta,codusuario
,montocapitaltran capital
,montointerestran interes
,montocargos cargos
,MontoOtrosTran seguros
,MontoImpuestos iva
,coddestino
from tcstransacciondiaria with(nolock)
where fecha>=@fecini and fecha<=@fecfin
and codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0
and codoficina not in('97','231','230')

declare @Ca table(
          codprestamo varchar(25),
          codfondo int,
		  codoficina varchar(3),
		  nrodiasatraso int
)
insert into @Ca
select p.codprestamo,c.codfondo,p.codoficina,c.nrodiasatraso
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo and c.codusuario=p.codusuario
where p.codprestamo in(select distinct codprestamo from #Co)

truncate table tCsACAPagos

insert into tCsACAPagos
select 
t.fecha
,t.codorigenpago
, t.codprestamo
,o.nomoficina sucursal
,c.nrodiasatraso
,count(t.codprestamo) nro
,sum(capital+interes+cargos+seguros+cargos*0.16+interes*0.16) total
,sum(capital) capital
,sum(case when c.codfondo=20 then t.capital*0.7 else 0 end) capitalprogre
,sum(case when c.codfondo=21 then t.capital*0.75 else 0 end) capitalCubo
,sum(case when c.codfondo=20 then t.capital*.3 
             when c.codfondo=21 then t.capital*.25 
             else t.capital end) capitalpropio

,sum(interes) interes
,sum(case when c.codfondo=20 then t.interes*0.7 else 0 end) interesProgresemos
,sum(case when c.codfondo=21 then t.interes*0.75 else 0 end) interesCubo
,sum(case 
       when c.codfondo=20 then t.interes*.30
       when c.codfondo=21 then t.interes*.25
       else t.interes end) interesPropio

,sum(cargos) cargos

,sum(seguros) seguros

,sum(cargos*0.16) cargosIVA

,sum(interes*0.16) IVAinteres
,sum(case when c.codfondo=20 then (t.interes*0.7)*0.16 else 0 end) IVAinteresProgresemos
,sum(case when c.codfondo=21 then (t.interes*0.75)*0.16 else 0 end) IVAinteresCubo
,sum(case when c.codfondo=20 then (t.interes*.30)*0.16
               when c.codfondo=21 then (t.interes*.25)*0.16       
               else t.interes*0.16 end) IVAinteresPropio
--into tCsACAPagos
from #Co t with(nolock)
inner join @Ca c on t.codprestamo=c.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
group by t.fecha,t.codorigenpago,t.codprestamo,o.nomoficina,c.nrodiasatraso

drop table #Co
GO