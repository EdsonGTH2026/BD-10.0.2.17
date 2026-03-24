SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pFMKDatosCobranza] @tipo int = 0, @codusuario varchar(15), @codprestamo varchar(25) = ''
AS

--declare @tipo int
--set @tipo=2 --0:por defecto, titular 1:aval 2:codeudor
--declare @codusuario varchar(15)
--set @codusuario='GGM1210671'
--declare @codprestamo varchar(25)
--set @codprestamo=''

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

create table #c(
  codprestamo varchar(25),
  montooriginal decimal(18,2),
  saldocapital decimal(18,2),
  saldocartera decimal(18,2),
  deudatotal decimal(18,2),
  cuotasporpagar int,
  cuotasatrasadas int,
  nrodiasatraso int,
  codusuario varchar(15)
)

insert into #c
select top 1 c.codprestamo
,d.montodesembolso MontoOriginal,d.saldocapital,d.saldocapital+d.interesvigente+d.interesvencido+d.moratoriovigente+d.moratoriovencido saldocartera
,d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovigente+d.moratoriovencido+d.moratorioctaorden
+d.otroscargos+d.impuestos+d.cargomora deudatotal,c.nrocuotasporpagar, 0 Cuotasatrasadas,c.nrodiasatraso, @codusuario
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.fecha=@fecha and d.codusuario=@codusuario
and c.codprestamo like (case when @codprestamo<>'' then @codprestamo else '%' end)

if(@tipo=0)
begin
  select c.codprestamo,cl.paterno, cl.materno, cl.nombres
  ,isnull(cl.telefonodirfampri,'') +'| ' +isnull(cl.telefonodirnegpri,'')+'| '+isnull(cl.telefonomovil,'') telefonos
  ,c.MontoOriginal,c.saldocapital,c.saldocartera
  ,c.deudatotal,c.cuotasporpagar, c.Cuotasatrasadas,c.nrodiasatraso
  ,isnull(cl.direcciondirfampri,cl.direcciondirnegpri) +' '+ isnull(cl.numextfam,cl.numextneg) +' '+ isnull(cl.numintfam,cl.numintneg) direccion,u.colonia,isnull(codpostalfam,codpostalneg) codpostal,u.municipio
  ,u.estado,c.codusuario
  from #c c
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
  left outer join vCsUbigeoColonia u on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
  
end
if(@tipo=1) --AVAL
begin
  
  SELECT top 1 @codusuario=DocPropiedad
  FROM tCsGarantias with(nolock)
  where tipogarantia='IPN' and codigo=(select codprestamo from #c)
  
  update #c set codusuario=(select codusuario from tcspadronclientes with(NOLOCK) where codorigen=@codusuario)
  
  select c.codprestamo,cl.paterno, cl.materno, cl.nombres
  ,isnull(cl.telefonodirfampri,'') +'| ' +isnull(cl.telefonodirnegpri,'')+'| '+isnull(cl.telefonomovil,'') telefonos
  ,c.MontoOriginal,c.saldocapital,c.saldocartera
  ,c.deudatotal,c.cuotasporpagar, c.Cuotasatrasadas,c.nrodiasatraso
  ,isnull(cl.direcciondirfampri,cl.direcciondirnegpri)  +' '+ isnull(cl.numextfam,cl.numextneg) +' '+ isnull(cl.numintfam,cl.numintneg) direccion,u.colonia,isnull(codpostalfam,codpostalneg) codpostal,u.municipio
  ,u.estado,c.codusuario
  from #c c
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
  left outer join vCsUbigeoColonia u on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
  
end
if(@tipo=2) --CODEUDOR
begin
  
  SELECT top 1 @codusuario=CodUsuario
  FROM tCsPrestamoCodeudor with(nolock)
  where codprestamo=(select codprestamo from #c)
  
  update #c set codusuario=@codusuario
  
  select c.codprestamo,cl.paterno, cl.materno, cl.nombres
  ,isnull(cl.telefonodirfampri,'') +'| ' +isnull(cl.telefonodirnegpri,'')+'| '+isnull(cl.telefonomovil,'') telefonos
  ,c.MontoOriginal,c.saldocapital,c.saldocartera
  ,c.deudatotal,c.cuotasporpagar, c.Cuotasatrasadas,c.nrodiasatraso
  ,isnull(cl.direcciondirfampri,cl.direcciondirnegpri) +' '+ isnull(cl.numextfam,cl.numextneg) +' '+ isnull(cl.numintfam,cl.numintneg)  direccion,u.colonia,isnull(codpostalfam,codpostalneg) codpostal,u.municipio
  ,u.estado,c.codusuario
  from #c c
  inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codusuario
  left outer join vCsUbigeoColonia u on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
  
end

drop table #c
GO