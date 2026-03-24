SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAAhSaldoIniFinOpera] @fecini smalldatetime,@fecfin smalldatetime
as
--declare @fecini smalldatetime
--declare @fecfin smalldatetime
--set @fecini='20160701'
--set @fecfin='20160731'

create table #tah(
	codoficina varchar(4),
	Fini_NroCtas int,
	Ffin_NroCtas int,
	Fini_saldo money,
	Ffin_saldo money,
	I_nroctas int default(0),
	E_nroctas int default(0),
	I_Monto money default(0),
	E_Monto money default(0),
	Clientes int default(0),
	Nuevos int default(0),
	Renovados int default(0)
)

insert into #tah (codoficina,Fini_NroCtas,Ffin_NroCtas,Fini_saldo,Ffin_saldo)
SELECT CodOficina
,count(case when fecha=@fecini then CodCuenta+FraccionCta+rtrim(ltrim(str(Renovado))) else null end) Fini_NroCtas
,count(case when fecha=@fecfin then CodCuenta+FraccionCta+rtrim(ltrim(str(Renovado))) else null end) Ffin_NroCtas

,sum(case when fecha=@fecini then SaldoCuenta else 0 end) Fini_saldo --+IntAcumulado
,sum(case when fecha=@fecfin then SaldoCuenta else 0 end) Ffin_saldo --+IntAcumulado
FROM tCsAhorros with(nolock)
where substring(codproducto,1,1)='2'
and fecha in (@fecini,@fecfin)
group by CodOficina

--select *
update #tah
set I_nroctas=t.I_nroctas,E_nroctas=t.E_nroctas,I_Monto=t.I_Monto,E_Monto=t.E_Monto
from #tah a
inner join (
	select codoficina
	,count(case when tipotransacnivel1='I' then CodigoCuenta+FraccionCta+rtrim(ltrim(str(Renovado))) else null end) I_nroctas
	,count(case when tipotransacnivel1='E' then CodigoCuenta+FraccionCta+rtrim(ltrim(str(Renovado))) else null end) E_nroctas
	,sum(case when tipotransacnivel1='I' then montototaltran else 0 end) I_Monto
	,sum(case when tipotransacnivel1='E' then montototaltran else 0 end) E_Monto
	from tcstransacciondiaria with(nolock)
	where fecha>=@fecini and fecha<=@fecfin
	and codsistema='AH' and substring(codproducto,1,1)='2'
	group by codoficina
) t on t.codoficina=a.codoficina

update #tah
set clientes=n.nro,nuevos=n.nuevo,renovados=n.renovacion
from #tah a
inner join (
	select pa.codoficina
	,count(distinct ltrim(rtrim(pa.codusuario)))  nro--,rtrim(ltrim(cta.codusuario)) codusuariox
	,sum(case when rtrim(ltrim(cta.codusuario)) is null then 1 else 0 end) nuevo
	,sum(case when rtrim(ltrim(cta.codusuario)) is not null then 1 else 0 end) renovacion
	from tcspadronahorros pa with(nolock)
	left outer join (
		select distinct codusuario
		from tcspadronahorros with(nolock)
		where substring(codproducto,1,1)='2'
		and fecapertura<@fecini
	) cta on cta.codusuario=pa.codusuario
	where substring(pa.codproducto,1,1)='2'
	and pa.fecapertura>=@fecini and pa.fecapertura<=@fecfin
	group by pa.codoficina
) n on n.codoficina=a.codoficina

select a.codoficina Nro,o.nomoficina Sucursal
,Fini_NroCtas,Fini_saldo

,I_nroctas,E_nroctas, I_nroctas-E_nroctas Ctas_Diferencia
,I_Monto,E_Monto, I_Monto-E_Monto		Saldo_Diferencia

,Ffin_NroCtas,Ffin_saldo

,Clientes,Nuevos,Renovados 
from #tah a inner join tcloficinas o with(nolock)
on a.codoficina=o.codoficina

drop table #tah
GO

GRANT EXECUTE ON [dbo].[pCsAAhSaldoIniFinOpera] TO [marista]
GO