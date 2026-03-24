SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
create function [dbo].[fduDetFacturaLinea] (@a numeric(10, 0),@b varchar(4),@c varchar(5))
 returns varchar(1000)
as
begin 
  declare @desconcepto varchar(1000)

  SELECT @desconcepto = COALESCE(@desconcepto+',','') + desconcepto
  FROM tCsTCFacturaDet
  where idfactura=@a
  and codoficina=@b
  and CodTipoFactura=@c

  return (@desconcepto)

end
GO