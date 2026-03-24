SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsABonoCarteraV2Ind
CREATE procedure [dbo].[pCsABonoCarteraV2Ind]	@fecha SMALLDATETIME
as
--declare @fecha SMALLDATETIME
--set @fecha='20150719'

declare @fechaMeta SMALLDATETIME
select @fechaMeta=ultimodia from tclperiodo where periodo=dbo.fduFechaATexto(@fecha, 'AAAAMM')

Declare @quin tinyint
set @quin= case when day(@fecha)<=15 then 1 else 2 end

declare @porcen decimal(10,2)
declare @porcen2 decimal(10,2)
set @porcen=0.1 -->0.1
set @porcen2=0.05 -->0.1

DECLARE @fec_1ra SMALLDATETIME
DECLARE @fec_2da SMALLDATETIME

DECLARE @FechaIni1 SMALLDATETIME
DECLARE @FechaIni2 SMALLDATETIME

DECLARE @fec_1ra_UltimoDia SMALLDATETIME
SET @fec_1ra   = @fecha
if (@quin=1)
	begin
		SET @FechaIni1 = DateAdd(Day,1,DateAdd(Day, -1, Cast(dbo.fduFechaATexto(@fec_1ra, 'AAAAMM') + '01' As SmallDateTime)))
		set @fec_1ra_UltimoDia=Cast(dbo.fduFechaATexto(@fec_1ra, 'AAAAMM') + '15' As SmallDateTime)		
	end
else
	begin
		SET @FechaIni1 = Cast(dbo.fduFechaATexto(@fec_1ra, 'AAAAMM') + '16' As SmallDateTime)
		select @fec_1ra_UltimoDia=ultimodia from tclperiodo where periodo=dbo.fduFechaATexto(@fec_1ra, 'AAAAMM')
	end

SET @fec_2da   = DateAdd(d,-1,@FechaIni1)
if (@quin=1)
	begin
		SET @FechaIni2 = Cast(dbo.fduFechaATexto(@fec_2da, 'AAAAMM') + '16' As SmallDateTime)
	end
else
	begin
		SET @FechaIni2 = DateAdd(Day,1,DateAdd(Day, -1, Cast(dbo.fduFechaATexto(@fec_2da, 'AAAAMM') + '01' As SmallDateTime)))
	end

--select @fecha '@fecha'													--2015-03-31 00:00:00			2015-03-31 00:00:00
--select @FechaIni1 '@FechaIni1'									--2015-03-01 00:00:00			2015-03-16 00:00:00
--select @FechaIni2 '@FechaIni2'									--2015-02-01 00:00:00			2015-03-01 00:00:00
--select @fec_1ra_UltimoDia '@fec_1ra_UltimoDia'	--2015-03-31 00:00:00			2015-03-31 00:00:00
--select @fec_1ra '@fec_1ra'											--2015-03-31 00:00:00			2015-03-31 00:00:00
--select @fec_2da '@fec_2da'											--2015-02-28 00:00:00			2015-03-15 00:00:00

create table #tmpca(
  codoficina varchar(4),
  nomoficina varchar(250),
  codasesor varchar(15),
  nomasesor varchar(250),
  duplicado int default(0),
	saldocapital decimal(16,2),
  ncliante int default(0),
  ncliactu int default(0),
  nnewcliactu int default(0),
  nrenovado int default(0),
	nrenovadoM int default(0),
	nrenovadoFP int default(0),
	nreasignado int default(0),
  porrenovar int default(0),
	liquidados int default(0),
	montointeres decimal(16,2) default(0),
	montointeres2 decimal(16,2) default(0),
	saldocartera decimal(16,2) default(0),
	saldomayor1dia decimal(16,2) default(0),
  moraactual decimal(16,2),
	montodesembolso decimal(16,2)
)
--verificar que sea el primer asesor el que coloco?????
insert into #tmpca (codoficina, nomoficina, codasesor, nomasesor,ncliante,ncliactu,nnewcliactu,saldocartera,saldomayor1dia,montodesembolso,saldocapital)        --nnewcliante
SELECT o.codoficina, o.nomoficina, c.codasesor,a.nomasesor
,count(distinct(case when c.fecha=@fec_2da then cd.codusuario else null end)) ncliante --renovacion anterior y cartera asignada anterior
,count(distinct(case when c.fecha=@fec_1ra then cd.codusuario else null end)) ncliactu
,count(distinct(case when c.fecha=@fec_1ra 
										 then
											(case when p.secuenciacliente=1 and p.desembolso>=@FechaIni1 and p.desembolso<=@Fec_1ra and p.tiporeprog='SINRE' then cd.codusuario else null end)
										 else null end)) nnewcliactu
