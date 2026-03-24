SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
  
 /*---calculo para el reporte diario---*/  
 --Gastos x intereses//comisiones y tarifas cobradas// ingresos por intereses  
   
CREATE procedure [dev_cchavezd].[pCs_cteraInteres] @fecha smalldatetime        
as       
set nocount on   
  
--declare @fecha smalldatetime  ---LA FECHA DE CORTE  
--set @fecha='20221130'   
    
declare @fecini smalldatetime  
set @fecini = cast(dbo.fdufechaaperiodo(@fecha)+'01'as smalldatetime)-- Fecha inicio de mes '20220201'  
    
    
---Interes devengado Ahorro    
 declare @devAh table  (  
          fecha smalldatetime,  
          devengado money  
)  
insert into @devAh  
select @fecha fecha  
,sum(case when InteresCalculado<0 then 0  
     else case when fechavencimiento is null then InteresCalculado  
          else case when fecha<fechavencimiento then InteresCalculado else 0 end end end) devengado  
from tcsahorros a with(nolock)  
where a.fecha>=@fecini --> fecha de inicio mes--'20220201'  
and a.fecha<=@fecha --> fecha de consulta--'20220209'  
  
          
-----------Comisiones Cobradas y pagadas     
declare @Co table  (  
          fecha smalldatetime,  
          cargos money,  
          seguros money,  
         cargoReest money  
)  
insert into @Co  
select @fecha  
,sum(montocargos) cargos  
,sum(MontoOtrosTran) seguros  
,sum(montoinvetran) cargo  
from tcstransacciondiaria with(nolock)  
where fecha>=@fecini and fecha<=@fecha  
and codsistema='CA' and tipotransacnivel3 in(104,105) and extornado=0  
and codoficina not in('97','231','230','999')  
   
 -------------------- Interes devengado Crédito  
declare @devCtera table(fecha smalldatetime,intDevTotal money)  
insert into @devCtera  
select @fecha fecha,sum(t.interesdevengado) intDevTotal  
from tcscarteradet t with(nolock)  
inner join tcscartera c with(nolock) on c.fecha=t.fecha and c.codprestamo=t.codprestamo  
inner join tcspadroncarteradet p with(nolock) on p.CodPrestamo=c.CodPrestamo  
where c.NroDiasAtraso<=89 and c.codoficina not in('97','231','230','999') and c.estado='VIGENTE'  
and t.fecha>=@fecini   
and t.fecha<=@fecha   
   
--create table #prev(fecha smalldatetime,cargos money,seguros money, devengadoAh money,intDevCred money)  
select t.fecha,cargos,seguros,cargoReest,devengado,intDevTotal  
from @Co t   
left outer join @devAh d on d.fecha=t.fecha  
left outer join @devCtera c on c.fecha=t.fecha  
  
   
GO