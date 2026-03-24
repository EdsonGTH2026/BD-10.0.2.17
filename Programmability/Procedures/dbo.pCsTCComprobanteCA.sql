SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCsTCComprobanteCA] @fecha smalldatetime,@codoficina varchar(4), @criterio varchar(200), @tipo char(1)
AS
BEGIN	
	SET NOCOUNT ON;

  declare @cad varchar(2000)
  set @cad = 'SELECT top 20 p.fechapago fecha, ''Recuperaciones'' Concepto,p.secpago, p.codprestamo, u.nombrecompleto, p.montopago '
  set @cad = @cad + 'FROM [10.0.2.14].finmas.dbo.tCaPagoReg p '
  set @cad = @cad + 'inner join [10.0.2.14].finmas.dbo.tcaprestamos ca on ca.codprestamo=p.codprestamo '
  set @cad = @cad + 'inner join [10.0.2.14].finmas.dbo.tususuarios u on u.codusuario=ca.codusuario '
  set @cad = @cad + 'where p.fechapago='''+dbo.fduFechaAAAAMMDD(@fecha)+''' and p.codoficina='+@codoficina+' and p.extornado=0 '
  if (@tipo='0') set @cad = @cad + 'and (p.Factura = ''0'' or p.Factura = '''') '
  set @cad = @cad + 'and u.nombrecompleto like '''+@criterio+''' union '
  set @cad = @cad + 'select top 20 t.fechapago fecha, ''Comision apertura'' Concepto,t.secpagoparcial secpago,t.codprestamo, u.nombrecompleto, t.MontoPago '
  set @cad = @cad + 'from [10.0.2.14].finmas.dbo.tCaPagoParcialAnticipado t '
  set @cad = @cad + 'inner join [10.0.2.14].finmas.dbo.tcaprestamos p on t.codprestamo=p.codprestamo '
  set @cad = @cad + 'inner join [10.0.2.14].finmas.dbo.tususuarios u on u.codusuario=p.codusuario '
  set @cad = @cad + 'where t.fechapago='''+dbo.fduFechaAAAAMMDD(@fecha)+''' and t.codoficina='+@codoficina+' and t.extornado=0 '
  if (@tipo='0') set @cad = @cad + 'and t.idfactura is null '
  set @cad = @cad + 'and u.nombrecompleto like '''+@criterio+''''
  print @cad
  execute (@cad)
  
END
GO