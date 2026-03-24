SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCobranzaPorDia] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on
---COBRANZA POR DIA--

declare @fecini smalldatetime
set @fecini = dbo.fdufechaaperiodo( @fecha) + '01' -- ='20190515' 

declare @fecfin smalldatetime
set @fecfin = @fecha --='20190515' 

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
          codfondo int
)

insert into @Ca
select p.codprestamo,c.codfondo
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo and c.codusuario=p.codusuario
where p.codprestamo in(select distinct codprestamo from #Co) 

select t.fecha, t.codorigenpago,
count(t.codprestamo) nro
,sum(capital) capital
,sum(case when c.codfondo=20 then t.capital*0.7 else 0 end) capitalprogre
,sum(case when c.codfondo=21 then t.capital*0.75 else 0 end) capitalFacorp
,sum(case when c.codfondo not in(20,21) then t.capital else t.capital*0.3 end) capitalpropio
,sum(interes) interes
,sum(case when c.codfondo=20 then t.interes*0.7 else 0 end) interesProgresemos
,sum(case when c.codfondo=21 then t.interes*0.75 else 0 end) interesFacorp
,sum(case when c.codfondo not in(20,21) then t.interes else t.interes*0.3 end) interesPropio
,sum(cargos) cargos
,sum(seguros) seguros
,sum(cargos*0.16) cargosIVA
,sum(interes*0.16) IVAinteres
,sum(case when c.codfondo=20 then (t.interes*0.7)*0.16 else 0 end) IVAinteresProgresemos
,sum(case when c.codfondo=21 then (t.interes*0.75)*0.16 else 0 end) IVAinteresFacorp
,sum(case when c.codfondo not in(20,21) then t.interes*0.16 else (t.interes*0.3)*0.16 end) IVAinteresPropio
from #Co t
inner join @Ca c on t.codprestamo=c.codprestamo
group by t.fecha, t.codorigenpago 

drop table #Co



GO