SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCaAgVencimientosDelDia] @codoficina varchar(5), @codasesor varchar(25), @fecha datetime	
AS
BEGIN
	SET NOCOUNT ON;

--declare @codoficina varchar(5)
--declare @codasesor varchar(25)
--declare @fecha smalldatetime

--set @codoficina = '6'
--set @codasesor = 'MMM1504841'
--set @fecha ='20110106'

select cd.codprestamo,pl.monto,cl.nombrecompleto,det.saldocapital
+InteresVigente+InteresVencido+InteresCtaOrden+MoratorioVigente+MoratorioVencido+MoratorioCtaOrden saldooriginal
, isnull(cl.TelefonoDirFamPri,cl.TelefonoDirNegPri) telefono,cl.TelefonoMovil
,isnull(cl.DireccionDirFamPri,cl.DireccionDirNegPri) +' '+ ubi.direccion direccion, g.NombreGrupo,ase.nombrecompleto asesor
from tCsPadronCarteraDet cd
inner join tcscarteradet det on det.fecha=cd.fechacorte and det.codprestamo=cd.codprestamo and det.codusuario=cd.codusuario
inner join tcscartera c on c.fecha=det.fecha and c.codprestamo=det.codprestamo
inner join (SELECT codoficina, codprestamo, codusuario, monto from (
SELECT codoficina, codprestamo, codusuario, sum(MontoDevengado-MontoPagado-MontoCondonado) monto
  FROM tCsPadronPlanCuotas p
  where p.fechavencimiento =@fecha
  group by codoficina, codprestamo, codusuario) a
  where monto<>0) pl
  on pl.codoficina=cd.codoficina and pl.codprestamo=cd.codprestamo and pl.codusuario=cd.codusuario
  inner join tcspadronclientes cl on cl.codusuario=cd.codusuario
  left outer join vgnlubigeo ubi on ubi.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
  left outer join tCsCarteraGrupos g on g.CodGrupo=cd.codgrupo and g.codoficina=cd.codoficina
  left outer join tcspadronclientes ase on ase.codusuario=cd.ultimoasesor
where cd.codoficina=@codoficina and cd.ultimoasesor=@codasesor
and c.nrodiasatraso=0

END
GO