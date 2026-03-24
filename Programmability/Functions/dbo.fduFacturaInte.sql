SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fduFacturaInte](@nrofactura numeric(10,0),@codoficina varchar(4),@tipfactura varchar(5))
RETURNS int
AS
BEGIN
	
	RETURN (select isnull(max(item),0)+1 from tCsTCFacturaIntegra
  where idFactura=@nrofactura and codoficina=@codoficina and CodTipoFactura=@tipfactura)

END
GO