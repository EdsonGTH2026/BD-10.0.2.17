SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pXaCSDatogeneral '339-170-06-07-01977'
create procedure [dbo].[pXaCSDatogeneral] @codprestamo varchar(25)
as

--Sucursal origen:              Cosamaloapan
--Fecha de entrega:          13/03/2018
--Monto de desmbolso:     $15,000.00
--Tipo de producto:           Finamigo Productivo
--Plazo:                             16
--Periodicidad de pago:    Semanal
--Tasa de interés anual:   114% sin IVA
--Garantías:                      $1,100 depósito en cuenta ahorro
--Día elegido de pago:      Martes
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

select substring(o.nomoficina,1,1) + lower(substring(o.nomoficina,2,len(o.nomoficina))) sucursal,pd.desembolso,pd.monto,case when pd.codproducto='170' then 'Finamigo Productivo' else 'Finamigo' end producto
,c.nrocuotas plazo,case when c.modalidadplazo='M' then 'Mensual' when c.modalidadplazo='S' then 'Semanal' else 'Mensual' end periodo,c.tasaintcorriente tasa
,@garantia garantia,@dia dia
from tcspadroncarteradet pd with(nolock) --on pd.codprestamo=p.codprestamo and pd.codusuario=p.codusuario
inner join tcscarteradet d with(nolock) on d.codprestamo=pd.codprestamo and d.codusuario=pd.codusuario and d.fecha=pd.fechacorte
inner join tcscartera c with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=pd.codoficina
where pd.codprestamo=@codprestamo--'339-170-06-07-01977'--

GO