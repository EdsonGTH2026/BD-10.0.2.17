SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsAhReprocesaAhorroVistavs3] @codcuenta varchar(25)--,@fraccioncta varchar(5),@renovado int
as
set nocount on
--declare	@codcuenta varchar(25)
--set @codcuenta='003-105-06-2-2-03596'

declare	@fraccioncta varchar(5)
declare @renovado int
set @fraccioncta='0'
set @renovado=0

declare @fmax smalldatetime
set @fmax='20220510'
declare @fecini smalldatetime
select @fecini='20220401'

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
	saldocuenta_x money,
	calculado_x money,
	acumulado_x money,	
	capitaliza_x money,
	isr money,
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
	select @acumulado=isnull(acumulado_x,0),@capital_ant=saldocuenta,@calculado_ant=isnull(calculado_x,0) from #tcsah WHERE fecha=@fecini-1
	
	UPDATE #tcsah 
	SET calculado_x = case when fecha in(select ultimodia from tclperiodo) then @calculado_ant else round((cast(tasainteres as decimal(16,4))/360/100)*saldocuenta,4) end	
	WHERE fecha=@fecini

	-- ACUMULA LOS INTERESES 
	UPDATE #tcsah 
	set acumulado_x= case when fecha in(select ultimodia from tclperiodo) then 0 else calculado_x+isnull(@acumulado,0) end
	,capitaliza=@capitaliza
	,capitaliza_x=case when fecha in(select ultimodia from tclperiodo) then @calculado_ant+@acumulado-isnull(@isr,0) else 0 end
	,isr=@isr
	WHERE fecha=@fecini
	
	UPDATE #tcsah 
	SET saldocuenta_x = isnull(@capital_ant,saldocuenta) + capitaliza_x +
							(case when fecha in(select ultimodia from tclperiodo) then isnull(@deposito,0)-isnull(@retiro,0) else 0 end)
							,deposito=@deposito
							,retiro=@retiro
	WHERE fecha=@fecini

	set @fecini =dateadd(day,1,@fecini)
end

--select * from #tcsah

update tcsahorros
set intacumulado=acumulado_x,interescalculado=calculado_x
from tcsahorros a
inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha

--update tcsahorros
--set saldocuenta=saldocuenta_x
--from tcsahorros a
--inner join #tcsah t on a.codcuenta=t.codcuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha
--where a.fecha=@fecfin

--select t.fecha,t.montototaltran,t.tipotransacnivel3,a.capitaliza_x
----update tcstransacciondiaria
----set montototaltran=a.capitaliza_x
--from #tcsah a
--inner join tcstransacciondiaria t with(nolock) on a.codcuenta=t.codigocuenta and a.fraccioncta=t.fraccioncta and a.renovado=t.renovado and a.fecha=t.fecha
--where a.fecha=@fecfin 
--and codsistema='AH' and extornado=0 and montototaltran<>0
--and tipotransacnivel3=15 --> 15: capitalizacion y 62: ISR

drop table #tcsah

GO