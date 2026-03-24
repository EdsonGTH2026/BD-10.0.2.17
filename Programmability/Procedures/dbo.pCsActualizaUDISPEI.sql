SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsActualizaUDISPEI]
as
	set nocount on

	declare @udi decimal(10, 8)

	select @udi=udi
	from tcsudis with(nolock)
	where fecha =
		(select max(fecha) from tcsudis with(nolock))


	update [10.0.2.14].finmas.dbo.tAhLimitesBajoRiesgo
	set valorUdi=@udi
GO