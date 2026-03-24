SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaCSCADatogeneral '339-170-06-07-01977'
CREATE procedure [dbo].[pXaCSCADatogeneral] @codprestamo varchar(25)
as

--declare @codprestamo varchar(25)
--set @codprestamo='339-170-06-07-01977'

declare @garantia money
select @garantia=isnull(sum(mocomercial),0) --monto
from tcsgarantias with(nolock)
where codigo=@codprestamo--'339-170-06-07-01977' 
and tipogarantia in('GARAH','EFECT')

declare @dia varchar(10)
select @dia=case when dia=1 then 'Domingo' when dia=2 then 'Lunes' when dia=3 then 'Martes' when dia=4 then 'Miercoles' when dia=5 then 'Jueves' when dia=6 then 'Viernes' when dia=7 then 'Sabado' else '' end
from (
	select distinct datepart(weekday,fechavencimiento) dia
	from tcspadronplancuotas
	where codprestamo=@codprestamo--'339-170-06-07-01977'
	and seccuota=1
) a

select substring(o.nomoficina,1,1) + lower(substring(o.nomoficina,2,len(o.nomoficina))) sucursal
,dbo.fdufechaatexto(pd.desembolso,'DD-MM-')+ cast(year(pd.desembolso) as char(4)) desembolso
,pd.monto,case when pd.codproducto='170' then 'Finamigo Productivo' else 'Finamigo' end producto
,c.nrocuotas plazo,case when c.modalidadplazo='M' then 'Mensual' when c.modalidadplazo='S' then 'Semanal' else 'Mensual' end periodo,c.tasaintcorriente tasa
,@garantia garantia,@dia dia
,isnull(cl.direcciondirfampri,cl.direcciondirnegpri) + ' ' + isnull(cl.numextfam,cl.numextneg) + ' ' + isnull(cl.numintfam,cl.numintneg) + ', C.P.' + isnull(codpostalfam,codpostalneg) direccion
,u.descubigeo localidad
,mu.descubigeo municipio
,es.descubigeo estado
,isnull(cl.telefonodirfampri,cl.telefonodirnegpri) telofono
,isnull(TelefonoMovil,'') celular
,isnull(cl.uscurp,'') curp
,isnull(cl.usrfc,'') rfc
from tcspadroncarteradet pd with(nolock) --on pd.codprestamo=p.codprestamo and pd.codusuario=p.codusuario
inner join tcscarteradet d with(nolock) on d.codprestamo=pd.codprestamo and d.codusuario=pd.codusuario and d.fecha=pd.fechacorte
inner join tcscartera c with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=pd.codoficina
inner join tcspadronclientes cl with(nolock) on cl.codusuario=pd.codusuario
left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(codubigeodirfampri,codubigeodirnegpri)
left outer join tclubigeo mu with(nolock) on mu.codubigeotipo='MUNI' and mu.codarbolconta=substring(u.codarbolconta,1,19)
left outer join tclubigeo es with(nolock) on es.codubigeotipo='ESTA' and es.codarbolconta=substring(u.codarbolconta,1,13)
where pd.codprestamo=@codprestamo--'339-170-06-07-01977'--
--select top 10 * from tcspadronclientes with(nolock)
--select top 10 * from tclubigeo with(nolock)
GO