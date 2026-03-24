SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fduCorrTAE] (@codoficina varchar(5))
RETURNS int
AS
BEGIN
	return (SELECT isnull(max(idtrans),0) + 1
  FROM [FinamigoConsolidado].[dbo].[tCsTAENet]
  where codoficina=@codoficina)

END
GO