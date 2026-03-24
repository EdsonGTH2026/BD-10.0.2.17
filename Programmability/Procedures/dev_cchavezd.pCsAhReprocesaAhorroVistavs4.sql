SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dev_cchavezd].[pCsAhReprocesaAhorroVistavs4] @codcuenta varchar(25)--,@fraccioncta varchar(5),@renovado int  
as  
--BEGIN TRAN  
set nocount on  
--declare @codcuenta varchar(25)  
--set @codcuenta='042-105-06-2-2-00209'  
  
declare @fraccioncta varchar(5)  
declare @renovado int  
set @fraccioncta='0'  
set @renovado=0  
  
declare @fmax smalldatetime  
set @fmax='20221130'  
declare @fecini smalldatetime  
select @fecini='20221101'  
  
create table #tcsah(  
 fecha smalldatetime,  
 codcuenta varchar(25),  
 fraccioncta varchar(5),  
 renovado int,  
 fechaapertura smalldatetime,  
 tasainteres money,  
 saldocuenta money,  
 interescalculado money,  
 intacumulado money,  
 capitaliza money,  
 isr money,  
 saldocuenta_x money,  
 calculado_x money,  
 acumulado_x money,   
 capitaliza_x money,   
 isr_x money,  
 deposito money,  
 retiro money  
)  
insert into #tcsah(fecha,codcuenta,fraccioncta,renovado,fechaapertura,tasainteres,saldocuenta,interescalculado,intacumulado)  
select fecha,codcuenta,fraccioncta,renovado,fechaapertura,tasainteres,saldocuenta,interescalculado,intacumulado  
from tcsahorros with(nolock)  
where codcuenta=@codcuenta and fraccioncta=@fraccioncta and renovado=@renovado  
and fecha>=@fecini  
and fecha<=@fmax  
order by fecha  
  
--declare @fecini smalldatetime  
----select @fecini=min(fecha) from #tcsah  
--select @fecini='20210701'  
declare @fecfin smalldatetime  
select @fecfin=max(fecha) from #tcsah  
  
--select fecha,tipotransacnivel1,tipotransacnivel2,tipotransacnivel3,descripciontran,montototaltran  
--from tcstransacciondiaria with(nolock)  
--where codsistema='AH' and extornado=0  
--and codigocuenta=@codcuenta and fraccioncta=@fraccioncta and renovado=@renovado  
--and t.tipotransacnivel3 not in(9,10,11,12,62,15)  
--and fecha>=@fecini and fecha<=@fmax  
  
