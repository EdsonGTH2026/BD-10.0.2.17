SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRptCrecimientoPromotor] @codoficina varchar(100)
as

--declare @codoficina varchar(100)
--set @codoficina='318'

declare @sucursales table(codigo varchar(4))
insert into @sucursales
select codigo 
from dbo.fduTablaValores(@codoficina)

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

select c.promotor,c.ini_monto,c.fin_monto,c.asi_monto_asi asignado,c.qui_monto_qui retirado,c.crecimiento
,datediff(month,ex.ingreso,@fecha) antiguedad

,case	when c.ini_monto>0 and c.ini_monto<=300000 then 'A'
		when c.ini_monto>300000 and c.ini_monto<=600000 then 'B'
		when c.ini_monto>600000 and c.ini_monto<=900000 then 'C'
		when c.ini_monto>900000 and c.ini_monto<=1200000 then 'D'
		when c.ini_monto>1200000 and c.ini_monto<=1500000 then 'E'
		when c.ini_monto>1500000 and c.ini_monto<=2000000 then 'F'
		when c.ini_monto>2000000 and c.ini_monto<=2500000 then 'G'
		when c.ini_monto>2500000 then 'H' else '' end Nivel
,case	when c.ini_monto>0 and c.ini_monto<=300000 then 20
		when c.ini_monto>300000 and c.ini_monto<=600000 then 32
		when c.ini_monto>600000 and c.ini_monto<=900000 then 40
		when c.ini_monto>900000 and c.ini_monto<=1200000 then 52
		when c.ini_monto>1200000 and c.ini_monto<=1500000 then 60
		when c.ini_monto>1500000 and c.ini_monto<=2000000 then 72
		when c.ini_monto>2000000 and c.ini_monto<=2500000 then 80
		when c.ini_monto>2500000 then 80 else 100 end MetaMes
,case	when c.ini_monto>0 and c.ini_monto<=300000 then 10
		when c.ini_monto>300000 and c.ini_monto<=600000 then 16
		when c.ini_monto>600000 and c.ini_monto<=900000 then 20
		when c.ini_monto>900000 and c.ini_monto<=1200000 then 26
		when c.ini_monto>1200000 and c.ini_monto<=1500000 then 30
		when c.ini_monto>1500000 and c.ini_monto<=2000000 then 36
		when c.ini_monto>2000000 and c.ini_monto<=2500000 then 40
		when c.ini_monto>2500000 then 40 else 50 end MetaQuin

from tCsACrecimientoPromotor c with(nolock)
left outer join tcsempleados ex on ex.codusuario=c.codpromotor
where c.codoficina in(select codigo from @sucursales)
GO