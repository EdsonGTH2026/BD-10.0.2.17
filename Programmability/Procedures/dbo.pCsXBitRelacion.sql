SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsXBitRelacion]
as
BEGIN

	exec [10.0.2.14].Finmas.dbo.pCaXBitRelacion 

END
GO