,sum(case when c.fecha=@fec_1ra then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) saldocartera
,sum(case when c.fecha=@fec_1ra then (case when c.nrodiasatraso>0 then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) else 0 end) saldomayor1dia
,sum(case when c.fecha=@fec_1ra 
					then 
							(case when (p.desembolso>=@FechaIni1 and p.desembolso<=@Fec_1ra) and p.tiporeprog='SINRE' then cd.montodesembolso else 0 end) 
					else 0 end) montodesembolso
,sum(case when c.fecha=@fec_1ra then cd.saldocapital else 0 end) saldocapital
FROM tCsCartera c with(nolock)
inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario
inner join (
  SELECT codasesor, nomasesor FROM tCsPadronAsesores with(nolock) --where activo=1 and activoactual=1
) a on a.codasesor=c.codasesor
inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
where c.fecha in (@fec_2da,@fec_1ra)
and c.cartera='ACTIVA'    
--And c.codproducto <> '164'        
And c.codproducto not in ('164','156','116')
--and c.nrodiasatraso<=60
--aqui quita a juridico, 41:lideres,59: coordinador administrativo
--and c.codasesor not in(SELECT codusuario FROM tCsEmpleados where codpuesto in(26,15,50,41,59,70,62,71,64))
and c.codasesor not in(SELECT codusuario FROM tCsEmpleados where codpuesto in(80,94))
--and c.codasesor='AHJ2110851'
group by o.codoficina, o.nomoficina, c.codasesor, a.nomasesor--c.fecha, 
order by o.codoficina

--REASIGNACION : CARTERA ASIGNADA - PERIODO ACTUAL
--select fecha, codasesor, asignado 
update #tmpca
set nrenovado=nrenovaP
,nrenovadoM=nrenovaP-renovafuera
,nrenovadoFP=renovafuera
,nreasignado=nasignado
from (
	select fecha,codasesor
	,sum(nrenovaP) nrenovaP
	,sum(renovafuera) renovafuera
	,sum(nasignado) nasignado
	from (
		select fecha,codprestamo,codasesor,nrenovaP
		,case when nrenovaP>=1 
					then (case when cancelacionanterior>=@FechaIni1 and cancelacionanterior<=@fec_1ra then 1 else 0 end) 
					else 0 end renovafuera
		,nasignado
		from (
			SELECT fecha, codprestamo, codasesor,cancelacionanterior
			,count(distinct(case when fechadesembolso>=@FechaIni1 and fechadesembolso<=@fec_1ra and secuenciacliente<>1 
											then codprestamo else null end)) nrenovaP
			,sum(asignado) nasignado
			from (
				select c.fecha, c.codprestamo, c.codasesor,c.fechadesembolso,max(p.cancelacionanterior) cancelacionanterior,max(p.secuenciacliente) secuenciacliente
				--,count(distinct(case when dbo.fdufechaaperiodo(c.fechadesembolso)<>dbo.fdufechaaperiodo(@fec_1ra)
				--or (dbo.fdufechaaperiodo(c.fechadesembolso)=dbo.fdufechaaperiodo(@fec_1ra) and p.primerasesor<>c.codasesor) then c.codprestamo else null end)) asignado
				,count(distinct(
					case when c.fechadesembolso>=@FechaIni1 and c.fechadesembolso<=@fec_1ra then null
						else
							case when can.codasesor<>c.codasesor then c.codprestamo else null end
						end
				)) asignado
				FROM tCsCartera c with(nolock)
				inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
				inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario
				left outer join tCsCartera can with(nolock) on can.codprestamo=c.codprestamo and can.fecha=@FechaIni1-1
				where c.fecha=@fec_1ra
				and c.cartera='ACTIVA'
				--And c.codproducto <> '164'
				And c.codproducto not in ('164','156','116')
				--and c.nrodiasatraso<61
				--and c.codasesor='ABB1402911'
				--and c.codasesor='VSG0406881'
				--and c.codasesor='ALD1401901'   
				--and c.codasesor='RSN0203871'
				group by c.fecha, c.codprestamo, c.codasesor,c.fechadesembolso
			) x
			group by fecha,codprestamo,codasesor,cancelacionanterior
		) a
	) b
	group by fecha,codasesor
) a
inner join #tmpca t on t.codasesor=a.codasesor

