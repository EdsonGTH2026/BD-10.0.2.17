SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--pCsACAGenIncentivosGS '20201215'
CREATE procedure [dbo].[pCsACAGenIncentivosGS] @fecha smalldatetime
as
set nocount on
--declare @fecha smalldatetime
--set @fecha='20201215'
----select @fecha=fechaconsolidacion from vcsfechaconsolidacion
----select * from tCsACaIncentivosGS where fecha='20201214'

declare @fecant smalldatetime
set @fecant=dateadd(day,-1,dbo.fdufechaaperiodo(@fecha)+'01')

delete from tCsACaIncentivosGS where fecha=@fecha

create table #salini(
	codoficina varchar(3),
	saldoKini money
)

insert into #salini
select c.codoficina,sum(c.saldocapital) saldocapital
from tcscartera c with(nolock)
where c.fecha=@fecant--'20201007'
and c.cartera='ACTIVA'
and c.nrodiasatraso<=30
and c.tiporeprog<>'REEST'
and c.codoficina not in('230','231')
group by c.codoficina

create table #Sal(
	codoficina varchar(3),
	programado_s money,
	pagado_s money,
	porpagado_s money,
	saldo money,
	saldo30 money,
	imor30 money
)
insert into #Sal
exec pCsCaIncOrgSucursal @fecha--'20201130'--

insert into tCsACaIncentivosGS
select fecha,b.codoficina,si.saldoKini,programado_s,pagado_s,PorCobranza,Nivel_CO,Puntaje_CO,saldo,saldovencido,PorImor,Nivel_IM,Puntaje_IM,Bono_1ra,Bono_2da,TotalBonos,Puntaje_CO+Puntaje_IM PuntajeTotal
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
--into tCsACaIncentivosGS
from (
	select fecha, codoficina
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
	from(
		select a.fecha,a.codoficina,s.programado_s,s.pagado_s
		,case when s.programado_s=0 then 0 else (s.pagado_s/s.programado_s)*100 end PorCobranza
		,s.saldo saldo,s.saldo30 saldovencido,s.imor30 PorImor
		,a.Bono_1ra
		,a.BonoDiferencia
		from (
			SELECT Fecha,codoficina
			,sum(programado_s) programado_s,sum(pagado_s) pagado_s
			,case when sum(programado_s)=0 then 0 else sum(pagado_s)/sum(programado_s)*100 end PorCobranza
			,sum(saldo) saldo,sum(saldovencido) saldovencido
			,case when sum(saldo)=0 then 0 else sum(saldovencido)/sum(saldo)*100 end PorImor
			,sum(case when day(@fecha)<=15 then BonoFinal else BonoFinal_1ra end) Bono_1ra
			,sum(BonoDiferencia) BonoDiferencia
			FROM tCsACaIncentivos with(nolock)		
			where fecha=@fecha
			group by Fecha,codoficina
		) a
		inner join #sal s with(nolock) on s.codoficina=a.codoficina		
	) ax
) b
left outer join #salini si with(nolock) on b.codoficina=si.codoficina

drop table #sal
drop table #salini
GO