SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaPICobranzaNac]
as
set nocount on

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion
--set @fecha='20190131'
declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(@fecha)+'01'
declare @fecfin smalldatetime
set @fecfin=@fecha

declare @Co table(
	codprestamo varchar(25),
	codusuario varchar(15),
	capital money,
	interes money,
	cargos money
)
insert into @Co
select codigocuenta,codusuario
,montocapitaltran capital
,montointerestran interes
,montocargos cargos
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
where p.codprestamo in(select distinct codprestamo from @Co)
and p.codoficina<>'98'

select count(t.codprestamo) nro,sum(capital) capital
,sum(case when c.codfondo=20 then t.capital*0.7 when c.codfondo=21 then t.capital*0.75 else 0 end) capitalprogre
,sum(case when c.codfondo=20 then t.capital*0.3 when c.codfondo=21 then t.capital*0.25 else t.capital end) capitalpropio
,sum(t.interes) interes
,sum(case when c.codfondo=20 then t.interes*0.7 when c.codfondo=21 then t.interes*0.75 else 0 end) interesprogre
,sum(case when c.codfondo=20 then t.interes*0.3 when c.codfondo=21 then t.interes*0.25 else t.interes end) interespropio
from @Co t
inner join @Ca c on t.codprestamo=c.codprestamo
GO