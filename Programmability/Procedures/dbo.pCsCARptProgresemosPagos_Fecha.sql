SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCARptProgresemosPagos_Fecha] @fecha smalldatetime
as
--declare @fecha smalldatetime
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

create table #Pagos(
	codprestamo varchar(25),
	fechapago smalldatetime,
	pagototal money,
	capitaltotal money,
	interestotal money,
	ivatotal money,
	origenpago varchar(5)
)
insert into #Pagos
select codigocuenta codprestamo,fecha fechapago
,montocapitaltran+montointerestran+montointerestran*0.16 pagototal
,montocapitaltran capitatotal,montointerestran interestotal,montointerestran*0.16 ivatotal,coddestino
from tcstransacciondiaria t with(nolock)
where fecha=@fecha and codsistema='CA' and extornado=0 and tipotransacnivel3 in(104,105) --not in(102,3,0,2)
--2764
select p.codprestamo,c.fechadesembolso,cl.nombrecompleto cliente,pd.desembolso fechaotorgamiento
,c.fechavencimiento,p.fechapago,p.pagototal,p.capitaltotal,p.interestotal,p.ivatotal
,p.pagototal*0.7 pagoprogresemos
,p.capitaltotal*0.7 capitalprogresemos,p.interestotal*0.7 interesprogresemos,p.ivatotal*0.7 ivaprogresemos
,case when p.origenpago in('3','4','5','DB','VB','7') then 'Bancos' else 'Efectivo' end procedenciapago

from #Pagos p with(nolock)
inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=p.codprestamo
inner join tcscartera c with(nolock) on c.codprestamo=pd.codprestamo and c.fecha=pd.fechacorte
inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
where c.codfondo=20
--483

drop table #Pagos
GO

GRANT EXECUTE ON [dbo].[pCsCARptProgresemosPagos_Fecha] TO [jmartinezc]
GO

GRANT EXECUTE ON [dbo].[pCsCARptProgresemosPagos_Fecha] TO [jarriagaa]
GO