SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCsTCComprobanteTC] @fecha smalldatetime,@codoficina varchar(4), @criterio varchar(200)
AS
BEGIN
	SET NOCOUNT ON;

  SELECT s.fecha,t.nombre,s.nrotrans,s.codservicio,u.nombrecompleto,s.MontoTotal
  FROM [10.0.2.14].finmas.dbo.tTcServiciosTrans s
  inner join [10.0.2.14].finmas.dbo.tTcClServicios t on t.codoficina=s.codoficina and t.codservicio=s.codservicio
  inner join [10.0.2.14].finmas.dbo.tususuarios u on u.codusuario=s.codusuario
  where s.fecha=@fecha and s.codoficina=@codoficina and s.estado='CANCELADO' and s.tiposervicio=1
  and s.codservicio in('7','12','8') and montocomision = 0 and IdFactura=-1
  and u.nombrecompleto like @criterio
  union
  SELECT s.fecha,t.nombre,s.nrotrans,s.codservicio,u.nombrecompleto,s.MontoTotal
  FROM [10.0.2.14].finmas.dbo.tTcServiciosTrans s
  inner join [10.0.2.14].finmas.dbo.tTcClServicios t on t.codoficina=s.codoficina and t.codservicio=s.codservicio
  inner join [10.0.2.14].finmas.dbo.tususuarios u on u.codusuario=s.codusuario
  where s.fecha=@fecha and s.codoficina=@codoficina and s.estado='CANCELADO' and s.tiposervicio=1
  and s.codservicio in('18') and s.montocomision <> 0 and IdFacturaComision=-1
  and u.nombrecompleto like @criterio
END
GO