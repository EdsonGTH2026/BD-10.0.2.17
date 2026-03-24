SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fduFacturaTrans](@codoficina varchar(4),@tipcomprob varchar(5))
RETURNS numeric(10, 0)
AS
BEGIN
	
	RETURN (SELECT isnull(max(idFactura),0) + 1
  FROM tCsTcFactura
  where CodTipoFactura=@tipcomprob and codoficina=@codoficina)

END
GO