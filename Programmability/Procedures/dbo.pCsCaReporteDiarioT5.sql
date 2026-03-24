SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* TABLA5. REGIONES ALCANCE */

Create Procedure [dbo].[pCsCaReporteDiarioT5]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

declare @sucursal table(zona varchar(5),codoficina varchar(4),nomoficina varchar(30))
insert into @sucursal values ('Z16',310,'VALLE DE SANTIAGO')
insert into @sucursal values ('Z16',311,'SAN FRANCISCO DEL RINCON')
insert into @sucursal values ('Z16',37,'SAN LUIS DE LA PAZ')
insert into @sucursal values ('Z16',335,'SAN JOSE ITURBIDE')
insert into @sucursal values ('Z16',309,'PENJAMO')
insert into @sucursal values ('Z16',333,'CORTAZAR')
insert into @sucursal values ('Z16',431,'Yuriria')
insert into @sucursal values ('Z16',438,'PIEDAD')
insert into @sucursal values ('Z16',439,'DOLORES HIDALGO')
insert into @sucursal values ('Z15',456,'LERMA')
insert into @sucursal values ('Z15',5,'TEMOAYA')
insert into @sucursal values ('Z15',6,'TENANCINGO')
insert into @sucursal values ('Z15',4,'ATLACOMULCO')
insert into @sucursal values ('Z15',3,'IXTLAHUACA')
insert into @sucursal values ('Z15',8,'PIRAMIDES')
insert into @sucursal values ('Z14',339,'ZIHUATANEJO')
insert into @sucursal values ('Z14',320,'SAN MARCOS')
insert into @sucursal values ('Z14',307,'TLAPA DE COMONFORT')
insert into @sucursal values ('Z14',308,'OMETEPEC')
insert into @sucursal values ('Z14',432,'Atoyac')
insert into @sucursal values ('Z14',301,'IGUALA')
insert into @sucursal values ('Z14',446,'PETATLAN')
insert into @sucursal values ('Z14',463,'HUITZUCO')
insert into @sucursal values ('Z14',434,'Chilapa')
insert into @sucursal values ('Z14',435,'TECPAN')
insert into @sucursal values ('Z13',442,'OXCUTZCAB')
insert into @sucursal values ('Z13',452,'UMAN')
insert into @sucursal values ('Z13',453,'MOTUL')
insert into @sucursal values ('Z18',447,'PANABÁ')
insert into @sucursal values ('Z13',332,'TEKAX')
insert into @sucursal values ('Z18',302,'TIZIMIN')
insert into @sucursal values ('Z18',303,'VALLADOLID')
insert into @sucursal values ('Z13',304,'PROGRESO')
insert into @sucursal values ('Z18',315,'XPUJIL')
insert into @sucursal values ('Z13',321,'TICUL')
insert into @sucursal values ('Z13',41,'CALKINI')
insert into @sucursal values ('Z18',341,'JOSE MA MORELOS')
insert into @sucursal values ('Z18',342,'Kantunilkin')
insert into @sucursal values ('Z13',327,'IZAMAL')
insert into @sucursal values ('Z13',324,'HUNUCMA')
insert into @sucursal values ('Z12',325,'TEPATITLAN')
insert into @sucursal values ('Z12',334,'AYOTLAN')
insert into @sucursal values ('Z12',336,'SAN JUAN DE LOS LAGOS')
insert into @sucursal values ('Z12',337,'SAYULA')
insert into @sucursal values ('Z12',318,'ZAPOTLANEJO')
insert into @sucursal values ('Z12',330,'AUTLAN')
insert into @sucursal values ('Z12',448,'LA BARCA')
insert into @sucursal values ('Z12',460,'OCOTLAN')
insert into @sucursal values ('Z12',436,'JALOSTOTITLAN')
insert into @sucursal values ('Z12',441,'TOTOTLAN')
insert into @sucursal values ('Z11',344,'Frontera')
insert into @sucursal values ('Z17',454,'ORIZABA')
insert into @sucursal values ('Z17',455,'HUEJUTLA')
insert into @sucursal values ('Z17',433,'Perote')
insert into @sucursal values ('Z17',15,'HUATUSCO')
insert into @sucursal values ('Z17',21,'MISANTLA')
insert into @sucursal values ('Z11',25,'SAN ANDRES TUXTLA')
insert into @sucursal values ('Z17',28,'PAPANTLA')
insert into @sucursal values ('Z17',33,'TANTOYUCA')
insert into @sucursal values ('Z11',326,'TEAPA')
insert into @sucursal values ('Z11',322,'COSAMALOAPAN')
insert into @sucursal values ('Z17',323,'FORTIN')



