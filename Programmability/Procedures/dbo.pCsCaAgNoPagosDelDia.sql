SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaAgNoPagosDelDia] @codoficina varchar(5), @codasesor varchar(25), @fecha datetime
AS
BEGIN
	SET NOCOUNT ON;

--declare @codoficina varchar(5)
--declare @codasesor varchar(25)
--declare @fecha smalldatetime

--set @codoficina = '6'
--set @codasesor = 'MMM1504841'
--set @fecha ='20110105'

select cd.codprestamo,cl.nombrecompleto,det.saldocapital + det.interesvigente+det.interesvencido+interesctaorden
+ det.moratoriovigente+det.moratoriovencido+moratorioctaorden saldocapital ,det.capitalatrasado+det.capitalvencido deudaactual
, isnull(TelefonoDirFamPri,TelefonoDirNegPri) telefono,TelefonoMovil
,isnull(cl.DireccionDirFamPri,DireccionDirNegPri) +' '+ ubi.direccion direccion, g.NombreGrupo
,c.nrodiasatraso
--,pl.monto
from tCsPadronCarteraDet cd
inner join tcscarteradet det on det.fecha=cd.fechacorte and det.codprestamo=cd.codprestamo
and det.codusuario=cd.codusuario
inner join tcscartera c on c.fecha=det.fecha and c.codprestamo=det.codprestamo
  inner join tcspadronclientes cl on cl.codusuario=cd.codusuario
  left outer join vgnlubigeo ubi on ubi.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
  left outer join tCsCarteraGrupos g on g.CodGrupo=cd.codgrupo and g.codoficina=cd.codoficina
where cd.codoficina=@codoficina and cd.ultimoasesor=@codasesor
and c.nrodiasatraso>0 and c.nrodiasatraso<=day(@fecha)

END
GO