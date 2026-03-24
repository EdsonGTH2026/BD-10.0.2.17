SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAhRptSaldosTasasSemana] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20200818'

set nocount on
set ansi_warnings off

declare @VariosPeriodos varchar(200)
select @VariosPeriodos=COALESCE(@VariosPeriodos+ ',', '') + periodo
from tclperiodo with(nolock) where periodo>=cast(year(@fecha) as varchar(4))+'01' and periodo<=dbo.fdufechaaperiodo(@fecha)

declare @tp table (i int identity, nrosemana int,fechafin smalldatetime,fechaini smalldatetime)
insert into @tp (nrosemana,fechafin,fechaini)
select nrosemana,fechafin,fechaini from fduTablaSemanaPeriodosFC(@VariosPeriodos)--('201501,201502,201503')

create table #tb(fecha smalldatetime, codcuenta varchar(25), saldocuenta money, codoficina varchar(4),fechavencimiento smalldatetime,intacumulado money)

Declare @fec smalldatetime
declare @n int
declare @ntmp int
select @n=count(*) from @tp
set @ntmp=0

while(@ntmp<>@n)
begin
	set @ntmp=@ntmp+1
	select @fec=fechafin from @tp where i=@ntmp

	insert into #tb
	select a.fecha, a.codcuenta,a.saldocuenta,a.codoficina,a.fechavencimiento,a.intacumulado
	from tcsahorros a with(nolock)
	where fecha=@fec
end
--select * from #tb

create table #p(
	nrosemana int,
	fechaini smalldatetime,
	fechafin smalldatetime,
	nrovista int,
	nrodpf int,
	saldovista money,
	saldodpf money,
	saldocorpo money,
	saldosucur money,
	ctascorpo money,
	ctassucur money,
	nro int,
	saldo money,
	ctavencimiento int,
	monvencimiento money,
	ctanuevas int,
	monnuevas money,
	ctarenovado int,
	monrenovado money,
	TasaPonDPF money,
	TasaPonDPFOfCen money,
	TasaPonDPFSinOfCen money,
	saldocorpoDPF money,
	ctascorpoDPF int,
	saldocorpoVista money,
	ctascorpoVista int,
	saldoSucurDPF money,
	ctasSucurDPF int,
	saldoSucurVista money,
	ctasSucurVista int,
	
	cap_total_nro int,
	cap_total_sal money,
	cap_dpf_nro int,
	cap_dpf_sal money,
	cap_vis_nro int,
	cap_vis_sal money,
	cap_gar_nro int,
	cap_gar_sal money
)

insert into #p (nrosemana,fechaini,fechafin
,nrovista,nrodpf,saldovista,saldodpf,nro,saldo,saldocorpo,saldosucur,ctascorpo,ctassucur
,saldocorpoDPF,ctascorpoDPF,saldocorpoVista,ctascorpoVista,saldoSucurDPF,ctasSucurDPF,saldoSucurVista,ctasSucurVista
)--,ctavencimiento,monvencimiento
select ps.nrosemana,ps.fechaini,ps.fechafin
,count(case when substring(a.codcuenta,5,1)='1' then a.codcuenta else null end) nrovista
,count(case when substring(a.codcuenta,5,1)='2' then a.codcuenta else null end) nrodpf
,sum(case when substring(a.codcuenta,5,1)='1' then a.saldocuenta + a.intacumulado else 0 end) saldovista
,sum(case when substring(a.codcuenta,5,1)='2' then a.saldocuenta + a.intacumulado else 0 end) saldodpf
,count(a.codcuenta) nro
,sum(a.saldocuenta+ a.intacumulado) saldo
,sum(case when a.codoficina='98' then a.saldocuenta + a.intacumulado else 0 end) saldocorpo
,sum(case when a.codoficina<>'98' then a.saldocuenta + a.intacumulado else 0 end) saldosucur
,count(case when a.codoficina='98' then a.codcuenta else null end) ctascorpo
,count(case when a.codoficina<>'98' then a.codcuenta else null end) ctassucur
--,count(case when a.fechavencimiento>=ps.fechaini and a.fechavencimiento<=ps.fechafin then a.codcuenta else null end) ctavencimiento
--,sum(case when a.fechavencimiento>=ps.fechaini and a.fechavencimiento<=ps.fechafin then a.saldocuenta else 0 end) monvencimiento
,sum(case when a.codoficina='98' then (case when substring(a.codcuenta,5,1)='2' then a.saldocuenta + a.intacumulado else 0 end) else 0 end) saldocorpoDPF
,count(case when a.codoficina='98' then (case when substring(a.codcuenta,5,1)='2' then a.codcuenta else null end) else null end) ctascorpoDPF
,sum(case when a.codoficina='98' then (case when substring(a.codcuenta,5,1)='1' then a.saldocuenta + a.intacumulado else 0 end) else 0 end) saldocorpoVista
,count(case when a.codoficina='98' then (case when substring(a.codcuenta,5,1)='1' then a.codcuenta else null end) else null end) ctascorpoVista

