SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsCaAgendaxDiaSaldos] @codusuario varchar(25), @fecha smalldatetime
AS
BEGIN
	SET NOCOUNT ON;

--declare @codusuario varchar(25)
--set @codusuario='RPR1703871'
--declare @fecha smalldatetime
--set @fecha='20110117'

SELECT a.fecha,a.codusuario,ase.nombrecompleto asesor,a.codorigen,a.codprestamo,cl.nombrecompleto,c.nrodiasatraso,c.estado
,cd.saldocapital,
cd.InteresVigente+cd.InteresVencido+cd.InteresCtaOrden+cd.MoratorioVigente+cd.MoratorioVencido+cd.MoratorioCtaOrden saldointereses
,cd.OtrosCargos+cd.Impuestos+cd.CargoMora otrosconceptos
, isnull(cl.TelefonoDirFamPri,cl.TelefonoDirNegPri) telefono, cl.TelefonoMovil
,isnull(cl.DireccionDirFamPri,cl.DireccionDirNegPri) +' '+ ubi.direccion direccion, g.NombreGrupo
FROM tCsCaSegAgenda a inner join tcspadroncarteradet p
on p.codusuario=a.codorigen and p.codprestamo=a.codprestamo
inner join tcscarteradet cd on cd.fecha=p.fechacorte and cd.codprestamo=p.codprestamo and cd.codusuario=p.codusuario
inner join tcscartera c on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
inner join tcspadronclientes cl on cl.codusuario=p.codusuario
left outer join vgnlubigeo ubi on ubi.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
left outer join tCsCarteraGrupos g on g.CodGrupo=p.codgrupo and g.codoficina=p.codoficina
inner join tcspadronclientes ase on ase.codusuario=a.codusuario
where not(a.codprestamo is null) and a.codprestamo<>''
and a.codusuario=@codusuario and a.fecha=@fecha

END
GO