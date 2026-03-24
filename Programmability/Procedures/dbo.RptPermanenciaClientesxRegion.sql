SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---PERMANENCIA DE CLIENTES RESUMEN 20221024---   
CREATE procedure [dbo].[RptPermanenciaClientesxRegion]  @fecha smalldatetime,@zona varchar(6)  
as  
set nocount on  

-- 2023.06.24 zccu - se optimiza todo el sp, por lentitud en el servidor 2.17 
  
--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion  
  
--declare @zona VARCHAR(5)  
--select @zona= 'z14'  

declare @fechacorte smalldatetime 
set @fechacorte = @fecha --LA FECHA DE CORTE  
declare @fecini smalldatetime  
set @fecini=(dbo.fdufechaaperiodo(dateadd(month,-24,@fecha)))+'01' ---- fecha de inicio de mes  

-----------------------VARIABLES DE TIEMPO----------
DECLARE @T1 DATETIME
DECLARE @T2 DATETIME
SET @T1=GETDATE()


---- 2023.06.24 zccu - se crea temporal con las sucursales/ para evitar joins a tcloficinas en cada tabla temporal
select o.codoficina  
into #sucursales 
from tClOficinas o with(nolock) 
inner join tclzona z with(nolock) on z.zona=o.zona 
where o.zona=@zona
and z.nombre <> 'Zona Cerradas' 
and z.nombre <> 'Zona Corporativo'
--and tipo <>'Cerrada'

 ---clientes que desembolsaron en el periodo consultado 
create table #clientesnuevos (codusuario varchar(30))
insert into #clientesnuevos 
select pc.codusuario 
from tcspadroncarteradet pc  with(nolock) 
INNER JOIN tClOficinas o with(nolock) ON pc.CodOficina=o.CodOficina 
where Desembolso>=@fecini 
and Desembolso<=@fechacorte 
and pc.SecuenciaCliente = 1  
and o.zona=@zona 
order by pc.desembolso   

          
SET @T2=GETDATE()
PRINT '1 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))
SET @T1=GETDATE()
          
