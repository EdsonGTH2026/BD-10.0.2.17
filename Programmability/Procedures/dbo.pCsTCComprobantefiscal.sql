SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCsTCComprobantefiscal] @codoficina varchar(4), @idfactura numeric(10,0),@codtipofactura varchar(2)
AS
BEGIN
	SET NOCOUNT ON;

  SELECT f.serie,f.folio,f.nroaprobacion,f.añoaprobacion,f.nroseriecerti,f.codusuario,f.RFC
      ,f.IVA,f.subtotal,f.total,f.cadoriginal,f.sellodigital,f.fecha,
      d.item,d.codsistema,d.desconcepto,d.monto,d.impuesto,d.total, 
      case @codtipofactura when '01' then 'FACTURA' when '07' then 'NOTA CREDITO' else 'NO DEFINIDO' end  tipocomprobante
      ,f.nombrefactura,d.cantidad
  FROM tCsTcFactura f with(nolock) inner join tCsTCFacturaDet d with(nolock) on f.idfactura=d.idfactura 
  and f.codoficina=d.codoficina and f.codtipofactura=d.codtipofactura
  where f.idfactura=@idfactura and f.codoficina=@codoficina and f.codtipofactura=@codtipofactura and f.estado=1

END
GO