/*CLIENTES POR RENOVAR EN EL MES*/
--Aqui se considero todos los clientes con fecha de vencimiento en el periodo o que haigan cancelado en el periodo
update #tmpca
set porrenovar=a.porrenovar
from (
select p.últimoasesor codasesor,count(p.codprestamo) porrenovar
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on p.codprestamo=c.codprestamo and p.fechacorte=c.fecha
where p.estadocalculado<>'CASTIGADA'
--and c.codproducto <> '164'
And c.codproducto not in ('164','156','116')
and c.nrodiasatraso<61 --> OJO PARAMETRO PARA LAS RENOVACIONES
and (c.fechavencimiento>=@FechaIni1 and c.fechavencimiento<=@fec_1ra_UltimoDia)
group by p.últimoasesor
) a
inner join #tmpca t on t.codasesor=a.codasesor

update #tmpca
set Liquidados=a.liquidados
from (
select p.últimoasesor codasesor,count(p.codusuario) liquidados
from tcspadroncarteradet p with(nolock)
inner join tcscartera c with(nolock) on p.codprestamo=c.codprestamo and p.fechacorte=c.fecha
where p.estadocalculado<>'CASTIGADA'
--and c.codproducto <> '164'
And c.codproducto not in ('164','156','116')
and c.nrodiasatraso<61
and (p.cancelacion>=@FechaIni1 and p.cancelacion<=@fec_1ra)--@fec_1ra_UltimoDia
group by p.últimoasesor
) a
inner join #tmpca t on t.codasesor=a.codasesor

/*monto interes recuperado*/
update #tmpca
set montointeres=a.montointeres,montointeres2=a.montointeres2
from (
	SELECT c.codasesor
	,sum(case when c.codproducto in('166','123','156') then t.montointerestran else 0 end) montointeres
	,sum(case when c.codproducto not in('166','123','156') then t.montointerestran else 0 end) montointeres2
	FROM tCsTransaccionDiaria t with(nolock)
	inner join tcscartera c with(nolock) on c.codprestamo=t.codigocuenta and c.fecha=dateadd(day,-1,t.fecha)
	where t.fecha>=@FechaIni1 and t.fecha<=@fec_1ra
	and t.codsistema='CA' and t.extornado=0 and t.tipotransacnivel3 in(104,105)
	and t.tipotransacnivel1='I' 
	--and c.codproducto<>'164'
	And c.codproducto not in ('164','156','116')
	and c.nrodiasatraso<61
	group by c.codasesor
) a
inner join #tmpca t on t.codasesor=a.codasesor     

update #tmpca
set moraactual=
case when isnull(saldocartera,0)= 0 then 0
else
      (isnull(saldomayor1dia,0) / isnull(saldocartera,0))*100
end

update #tmpca
set duplicado=nro
from (
select nomasesor,count(nomasesor) nro
from #tmpca
group by nomasesor
having count(nomasesor)>1
) a
inner join #tmpca b on a.nomasesor=b.nomasesor

