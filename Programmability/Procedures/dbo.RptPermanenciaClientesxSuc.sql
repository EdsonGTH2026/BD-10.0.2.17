SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---PERMANENCIA DE CLIENTES RESUMEN 20221024---

create procedure [dbo].[RptPermanenciaClientesxSuc]  @fecha smalldatetime,@codoficina varchar(5)
as
set nocount on 


--declare @fecha smalldatetime
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

--declare @codoficina VARCHAR(5)
--select @codoficina= '309'

declare @fechacorte smalldatetime
set @fechacorte = @fecha --LA FECHA DE CORTE

declare @fecini smalldatetime
set @fecini=(dbo.fdufechaaperiodo(dateadd(month,-24,@fecha)))+'01' ---- fecha de inicio de mes

---clientes que desembolsaron en el periodo consultado
select pc.codusuario
into #clientesnuevos
from tcspadroncarteradet pc  with(nolock)
where Desembolso>=@fecini
and Desembolso<=@fechacorte
and pc.SecuenciaCliente = 1 
and pc.codoficina=@codoficina
--AND pc.CodOficina <> '999' and pc.CodOficina <> '231'
order by pc.desembolso

 --- fecha de primer desembolso, y ultimo desembolso por usuario
select codusuario, min(desembolso) primer_desemb, max(desembolso) ultimo_desemb
into #ClixDesembs
--select top 10*
from tcspadroncarteradet pc  with(nolock)
where codusuario in(
       select codusuario   from #clientesnuevos with(nolock)
) and desembolso <= @fechacorte
group by codusuario

 
 
select --'PrimerCredito' et,
@fechacorte fechaCorte
,pc.codprestamo, pc.codusuario, p.NombreCompleto, pc.codoficina, o.NomOficina AS sucursal
, z.Nombre region
,pc.SecuenciaCliente
--,pc.EstadoCalculado --> al dia de hoy
,case when tcs.Estado is null then 'CANCELADO' 
	  when tcs.NroDiasAtraso >= 31 then 'VENCIDO'
      when tcs.NroDiasAtraso <= 30 then 'VIGENTE'
	  else '¿?' end EstadoCalculado --> al dia de corte
,pc.Desembolso, pc.monto
--,pc.Cancelacion
,case when tcs.estado is null then pc.Cancelacion else null end cancelacion
--, pc.SaldoCalculado
,case when tcs.estado is null then pc.NroDiasMaximo  else null end NroDiasMaximo
--, pc.NroDiasMaximo
,case when tcs.SaldoCapital is null then 0 else tcs.SaldoCapital end saldoCapital
--,case when tcs.NroDiasAtraso is null then 0 else tcs.NroDiasAtraso end NroDiasAtrasoCorte
--,p.FechaNacimiento
--,pc.UltimoAsesor ->codigo promotor
--, e.paterno+' '+ e.materno+' '+e.nombres Promotor
--, e.Salida ---> fecha salida promotor
,case when e.Salida >0 then 'BAJA' else 'ACTIVO' end estatusPromotor
into #Primer
from #ClixDesembs xi with(nolock)
inner join tcspadroncarteradet pc with(nolock) on xi.codusuario=pc.codusuario and xi.primer_desemb=pc.Desembolso
left outer join tCsCartera tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.primer_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte
inner join tcspadronclientes p with(nolock) on p.codusuario=pc.CodUsuario
INNER JOIN tClOficinas o with(nolock) ON pc.CodOficina=o.CodOficina
inner join tclzona z on z.zona=o.zona
--left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.UltimoAsesor
left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.PrimerAsesor  -- PROMOTOR QUE COLOCO EL CREDITO
where z.nombre <> 'Zona Cerradas' and z.nombre <> 'Zona Corporativo'
and pc.codoficina=@codoficina
 


select --'UltimoCredito' et,
@fechacorte fechaCorte
,pc.codprestamo, pc.codusuario, p.NombreCompleto, pc.codoficina, o.NomOficina AS sucursal
, z.Nombre region
,pc.SecuenciaCliente
--,pc.EstadoCalculado --> al dia de hoy
,case when tcs.Estado is null then 'CANCELADO' 
	  when tcs.NroDiasAtraso >= 31 then 'VENCIDO'
      when tcs.NroDiasAtraso <= 30 then 'VIGENTE'
	  else '¿?' end EstadoCalculado --> al dia de corte
