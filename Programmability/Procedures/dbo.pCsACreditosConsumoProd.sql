SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsACreditosConsumoProd] @fecha smalldatetime
as
--2)      Listado de créditos activos por Venta de Productos al momento con los siguientes campos:
--Sucursal
--No. Crédito
--Nombre de Cliente
--Fecha de ultimo desembolso
--Fecha de Vencimiento
--Monto
--Cód. De Producto
--Día de Pago --> ojo
--Teléfono
--Dirección
--Días de Mora / atraso
 
select o.nomoficina sucursal,c.codprestamo NoCredito,cl.nombrecompleto NombreCliente,c.fechadesembolso fechadesembolso,c.fechavencimiento,c.montodesembolso
--,p.secuenciacliente NoCiclos
,c.codproducto, dp.diapago
, isnull(isnull(cl.telefonodirfampri,telefonodirnegpri),'') telefono,isnull(cl.telefonomovil,'') telefonomovil
,case when isnull(cl.DireccionDirFamPri,DireccionDirNegPri) is null then ''
else
	upper(isnull(isnull(cl.DireccionDirFamPri,DireccionDirNegPri),'')) + ',' 
	+ case when NumExtFam is null or rtrim(ltrim(NumExtFam))=''
		  then (case when NumExtNeg is null or ltrim(rtrim(NumExtNeg))='' or ltrim(rtrim(NumExtNeg))='sn'
					 then 'S/N' else replace(replace(replace(replace(replace(NumExtNeg,' ',''),'*',''),'-',''),'.',''),'_','') end)
		  when rtrim(ltrim(NumExtFam))='sn' or rtrim(ltrim(NumExtFam))='SINNUMERO' then 'S/N'
		  else replace(replace(replace(replace(replace(NumExtFam,' ',''),'*',''),'-',''),'.',''),'_','') end + ' ' +
	case when NumIntFam is null or rtrim(ltrim(NumIntFam))=''
		  then (case when NumIntNeg is null or ltrim(rtrim(NumIntNeg))='' or ltrim(rtrim(NumIntNeg))='sn'
					 then '' else replace(replace(replace(replace(replace(NumIntNeg,' ',''),'*',''),'-',''),'.',''),'_','') end)
		  when rtrim(ltrim(NumIntFam))='sn' or rtrim(ltrim(NumIntFam))='SINNUMERO' then ''
		  else replace(replace(replace(replace(replace(NumIntFam,' ',''),'*',''),'-',''),'.',''),'_','') end	  
		  + ','
	+ isnull(u.descubigeo,'')
	+ case when isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1)='' or isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1)='0'
			then ''
			else ' CP.' + isnull(isnull(isnull(cl.CodPostalFam,cl.CodPostalNeg),u.campo1),'') end 
	+ ', ' + isnull(m.descubigeo,'') + ', Estado ' + isnull(e.descubigeo,'')
end
as Direccion
,c.nrodiasatraso
from tcscartera c with(nolock)
---inner join tcspadroncarteradet p with(nolock) on p.codprestamo=c.codprestamo
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
left outer join (select codprestamo,max(case datepart(weekday,fechavencimiento) when 1 then 'Domingo'
					when 2 then 'Lunes' when 3 then 'Martes' when 4 then 'Miercoles' when 5 then 'Jueves' when 6 then 'Viernes' when 7 then 'Sabado' else '0' end) diapago
				from tcspadronplancuotas with(nolock)
				where codconcepto='INTE'
				--and codprestamo='315-370-06-04-00016'
				group by codprestamo
) dp on dp.codprestamo=c.codprestamo
left outer join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
left outer join tclubigeo m with(nolock) on m.codarbolconta=substring(u.codarbolconta,1,19)
left outer join tclubigeo e with(nolock) on e.codarbolconta=substring(u.codarbolconta,1,13)
where c.fecha=@fecha--'20180717' 
and c.cartera='ACTIVA'
and c.codproducto='370'

--select codprestamo,max(case datepart(weekday,fechavencimiento) when 1 then 'Domingo'
--	when 2 then 'Lunes' when 3 then 'Martes' when 4 then 'Miercoles' when 5 then 'Jueves' when 6 then 'Viernes' when 7 then 'Sabado' else '0' end) diapago
--from tcspadronplancuotas with(nolock)
--where codconcepto='INTE'
--and codprestamo='315-370-06-04-00016'
--group by codprestamo

GO