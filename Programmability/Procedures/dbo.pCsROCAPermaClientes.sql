SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
---PERMANENCIA DE CLIENTES RESUMEN 2022.10.24 zccu---    
---SP para generar informacion para el reporte Operativo enviado a DG    
---Optimiza consultas zccu 2023.10.16 
CREATE procedure [dbo].[pCsROCAPermaClientes]    
AS  
set nocount on     
    
declare @fecha smalldatetime    
select @fecha=fechaconsolidacion from vcsfechaconsolidacion    
    
    
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
AND pc.CodOficina not in( '999','231' )     
and pc.SecuenciaCliente = 1   
--and pc.CodOficina <> '231'    
order by pc.desembolso    
    
 --- fecha de primer desembolso, y ultimo desembolso por usuario    
select codusuario, min(desembolso) primer_desemb, max(desembolso) ultimo_desemb    
into #ClixDesembs --select top 10*    
from tcspadroncarteradet pc  with(nolock)    
where desembolso<= @fechacorte 
AND CodOficina not in('999','231' )     
and codusuario in(select codusuario from #clientesnuevos with(nolock))
    
group by codusuario    
    
select Codprestamo,CodUsuario,FechaDesembolso,Fecha 
,Estado,NroDiasAtraso,SaldoCapital
into #ca  
from tcscartera with(nolock)  
where fecha= @fechacorte    
  
     
select --'PrimerCredito' et,    
@fechacorte fechaCorte,pc.codprestamo, pc.codusuario, p.NombreCompleto
, pc.codoficina, o.NomOficina AS sucursal    
, z.Nombre region ,pc.SecuenciaCliente  --,pc.EstadoCalculado --> al dia de hoy    
,case when tcs.Estado is null then 'CANCELADO'     
   when tcs.NroDiasAtraso >= 31 then 'VENCIDO'    
      when tcs.NroDiasAtraso <= 30 then 'VIGENTE'    
   else '¿?' end EstadoCalculado --> al dia de corte    
,pc.Desembolso, pc.monto  --,pc.Cancelacion    
,case when tcs.estado is null then pc.Cancelacion else null end cancelacion --, pc.SaldoCalculado    
,case when tcs.estado is null then pc.NroDiasMaximo  else null end NroDiasMaximo --, pc.NroDiasMaximo    
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
--left outer join tCsCartera tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.primer_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte   
left outer join #ca tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.primer_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte    
inner join tcspadronclientes p with(nolock) on p.codusuario=pc.CodUsuario    
INNER JOIN tClOficinas o with(nolock) ON pc.CodOficina=o.CodOficina    
inner join tclzona z on z.zona=o.zona    
--left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.UltimoAsesor    
left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.PrimerAsesor  -- PROMOTOR QUE COLOCO EL CREDITO    
where z.nombre <> 'Zona Cerradas' and z.nombre <> 'Zona Corporativo'    
     
    
    
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
--left outer join tCsCartera tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.ultimo_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte    
left outer join #ca tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.ultimo_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte    
inner join tcspadronclientes p with(nolock) on p.codusuario=pc.CodUsuario    
INNER JOIN tClOficinas o with(nolock) ON pc.CodOficina=o.CodOficina    
inner join tclzona z on z.zona=o.zona    
--left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.UltimoAsesor    
left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.PrimerAsesor  -- PROMOTOR QUE COLOCO EL CREDITO    
where z.nombre <> 'Zona Cerradas' and z.nombre <> 'Zona Corporativo'    
    
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
    
-------VALIDAR --- TABLA TEMPORAL / SE BORRA TODA E SE INSERTAN NUEVOS REGISTROS.-- ZCCU  
DELETE FROM FNMGCONSOLIDADO.DBO.TmpROCAPermaClientes  
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAPermaClientes   
select     
fechacorte,cast(cosechaGeneracion as varchar )cosechaGeneracion,añoGeneracion    
,sum(nroClientes)nroCliNuevos    
,sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end) nroVigentes    
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )nroLiquiBueno    
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end) nroLiquiMalo    
,Round (case when sum(nroClientes)=0 then 0 
        else sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end,2) PorVigentes    
,round( case when sum(nroClientes)=0 then 0 
        else sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )/cast(sum(nroClientes)as decimal)*100 end,2) PorBuenosNR    
,Round (case when sum(nroClientes)=0 then 0 
       else sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end,2) PorMalos     
,sum(ultimoMontoOtorgado)MoNuevo    
,sum(case when estadoActualCliente='VIGENTE' then ultimoMontoOtorgado else 0 end) MoVigentes    
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then ultimoMontoOtorgado else 0 end) MoLiquiBueno    
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then ultimoMontoOtorgado else 0 end) MoLiquiMalo    
, 60  ObjetivoVigente  
--INTO FNMGCONSOLIDADO.DBO.TmpROCAPermaClientes  
from #base with(nolock)    
group by fechacorte,cosechaGeneracion,añoGeneracion    --order by cosechaGeneracion   
--union   
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAPermaClientes  
select     
fechacorte,'Total General' cosechaGeneracion,1 añoGeneracion    
,sum(nroClientes)nroCliNuevos    
,sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end) nroVigentes    
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )nroLiquiBueno    
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end) nroLiquiMalo    
,Round (case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end,2) PorVigentes    
,Round (case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )/cast(sum(nroClientes)as decimal)*100 end,2) PorBuenosNR    
,Round (case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end,2) PorMalos    
,sum(ultimoMontoOtorgado)MoNuevo    
,sum(case when estadoActualCliente='VIGENTE' then ultimoMontoOtorgado else 0 end) MoVigentes    
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then ultimoMontoOtorgado else 0 end) MoLiquiBueno    
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then ultimoMontoOtorgado else 0 end) MoLiquiMalo    
, 60  ObjetivoVigente    
from #base with(nolock)    
group by fechacorte    
--union      
INSERT INTO FNMGCONSOLIDADO.DBO.TmpROCAPermaClientes  
select     
fechacorte,'Total Año' cosechaGeneracion, añoGeneracion    
,sum(nroClientes)nroCliNuevos    
,sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end) nroVigentes    
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )nroLiquiBueno    
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end) nroLiquiMalo    
,Round (case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end,2) PorVigentes    
,Round (case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )/cast(sum(nroClientes)as decimal)*100 end,2) PorBuenosNR    
,Round (case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end,2) PorMalos    
,sum(ultimoMontoOtorgado)MoNuevo    
,sum(case when estadoActualCliente='VIGENTE' then ultimoMontoOtorgado else 0 end) MoVigentes    
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then ultimoMontoOtorgado else 0 end) MoLiquiBueno    
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then ultimoMontoOtorgado else 0 end) MoLiquiMalo    
, 60  ObjetivoVigente    
 from #base with(nolock)    
 group by fechacorte,añoGeneracion    
  
drop table #ca  
drop table #base
GO