--- fecha de primer desembolso, y ultimo desembolso por usuario 
create table #ClixDesembs (codusuario varchar(30),primer_desemb smalldatetime,ultimo_desemb smalldatetime)
insert into #ClixDesembs --select top 10* 
select codusuario, min(desembolso) primer_desemb, max(desembolso) ultimo_desemb 
from tcspadroncarteradet pc  with(nolock) 
where codusuario in(select codusuario from #clientesnuevos with(nolock)) 
and desembolso <= @fechacorte 
group by codusuario  

---- 2023.06.24 zccu - se crea temporal de tcacartera 

select *
into #tmpCA
from  tCsCartera  with (nolock)
where Fecha= @fechacorte 
and codusuario in (select codusuario from #ClixDesembs with(nolock)) 
        
SET @T2=GETDATE()
PRINT '2 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))
SET @T1=GETDATE()
              

select --'PrimerCredito' et, 
@fechacorte fechaCorte 
,pc.codprestamo
, pc.codusuario
--, p.NombreCompleto
, pc.codoficina
--, o.NomOficina AS sucursal 
--, z.Nombre region 
,pc.SecuenciaCliente 
,case when tcs.Estado is null then 'CANCELADO' 
	when tcs.NroDiasAtraso >= 31 then 'VENCIDO'
	when tcs.NroDiasAtraso <= 30 then 'VIGENTE'
	else '¿?' end EstadoCalculado --> al dia de corte 
,pc.Desembolso
,pc.monto 
,case when tcs.estado is null then pc.Cancelacion else null end cancelacion --, pc.SaldoCalculado 
,case when tcs.estado is null then pc.NroDiasMaximo  else null end NroDiasMaximo --, pc.NroDiasMaximo 
,case when tcs.SaldoCapital is null then 0 else tcs.SaldoCapital end saldoCapital 
--,case when e.Salida >0 then 'BAJA' else 'ACTIVO' end estatusPromotor 
into #Primer 
from #ClixDesembs xi with(nolock) 
inner join tcspadroncarteradet pc with(nolock) on xi.codusuario=pc.codusuario and xi.primer_desemb=pc.Desembolso 
--left outer join tCsCartera tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.primer_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte 
---- 2023.06.24 zccu/ se cruza con temporal de cartera.
left outer join #tmpCA tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.primer_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte 
--inner join tcspadronclientes p with(nolock) on p.codusuario=pc.CodUsuario ---- 2023.06.24 zccu/ se comentan cruces no necesarios.
--INNER JOIN tClOficinas o with(nolock) ON pc.CodOficina=o.CodOficina 
--inner join tclzona z with(nolock)on z.zona=o.zona 
--left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.PrimerAsesor  -- PROMOTOR QUE COLOCO EL CREDITO 
where pc.codoficina in (select codoficina from #sucursales with(nolock))
          
SET @T2=GETDATE()
PRINT '3 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))
SET @T1=GETDATE()
          
          
select 
--'UltimoCredito' et
 @fechacorte fechaCorte ,pc.codprestamo
, pc.codusuario
--, p.NombreCompleto
, pc.codoficina
--, o.NomOficina AS sucursal 
--,z.Nombre region 
,pc.SecuenciaCliente 
,case when tcs.Estado is null then 'CANCELADO'
	when tcs.NroDiasAtraso >= 31 then 'VENCIDO'
	when tcs.NroDiasAtraso <= 30 then 'VIGENTE'
	else '¿?' end EstadoCalculado --> al dia de corte 
,pc.Desembolso, pc.monto --,pc.Cancelacion 
,case when tcs.estado is null then pc.Cancelacion else null end cancelacion 
,case when tcs.estado is null then pc.NroDiasMaximo  else null end NroDiasMaximo --, pc.NroDiasMaximo 
,case when tcs.SaldoCapital is null then 0 else tcs.SaldoCapital end saldoCapital 
--,case when e.Salida >0 then 'BAJA' else 'ACTIVO' end estatusPromotor
into #Ultimo 
from #ClixDesembs xi with(nolock) 
inner join tcspadroncarteradet pc with(nolock) on xi.codusuario=pc.codusuario and xi.ultimo_desemb=pc.Desembolso 
--left outer join tCsCartera tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.ultimo_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte 
---- 2023.06.24 zccu/ se cruza con temporal de cartera.
left outer join #tmpCA tcs with (nolock) on xi.codusuario=tcs.CodUsuario  and xi.ultimo_desemb=tcs.FechaDesembolso and tcs.Fecha= @fechacorte 
--inner join tcspadronclientes p with(nolock) on p.codusuario=pc.CodUsuario ---- 2023.06.24 zccu/ se comentan cruces no necesarios.
--INNER JOIN tClOficinas o with(nolock) ON pc.CodOficina=o.CodOficina 
--inner join tclzona z on z.zona=o.zona 
--left outer join tCsempleados e with(nolock) on e.CodUsuario = pc.PrimerAsesor  -- PROMOTOR QUE COLOCO EL CREDITO 
--where z.nombre <> 'Zona Cerradas' 
--and z.nombre <> 'Zona Corporativo' 
--and o.zona=@zona
where pc.codoficina in (select codoficina from #sucursales with(nolock))

          
SET @T2=GETDATE()
PRINT '4 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))
SET @T1=GETDATE()
          
drop table #clientesnuevos 
drop table #ClixDesembs   

select  @fechacorte fechaCorte 
,dbo.fdufechaaperiodo(p.desembolso) cosechaGeneracion 
,DATEPART(year,p.desembolso) añoGeneracion 
,CAST (DATEPART(qq,p.desembolso)as varchar)+'T'+ CAST (DATEPART(year,p.desembolso) as varchar ) trimestreGeneracion 
,count(p.codprestamo) nroClientes 
--,p.sucursal ,p.region 
,case when (case when u.secuenciaCliente is null then p.estadocalculado 
				else u.estadoCalculado end) = 'CANCELADO' and p.NroDiasMaximo >= 31 then 'LIQUIDADO MALO'       
	  when (case when u.secuenciaCliente is null then p.estadocalculado 
				else u.estadoCalculado end) = 'CANCELADO' and u.NroDiasMaximo >= 31 then 'LIQUIDADO MALO'       
	  when (case when u.secuenciaCliente is null then p.estadocalculado 
				else u.estadoCalculado end ) = 'CANCELADO' and u.NroDiasMaximo <= 30 then 'LIQUIDADO BUENO'       
	  when (case when u.secuenciaCliente is null then p.estadocalculado 
				else u.estadoCalculado end ) = 'CANCELADO' and p.NroDiasMaximo <= 30 then 'LIQUIDADO BUENO'  
	  else (case when u.secuenciaCliente is null then p.estadocalculado 
				else u.estadoCalculado end) end estadoActualCliente 
				
,case when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 15 then 'f.C15+'
      when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 10 then 'e.C10-14'
	  when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 5 then 'd-C5-9'       
	  when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) >= 3 then 'c.C3-4'       
	  when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) = 2 then 'b.C2'       
	  when (case when u.secuenciaCliente is null then p.secuenciaCliente else u.secuenciaCliente end) = 1 then 'a.C1'  
	  else '¿?' end rangoCicloMaximo     

--,case when u.estatusPromotor is null then p.estatusPromotor else u.estatusPromotor end estatusProm   
,SUM(p.monto) PrimerMontoOtorgado 
,SUM(case when u.monto is null then p.monto else u.monto end) UltimoMontoOtorgado 
,SUM(case when u.saldoCapital is null then p.saldoCapital else u.saldoCapital end) saldoCapital 
,dbo.fdufechaaperiodo (case when u.desembolso is null then p.desembolso else u.desembolso end) cosechaUlimoDesembolso 
,dbo.fdufechaaperiodo (case when u.cancelacion is null then p.cancelacion else u.cancelacion end) cosechaUltimaLiquidacion 
into #base 
from #Primer p 
left outer join #Ultimo u on p.codusuario=u.codusuario 
group by  dbo.fdufechaaperiodo(p.desembolso) 
,DATEPART(year,p.desembolso) 
,CAST (DATEPART(qq,p.desembolso)as varchar)+'T'+ CAST (DATEPART(year,p.desembolso) as varchar ) 
--,p.sucursal, p.region 
,case when (case when u.secuenciaCliente is null then p.estadocalculado 
					else u.estadoCalculado end) = 'CANCELADO' and p.NroDiasMaximo >= 31 then 'LIQUIDADO MALO'       
	  when (case when u.secuenciaCliente is null then p.estadocalculado 
					else u.estadoCalculado end) = 'CANCELADO' and u.NroDiasMaximo >= 31 then 'LIQUIDADO MALO'       
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
			
--,case when u.estatusPromotor is null then p.estatusPromotor else u.estatusPromotor end   
,dbo.fdufechaaperiodo (case when u.desembolso is null then p.desembolso else u.desembolso end)  
,dbo.fdufechaaperiodo (case when u.cancelacion is null then p.cancelacion else u.cancelacion end)    

          
SET @T2=GETDATE()
PRINT '5 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))
SET @T1=GETDATE()
          
drop table #Ultimo 
drop table #Primer    

select      --------------------- 24 MESES MOSTRADOS 
fechacorte,cast(cosechaGeneracion as varchar )cosechaGeneracion,añoGeneracion 
--,sucursal 
,'Region' region 
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
group by fechacorte,cosechaGeneracion,añoGeneracion--,region 
--order by cosechaGeneracion 
union             
---------- TOTAL DEL LOS REGISTROS MOSTRADOS 
select  fechacorte,'Total General' cosechaGeneracion,1 añoGeneracion --,sucursal 
,'TotalGeneral ' region 
,sum(nroClientes)nroCliNuevos 
,sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end) nroVigentes 
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )nroLiquiBueno 
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end) nroLiquiMalo 
,case when sum(nroClientes)=0 then 0 
		else sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorVigentes 
