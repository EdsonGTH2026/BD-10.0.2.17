SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
    
CREATE procedure [dbo].[pFNPICaCubetasCrecCiclo_QA] @codoficina varchar(2000),@ciclo int     
as      
set nocount on      
declare @fecha smalldatetime      
select @fecha=fechaconsolidacion from vcsfechaconsolidacion    
    
--set @fecha='20210808'        
--declare @codoficina varchar(2000)      
--set @codoficina='15,21,3'    
--declare @ciclo int   
--set @ciclo=2  
      
declare @fecfin smalldatetime      
set @fecfin=@fecha      
declare @fecini smalldatetime      
--set @fecini=cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1      

--------------AJUSTAR @fecini POR: COMO FINALIZA LA CARTERA EL ULTIMO DOMINGO.---ZCCU 2024.06.25
declare @dia varchar(15)  
SELECT @dia = DATENAME(weekday,@FECHA)   -----> Siempre mostrar la cartera del ultimo lunes.  
if @dia = 'Monday'  
 begin  
 set @fecini= @fecha-1
 end  
if @dia = 'Tuesday'  
 begin  
 set @fecini= @fecha-2
 end
if @dia = 'Wednesday'  
 begin  
 set @fecini=@fecha-3
 end
if @dia = 'Thursday'  
 begin  
 set @fecini=@fecha-4
 end
if @dia = 'Friday'  
 begin  
 set @fecini=@fecha-5
 end
if @dia = 'Saturday'  
 begin  
 set @fecini=@fecha-6
 end
if @dia = 'Sunday'  
 begin  
 set @fecini=@fecha-7
 end
------------------------------------------------------------------  
declare @sucursales table(codigo varchar(4))      
insert into @sucursales      
select codigo       
from dbo.fduTablaValores(@codoficina)      
   
declare @ciclo_ini int      
declare @ciclo_fin int      
      
--Ciclo 1,2 y 3      
if(@ciclo in(2,3,4))      
begin      
 set @ciclo_ini=@ciclo-1      
 set @ciclo_fin=@ciclo-1      
end      
--Ciclo 4-10      
if(@ciclo=5)      
begin      
 set @ciclo_ini=4      
 set @ciclo_fin=10      
end      
--Ciclo 11+      
if(@ciclo=6)      
begin      
 set @ciclo_ini=11      
 set @ciclo_fin=999      
end    
    
     
delete from @sucursales where codigo in('98','97','999')      
      
declare @resultado table(item tinyint,fecha smalldatetime,totalsaldo money,D0saldo money,D1a7saldo money      
,D8a15saldo money,D16a30saldo money,D31a60saldo money,D61a89saldo money,D90a120saldo money      
,D121a150saldo money,D151a180saldo money,D181a210saldo money,D211a240saldo money,Dm241saldo money      
,Vig0a30saldo money,Atr31a89saldo money,Ven90msaldo money,Imor30 money,Imor60 money,Imor90 money      
,totalnro int,D0nro int,D1a7nro int      
,D8a15nro int,D16a30nro int,D31a60nro int,D61a89nro int,D90a120nro int      
,D121a150nro int,D151a180nro int,D181a210nro int,D211a240nro int,Dm241nro int      
,Vig0a30nro int,Atr31a89nro int,Ven90mnro int      
)      
insert into @resultado      
select 1 item,fecha      
,sum(totalsaldo) totalsaldo,sum(D0saldo) D0saldo,sum(D1a7saldo) D1a7saldo,sum(D8a15saldo) D8a15saldo,sum(D16a30saldo) D16a30saldo      
,sum(D31a60saldo) D31a60saldo,sum(D61a89saldo) D61a89saldo,sum(D90a120saldo) D90a120saldo,sum(D121a150saldo) D121a150saldo      
,sum(D151a180saldo) D151a180saldo,sum(D181a210saldo) D181a210saldo,sum(D211a240saldo) D211a240saldo,sum(Dm241saldo) Dm241saldo      
,sum(Vig0a30saldo) Vig0a30saldo,sum(Atr31a89saldo) Atr31a89saldo,sum(Ven90msaldo) Ven90msaldo      
,sum(D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241saldo)/cast(sum(totalsaldo) as decimal(16,2))*100 Imor30      
,sum(D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241saldo)/cast(sum(totalsaldo) as decimal(16,2))*100 Imor60      
,sum(D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241saldo)/cast(sum(totalsaldo) as decimal(16,2))*100 Imor90      
      
