SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pXaCaReDatosClientes] @codprestamo varchar(20)
as
--declare @codprestamo varchar(20)
--set @codprestamo='004-170-06-08-01287'

declare @codusuario varchar(15)

select @codusuario=rtrim(ltrim(codusuario))
from tcspadroncarteradet with(nolock)
where codprestamo=@codprestamo

select cl.nombrecompleto
,isnull(cl.direcciondirfampri,cl.direcciondirnegpri) direccion
,isnull(cl.codpostalfam,cl.codpostalneg) CodPostal
,u.descubigeo localidad
,mu.descubigeo municipio
,es.descubigeo estado
,isnull(cl.telefonodirfampri,cl.telefonodirnegpri) telefonodom
,isnull(cl.telefonomovil,'') nrocelular
,isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri) codubigeo
from tcspadronclientes cl with(nolock)
left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
left outer join tclubigeo mu with(nolock) on mu.codubigeotipo='MUNI' and mu.codarbolconta=substring(u.codarbolconta,1,19)
left outer join tclubigeo es with(nolock) on es.codubigeotipo='ESTA' and es.codarbolconta=substring(u.codarbolconta,1,13)
where cl.codusuario=@codusuario

GO