,case when sum(nroClientes)=0 then 0 
		else sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )/cast(sum(nroClientes)as decimal)*100 end PorBuenosNR 
,case when sum(nroClientes)=0 then 0 
		else sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorMalos 
,sum(ultimoMontoOtorgado)MoNuevo 
,sum(case when estadoActualCliente='VIGENTE' then ultimoMontoOtorgado else 0 end) MoVigentes 
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then ultimoMontoOtorgado else 0 end) MoLiquiBueno 
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then ultimoMontoOtorgado else 0 end) MoLiquiMalo
, 60  ObjetivoVigente  
from #base with(nolock)  
group by fechacorte--,region  ---------TOTAL AL AÑO X SUCURSAL
UNION 
select  fechacorte,'Total Año' cosechaGeneracion, añoGeneracion --,sucursal 
,'Año'region ,sum(nroClientes)nroCliNuevos 
,sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end) nroVigentes 
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )nroLiquiBueno 
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end) nroLiquiMalo 
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='VIGENTE' then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorVigentes 
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente='LIQUIDADO BUENO' then nroClientes else 0 end )/cast(sum(nroClientes)as decimal)*100 end PorBuenosNR 
,case when sum(nroClientes)=0 then 0 else sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then nroClientes else 0 end)/cast(sum(nroClientes)as decimal)*100 end PorMalos 
,sum(ultimoMontoOtorgado)MoNuevo 
,sum(case when estadoActualCliente='VIGENTE' then ultimoMontoOtorgado else 0 end) MoVigentes 
,sum(case when estadoActualCliente='LIQUIDADO BUENO' then ultimoMontoOtorgado else 0 end)MoLiquiBueno 
,sum(case when estadoActualCliente in ('LIQUIDADO MALO','VENCIDO') then ultimoMontoOtorgado else 0 end) MoLiquiMalo 
, 60  ObjetivoVigente  
from #base with(nolock)  
group by fechacorte,añoGeneracion --,region        


          
SET @T2=GETDATE()
PRINT '6 --> ' + CAST(DATEDIFF(MILLISECOND,@T1,@T2) AS VARCHAR(20))
SET @T1=GETDATE()
          
drop table #base 
drop table #sucursales
GO