while (@fecini<=@fecfin)  
begin  
 declare @capitaliza money  
 declare @isr money  
 set @capitaliza=0  
 set @isr=0  
 select @capitaliza=sum(case when tipotransacnivel3=15 then montototaltran else 0 end) --'Capitaliza'  
 ,@isr=sum(case when tipotransacnivel3=62 then montototaltran else 0 end)  
 from tcstransacciondiaria with(nolock)  
 where fecha=@fecini  
 and codsistema='AH' and extornado=0 and montototaltran<>0  
 and tipotransacnivel3 in(15,62) --> 15: capitalizacion y 62: ISR  
 and codigocuenta=@codcuenta and fraccioncta=@fraccioncta and renovado=@renovado  
 group by codigocuenta,fraccioncta,renovado  
   
 declare @deposito money  
 declare @retiro money  
 --select fecha,tipotransacnivel1,tipotransacnivel2,tipotransacnivel3,descripciontran,montototaltran  
 select   
 @deposito=sum(case when tipotransacnivel1='I' and tipotransacnivel3 not in (7) then montototaltran else 0 end) --'Depositos'  
 ,@retiro=sum(case when tipotransacnivel1='E' or (tipotransacnivel1='I' and tipotransacnivel3 in (7)) then montototaltran else 0 end) --'Retiros'  
 from tcstransacciondiaria with(nolock)  
 where codsistema='AH' and extornado=0  
 and codigocuenta=@codcuenta and fraccioncta=@fraccioncta and renovado=@renovado  
 and tipotransacnivel3 not in(9,10,11,12,62,15)  
 and fecha=@fecini --and fecha<=@fmax  
  
 declare @acumulado money  
 declare @capital_ant money  
 declare @calculado_ant money  
 select @acumulado=isnull(acumulado_x,0),@capital_ant=isnull(saldocuenta_x,saldocuenta),@calculado_ant=isnull(calculado_x,0) from #tcsah WHERE fecha=@fecini-1  
    
 UPDATE #tcsah   
 SET saldocuenta_x = @capital_ant + isnull(@deposito,0) - isnull(@retiro,0)  
       ,deposito=@deposito  
       ,retiro=@retiro  
 WHERE fecha=@fecini  
  
 UPDATE #tcsah   
 --SET calculado_x = case when fecha in(select ultimodia from tclperiodo) then @calculado_ant else round((cast(tasainteres as decimal(16,4))/360/100)*saldocuenta,4) end   
 SET calculado_x = round((cast(tasainteres as decimal(16,4))/360/100)*isnull(saldocuenta_x,saldocuenta),4)  
 WHERE fecha=@fecini  
  
 -- ACUMULA LOS INTERESES   
 UPDATE #tcsah   
 set acumulado_x= case when fecha in(select ultimodia from tclperiodo) then 0 else calculado_x+isnull(@acumulado,0) end  
 ,capitaliza=@capitaliza  
 --,capitaliza_x=case when fecha in(select ultimodia from tclperiodo) then @calculado_ant+@acumulado-isnull(@isr,0) else 0 end  
 ,capitaliza_x=case when fecha in(select ultimodia from tclperiodo) then calculado_x + @acumulado else 0 end-- -isnull(@isr,0)  
 ,isr=@isr  
 ,isr_x= case when fecha in(select ultimodia from tclperiodo) then (0.00000222)*day(@fecini)*saldocuenta_x else 0 end  
 WHERE fecha=@fecini  
   
 UPDATE #tcsah   
 SET saldocuenta_x = case when fecha in(select ultimodia from tclperiodo) then saldocuenta_x + capitaliza_x - isr_x else saldocuenta_x end      
 WHERE fecha=@fecini  
  
 set @fecini =dateadd(day,1,@fecini)  
end  
  
--select * from #tcsah  
  
/*este es apra actualizar acumulado*/  
update tcsahorros  
set intacumulado=acumulado_x--,interescalculado=calculado_x  
from tcsahorros a  
inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha  
  
update tcsahorros  
set saldocuenta=saldocuenta_x  
from tcsahorros a  
inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha  
where a.fecha=@fecfin  
  
--select t.fecha,t.montototaltran,t.tipotransacnivel3,a.capitaliza_x---,t.saldocuenta,a.saldocuenta_x-a.isr_x  
update tcstransacciondiaria  
set montototaltran=a.capitaliza_x  
from #tcsah a  
inner join tcstransacciondiaria t with(nolock) on a.codcuenta=t.codigocuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha  
where a.fecha=@fecfin   
and codsistema='AH' and extornado=0 and montototaltran<>0  
and tipotransacnivel3=15 --> 15: capitalizacion   
  
--select t.fecha,t.montototaltran,t.tipotransacnivel3,a.isr_x---,t.saldocuenta_xt.saldocuenta,  
update tcstransacciondiaria  
set montototaltran=a.isr_x  
from #tcsah a  
inner join tcstransacciondiaria t with(nolock) on a.codcuenta=t.codigocuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha  
where a.fecha=@fecfin   
and codsistema='AH' and extornado=0 and montototaltran<>0  
and tipotransacnivel3=62 -->  62: ISR  
  
  
----ACTUALIZA 2.14  
  
