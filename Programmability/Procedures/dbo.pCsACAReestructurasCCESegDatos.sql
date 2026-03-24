SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsACAReestructurasCCESegDatos '20200501', ''
CREATE procedure [dbo].[pCsACAReestructurasCCESegDatos] @fecha smalldatetime, @codoficina varchar(5)
as
	--declare @fecha smalldatetime
	--select @fecha=fechaconsolidacion from vcsfechaconsolidacion
	
	select c.fecha,r.*,c.nrodiasatraso nrodiasatraso2,d.saldocapital,d.interesvigente,d.interesvencido,d.interesctaorden
	,d.otroscargos,d.cargomora,d.impuestos
	,re.montogarliq,re.SaldoCalificacion,re.ParteCubierta,re.ParteExpuesta,re.PorcParteCubierta,re.PorcParteExpuesta,re.EPRC_ParteCubierta,re.EPRC_ParteExpuesta,re.EPRC_InteresesVencidos,re.EPRC_TOTAL
	from tCsACAReestructurasCCEseg r with(nolock)
	inner join tcscartera c with(nolock) on c.codprestamo=r.codprestamo and c.fecha=@fecha
	inner join tcscarteradet d with(nolock) on d.codprestamo=c.codprestamo and d.fecha=c.fecha
	inner join tcscarterareserva re with(nolock) on re.codprestamo=c.codprestamo and re.fecha=c.fecha


GO