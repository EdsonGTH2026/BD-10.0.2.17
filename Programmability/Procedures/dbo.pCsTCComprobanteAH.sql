SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCsTCComprobanteAH] @fecha smalldatetime,@codoficina varchar(4),@criterio varchar(200)
AS
BEGIN
	SET NOCOUNT ON;

  SELECT @fecha fecha,t.descripcion Operacion,a.nrotrans,a.codcuenta,u.nombrecompleto ,a.MontoTotal total
  FROM [10.0.2.14].finmas.dbo.tAhTransaccion a
  inner join [10.0.2.14].finmas.dbo.tAhClTipoTrans t on t.idtipotrans=a.codtipotrans
  inner join [10.0.2.14].finmas.dbo.tahcuenta c 
  on c.codcuenta=a.codcuenta and c.fraccioncta=a.fraccioncta and c.renovado=a.renovado
  left outer join [10.0.2.14].finmas.dbo.tususuarios u on u.codusuario=c.codustitular
  where (a.fecha>=@fecha and a.fecha<=dateadd(day,1,@fecha)) and a.codoficina=@codoficina
  and a.codtipotrans in (21,22,23,24,25,26,16)
  and a.IdFactura = 0 and u.nombrecompleto like @criterio
 
END
GO