declare @Region table(fecha smalldatetime, region varchar(30),nomoficina varchar(30),codoficina varchar(4)
					  ,saldo0a30ini money,saldo31a89ini money,saldo90ini money,saldoCapIni money
					  ,saldo0a30Fin money,saldo31a89fin money,saldo90fin money,saldoCapfinal money
					  ,capitalProgramado money,capitalPagado money
					  ,MontoRenov money,montoLiqui money
					  ,ptmosRenov money,ptmsLiqui money
					  ,ptmosVigIni money,ptmosVigFin money)
insert into @Region
select
 c.fecha,region,c.nomoficina,codoficina,saldo0a30ini,saldo31a89ini,saldo90ini,saldoCapIni
             ,saldo0a30Fin,saldo31a89fin,saldo90fin,saldoCapfinal
             ,capitalProgramado,capitalPagado,MontoRenov,montoLiqui,ptmosRenov,ptmsLiqui,ptmosVigIni,ptmosVigFin          
FROM [FNMGConsolidado].[dbo].[tCaReporteKPI] c WITH(NOLOCK)
inner join @sucursal o on o.nomoficina=c.nomoficina
where c.fecha=@fecha and region<>'pro exito'


select  c.fecha
, region
,sum(saldo0a30ini) carteraVgte_inicial
,case when sum(saldoCapIni)=0 then 0 else (sum(saldo31a89ini)+sum(saldo90ini))/sum(saldoCapIni)end *100 imor31_inicial
,sum(saldo0a30Fin) carteraVgteActual
,case when sum(saldoCapfinal) =0 then 0 else isnull((sum(saldo31a89fin)+sum(saldo90fin))/sum(saldoCapfinal),0)end *100 imor31_Actual
,isnull(sum(saldo0a30Fin),0)-isnull(sum(saldo0a30ini),0)CRECIMIENTO
,case when sum(capitalProgramado)=0 then 0 else ISNULL(sum(capitalPagado)/sum(capitalProgramado),0)end *100 alcanceCobranza_por
,case when sum(montoLiqui)=0 then 0 else ISNULL(sum(MontoRenov)/sum(montoLiqui),0)end *100 permanencia_s
,case when sum(ptmsLiqui)=0 then 0 else ISNULL(sum(ptmosRenov)/cast(sum(ptmsLiqui)as decimal),0)end *100 permanencia_n
,sum(ptmosVigIni)ptmosVigIni,sum(ptmosVigFin)ptmosVigFin
,sum(case when isnull(PtmosVigIni,0)>=0 and isnull(PtmosVigIni,0)<300 then 20
	when isnull(PtmosVigIni,0)>=300 and isnull(PtmosVigIni,0)<500 then 15
	when isnull(PtmosVigIni,0)>=500 and isnull(PtmosVigIni,0)<700 then 10
	when isnull(PtmosVigIni,0)>=700 and isnull(PtmosVigIni,0)<1000 then 5
	when isnull(PtmosVigIni,0)>=1000 then 0 end) metacliente
FROM @region c
left outer join @sucursal o on o.nomoficina=c.nomoficina
group by c.fecha,region
union select
 c.fecha,'TOTAL' as region
,sum(saldo0a30ini) carteraVgte_inicial
,case when sum(saldoCapIni)=0 then 0 else (sum(saldo31a89ini)+sum(saldo90ini))/sum(saldoCapIni)end *100 imor31_inicial
,sum(saldo0a30Fin) carteraVgteActual
,case when sum(saldoCapfinal) =0 then 0 else isnull((sum(saldo31a89fin)+sum(saldo90fin))/sum(saldoCapfinal),0)end *100 imor31_Actual
,isnull(sum(saldo0a30Fin),0)-isnull(sum(saldo0a30ini),0)CRECIMIENTO
,case when sum(capitalProgramado)=0 then 0 else ISNULL(sum(capitalPagado)/sum(capitalProgramado),0)end *100 alcanceCobranza_por
,case when sum(montoLiqui)=0 then 0 else ISNULL(sum(MontoRenov)/sum(montoLiqui),0)end *100 permanencia_s
,case when sum(ptmsLiqui)=0 then 0 else ISNULL(sum(ptmosRenov)/cast(sum(ptmsLiqui)as decimal),0)end *100 permanencia_n
,sum(ptmosVigIni)ptmosVigIni,sum(ptmosVigFin)ptmosVigFin
,sum(case when isnull(PtmosVigIni,0)>=0 and isnull(PtmosVigIni,0)<300 then 20
	when isnull(PtmosVigIni,0)>=300 and isnull(PtmosVigIni,0)<500 then 15
	when isnull(PtmosVigIni,0)>=500 and isnull(PtmosVigIni,0)<700 then 10
	when isnull(PtmosVigIni,0)>=700 and isnull(PtmosVigIni,0)<1000 then 5
	when isnull(PtmosVigIni,0)>=1000 then 0 end) metacliente
FROM @region c
left outer join @sucursal o on o.nomoficina=c.nomoficina
group by c.fecha
GO