,pc.Desembolso, pc.monto
--,pc.Cancelacion
,case when tcs.estado is null then pc.Cancelacion else null end cancelacion
--, pc.SaldoCalculado
,case when tcs.estado is null then pc.NroDiasMaximo  else null end NroDiasMaximo
--, pc.NroDiasMaximo
,case when tcs.SaldoCapital is null then 0 else tcs.SaldoCapital end saldoCapital
--,case when tcs.NroDiasAtraso is null then 0 else tcs.NroDiasAtraso end NroDiasAtrasoCorte
--,p.FechaNacimiento
--,pc.UltimoAsesor ->codigo promotor
--, e.paterno+' '+ e.materno+' '+e.nombres Promotor
--, e.Salida ---> fecha salida promotor
, case when e.Salida >0 then 'BAJA' else 'ACTIVO' end estatusPromotor
into #Ultimo
from #ClixDesembs xi with(nolock)
inner join tcspadroncarteradet pc with(nolock) on xi.codusuario=pc.codusuario and xi.ultimo_desemb=pc.Desembolso
left outer join tCsCartera tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.ultimo_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte
inner join tcspadronclientes p with(nolock) on p.codusuario=pc.CodUsuario
INNER JOIN tClOficinas o with(nolock) ON pc.CodOficina=o.CodOficina
inner join tclzona z on z.zona=o.zona
--left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.UltimoAsesor
left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.PrimerAsesor  -- PROMOTOR QUE COLOCO EL CREDITO
where z.nombre <> 'Zona Cerradas' and z.nombre <> 'Zona Corporativo'
and pc.codoficina=@codoficina

drop table #clientesnuevos
drop table #ClixDesembs
 
select 
@fechacorte fechaCorte
,dbo.fdufechaaperiodo(p.desembolso) cosechaGeneracion
,DATEPART(year,p.desembolso) añoGeneracion
,CAST (DATEPART(qq,p.desembolso)as varchar)+'T'+ CAST (DATEPART(year,p.desembolso) as varchar ) trimestreGeneracion
,count(p.codprestamo) nroClientes
,p.sucursal
,p.region
,case when (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end) = 'CANCELADO' and p.NroDiasMaximo >= 31 then 'LIQUIDADO MALO'
      when (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end) = 'CANCELADO' and u.NroDiasMaximo >= 31 then 'LIQUIDADO MALO'
      when (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end ) = 'CANCELADO' and u.NroDiasMaximo <= 30 then 'LIQUIDADO BUENO'
      when (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end ) = 'CANCELADO' and p.NroDiasMaximo <= 30 then 'LIQUIDADO BUENO'
 else (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end) end estadoActualCliente
,case when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 15 then 'f.C15+'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 10 then 'e.C10-14'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 5 then 'd-C5-9'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 3 then 'c.C3-4'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) = 2 then 'b.C2'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) = 1 then 'a.C1'
 else '¿?' end rangoCicloMaximo    
,case when u.estatusPromotor is null then p.estatusPromotor else u.estatusPromotor end estatusProm 

,SUM(p.monto) PrimerMontoOtorgado
,SUM(case when u.monto is null then p.monto else u.monto end) UltimoMontoOtorgado
,SUM(case when u.saldoCapital is null then p.saldoCapital else u.saldoCapital end) saldoCapital
,dbo.fdufechaaperiodo (case when u.desembolso is null then p.desembolso else u.desembolso end) cosechaUlimoDesembolso
,dbo.fdufechaaperiodo (case when u.cancelacion is null then p.cancelacion else u.cancelacion end) cosechaUltimaLiquidacion
into #base
from #Primer p
left outer join #Ultimo u on p.codusuario=u.codusuario
group by 
dbo.fdufechaaperiodo(p.desembolso)
,DATEPART(year,p.desembolso)
,CAST (DATEPART(qq,p.desembolso)as varchar)+'T'+ CAST (DATEPART(year,p.desembolso) as varchar )
,p.sucursal, p.region
,case when (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end) = 'CANCELADO' and p.NroDiasMaximo >= 31 then 'LIQUIDADO MALO'
      when (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end) = 'CANCELADO' and u.NroDiasMaximo >= 31 then 'LIQUIDADO MALO'
      when (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end ) = 'CANCELADO' and u.NroDiasMaximo <= 30 then 'LIQUIDADO BUENO'
      when (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end ) = 'CANCELADO' and p.NroDiasMaximo <= 30 then 'LIQUIDADO BUENO'
 else (case when u.secuenciaCliente is null then p.estadocalculado else u.estadoCalculado end) end