,sum(case when a.codoficina<>'98' then (case when substring(a.codcuenta,5,1)='2' then a.saldocuenta + a.intacumulado else 0 end) else 0 end) saldoSucurDPF
,count(case when a.codoficina<>'98' then (case when substring(a.codcuenta,5,1)='2' then a.codcuenta else null end) else null end) ctasSucurDPF
,sum(case when a.codoficina<>'98' then (case when substring(a.codcuenta,5,1)='1' then a.saldocuenta + a.intacumulado else 0 end) else 0 end) saldoSucurVista
,count(case when a.codoficina<>'98' then (case when substring(a.codcuenta,5,1)='1' then a.codcuenta else null end) else null end) ctasSucurVista
from #tb a with(nolock)
inner join @tp ps on ps.fechafin=a.fecha
group by ps.nrosemana,ps.fechaini,ps.fechafin

drop table #tb

declare @tasapon table (
	fechafin smalldatetime,
	tasa varchar(200),
	TasaPonDPF as cast(substring(tasa,1,charindex('|',tasa)-1) as money),
	TasaPonDPFOfCen as cast(substring(tasa,charindex('|',tasa)+1,charindex('|',tasa)-1) as money),
	TasaPonDPFSinOfCen as cast(substring(tasa,charindex('|',tasa)+charindex('|',tasa)+1,charindex('|',tasa)-1) as money)
)

insert into @tasapon
select fechafin, dbo.fduAhTasaPonderada(fechafin) tasa
from fduTablaSemanaPeriodosFC(@VariosPeriodos)--('201501,201502,201503')

update #p
set TasaPonDPF=t.TasaPonDPF,TasaPonDPFOfCen=t.TasaPonDPFOfCen, TasaPonDPFSinOfCen=t.TasaPonDPFSinOfCen
from #p p inner join @tasapon t on t.fechafin=p.fechafin