,sum(totalnro) totalnro,sum(D0nro) D0nro,sum(D1a7nro) D1a7nro,sum(D8a15nro) D8a15nro,sum(D16a30nro) D16a30nro      
,sum(D31a60nro) D31a60nro,sum(D61a89nro) D61a89nro,sum(D90a120nro) D90a120nro,sum(D121a150nro) D121a150nro      
,sum(D151a180nro) D151a180nro,sum(D181a210nro) D181a210nro,sum(D211a240nro) D211a240nro,sum(Dm241nro) Dm241nro      
,sum(Vig0a30nro) Vig0a30nro,sum(Atr31a89nro) Atr31a89nro,sum(Ven90mnro) Ven90mnro      
from FNMGConsolidado.dbo.tCACubetasxSucCiclo with(nolock)      
where fecha=@fecini      
and codoficina in(select codigo from @sucursales)   
and ciclo>=@ciclo_ini and ciclo<=@ciclo_fin    
group by fecha      
union      
select 2 item,fecha      
,sum(totalsaldo) totalsaldo,sum(D0saldo) D0saldo,sum(D1a7saldo) D1a7saldo,sum(D8a15saldo) D8a15saldo,sum(D16a30saldo) D16a30saldo      
,sum(D31a60saldo) D31a60saldo,sum(D61a89saldo) D61a89saldo,sum(D90a120saldo) D90a120saldo,sum(D121a150saldo) D121a150saldo      
,sum(D151a180saldo) D151a180saldo,sum(D181a210saldo) D181a210saldo,sum(D211a240saldo) D211a240saldo,sum(Dm241saldo) Dm241saldo      
,sum(Vig0a30saldo) Vig0a30saldo,sum(Atr31a89saldo) Atr31a89saldo,sum(Ven90msaldo) Ven90msaldo      
,sum(D31a60saldo+D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241saldo)/cast(sum(totalsaldo) as decimal(16,2))*100 Imor30      
,sum(D61a89saldo+D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241saldo)/cast(sum(totalsaldo) as decimal(16,2))*100 Imor60      
,sum(D90a120saldo+D121a150saldo+D151a180saldo+D181a210saldo+D211a240saldo+Dm241saldo)/cast(sum(totalsaldo) as decimal(16,2))*100 Imor90      
      
,sum(totalnro) totalnro,sum(D0nro) D0nro,sum(D1a7nro) D1a7nro,sum(D8a15nro) D8a15nro,sum(D16a30nro) D16a30nro      
,sum(D31a60nro) D31a60nro,sum(D61a89nro) D61a89nro,sum(D90a120nro) D90a120nro,sum(D121a150nro) D121a150nro      
,sum(D151a180nro) D151a180nro,sum(D181a210nro) D181a210nro,sum(D211a240nro) D211a240nro,sum(Dm241nro) Dm241nro      
,sum(Vig0a30nro) Vig0a30nro,sum(Atr31a89nro) Atr31a89nro,sum(Ven90mnro) Ven90mnro      
from FNMGConsolidado.dbo.tCACubetasxSucCiclo with(nolock)      
where fecha=@fecfin      
and codoficina in(select codigo from @sucursales)   
and ciclo>=@ciclo_ini and ciclo<=@ciclo_fin    
group by fecha      
      