--/*--181
select @fec_1ra as fecha,p.codoficina,p.nomoficina,z.nombre region,p.codasesor,p.nomasesor,pu.Descripcion puesto,case when e.estado=1 then 'ACTIVO' else 'BAJA' end EstadoAsesor,p.duplicado
,p.saldocartera,p.saldocapital,p.ncliante,p.ncliactu,p.nnewcliactu,p.nrenovado,p.nrenovadoM,p.nrenovadoFP,p.nreasignado,p.porrenovar,p.liquidados,p.montodesembolso,p.montointeres,p.montointeres2
,@porcen porcen,@porcen2 porcen2,p.montointeres*@porcen + p.montointeres2*@porcen2 Pagoxinteres10,p.moraactual
,case when p.porrenovar=0 then 0 else cast((cast((p.nrenovadoM + p.nrenovadoFP) as decimal(10,2))/cast(p.porrenovar as decimal(10,2)))*100 as decimal(10,2)) end PorRenoClie
,case when p.ncliactu-p.ncliante<0 then 0 else p.ncliactu-p.ncliante end NetoClientesNuevos
,isnull(f1.varbono,0) BonoCrecimientoClientes
,isnull(f2.varbono,0)*(p.nrenovadoM+p.nrenovadoFP) BonoRenovacionMes
--,p.nrenovadoFP*75 BonoRenovacionesFP
,(isnull(f1.varbono,0) + isnull(f2.varbono,0)*(p.nrenovadoM + p.nrenovadoFP)) PreBono--BonoSinDeduccion
,isnull(f22.varbono,0) PorcentajeDeduccion
,(isnull(f1.varbono,0) + isnull(f2.varbono,0)*(p.nrenovadoM + p.nrenovadoFP))-(isnull(f1.varbono,0) + isnull(f2.varbono,0)*(p.nrenovadoM + p.nrenovadoFP))*isnull(f22.varbono,0)/100 BonoFinal
,CEILING(isnull(MCN.valorprog,0)/2)+CEILING(isnull(MCR.valorprog,0)/2) MCT
,CEILING(isnull(MCD.valorprog,0)/2) MCD
,case when (CEILING(isnull(MCN.valorprog,0)/2)+CEILING(isnull(MCR.valorprog,0)/2))=0 then 100-- si es Cero (0) significa que no tienen metas y se colocara el 100%
				else cast(((case when p.ncliactu-p.ncliante<0 then 0 else p.ncliactu-p.ncliante end)/(CEILING(isnull(MCN.valorprog,0)/2)+CEILING(isnull(MCR.valorprog,0)/2)))*100 as decimal(16,2)) end '%MNC'
,case when CEILING(isnull(MCD.valorprog,0)/2)=0 then 100-- si es Cero (0) significa que no tienen metas y se colocara el 100%
				else cast((p.montodesembolso/(CEILING(isnull(MCD.valorprog,0)/2)))*100 as decimal(16,2)) end '%MDE'
,CEILING(isnull(MCN.valorprog,0)/2) MetaProgN
,CEILING(isnull(MCR.valorprog,0)/2) MetaProgR
,saldomayor1dia
into #tmpca2
from #tmpca p
inner join tcloficinas o on o.codoficina=p.codoficina
inner join tclzona z on z.zona=o.zona
inner join tCsEmpleados e on e.codusuario=p.codasesor
inner join tcsclpuestos pu on pu.codigo=e.codpuesto
LEFT OUTER JOIN tCsCaFactoresCalcBono f1 ON (case when p.ncliactu-p.ncliante-p.nreasignado<0 then 0 else p.ncliactu-p.ncliante-p.nreasignado end) between f1.MtoMin and f1.MtoMax and f1.tipo = 23
--LEFT OUTER JOIN tCsCaFactoresCalcBono f1 ON (case when p.ncliactu-p.ncliante<0 then 0 else p.ncliactu-p.ncliante end) between f1.MtoMin and f1.MtoMax and f1.tipo = 23
LEFT OUTER JOIN tCsCaFactoresCalcBono f22 ON p.moraactual between f22.MtoMin and f22.MtoMax and f22.tipo = 22
left outer join tCsBsMetaxUEN MCN on MCN.ncamvalor=p.codasesor and MCN.fecha=@fechaMeta and MCN.iCodTipoBS=5 and MCN.iCodIndicador=11--> metas de nuevos clientes
left outer join tCsBsMetaxUEN MCR on MCR.ncamvalor=p.codasesor and MCR.fecha=@fechaMeta and MCR.iCodTipoBS=5 and MCR.iCodIndicador=8--> metas de nuevos renovados
left outer join tCsBsMetaxUEN MCD on MCD.ncamvalor=p.codasesor and MCD.fecha=@fechaMeta and MCD.iCodTipoBS=5 and MCD.iCodIndicador=1--> metas de desembolsos

LEFT OUTER JOIN tCsCaFactoresCalcBono f2 ON (case when CEILING(isnull(MCR.valorprog,0)/2)=0 then case when cast((p.nrenovadoM+p.nrenovadoFP) as decimal(10,2))=0 then 0 else 100 end
																									else cast((cast((p.nrenovadoM+p.nrenovadoFP) as decimal(10,2))/CEILING(isnull(MCR.valorprog,0)/2))*100 as decimal(10,2)) 
																						 end)
																						between f2.MtoMin and f2.MtoMax and f2.tipo = 21

--Nuevos
--select fecha,ncamvalor,valorprog from tCsBsMetaxUEN where fecha='20150228' and iCodTipoBS=5 and iCodIndicador=11
--Renovados
--select fecha,ncamvalor,valorprog from tCsBsMetaxUEN where fecha='20150331' and iCodTipoBS=5 and iCodIndicador=12
--select * from #tmpca2
delete tCsRptBonoCarteraV2
where fecha=@fecha and tipocalculo=1

insert into tCsRptBonoCarteraV2
select b.Fecha,1 Tipo,b.codoficina,b.nomoficina,b.region,b.codasesor,b.nomasesor,b.puesto,b.estadoasesor,e.Ingreso,e.CodEmpleado
,b.duplicado,b.saldocartera,b.saldomayor1dia,b.saldocapital,b.ncliante,b.ncliactu--,MCN,MCR,MCD--,[%MCN],[%MCR],[%MCD]
,b.nnewcliactu,b.nrenovado,b.nrenovadoM,b.nrenovadoFP,b.nreasignado,b.porrenovar NumARenovar,b.liquidados,b.montodesembolso,b.montointeres,b.montointeres2
,b.porcen,b.porcen2,b.pagoxinteres10 Bonopagoxinteres
,b.moraactual,b.PorRenoClie,b.NetoClientesNuevos
,b.BonoCrecimientoClientes,b.BonoRenovacionMes--,BonoRenovacionesFP
,b.PreBono + b.pagoxinteres10 as PreBono
,b.PorcentajeDeduccion
,(b.PreBono + b.pagoxinteres10) - (b.PreBono + b.pagoxinteres10)*b.PorcentajeDeduccion/100 as BonoFinal
,b.MetaProgN,b.MetaProgR
,b.MCT
,b.MCD
,b.[%MNC]
,b.[%MDE]
,case when [%MNC]>=80 then (((PreBono + pagoxinteres10) - (PreBono + pagoxinteres10)*PorcentajeDeduccion/100)/2)*(case when [%MNC]>100 then 100 else [%MNC] end)/100 else 0 end BMetaMNC
,case when [%MDE]>=80 then (((PreBono + pagoxinteres10) - (PreBono + pagoxinteres10)*PorcentajeDeduccion/100)/2)*(case when [%MDE]>100 then 100 else [%MDE] end)/100 else 0 end BMetaMDE
,case when [%MNC]>=80 then (((PreBono + pagoxinteres10) - (PreBono + pagoxinteres10)*PorcentajeDeduccion/100)/2)*(case when [%MNC]>100 then 100 else [%MNC] end)/100 else 0 end
+ case when [%MDE]>=80 then (((PreBono + pagoxinteres10) - (PreBono + pagoxinteres10)*PorcentajeDeduccion/100)/2)*(case when [%MDE]>100 then 100 else [%MDE] end)/100 else 0 end BONOAPAGAR
--into tCsRptBonoCarteraV2
from #tmpca2 b
left outer join tCsEmpleados e on e.codusuario=b.codasesor

drop table #tmpca
drop table #tmpca2
GO