SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[pCsTCComprobanteIntegra] @idfactura numeric(10,0), @codoficina varchar(4), @tipo varchar(5)
AS
BEGIN
	SET NOCOUNT ON;

  SELECT f.codsistema,f.codtipoopera,f.descripconcepto,f.fechaoriginal, c.nombrecompleto ,f.monto,f.impuesto,
  f.total,f.coddato2,fc.serie,fc.folio,fc.nombrefactura,fc.fecha,o.nomoficina
  FROM tCsTCFacturaIntegra f with(nolock)
  left outer join (select codorigen,nombrecompleto from tcspadronclientes with(nolock)) c on
  c.codorigen=f.coddato1
  inner join tCsTCFactura fc with(nolock) on fc.idfactura=f.idfactura and fc.codoficina=f.codoficina and fc.codtipofactura=f.codtipofactura
  inner join tcloficinas o on o.codoficina=fc.codoficina
  where f.idfactura=@idfactura and f.codoficina=@codoficina and f.codtipofactura=@tipo
  order by f.codsistema, f.descripconcepto
  
END
GO