--select a.Codcuenta,a.saldocuenta,a.interescalculado,a.intAcumulado,saldocuenta_x,  
--round((cast(t.tasainteres as decimal(16,4))/360/100)*isnull(saldocuenta_x,t.saldocuenta),4)interescalculado_a,  
--(round((cast(t.tasainteres as decimal(16,4))/360/100)*isnull(saldocuenta_x,t.saldocuenta),4))*19 intAcumulado_a  
--UPDATE [10.0.2.14].finmas.dbo.tahcuenta  
--SET saldocuenta=saldocuenta_x  
--,interescalculado = round((cast(t.tasainteres as decimal(16,4))/360/100)*isnull(saldocuenta_x,t.saldocuenta),4)  
--,intAcumulado =(round((cast(t.tasainteres as decimal(16,4))/360/100)*isnull(saldocuenta_x,t.saldocuenta),4))*19  
--from [10.0.2.14].finmas.dbo.tahcuenta a  
--inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado   
--where t.fecha=@fecfin  
  
  
  
----select a.nrotrans,a.codtipotrans,a.fecha,a.observacion,a.montototal,a.saldocta,t.isr_x,t.saldocuenta_x  
  
--UPDATE  [10.0.2.14].finmas.dbo.tahtransaccionmaestra  
--SET montototal=t.isr_x,saldocta=t.saldocuenta_x  
--from [10.0.2.14].finmas.dbo.tahtransaccionmaestra a  
--inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and t.fecha>=@fecfin   
--where a.fecha>=@fecfin and a.fecha<@fecfin+1  
--and a.codsistema='AH'  and a.montototal<>0  
--and a.codtipotrans=62 -->  62: ISR  
   
----select a.nrotrans,a.codtipotrans,a.fecha,a.observacion,a.montototal,a.saldocta,t.capitaliza_x,t.saldocuenta_x+t.isr_x  
--UPDATE  [10.0.2.14].finmas.dbo.tahtransaccionmaestra  
--SET montototal=t.capitaliza_x ,saldocta=t.saldocuenta_x+t.isr_x  
--from [10.0.2.14].finmas.dbo.tahtransaccionmaestra a  
--inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and t.fecha>=@fecfin  
--where  a.fecha>=@fecfin and a.fecha<@fecfin+1  
--and a.codsistema='AH'  and a.montototal<>0  
--and a.codtipotrans=15    
---------------------------------------------VALIDAR  
  
  
--select a.Codcuenta,a.saldocuenta,a.interescalculado,a.intAcumulado  
--from [10.0.2.14].finmas.dbo.tahcuenta a  
--where  codcuenta=@codcuenta  
  
--select a.nrotrans,a.codtipotrans,a.fecha,a.observacion,a.montototal,a.saldocta  
--from [10.0.2.14].finmas.dbo.tahtransaccionmaestra a  
--where a.fecha>=@fecfin and a.fecha<@fecfin+1  
--and a.codsistema='AH'  and a.montototal<>0  
--and a.codtipotrans=62 -->  62: ISR  
--AND codcuenta=@codcuenta  
   
--select a.nrotrans,a.codtipotrans,a.fecha,a.observacion,a.montototal,a.saldocta  
--from [10.0.2.14].finmas.dbo.tahtransaccionmaestra a  
--where  a.fecha>=@fecfin and a.fecha<@fecfin+1  
--and a.codsistema='AH'  and a.montototal<>0  
--and a.codtipotrans=15    
--AND codcuenta=@codcuenta  
  
  
  
/*VALIDAR 2.17*/  
--SELECT A.FECHA,A.intacumulado,A.saldocuenta  
--from tcsahorros a  
--inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha  
  
----select t.fecha,t.montototaltran,t.tipotransacnivel3,a.capitaliza_x---,t.saldocuenta,a.saldocuenta_x-a.isr_x  
--SELECT montototaltran  
--from #tcsah a  
--inner join tcstransacciondiaria t with(nolock) on a.codcuenta=t.codigocuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha  
--where a.fecha=@fecfin   
--and codsistema='AH' and extornado=0 and montototaltran<>0  
--and tipotransacnivel3=15 --> 15: capitalizacion   
  
  
--SELECT montototaltran  
--FROM #tcsah a  
--inner join tcstransacciondiaria t with(nolock) on a.codcuenta=t.codigocuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha  
--where a.fecha=@fecfin   
--and codsistema='AH' and extornado=0 and montototaltran<>0  
--and tipotransacnivel3=62 -->  62: ISR  
  
drop table #tcsah  
  
--ROLLBACK TRAN
GO