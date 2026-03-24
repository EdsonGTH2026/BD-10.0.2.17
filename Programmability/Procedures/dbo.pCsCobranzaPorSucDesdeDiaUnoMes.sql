SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO


--COBRANZA POR SUCURSAL DESDE EL 01 DEL MES.
CREATE procedure [dbo].[pCsCobranzaPorSucDesdeDiaUnoMes] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on
--use finamigoconsolidado
--comentar pruebas
--declare @fecha smalldatetime
--set @fecha = '20190523'

declare @fecini smalldatetime
set @fecini = dbo.fdufechaaperiodo( @fecha) + '01'
--select @fecini

declare @fecfin smalldatetime
set @fecfin = @fecha

create table #Co (
	fecha smalldatetime,
	codprestamo varchar(25),
	codoficina varchar(15),
	capital money,
	interes money,
	cargos money,
	seguros money,
	montoimpuestos money,
	codorigenpago varchar(15)
)

insert into #Co

select fecha, codigocuenta, codoficina
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
          sucursal varchar(25)
)

insert into @Ca
select p.codprestamo, p.codoficina
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on c.fecha=p.fechacorte and c.codprestamo=p.codprestamo --and c.codusuario=p.codusuario
where p.codprestamo in(select distinct codprestamo from #Co)

select 
--dbo.fdufechaaperiodo(t.fecha) mes, 
t.fecha,
co.nomoficina
,count(t.codprestamo) nro,sum(capital) capital
,sum(interes) interes
,sum(cargos) cargos
,sum(seguros) seguros
,sum(cargos*0.16) cargosIVA
,sum(interes*0.16) IVAinteres
from #Co t
inner join @Ca c on t.codprestamo=c.codprestamo
inner join tcloficinas co on co.codoficina=c.sucursal
--group by dbo.fdufechaaperiodo(t.fecha), co.nomoficina
group by t.fecha, co.nomoficina
 

drop table #Co
GO