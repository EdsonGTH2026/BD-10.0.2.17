SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACAReestructurasCCESegVs2Datos] @fecha smalldatetime, @codoficina varchar(2000)
as
	--declare @fecha smalldatetime
	--select @fecha=fechaconsolidacion from vcsfechaconsolidacion
	
	select *
	from tCsACAReestructurasCCESegVs2 with(nolock)
	where (@codoficina<>'%' and codoficina in(
		select codigo from dbo.fduTablaValores(@codoficina)
	)) or (@codoficina='%')
GO