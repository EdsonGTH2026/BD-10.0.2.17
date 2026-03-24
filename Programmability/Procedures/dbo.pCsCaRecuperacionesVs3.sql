SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCaRecuperacionesVs3
CREATE procedure [dbo].[pCsCaRecuperacionesVs3] @fecha SmalldateTime
as
--declare @fecha SmalldateTime
--set @fecha='20140620'

CREATE TABLE #tmp(
	Fecha       smalldatetime,
	CodOficina	varchar (4),
	DescOficina	varchar (40),
	OMontoPagado	money,
	Capital			money,
	Interes			money,
	Moratorio		money,
	CargoxMora	money,
	IVAInteres	money,
	IVAMoratorio money,
	IVACargoxMora money,
	ONroOper			int,
	OMontoPagadoN money,
	OMontoPagadoR money,
) ON [PRIMARY]

Insert Into #tmp Exec [BD-FINAMIGO-DC].finmas.dbo.pCsCaRecuperacionesVs3 @Fecha

declare @periodo varchar(6)
set @periodo=dbo.fduFechaAPeriodo(@fecha)

select a.codoficina,dbo.fdurellena('0',z.Orden,2,'D')+ o.Zona As Zona, ISNULL(z.Nombre, 'Zona No Especificada') NomZona
,dbo.fduRellena('0',a.Codoficina,2,'D') + ' ' + o.NomOficina  AS NomOficina
,case when o.Tipo='Cerrada' then o.Tipo else 'Activa' end Tipo
,a.Anroop,a.AnroopN,a.AnroopR,a.AMontoPagado,a.AMontoPagadoN,a.AMontoPagadoR
,isnull(p.Pnroop,0) Pnroop,isnull(p.PnroopN,0) PnroopN,isnull(p.PnroopR,0) PnroopR,isnull(p.PMontoPagado,0) PMontoPagado,isnull(p.PMontoPagadoN,0) PMontoPagadoN,isnull(p.PMontoPagadoR,0) PMontoPagadoR
,isnull(s.snroop,0) snroop,isnull(s.snroopN,0) snroopN,isnull(s.snroopR,0) snroopR,isnull(s.sMontoPagado,0) sMontoPagado,isnull(s.sMontoPagadoN,0) sMontoPagadoN,isnull(s.sMontoPagadoR,0) sMontoPagadoR
,s.nrosemana,isnull(op.OMontoPagado,0) OMontoPagado,isnull(op.ONroOper,0) ONroOper,isnull(op.OMontoPagadoN,0) OMontoPagadoN,isnull(op.OMontoPagadoR,0) OMontoPagadoR
from (
  SELECT t.codoficinacuenta codoficina
  ,count(distinct t.codigocuenta) Anroop
  ,count(distinct(case when fc.ciclo=1 then t.codigocuenta else null end)) AnroopN
  ,count(distinct(case when fc.ciclo<>1 then t.codigocuenta else null end)) AnroopR
  ,sum(t.montototaltran) AMontoPagado
  ,sum(case when fc.ciclo=1 then t.montototaltran else 0 end) AMontoPagadoN
  ,sum(case when fc.ciclo<>1 then t.montototaltran else 0 end) AMontoPagadoR
  FROM tCsTransaccionDiaria t with(nolock)
  -->aqui
  left outer join (
    SELECT cl.codusuario, max(p.secuenciacliente) ciclo
    FROM tCspadronCarteradet p with(nolock)
    inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
    group by cl.codusuario
  ) fc on fc.codusuario=t.codusuario
  -->aqui
  where t.codsistema='CA' and t.extornado=0
  and t.fecha>=substring(@periodo,1,4)+'0101' and t.fecha<=@fecha
  and t.TipoTransacNivel1<>'E'
  and t.tipotransacnivel3 not in (2,101)
  group by t.codoficinacuenta
) a
inner join tcloficinas o with(nolock) on o.codoficina=a.codoficina
left outer join tClZona z with(nolock) on o.Zona = z.Zona
left outer join (
  SELECT t.codoficinacuenta codoficina
  ,count(distinct t.codigocuenta) Pnroop
  ,count(distinct(case when fc.ciclo=1 then t.codigocuenta else null end)) PnroopN
  ,count(distinct(case when fc.ciclo<>1 then t.codigocuenta else null end)) PnroopR
  ,sum(t.montototaltran) PMontoPagado
  ,SUM(case when fc.ciclo=1 then t.montototaltran else 0 end) PMontoPagadoN
  ,SUM(case when fc.ciclo<>1 then t.montototaltran else 0 end) PMontoPagadoR
  FROM tCsTransaccionDiaria t with(nolock)
  -->aqui
  left outer join (
    SELECT cl.codusuario, max(p.secuenciacliente) ciclo
    FROM tCspadronCarteradet p with(nolock)
    inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
    group by cl.codusuario
  ) fc on fc.codusuario=t.codusuario
  -->aqui
  where t.codsistema='CA' and t.extornado=0
  and dbo.fduFechaAPeriodo(t.fecha)=@periodo
  and t.TipoTransacNivel1<>'E'
  and t.tipotransacnivel3 not in (2,101)
  group by t.codoficinacuenta
) p on p.codoficina=a.codoficina
left outer join (
  SELECT t.codoficinacuenta codoficina
  ,count(distinct t.codigocuenta) Snroop
  ,count(distinct(case when fc.ciclo=1 then t.codigocuenta else null end)) SnroopN
  ,count(distinct(case when fc.ciclo<>1 then t.codigocuenta else null end)) SnroopR
  ,sum(t.montototaltran) SMontoPagado
  ,SUM(case when fc.ciclo=1 then t.montototaltran else 0 end) SMontoPagadoN
  ,SUM(case when fc.ciclo<>1 then t.montototaltran else 0 end) SMontoPagadoR
  ,p.nrosemana
  FROM tCsTransaccionDiaria t with(nolock)
  -->aqui
    inner join (
  --    select fechaini,fechafin,nrosemana from dbo.fduTablaSemanaPeriodos('201404') where fechaini<='20140423' and fechafin>='20140423'
        select fechaini,fechafin,nrosemana from dbo.fduTablaSemanaPeriodos(@periodo) where fechaini<=@fecha and fechafin>=@fecha
    ) p on t.fecha>=p.fechaini and t.fecha<=p.fechafin
  -->aqui
  left outer join (
    SELECT cl.codusuario, max(p.secuenciacliente) ciclo
    FROM tCspadronCarteradet p with(nolock)
    inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
    group by cl.codusuario
  ) fc on fc.codusuario=t.codusuario
  -->aqui
  where t.codsistema='CA' and t.extornado=0
  and t.TipoTransacNivel1<>'E'
  and t.tipotransacnivel3 not in (2,101,3)
  group by t.codoficinacuenta,p.nrosemana
) s on s.codoficina=a.codoficina
left outer join #tmp op on op.codoficina=a.codoficina

drop table #tmp
GO