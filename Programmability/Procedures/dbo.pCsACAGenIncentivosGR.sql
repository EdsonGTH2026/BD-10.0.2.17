SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACAGenIncentivosGR] @fecha smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20201015'
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

delete from tCsACaIncentivosGR where fecha=@fecha

insert into tCsACaIncentivosGR
select fecha,zona,responsable,programado_s,pagado_s,PorCobranza,Nivel_CO,Puntaje_CO,saldo,saldovencido,PorImor,Nivel_IM,Puntaje_IM,Bono_1ra,Bono_2da,TotalBonos,Puntaje_CO+Puntaje_IM PuntajeTotal
,case	when Puntaje_CO+Puntaje_IM>=10 then 50
		when Puntaje_CO+Puntaje_IM>=8 and Puntaje_CO+Puntaje_IM<10 then 40
		when Puntaje_CO+Puntaje_IM>=6 and Puntaje_CO+Puntaje_IM<8 then 30
		when Puntaje_CO+Puntaje_IM>=4 and Puntaje_CO+Puntaje_IM<6 then 20
		when Puntaje_CO+Puntaje_IM>=2 and Puntaje_CO+Puntaje_IM<4 then 10
		else 0 end PorBono
,(case	when Puntaje_CO+Puntaje_IM>=10 then 50
		when Puntaje_CO+Puntaje_IM>=8 and Puntaje_CO+Puntaje_IM<10 then 40
		when Puntaje_CO+Puntaje_IM>=6 and Puntaje_CO+Puntaje_IM<8 then 30
		when Puntaje_CO+Puntaje_IM>=4 and Puntaje_CO+Puntaje_IM<6 then 20
		when Puntaje_CO+Puntaje_IM>=2 and Puntaje_CO+Puntaje_IM<4 then 10
		else 0 end)*TotalBonos/100 Bono
--into tCsACaIncentivosGR
from (
	select fecha, zona, responsable
	,programado_s,pagado_s,PorCobranza
	,case	when PorCobranza>=96 then 'EXCELENTE'
			when PorCobranza>=94 and PorCobranza<96 then 'BUENO'
			when PorCobranza>=92 and PorCobranza<94 then 'ACEPTABLE'
			when PorCobranza>=90 and PorCobranza<92 then 'INADECUADO'
			when PorCobranza>=85 and PorCobranza<90 then 'MALO'
			else 'PESIMO' end Nivel_CO
	,case	when PorCobranza>=96 then 5
			when PorCobranza>=94 and PorCobranza<96 then 4
			when PorCobranza>=92 and PorCobranza<94 then 3
			when PorCobranza>=90 and PorCobranza<92 then 2
			when PorCobranza>=85 and PorCobranza<90 then 1
			else 0 end Puntaje_CO
	,saldo,saldovencido,PorImor
	,case	when PorImor>=0 and PorImor<=4 then 'EXCELENTE'
			when PorImor>4 and PorImor<=6 then 'BUENO'
			when PorImor>6 and PorImor<=8 then 'ACEPTABLE'
			when PorImor>8 and PorImor<=12 then 'INADECUADO'
			when PorImor>12 and PorImor<=15 then 'MALO'
			else 'PESIMO' end Nivel_IM
	,case	when PorImor>=0 and PorImor<=4 then 5
			when PorImor>4 and PorImor<=6 then 4
			when PorImor>6 and PorImor<=8 then 3
			when PorImor>8 and PorImor<=12 then 2
			when PorImor>12 and PorImor<=15 then 1
			else 0 end Puntaje_IM
	,Bono_1ra,BonoDiferencia Bono_2da, Bono_1ra+BonoDiferencia TotalBonos
	from (
		SELECT a.Fecha,z.zona,z.responsable
		,sum(programado_s) programado_s,sum(pagado_s) pagado_s
		,case when sum(programado_s)=0 then 0 else sum(pagado_s)/sum(programado_s)*100 end PorCobranza
		,sum(saldo) saldo,sum(saldovencido) saldovencido
		,case when sum(saldo)=0 then 0 else sum(saldovencido)/sum(saldo)*100 end PorImor
		,sum(case when day(@fecha)<=15 then BonoFinal else BonoFinal_1ra end) Bono_1ra, sum(BonoDiferencia) BonoDiferencia
		FROM tCsACaIncentivos a with(nolock)
		inner join tcloficinas o with(nolock) on o.codoficina=a.codoficina
		inner join tclzona z with(nolock) on z.zona=o.zona
		where fecha=@fecha
		group by a.Fecha,z.zona,z.responsable
	) a
) b
GO