SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCaIncentivos] @codasesor varchar(15)
as
	declare @fecha smalldatetime
	select @fecha=fechaconsolidacion from vcsfechaconsolidacion

	select Fecha,	codoficina,	codasesor,	coordinador,	saldocapital,	desembolso,	pordeudese,	categoria,	PorBonoInte,	programado_s,	pagado_s
	,	porpagado_s,	nivelCO,	puntosCO,	saldo,	saldovencido,	imor30,	nivelp2,	puntosp2,	puntaje,	nivelBono,	PorBono,	saldoini,	saldofin
	,	crecimiento,	montointecob,	PorcBonoFinal
	,0 as	BonoFinal,	PorCrecimiento,	montointecob_1ra,	PorcBonoFinal_1ra,	BonoFinal_1ra,	ReeBono_1ra
	,	montointecobtotal,	BonoConCrecimiento,	BonoDiferencia,	ReeProgramado_s,	ReePagado_s,	ReePorPagado_s,	ReePorBonoIntCob,	ReeMontoIntCob
	,0 as	PorReeCumpli,	ReeBono
	from tCsACaIncentivos with(nolock)
	where fecha=@fecha--'20201018'--
	and codasesor=@codasesor--'ACA890202FH300'
GO