,case when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 15 then 'f.C15+'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 10 then 'e.C10-14'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 5 then 'd-C5-9'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 3 then 'c.C3-4'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) = 2 then 'b.C2'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) = 1 then 'a.C1'
 else '¿?' end     
,case when u.estatusPromotor is null then p.estatusPromotor else u.estatusPromotor end  
,dbo.fdufechaaperiodo (case when u.desembolso is null then p.desembolso else u.desembolso end) 
,dbo.fdufechaaperiodo (case when u.cancelacion is null then p.cancelacion else u.cancelacion end) 


drop table #Ultimo
drop table #Primer



select                     --------------------- 24 MESES MOSTRADOS
fechacorte,cast(cosechaGeneracion as varchar )cosechaGeneracion,añoGeneracion
,sucursal
,region
,sum(nroClientes)nroCliNuevos
,sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end) nroVigentes
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )nroLiquiBueno
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end) nroLiquiMalo
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorVigentes
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )/cast(sum(nroClientes)as decimal)*100 end PorBuenosNR
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorMalos

,sum(ultimoMontoOtorgado)MoNuevo
,sum(case when estadoActualCliente='VIGENTE' then ultimoMontoOtorgado else 0 end) MoVigentes
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then ultimoMontoOtorgado else 0 end) MoLiquiBueno
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then ultimoMontoOtorgado else 0 end) MoLiquiMalo
, 60  ObjetivoVigente
 from #base with(nolock)
 group by fechacorte,cosechaGeneracion,añoGeneracion,sucursal,region
--order by cosechaGeneracion
union             ---------- TOTAL DEL LOS REGISTROS MOSTRADOS
select 
fechacorte,'Total General' cosechaGeneracion,1 añoGeneracion
,sucursal
,region
,sum(nroClientes)nroCliNuevos
,sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end) nroVigentes
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )nroLiquiBueno
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end) nroLiquiMalo
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorVigentes
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )/cast(sum(nroClientes)as decimal)*100 end PorBuenosNR
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorMalos
,sum(ultimoMontoOtorgado)MoNuevo
,sum(case when estadoActualCliente='VIGENTE' then ultimoMontoOtorgado else 0 end) MoVigentes
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then ultimoMontoOtorgado else 0 end) MoLiquiBueno
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then ultimoMontoOtorgado else 0 end) MoLiquiMalo
, 60  ObjetivoVigente
 from #base with(nolock)
 group by fechacorte,sucursal,region
union    ---------TOTAL AL AÑO X SUCURSAL
select 
fechacorte,'Total Año' cosechaGeneracion, añoGeneracion
,sucursal
,region
,sum(nroClientes)nroCliNuevos
,sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end) nroVigentes
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )nroLiquiBueno
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end) nroLiquiMalo
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorVigentes
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )/cast(sum(nroClientes)as decimal)*100 end PorBuenosNR
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorMalos
,sum(ultimoMontoOtorgado)MoNuevo
,sum(case when estadoActualCliente='VIGENTE' then ultimoMontoOtorgado else 0 end) MoVigentes
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then ultimoMontoOtorgado else 0 end) MoLiquiBueno
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then ultimoMontoOtorgado else 0 end) MoLiquiMalo
, 60  ObjetivoVigente
 from #base with(nolock)
 group by fechacorte,añoGeneracion
 ,sucursal
,region







drop table #base
GO