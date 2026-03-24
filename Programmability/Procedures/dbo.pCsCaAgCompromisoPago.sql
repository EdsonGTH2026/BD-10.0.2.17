SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCaAgCompromisoPago] @codprestamo varchar(25),@codusuario varchar(15),@fecha datetime,@hora datetime
AS
BEGIN
	SET NOCOUNT ON;

  SELECT s.codusuario,s.Codprestamo,s.fecha,s.hora,s.resultado,s.fechacompro,s.montocompro
  ,g.NombreGrupo,cd.saldocapital,cd.capitalvencido,cd.interesvigente,cd.interesvencido,cd.moratoriovigente,cd.moratoriovencido,
  cd.otroscargos,cd.impuestos,cd.cargomora,c.nrodiasatraso,
  cl.nombrecompleto,isnull(cl.DireccionDirFamPri,cl.DireccionDirNegPri) +' '+ ubi.direccion direccion,
  o.descoficina,o.direccion +' '+ ubi.direccion direccionoficina,
  case s.formapago when '1' then 'total' when '2' then 'parcial' when '3' then 'perzonalizada' else 'NINGUNA' end formapago
  FROM tCsCaSegCartera s
  inner join tcspadroncarteradet p on p.codprestamo=s.codprestamo and p.codusuario=s.codusuario
  left outer join tCsCarteraGrupos g on g.CodGrupo=p.codgrupo and g.codoficina=p.codoficina
  inner join tcscarteradet cd on cd.codprestamo=p.codprestamo and cd.codusuario=p.codusuario and cd.fecha=p.fechacorte
  inner join tcscartera c on c.codprestamo=cd.codprestamo and c.fecha=cd.fecha
  inner join tcspadronclientes cl on cl.codusuario=p.codusuario
  left outer join vgnlubigeo ubi on ubi.codubigeo=isnull(cl.codubigeodirfampri,cl.codubigeodirnegpri)
  inner join tcloficinas o on o.codoficina=p.codoficina
  left outer join vgnlubigeo ubiofi on ubi.codubigeo=o.codubigeo
  where s.codprestamo=@codprestamo and s.codusuario=@codusuario
  and s.fecha=@fecha and s.hora=@hora

END
GO