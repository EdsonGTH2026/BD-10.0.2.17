SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--exec pPNCAHuerfanoActivoIni
CREATE procedure [dbo].[pPNCAHuerfanoActivoIni]
as
set nocount on
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

declare @EnHora bit
set @EnHora=0
if((CONVERT(VARCHAR(8),GETDATE(),108)<='23:55:00') or
			(CONVERT(VARCHAR(8),GETDATE(),108)>='05:00:00'))
			begin
				--select 'Aqui'
				set @EnHora=1
			end

declare @fecini smalldatetime
set @fecini= cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1

declare @fecval smalldatetime
select @fecval=fecha from tPNCaGruxTipoPromotor with(nolock) group by fecha

if(@fecval=@fecini)
	begin
		--select '0'
		select * from tPNCaGruxTipoPromotor with(nolock)
		order by promotor
	end
else
	begin
		if(@EnHora=0)
			begin
				--select '1'
				select * from tPNCaGruxTipoPromotor with(nolock)
				order by promotor
			end
		else
			begin
			--select '2'
			truncate table tPNCaGruxTipoPromotor
			
			create table #ptmos (codprestamo varchar(25))
			insert into #ptmos
			select c.codprestamo
			from tcscartera c with(nolock)
			inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
			where c.fecha=@fecini and c.cartera='ACTIVA' and c.codoficina not in('97','230','231','999')
			and c.codprestamo not in (select codprestamo from tCsCarteraAlta with(nolock))
			group by c.fecha,c.codprestamo

			insert into tPNCaGruxTipoPromotor
			select fecha,promotor
			,count(distinct codprestamo) nroptmo
			,sum(saldocapital) saldocapital
			,count(distinct D0a30nroptmo) D0a30nroptmo,sum(D0a30saldo) D0a30saldo, (case when sum(saldocapital)=0 then 0 else sum(D0a30saldo)/sum(saldocapital) end)*100 D0a30Por
			,count(distinct D31mnroptmo) D31mnroptmo,sum(D31msaldo) D31msaldo, (case when sum(saldocapital)=0 then 0 else sum(D31msaldo)/sum(saldocapital) end)*100 D31mPor
			--into tPNCaGruxTipoPromotor
			from (
				SELECT --cl.nombrecompleto promotor
				case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else 'ACTIVA' end promotor
				,c.Fecha,cd.codusuario,c.CodPrestamo
				,cd.saldocapital
				,case when c.Estado<>'VENCIDO' then
				case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.codprestamo else null end
				 else null end D0a30nroptmo
				,case when c.Estado<>'VENCIDO' then
					case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=30 then cd.saldocapital else 0 end
				 else 0 end D0a30saldo
				,case when c.NroDiasAtraso>=31 then cd.codprestamo else null end D31mnroptmo
				,case when c.NroDiasAtraso>=31 then cd.saldocapital else 0 end D31msaldo
				FROM tCsCartera c with(nolock)
				inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
				--inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
				inner join tcspadronclientes cl with(nolock) on cl.codusuario=c.codasesor
				left outer join tcsempleadosfecha e with(nolock) on e.codusuario=c.codasesor and e.fecha=@fecha-->huerfano
				where c.fecha=@fecini and c.cartera='ACTIVA'
				and c.codprestamo in(select codprestamo from #ptmos)
				and c.codoficina<>'98'
			) a
			group by fecha,promotor

			drop table #ptmos

			select * from tPNCaGruxTipoPromotor with(nolock)
			order by promotor
			end
	end
GO