declare @fec0 smalldatetime
--select @n=max(nrosemana) from #p
--select @ntmp=min(nrosemana)-1 from #p
select @n=max(i) from @tp
select @ntmp=min(i)-1 from @tp
--print '@n: ' + str(@n)
--select * from @tp
while(@ntmp<>@n)
begin
	set @ntmp=@ntmp+1
	select @fec0=fechaini,@fec=fechafin from @tp where i=@ntmp
	--print '@ntmp: ' + str(@ntmp)
	--print '@fec0: ' + cast(@fec0 as varchar(20))
	--print '@fec: ' + cast(@fec as varchar(20))
	--select *
	update #p
	set ctavencimiento=a.nro,monvencimiento=isnull(a.saldocuenta,0)
	from (
		SELECT @fec fecha,count(codcuenta) nro, sum(saldocuenta+intacumulado) saldocuenta
		FROM tCsAhorros with(nolock)
		where fecha=@fec0 and fechavencimiento>=@fec0 and fechavencimiento<=@fec
		and substring(codcuenta,5,1)='2'
		--group by fecha
	) a inner join #p p on p.fechafin=a.fecha

	create table #re(codusuario varchar(25))
	insert into #re
	--select distinct codusuario 
	--from tCsAhorros with(nolock)
	--where fecha=@fec0 and fechaapertura<@fec0
	--and substring(codproducto,1,1)='2'
	select distinct codusuario 
	from tCspadronAhorros with(nolock)
	where fecapertura<@fec0
	and substring(codproducto,1,1)='2'

	--select *
	update #p
	set ctanuevas=isnull(a.nuevo,0),monnuevas=isnull(a.salnuevo,0),ctarenovado=isnull(a.renovado,0),monrenovado=isnull(a.salrenovado,0)
	from (
		SELECT @fec fecha,count(codcuenta) nrocuenta,sum(saldocuenta) saldocuenta
		,count(nuevo) nuevo, sum(salnuevo) salnuevo
		,count(renovado) renovado,sum(salrenovado) salrenovado
		from (
			--select codcuenta, saldocuenta
			--,case when codusuario not in (select distinct codusuario from #re with(nolock)) 
			--			then codusuario else null end nuevo
			--,case when codusuario not in (select distinct codusuario from #re with(nolock)) 
			--			then saldocuenta else 0 end salnuevo
			--,case when codusuario in (select distinct codusuario from #re with(nolock)) 
			--			then codusuario else null end renovado
			--,case when codusuario in (select distinct codusuario from #re with(nolock)) 
			--			then saldocuenta else 0 end salrenovado
			----,case when codusuario not in (
			----			select distinct codusuario from tCsAhorros with(nolock) 
			----			where fecha=@fec0 and fechaapertura<@fec0
			----			) 
			----then codusuario else null end nuevo
			----,case when codusuario not in (
			----			select distinct codusuario from tCsAhorros with(nolock) 
			----			where fecha=@fec0 and fechaapertura<@fec0
			----			) 
			----then saldocuenta else 0 end salnuevo
			----,case when codusuario in (select distinct codusuario from tCsAhorros with(nolock) 
			----													where fecha=@fec0 and fechaapertura<@fec0--fechaapertura>=@fec0 and fechaapertura<=@fec
			----													) 
			----			then codusuario else null end renovado
			----,case when codusuario in (select distinct codusuario from tCsAhorros with(nolock) 
			----													where fecha=@fec0 and fechaapertura<@fec0--fechaapertura>=@fec0 and fechaapertura<=@fec
			----													) 
			----			then saldocuenta else 0 end salrenovado
			--FROM tCsAhorros with(nolock)
			--where fecha=@fec and fechaapertura>=@fec0 and fechaapertura<=@fec
			--and substring(codcuenta,5,1)='2'
			
			select a.codcuenta, a.saldocuenta--, a.codusuario
			,case when r.codusuario is null then a.codusuario else null end nuevo
			,case when r.codusuario is null then a.saldocuenta else 0 end salnuevo
			,case when r.codusuario is not null then a.codusuario else null end renovado
			,case when r.codusuario is not null then a.saldocuenta else 0 end salrenovado
			FROM tCsAhorros a with(nolock)
			left outer join #re r with(nolock) on r.codusuario=a.codusuario
			--where a.fecha='20200816' and a.fechaapertura>='20200810' and a.fechaapertura<='20200816'
			where a.fecha=@fec and a.fechaapertura>=@fec0 and a.fechaapertura<=@fec
			and substring(a.codcuenta,5,1)='2'

		) ax
	) a inner join #p p on p.fechafin=a.fecha

	--if(@fec0='20200810')
	--begin
	--	select codcuenta, saldocuenta,codusuario
	--	,case when codusuario not in (select distinct codusuario from #re with(nolock)) 
	--				then codusuario else null end nuevo
	--	,case when codusuario not in (select distinct codusuario from #re with(nolock)) 
	--				then saldocuenta else 0 end salnuevo
	--	,case when codusuario in (select distinct codusuario from #re with(nolock)) 
	--				then codusuario else null end renovado
	--	,case when codusuario in (select distinct codusuario from #re with(nolock)) 
	--				then saldocuenta else 0 end salrenovado
	--	FROM tCsAhorros with(nolock)
	--	where fecha=@fec and fechaapertura>=@fec0 and fechaapertura<=@fec
	--	and substring(codcuenta,5,1)='2'
	--end

	drop table #re
	
	--select *
	update #p	
	set --cap_total_nro=isnull(a.nrocuenta,0),cap_total_sal=isnull(a.saldocuenta,0),
	 cap_dpf_nro=isnull(a.DPF_Nro,0),cap_dpf_sal=isnull(a.DPF_Sal,0),cap_vis_nro=isnull(a.Vis_Nro,0)
	,cap_vis_sal=isnull(a.Vis_Sal,0)
	--,cap_gar_nro=isnull(a.Gar_Nro,0),cap_gar_sal=isnull(a.Gar_Sal,0)
	from (
		SELECT @fec fecha,count(codcuenta) nrocuenta,sum(saldocuenta) saldocuenta,count(DPF_Nro) DPF_Nro,sum(DPF_Sal) DPF_Sal,count(Gar_Nro) Gar_Nro,sum(Gar_Sal) Gar_Sal,count(Vis_Nro) Vis_Nro,sum(Vis_Sal) Vis_Sal
		from (
			select codcuenta,saldocuenta,case when substring(codcuenta,5,1)='2' then codcuenta else null end DPF_Nro
			,case when substring(codcuenta,5,1)='2' then saldocuenta else 0 end DPF_Sal
			,case when substring(codcuenta,5,1)='1' and codproducto='111' then codcuenta else null end Gar_Nro
			,case when substring(codcuenta,5,1)='1' and codproducto='111' then saldocuenta else 0 end Gar_Sal
			,case when substring(codcuenta,5,1)='1' and codproducto<>'111' then codcuenta else null end Vis_Nro
			,case when substring(codcuenta,5,1)='1' and codproducto<>'111' then saldocuenta else 0 end Vis_Sal			
			FROM tCsAhorros with(nolock)
			where fecha=@fec and fechaapertura>=@fec0 and fechaapertura<=@fec
		) ax
	) a inner join #p p on p.fechafin=a.fecha

	update #p	
	set cap_gar_nro=isnull(a.nrocuentas,0),cap_gar_sal=isnull(a.montototaltran,0)
	from (
		select @fec fecha, count(codigocuenta) nrocuentas,sum(montototaltran) montototaltran
		from(
			select fecha,codigocuenta,tipotransacnivel1,tipotransacnivel2,tipotransacnivel3,nombrecliente,descripciontran,montototaltran
			from tcstransacciondiaria with(nolock)
			where codsistema='AH' and fecha>=@fec0 and fecha<=@fec
			and substring(codigocuenta,5,3)='111'
			and tipotransacnivel1='I'
			and extornado=0
		) ax
	) a inner join #p p on p.fechafin=a.fecha

end

update #p
set cap_total_nro=cap_dpf_nro+cap_vis_nro+cap_gar_nro,cap_total_sal=cap_dpf_sal+cap_vis_sal+cap_gar_sal

select *
from #p
order by nrosemana

drop table #p
GO