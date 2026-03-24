SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCAClientesCarteraAhorros] @codoficina varchar(200), @fecha smalldatetime AS
set nocount on
--declare @codoficina varchar(200)
--declare @fecha smalldatetime
--set @fecha='20130430'
--set @codoficina='2,3,5,6,7'

create table #tmpah(
  codcuenta varchar(25),
  codusuario varchar(15),
  saldocuenta money
)
insert into #tmpah
select codcuenta,codusuario,saldocuenta from tcsahorros with(nolock) where fecha=@fecha

select ca.codoficina, o.nomoficina, cl.nombrecompleto, ca.codprestamo,ca.nrodiasatraso
,cd.saldocapital,cd.interesvigente+interesvencido interes, cd.moratoriovigente + moratoriovencido moratorio
,cd.saldocapital+cd.interesvigente+interesvencido+cd.moratoriovigente+moratoriovencido montototal
,ca.fechavencimiento,isnull(cl.telefonodirfampri,cl.telefonodirnegpri) telefono
,isnull(cl.direcciondirfampri,cl.direcciondirnegpri) direccion,u.DescUbiGeo colonia, isnull(cl.codpostalfam,cl.codpostalneg) codpostal 
,ah.codcuenta, ah.saldocuenta
from tcscartera ca with(nolock)
inner join tcscarteradet cd with(nolock) on ca.fecha=cd.fecha and ca.codprestamo=cd.codprestamo
inner join tcspadronclientes cl with(nolock) on cl.codusuario=cd.codusuario
left outer join tClUbigeo u with(nolock) on u.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirfampri)
inner join tcloficinas o with(nolock) on o.codoficina=ca.codoficina
inner join #tmpah ah on ah.codusuario=cd.codusuario
where ca.fecha=@fecha and ca.cartera='ACTIVA'
and ca.codoficina in (select codigo from dbo.fduTablaValores(@codoficina))

drop table #tmpah
GO