if(not exists(select 1 from @resultado where item=1))      
begin      
 insert into @resultado      
 select 1 item,@fecini fecha      
 ,0 totalsaldo,0 D0saldo,0 D1a7saldo,0 D8a15saldo,0 D16a30saldo      
 ,0 D31a60saldo,0 D61a89saldo,0 D90a120saldo,0 D121a150saldo      
 ,0 D151a180saldo,0 D181a210saldo,0 D211a240saldo,0 Dm241saldo      
 ,0 Vig0a30saldo,0 Atr31a89saldo,0 Ven90msaldo      
 ,0 Imor30,0 Imor60,0 Imor90      
 ,0 totalnro,0 D0nro,0 D1a7nro,0 D8a15nro,0 D16a30nro      
 ,0 D31a60nro,0 D61a89nro,0 D90a120nro,0 D121a150nro      
 ,0 D151a180nro,0 D181a210nro,0 D211a240nro,0 Dm241nro      
 ,0 Vig0a30nro,0 Atr31a89nro,0 Ven90mnro      
end      
if(not exists(select 1 from @resultado where item=2))      
begin      
 insert into @resultado      
 select 2 item,@fecfin fecha      
 ,0 totalsaldo,0 D0saldo,0 D1a7saldo,0 D8a15saldo,0 D16a30saldo      
 ,0 D31a60saldo,0 D61a89saldo,0 D90a120saldo,0 D121a150saldo      
 ,0 D151a180saldo,0 D181a210saldo,0 D211a240saldo,0 Dm241saldo      
 ,0 Vig0a30saldo,0 Atr31a89saldo,0 Ven90msaldo      
 ,0 Imor30,0 Imor60,0 Imor90      
 ,0 totalnro,0 D0nro,0 D1a7nro,0 D8a15nro,0 D16a30nro      
 ,0 D31a60nro,0 D61a89nro,0 D90a120nro,0 D121a150nro      
 ,0 D151a180nro,0 D181a210nro,0 D211a240nro,0 Dm241nro      
 ,0 Vig0a30nro,0 Atr31a89nro,0 Ven90mnro      
end      
      
insert into @resultado      
select 3 item,null fecha      
,a.totalsaldo-b.totalsaldo,a.D0saldo-b.D0saldo,a.D1a7saldo-b.D1a7saldo,a.D8a15saldo-b.D8a15saldo,a.D16a30saldo-b.D16a30saldo      
,a.D31a60saldo-b.D31a60saldo,a.D61a89saldo-b.D61a89saldo,a.D90a120saldo-b.D90a120saldo,a.D121a150saldo-b.D121a150saldo      
,a.D151a180saldo-b.D151a180saldo,a.D181a210saldo-b.D181a210saldo,a.D211a240saldo-b.D211a240saldo,a.Dm241saldo-b.Dm241saldo      
,a.Vig0a30saldo-b.Vig0a30saldo,a.Atr31a89saldo-b.Atr31a89saldo,a.Ven90msaldo-b.Ven90msaldo      
,a.Imor30-b.Imor30,a.Imor60-b.Imor60,a.Imor90-b.Imor90      
,a.totalnro-b.totalnro,a.D0nro-b.D0nro,a.D1a7nro-b.D1a7nro,a.D8a15nro-b.D8a15nro,a.D16a30nro-b.D16a30nro      
,a.D31a60nro-b.D31a60nro,a.D61a89nro-b.D61a89nro,a.D90a120nro-b.D90a120nro,a.D121a150nro-b.D121a150nro      
,a.D151a180nro-b.D151a180nro,a.D181a210nro-b.D181a210nro,a.D211a240nro-b.D211a240nro,a.Dm241nro-b.Dm241nro      
,a.Vig0a30nro-b.Vig0a30nro,a.Atr31a89nro-b.Atr31a89nro,a.Ven90mnro-b.Ven90mnro      
from @resultado a      
cross join (select * from @resultado where item=1) b       
where a.item=2      
      
select * from @resultado 
GO