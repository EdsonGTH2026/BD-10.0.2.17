SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACaDesembolsoxtipotransdatos] @fecha smalldatetime, @codoficina varchar(2000)
as 
	select * from tcsacadesembolsoxtipotrans with(nolock)
GO