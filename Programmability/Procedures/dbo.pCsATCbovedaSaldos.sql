SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsATCbovedaSaldos] @fecha smalldatetime, @codoficina varchar(4)
as
		set nocount on

	declare @fecini smalldatetime
	set @fecini=dateadd(day,-30,@fecha)

	select  fecha,codoficina,saldoinisis,saldofinsis,saldofinus
	from tcsbovedasaldos with (nolock)
	where fecha>=@fecini and fecha<=@fecha
GO