SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE Procedure [dbo].[pCsReportD_AlcanceRegion] @fecha smalldatetime    
as    
BEGIN

set nocount on  
--declare @fecha smalldatetime
--set @fecha=(select fechaconsolidacion from vcsfechaconsolidacion)

declare @MeCrecimiento table(codigo varchar(3),metaColocacion money)
insert into @MeCrecimiento
select codigo,monto 
from tcscametas m with(nolock)
where dbo.fdufechaaperiodo(m.fecha)=dbo.fdufechaaperiodo(@fecha) --fecha fin de mes actual
and tipocodigo=1 and meta=2 

declare @Region table(fecha smalldatetime, region varchar(30),nomoficina varchar(30),codoficina varchar(4)
					  ,saldo0a30ini money,saldo31a89ini money,saldo90ini money,saldoCapIni money
					  ,saldo0a30Fin money,saldo31a89fin money,saldo90fin money,saldoCapfinal money
					  ,capitalProgramado money,capitalPagado money
					  ,MontoRenov money,montoLiqui money
					  ,ptmosRenov money,ptmsLiqui money
					  ,ptmosVigIni money,ptmosVigFin money
					  ,porcolocacion money,montoentrega money
					  ,mes0a3 int,mes3a6 int,mes6a9 int
					  ,mes9a12 int,mes12 int,totsucursal int
                      ,TotaPtmos int,nuevosptmos int)
insert into @Region
select
 c.fecha,region,c.nomoficina,codoficina,saldo0a30ini,saldo31a89ini,saldo90ini,saldoCapIni
             ,saldo0a30Fin,saldo31a89fin,saldo90fin,saldoCapfinal
             ,capitalProgramado,capitalPagado,MontoRenov,montoLiqui,ptmosRenov,ptmsLiqui,ptmosVigIni,ptmosVigFin
             ,porcolocacion,montoentrega,mes0a3,mes3a6,mes6a9,mes9a12,mes12,totsucursal
             ,TotaPtmos,nuevosptmos
--select *             
FROM [FNMGConsolidado].[dbo].[tCaReporteKPI] c
--where fecha='20220823'
inner join tcloficinas o on o.nomoficina=c.nomoficina and tipo<>'cerrada'
where c.fecha=@fecha and region<>'pro exito'

select  c.fecha
, region
,sum(saldo0a30ini) carteraVgte_inicial
,case when sum(saldoCapIni)=0 then 0 else (sum(saldo31a89ini)+sum(saldo90ini))/sum(saldoCapIni)end *100 imor31_inicial
,sum(saldo0a30Fin) carteraVgteActual
,case when sum(saldoCapfinal) =0 then 0 else isnull((sum(saldo31a89fin)+sum(saldo90fin))/sum(saldoCapfinal),0)end *100 imor31_Actual
,sum(metaColocacion)MetaCrecimiento -- se cambia por la meta de colocacion
,isnull(sum(saldo0a30Fin),0)-isnull(sum(saldo0a30ini),0)CRECIMIENTO
,case when sum(metaColocacion)=0 then 0 else isnull(sum(montoentrega)/sum(metaColocacion),0)end *100 AlcanceCrecimiento
,case when sum(capitalProgramado)=0 then 0 else ISNULL(sum(capitalPagado)/sum(capitalProgramado),0)end *100 alcanceCobranza_por
,case when sum(montoLiqui)=0 then 0 else ISNULL(sum(MontoRenov)/sum(montoLiqui),0)end *100 permanencia_s
,case when sum(ptmsLiqui)=0 then 0 else ISNULL(sum(ptmosRenov)/cast(sum(ptmsLiqui)as decimal),0)end *100 permanencia_n
,sum(ptmosVigIni)ptmosVigIni,sum(ptmosVigFin)ptmosVigFin
--,sum(case when isnull(PtmosVigIni,0)>=0 and isnull(PtmosVigIni,0)<300 then 20
--	when isnull(PtmosVigIni,0)>=300 and isnull(PtmosVigIni,0)<500 then 15
--	when isnull(PtmosVigIni,0)>=500 and isnull(PtmosVigIni,0)<700 then 10
--	when isnull(PtmosVigIni,0)>=700 and isnull(PtmosVigIni,0)<1000 then 5
--	when isnull(PtmosVigIni,0)>=1000 then 0 end) 
,0 metacliente  -- se quita 
,sum(montoentrega)montocolocado
,sum(mes0a3+mes3a6) mes0a6 
,sum(mes6a9+mes9a12+mes12) mes6m
,sum(totsucursal)totsucursal
,sum(TotaPtmos)ColocadoPtmos
,sum(nuevosptmos) ptmosNuevoColoca
FROM @region c
--left outer join @sucursal o on o.nomoficina=c.nomoficina
left outer join @MeCrecimiento m on m.codigo=c.codoficina
group by c.fecha,region
union select
 c.fecha,'TOTAL' as region
,sum(saldo0a30ini) carteraVgte_inicial
,case when sum(saldoCapIni)=0 then 0 else (sum(saldo31a89ini)+sum(saldo90ini))/sum(saldoCapIni)end *100 imor31_inicial
,sum(saldo0a30Fin) carteraVgteActual
,case when sum(saldoCapfinal) =0 then 0 else isnull((sum(saldo31a89fin)+sum(saldo90fin))/sum(saldoCapfinal),0)end *100 imor31_Actual
,sum(metaColocacion)MetaCrecimiento -- se cambia por la meta de colocacion

,isnull(sum(saldo0a30Fin),0)-isnull(sum(saldo0a30ini),0)CRECIMIENTO
,case when sum(metaColocacion)=0 then 0 else isnull(sum(montoentrega)/sum(metaColocacion),0)end *100 AlcanceCrecimiento
,case when sum(capitalProgramado)=0 then 0 else ISNULL(sum(capitalPagado)/sum(capitalProgramado),0)end *100 alcanceCobranza_por
,case when sum(montoLiqui)=0 then 0 else ISNULL(sum(MontoRenov)/sum(montoLiqui),0)end *100 permanencia_s
,case when sum(ptmsLiqui)=0 then 0 else ISNULL(sum(ptmosRenov)/cast(sum(ptmsLiqui)as decimal),0)end *100 permanencia_n
,sum(ptmosVigIni)ptmosVigIni,sum(ptmosVigFin)ptmosVigFin
--,sum(case when isnull(PtmosVigIni,0)>=0 and isnull(PtmosVigIni,0)<300 then 20
--	when isnull(PtmosVigIni,0)>=300 and isnull(PtmosVigIni,0)<500 then 15
--	when isnull(PtmosVigIni,0)>=500 and isnull(PtmosVigIni,0)<700 then 10
--	when isnull(PtmosVigIni,0)>=700 and isnull(PtmosVigIni,0)<1000 then 5
--	when isnull(PtmosVigIni,0)>=1000 then 0 end)
	,0 metacliente
,sum(montoentrega)montocolocado
,sum(mes0a3+mes3a6) mes0a6 
,sum(mes6a9+mes9a12+mes12)
,sum(totsucursal)totsucursal
,sum(TotaPtmos)ColocadoPtmos
,sum(nuevosptmos) ptmosNuevoColoca
FROM @region c
--left outer join @sucursal o on o.nomoficina=c.nomoficina
left outer join @MeCrecimiento m on m.codigo=c.codoficina
group by c.fecha
END
GO