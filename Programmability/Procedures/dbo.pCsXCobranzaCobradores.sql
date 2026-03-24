SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- pCsXCobranzaCobradores '3','','','ACTIVA',60,0      
CREATE procedure [dbo].[pCsXCobranzaCobradores] @codoficina varchar(3), @cliente varchar(30),@codprestamo varchar(20),@CA varchar(15),@diaslim int,@diasmax int      
as      
set nocount on      
 --comentar      
 /*      
 declare @codoficina varchar(1000)      
 declare @cliente varchar(30)      
 declare @codprestamo varchar(20)      
 declare @CA varchar(15)      
 declare @diaslim int      
 declare @diasmax int      
      
 set @codoficina = '301'    
 set @cliente = ''      
 set @codprestamo = ''      
 set @CA='ACTIVA'      
 set @diaslim=30      
 set @diasmax=200      
  */     
 if (@cliente <> '') set @cliente = '%' + @cliente + '%'      
 if (@codprestamo <> '') set @codprestamo = '%' + @codprestamo + '%'      
 if (@CA='') set @CA='ACTIVA'      
       
 declare @fechaProceso smalldatetime      
 Select @fechaProceso = FechaConsolidacion From vCsFechaConsolidacion     
   
select c.fecha, c.CodPrestamo, c.Estado,c.CodOficina, c.CodProducto,      
c.CodUsuario,c.FechaDesembolso, c.FechaVencimiento, c.MontoDesembolso,c.NroDiasAtraso
, c.SaldoCapital,c.ModalidadPlazo, c.NroCuotas,c.CuotaActual, c.NroCuotasPagadas, c.NroCuotasPorPagar,cartera   
into   #ptmos
from dbo.tCsCartera c with(nolock)   
--from #ptmos c with(nolock)         
where c.fecha = @fechaProceso --and c.Estado = 'VENCIDO'      
and ((c.CodPrestamo like @codprestamo and @codprestamo <> '') or (c.CodPrestamo = c.CodPrestamo and @codprestamo = ''))      
and c.codoficina not in(230,231)      
and c.codoficina in(select codigo from dbo.fduTablaValores(@codoficina))    
and c.cartera=@CA      
and c.NroDiasAtraso>=@diaslim   --- SE CORRIGE A LIMITES CORRECTOS  ZCCU 2023.05.30    
and c.NroDiasAtraso<@diasmax 
    
---  /*se crea tabla temporal para optimizar*/ ZCCU 2023.05.30    
create table #cap (codprestamo varchar(30),saldoatrasado money)  
insert into #cap  
select codprestamo,sum(case when codconcepto='CAPI' then case when fechainicio<@fechaProceso--'20180416'       
     then montodevengado-montopagado-montocondonado else 0 end      
else montodevengado-montopagado-montocondonado end) saldoatrasado      
--select top 10*
from tcspadronplancuotas with(nolock)      
where estadocuota<>'CANCELADO' and codprestamo in (select codprestamo from #ptmos with(nolock))
group by codprestamo      
   
    
  
  
select c.fecha, c.CodPrestamo, c.Estado,c.CodOficina, c.CodProducto,      
c.CodUsuario, pc.NombreCompleto as Cliente,      
c.FechaDesembolso, c.FechaVencimiento, c.MontoDesembolso,      
c.NroDiasAtraso, c.SaldoCapital,c.ModalidadPlazo, c.NroCuotas,       
c.CuotaActual, c.NroCuotasPagadas, c.NroCuotasPorPagar,      
pc.CodUbiGeoDirFamPri, pc.DireccionDirFamPri,  pc.NumExtFam,  pc.NumIntFam,  pc.TelefonoDirFamPri, pc.CodPostalFam,      
vuc.Colonia, vuc.Municipio, vuc.estado      
,cc.saldoatrasado,d.saldocapital+d.interesvigente+d.interesvencido+d.interesctaorden+d.moratoriovencido+d.moratoriovigente+d.moratorioctaorden+d.impuestos+d.cargomora+d.otroscargos deuda      
--from dbo.tCsCartera c with(nolock)   
from #ptmos c with(nolock)         
inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo      
inner join tCsPadronClientes pc with(nolock) on pc.CodUsuario =  c.CodUsuario      
inner join vCsUbigeoColonia vuc with(nolock) on vuc.CodUbiGeo = pc.CodUbiGeoDirFamPri    
inner join #cap cc on cc.codprestamo=c.codprestamo      
where c.fecha = @fechaProceso --and c.Estado = 'VENCIDO'      
--and ((c.CodPrestamo like @codprestamo and @codprestamo <> '') or (c.CodPrestamo = c.CodPrestamo and @codprestamo = ''))      
--and c.codoficina not in(230,231)      
--and c.codoficina in(select codigo from dbo.fduTablaValores(@codoficina))    
--and c.cartera=@CA      
--and c.NroDiasAtraso>=@diaslim   --- SE CORRIGE A LIMITES CORRECTOS  ZCCU 2023.05.30    
--and c.NroDiasAtraso<@diasmax      
and ((pc.NombreCompleto like @cliente and @cliente <> '') or (pc.NombreCompleto = pc.NombreCompleto and @cliente = ''))      
order by c.NroDiasAtraso desc      
  
drop table #cap  
drop table #ptmos  
GO