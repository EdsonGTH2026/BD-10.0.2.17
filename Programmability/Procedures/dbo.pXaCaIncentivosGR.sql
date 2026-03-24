SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCaIncentivosGR] @codoficina varchar(3)
as
	declare @fecha smalldatetime
	select @fecha=fechaconsolidacion from vcsfechaconsolidacion

	select a.fecha,a.codoficina,o.nomoficina sucursal,a.saldoini,a.programado_s,a.pagado_s,a.PorCobranza,a.Nivel_CO,a.Puntaje_CO,a.saldo,a.saldovencido,a.PorImor,a.Nivel_IM,a.Puntaje_IM,a.Bono_1ra,a.Bono_2da,a.TotalBonos,a.PuntajeTotal,a.PorBono,a.Bono
	from tCsACaIncentivosGS a with(nolock)
	inner join tcloficinas o with(nolock) on o.codoficina=a.codoficina
	where a.fecha=@fecha--'20201018'--
	and a.codoficina=@codoficina--'ACA890202FH300'
GO