SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCARptProgresemosPagos]
as
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion
--set @fecha='20200814'

create table #rst(
	codprestamo varchar(25),
	fecha smalldatetime,
	secpago int,
	rst money,
	ivarst money
)
insert into #rst
select p.codprestamo,p.fechapago,p.secpago,co.rst,co.ivarst
from [10.0.2.14].finmas.dbo.tcapagoreg p --with(nolock)
inner join (
	select secpago,codoficina
	--,sum(case when codconcepto='CAPI'  then montopagado else 0 end) capital
	--,sum(case when codconcepto='INTE'  then montopagado else 0 end) interes
	--,sum(case when codconcepto='IVAIT'  then montopagado else 0 end) ivainteres
	,sum(case when codconcepto='RST'  then montopagado else 0 end) rst
	,sum(case when codconcepto='IVART'  then montopagado else 0 end) ivarst
	--,sum(case when codconcepto='MORA'  then montopagado else 0 end) cargomora
	--,sum(case when codconcepto='IVAMO'  then montopagado else 0 end) ivacargomora
	--,sum(case when codconcepto='SVD'  then montopagado else 0 end)  seguro
	--,sum(case when codconcepto='SDD'  then montopagado else 0 end)  segurodeu
	from [10.0.2.14].finmas.dbo.tcapagodet d --with(nolock)
	group by secpago,codoficina
) co on co.secpago=p.secpago and co.codoficina=p.codoficina
where p.fechapago=@fecha
and co.rst<>0

create table #Pagos(
	codprestamo varchar(25),
	fechapago smalldatetime,
	pagototal money,
	capitaltotal money,
	interestotal money,
	ivatotal money,
	origenpago varchar(5),
	tipopago varchar(15),
	rst money
)
insert into #Pagos
select t.codigocuenta codprestamo,t.fecha fechapago
,t.montocapitaltran+t.montointerestran+t.montointerestran*0.16 
	+ (case when t.montoinvetran<>0 then t.montoinvetran else (case when t.montootrostran<>0 then isnull(r.rst,0) else 0 end) end)
	+ (case when t.montoinvetran<>0 then 0 else (case when t.montootrostran<>0 then isnull(r.ivarst,0) else 0 end) end) pagototal
,t.montocapitaltran capitatotal,t.montointerestran interestotal
,t.montointerestran*0.16 + (case when t.montoinvetran<>0 then 0 else (case when t.montootrostran<>0 then isnull(r.ivarst,0) else 0 end) end) ivatotal
,t.coddestino
,case when t.tipotransacnivel3 in(104,105) then 'Pago' else 'Condonación' end tipopago
,case when t.montoinvetran<>0 then t.montoinvetran else (case when t.montootrostran<>0 then isnull(r.rst,0) else 0 end) end montorst
from tcstransacciondiaria t with(nolock)
left outer join #rst r with(nolock) on r.fecha=t.fecha and r.codprestamo=t.codigocuenta and r.secpago=t.nrotransaccion
where t.fecha=@fecha and t.codsistema='CA' and t.extornado=0 and t.tipotransacnivel3 in(104,105,2) --not in(102,3,0,2)
and t.tipotransacnivel1<>'E'

--select t.*,r.*
--from tcstransacciondiaria t with(nolock)
--left outer join #rst r with(nolock) on r.fecha=t.fecha and r.codprestamo=t.codigocuenta and r.secpago=t.nrotransaccion
--where t.fecha=@fecha and t.codsistema='CA' and t.extornado=0 and t.tipotransacnivel3 in(104,105,2) --not in(102,3,0,2)
--and t.tipotransacnivel1<>'E'

--2764
select p.codprestamo,cl.nombrecompleto cliente,pd.desembolso fechaotorgamiento
,c.fechavencimiento,p.fechapago,p.pagototal,p.capitaltotal,p.interestotal,p.ivatotal
,p.pagototal*0.7 pagoprogresemos
,p.capitaltotal*0.7 capitalprogresemos,p.interestotal*0.7 interesprogresemos,p.ivatotal*0.7 ivaprogresemos
,case when p.tipopago='Condonacion' then '' else (case when p.origenpago in('3','4','5','DB','VB','7') then 'Bancos' else 'Efectivo' end) end procedenciapago
,c.tiporeprog
,p.tipopago
,p.rst
,p.rst*0.7 rstprogresemos
from #Pagos p with(nolock)
inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=p.codprestamo
inner join tcscartera c with(nolock) on c.codprestamo=pd.codprestamo and c.fecha=pd.fechacorte
inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
where c.codfondo=20
--483

drop table #Pagos
drop table #rst
GO

GRANT EXECUTE ON [dbo].[pCsCARptProgresemosPagos] TO [jmartinezc]
GO

GRANT EXECUTE ON [dbo].[pCsCARptProgresemosPagos] TO [jarriagaa]
GO