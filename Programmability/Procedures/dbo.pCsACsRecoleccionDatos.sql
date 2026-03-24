SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACsRecoleccionDatos]  @fecha smalldatetime, @codoficina varchar(500)
as
	set nocount on
set ansi_warnings off
	declare @Fecini smalldatetime
	select @Fecini=dateadd(day,-30,fechaconsolidacion) from vcsfechaconsolidacion

	select * from tCsABovRecolecion where fecharec>=@Fecini and fecharec<=@fecha

GO