SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCACartaLN_Metas] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on
/*
--COMENTAR
Declare @fecha smalldatetime
declare @codoficina varchar(4)

set @fecha='20180515'
set @codoficina='37'
*/


Declare @fecini smalldatetime
Declare @fecini2 smalldatetime
Declare @fecano smalldatetime

declare @ncreBM decimal(8,2)
declare @ncreAM decimal(8,2)

set @fecha = convert(varchar,@fecha,112)
set @fecini = dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'
set @fecano = dbo.fdufechaatexto(dateadd(year,-1,@fecha),'AAAAMM')+'01'

set @fecini2 = dateadd(day,-1,@fecini)

--#################################################### META
PRINT '#####################################################################################'
PRINT '##################################### METAS ######################################'

--Limpia la tabla
delete from tCsRptEMI_LS_Metas where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina --order by item


create table #Metas (
	item int,
	Indicador varchar(30),
	Meta varchar(100),
	BonoAlcanzable varchar(20),
	PorcBonoAlcanzado varchar(20),
	BonoFinal varchar(20),
)

--select * from #Metas

--++++++++++++++++++ CRECIMIENTO DE CARTERA ++++++++++++++++++
declare @SCBM_INI money
declare @CrecimientoClientes int
declare @CrecimientoMeta varchar(30)
declare @CrecimientoPorcBonoAlcanzable money
declare @CrecimientoBonoAlcanzable money
declare @CrecimientoBonoFinal money

select @SCBM_INI = convert(money,InicioMes) from tCsRptEMI_LS_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina and item = 1
set @CrecimientoClientes = 20 --??definir de donde sale

if @SCBM_INI < 2000000 
	begin 
		set @CrecimientoMeta = (select case 
					when @CrecimientoClientes >= 30 and @CrecimientoClientes <= 34 then '30 a 34 clientes'
					when @CrecimientoClientes >= 35 and @CrecimientoClientes <= 39 then '35 a 39 clientes'
					when @CrecimientoClientes >= 40 and @CrecimientoClientes <= 44 then '40 a 44 clientes'
					when @CrecimientoClientes >= 45 and @CrecimientoClientes <= 49 then '45 a 49 clientes'
					when @CrecimientoClientes >= 50 and @CrecimientoClientes <= 54 then '50 a 54 clientes'
					when @CrecimientoClientes >= 55 then 'Mas de 55 clientes'
					end ) 
		set @CrecimientoPorcBonoAlcanzable = (select case 
					when @CrecimientoClientes >= 30 and @CrecimientoClientes <= 34 then 70
					when @CrecimientoClientes >= 35 and @CrecimientoClientes <= 39 then 100
					when @CrecimientoClientes >= 40 and @CrecimientoClientes <= 44 then 110
					when @CrecimientoClientes >= 45 and @CrecimientoClientes <= 49 then 120
					when @CrecimientoClientes >= 50 and @CrecimientoClientes <= 54 then 130
					when @CrecimientoClientes >= 55 then 140
					end )
	end
if @SCBM_INI >= 2000000 and @SCBM_INI < 3000000 
	begin
		set @CrecimientoMeta = (select case 
					when @CrecimientoClientes >= 20 and @CrecimientoClientes <= 24 then '20 a 24 clientes'
					when @CrecimientoClientes >= 25 and @CrecimientoClientes <= 29 then '25 a 29 clientes'
					when @CrecimientoClientes >= 30 and @CrecimientoClientes <= 34 then '30 a 35 clientes'
					when @CrecimientoClientes >= 35 and @CrecimientoClientes <= 39 then '35 a 39 clientes'
					when @CrecimientoClientes >= 40 and @CrecimientoClientes <= 44 then '40 a 44 clientes'
					when @CrecimientoClientes >= 45 then 'Mas de 45 clientes'
					end )
		set @CrecimientoPorcBonoAlcanzable = (select case 
					when @CrecimientoClientes >= 20 and @CrecimientoClientes <= 24 then 70
					when @CrecimientoClientes >= 25 and @CrecimientoClientes <= 29 then 100
					when @CrecimientoClientes >= 30 and @CrecimientoClientes <= 34 then 110
					when @CrecimientoClientes >= 35 and @CrecimientoClientes <= 39 then 120
					when @CrecimientoClientes >= 40 and @CrecimientoClientes <= 44 then 130
					when @CrecimientoClientes >= 45 then 140
					end )
	end
if @SCBM_INI >= 3000000 and @SCBM_INI < 4000000 
	begin
		set @CrecimientoMeta = (select case 
					when @CrecimientoClientes >= 15 and @CrecimientoClientes <= 19 then '15 a 19 clientes'
					when @CrecimientoClientes >= 20 and @CrecimientoClientes <= 24 then '20 a 24 clientes'
					when @CrecimientoClientes >= 25 and @CrecimientoClientes <= 29 then '25 a 29 clientes'
					when @CrecimientoClientes >= 30 and @CrecimientoClientes <= 34 then '30 a 34 clientes'
					when @CrecimientoClientes >= 35 and @CrecimientoClientes <= 39 then '35 a 39 clientes'
					when @CrecimientoClientes >= 40 then 'Mas de 40 clientes'
					end )
		set @CrecimientoPorcBonoAlcanzable = (select case 
					when @CrecimientoClientes >= 15 and @CrecimientoClientes <= 19 then 70
					when @CrecimientoClientes >= 20 and @CrecimientoClientes <= 24 then 100
					when @CrecimientoClientes >= 25 and @CrecimientoClientes <= 29 then 110
					when @CrecimientoClientes >= 30 and @CrecimientoClientes <= 34 then 120
					when @CrecimientoClientes >= 35 and @CrecimientoClientes <= 39 then 130
					when @CrecimientoClientes >= 40 then 140
					end )
	end
if @SCBM_INI >= 4000000 
	begin
		set @CrecimientoMeta = (select case 
					when @CrecimientoClientes >= 10 and @CrecimientoClientes <= 14 then '10 a 14 clientes'
					when @CrecimientoClientes >= 15 and @CrecimientoClientes <= 20 then '15 a 20 clientes'
					when @CrecimientoClientes >= 21 and @CrecimientoClientes <= 24 then '21 a 24 clientes'
					when @CrecimientoClientes >= 25 and @CrecimientoClientes <= 29 then '25 a 29 clientes'
					when @CrecimientoClientes >= 30 then 'Mas de 30 Clientes'
					end )
		set @CrecimientoPorcBonoAlcanzable = (select case 
					when @CrecimientoClientes >= 10 and @CrecimientoClientes <= 14 then 70
					when @CrecimientoClientes >= 15 and @CrecimientoClientes <= 20 then 100
					when @CrecimientoClientes >= 21 and @CrecimientoClientes <= 24 then 110
					when @CrecimientoClientes >= 25 and @CrecimientoClientes <= 29 then 120
					when @CrecimientoClientes >= 30 then 140
					end )
	end

--calcula bono alcanzable
set @CrecimientoBonoAlcanzable = (@SCBM_INI * 0.001665)
--calcula bono final
set @CrecimientoBonoFinal = @CrecimientoBonoAlcanzable * (@CrecimientoPorcBonoAlcanzable /100)

insert into #Metas (item, Indicador, Meta, BonoAlcanzable, PorcBonoAlcanzado, BonoFinal )
select 
1, 'Crecimiento de Cartera',@CrecimientoMeta, convert(varchar,@CrecimientoBonoAlcanzable), convert(varchar,@CrecimientoPorcBonoAlcanzable), convert(varchar,@CrecimientoBonoFinal)

--obtiene los valores
--select @ncreBM = InicioMes from tCsRptEMI_LS_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina and item = 3
--select @ncreAM = InicioMes from tCsRptEMI_LS_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina and item = 4

--select @ncreBM as '@ncreBM', @ncreAM as '@ncreAM'  --borrar



--+++++++++++++++ CALIDAD DE CARTERA ++++++++++++++++++
declare @SumCer4Saldo money
declare @SumCer4Num money
declare @PromCer4Saldo money
declare @PromCer4Num money
declare @CalidadMetaSaldo varchar(30)
declare @CalidadMetaNum varchar(30)
declare @CalidadBonoAlcanzable money

declare @CalidadPorcBonoAlcanzable money
declare @CalidadBonoFinal money

--Obtiene la sumatoria del Saldo Cer@4
select @SumCer4Saldo =
(case when isnumeric(m1) =1 then convert(money,m1) else 0.0 end) +(case when isnumeric(m2) =1 then convert(money,m2) else 0.0 end) + (case when isnumeric(m3) =1 then convert(money,m3) else 0.0 end) +  
(case when isnumeric(m4) =1 then convert(money,m4) else 0.0 end) +(case when isnumeric(m5) =1 then convert(money,m5) else 0.0 end) + (case when isnumeric(m6) =1 then convert(money,m6) else 0.0 end) +  
(case when isnumeric(m7) =1 then convert(money,m7) else 0.0 end) +(case when isnumeric(m8) =1 then convert(money,m8) else 0.0 end) + (case when isnumeric(m9) =1 then convert(money,m9) else 0.0 end) +  
(case when isnumeric(m10) =1 then convert(money,m10) else 0.0 end) +(case when isnumeric(m11) =1 then convert(money,m11) else 0.0 end) + (case when isnumeric(m12) =1 then convert(money,m12) else 0.0 end)   
from tCsRptEMI_LS_CarteraRiesgo 
where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina and item = 1
--Obtiene la sumatoria del Numero Cer@4
select @SumCer4Num =
(case when isnumeric(m1) =1 then convert(money,m1) else 0.0 end) +(case when isnumeric(m2) =1 then convert(money,m2) else 0.0 end) + (case when isnumeric(m3) =1 then convert(money,m3) else 0.0 end) +  
(case when isnumeric(m4) =1 then convert(money,m4) else 0.0 end) +(case when isnumeric(m5) =1 then convert(money,m5) else 0.0 end) + (case when isnumeric(m6) =1 then convert(money,m6) else 0.0 end) +  
(case when isnumeric(m7) =1 then convert(money,m7) else 0.0 end) +(case when isnumeric(m8) =1 then convert(money,m8) else 0.0 end) + (case when isnumeric(m9) =1 then convert(money,m9) else 0.0 end) +  
(case when isnumeric(m10) =1 then convert(money,m10) else 0.0 end) +(case when isnumeric(m11) =1 then convert(money,m11) else 0.0 end) + (case when isnumeric(m12) =1 then convert(money,m12) else 0.0 end)   
from tCsRptEMI_LS_CarteraRiesgo 
where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina and item = 2

set @PromCer4Saldo = @SumCer4Saldo/12
set @PromCer4Num = @SumCer4Num/12
--select @SumCer4Saldo as '@SumCer4Saldo', @SumCer4Num as '@SumCer4Num'
--select @PromCer4Saldo as '@PromCer4Saldo', @PromCer4Num as '@PromCer4Num'

set @CalidadMetaSaldo = 'CER@4 en saldo' --+ convert(varchar,@PromCer4Saldo) 
set @CalidadMetaNum = 'CER@4 en número' --+ convert(varchar,@PromCer4Num) 

if @PromCer4Num <= 4
begin
	set @CalidadMetaNum = @CalidadMetaNum + ' - EXCELENTE'

	if @PromCer4Saldo <= 4
	begin		
		set @CalidadMetaSaldo = @CalidadMetaSaldo + ' - EXCELENTE'
		set @CalidadPorcBonoAlcanzable = 120
	end
	if @PromCer4Saldo > 4 and @PromCer4Saldo <= 6
	begin
		set @CalidadMetaSaldo = @CalidadMetaSaldo + ' - ACEPTABLE'
		set @CalidadPorcBonoAlcanzable = 75
	end
	if @PromCer4Saldo > 6
	begin
		set @CalidadMetaSaldo = @CalidadMetaSaldo + ' - NO ACEPTABLE'
		set @CalidadPorcBonoAlcanzable = 25
	end
end

if @PromCer4Num > 4 and @PromCer4Num <= 6
begin
	set @CalidadMetaNum = @CalidadMetaNum + ' - ACEPTABLE'

	if @PromCer4Saldo <= 4
	begin		
		set @CalidadMetaSaldo = @CalidadMetaSaldo + ' - EXCELENTE'
		set @CalidadPorcBonoAlcanzable = 100
	end
	if @PromCer4Saldo > 4 and @PromCer4Saldo <= 6
	begin
		set @CalidadMetaSaldo = @CalidadMetaSaldo + ' - ACEPTABLE'
		set @CalidadPorcBonoAlcanzable = 50
	end
	if @PromCer4Saldo > 6
	begin
		set @CalidadMetaSaldo = @CalidadMetaSaldo + ' - NO ACEPTABLE'
		set @CalidadPorcBonoAlcanzable = 0
	end
end

if @PromCer4Num > 6
begin
	set @CalidadMetaNum = @CalidadMetaNum + ' - EXCELENTE'

	if @PromCer4Saldo <= 4
	begin		
		set @CalidadMetaSaldo = @CalidadMetaSaldo + ' - EXCELENTE'
		set @CalidadPorcBonoAlcanzable = 50
	end
	if @PromCer4Saldo > 4 and @PromCer4Saldo <= 6
	begin
		set @CalidadMetaSaldo = @CalidadMetaSaldo + ' - ACEPTABLE'
		set @CalidadPorcBonoAlcanzable = 25
	end
	if @PromCer4Saldo > 6
	begin
		set @CalidadMetaSaldo = @CalidadMetaSaldo + ' - NO ACEPTABLE'
		set @CalidadPorcBonoAlcanzable = 0
	end
end

--calcula bono alcanzable
set @CalidadBonoAlcanzable = @SCBM_INI * 0.00148
--calcula bono final
set @CalidadBonoFinal = @CalidadBonoAlcanzable * (@CalidadPorcBonoAlcanzable /100)

insert into #Metas (item, Indicador, Meta, BonoAlcanzable, PorcBonoAlcanzado, BonoFinal )
select 
2, 'Calidad de Cartera',@CalidadMetaSaldo + ' y '+ @CalidadMetaNum , convert(varchar,@CalidadBonoAlcanzable), convert(varchar,@CalidadPorcBonoAlcanzable), convert(varchar, @CalidadBonoFinal)

--+++++++++++++++++ PASO A ALTA MORA ++++++++++++++++++
declare @PasoAMBonoAlcanzable money
declare @PasoAMPorcentaje money
declare @PasoAMPorcBonoAlcanzable money
declare @PasoAMBonoFinal money

declare @NCBM_Ini money
declare @NCAM_Ini money
declare @NCAM_Hoy money

select @NCBM_Ini = convert(money,InicioMes) 
from tCsRptEMI_LS_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina and item = 3

select @NCAM_Ini = convert(money,InicioMes), @NCAM_Hoy = convert(money,Hoy)  
from tCsRptEMI_LS_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodOficina = @codoficina and item = 4

--% P.A.M = (#CAM Hoy - #CAM inicio ) / #CBM inicio mes
set @PasoAMPorcentaje= (@NCAM_Hoy - @NCAM_Ini) / @NCBM_Ini

--select @NCBM_Ini as '@NCBM_Ini', @NCAM_Ini as '@NCAM_Ini', @NCAM_Hoy as '@NCAM_Hoy', @PasoAMPorcentaje as '@PasoAMPorcentaje' --comentar

--determina el % del bono
select @PasoAMPorcBonoAlcanzable = (case 
		when @PasoAMPorcentaje < 0 then 120 
		when @PasoAMPorcentaje >= 0 and @PasoAMPorcentaje <= 1 then 100
		when @PasoAMPorcentaje > 1 and @PasoAMPorcentaje <= 2  then 50
		else 0
		end)
--select @PasoAMPorcBonoAlcanzable as '@PasoAMPorcentajeBono'  --comentar

--calcula bono alcanzable
set @PasoAMBonoAlcanzable = @SCBM_INI * 0.000185
--calcula bono final
set @PasoAMBonoFinal = @PasoAMBonoAlcanzable * (@PasoAMPorcBonoAlcanzable /100)

insert into #Metas (item, Indicador, Meta, BonoAlcanzable, PorcBonoAlcanzado, BonoFinal )
select 
3, 'Paso a Alta Mora','MENOR A 1%',convert(varchar,@PasoAMBonoAlcanzable), convert(varchar,@PasoAMPorcBonoAlcanzable), convert(varchar, @PasoAMBonoFinal)

--+++++++++++++++++ RENOVACIONES ++++++++++++++++++
declare @RenovacionesBonoAlcanzable money
declare @RenovacionesBonoFinal money
declare @RenovacionesPorcBonoAlcanzable money
declare @RenovacionesPorcRenCosecha money

select top 1 @RenovacionesPorcRenCosecha = PorReno from tCsRptEMI_LS_Cosecha where Fecha = convert(varchar,@fecha,112) and CodOficina = @codoficina order by periodo desc

select 
@RenovacionesPorcBonoAlcanzable = (case
									when @RenovacionesPorcRenCosecha >= 60 and @RenovacionesPorcRenCosecha < 70 then 70
									when @RenovacionesPorcRenCosecha >= 70 and @RenovacionesPorcRenCosecha < 80 then 100
									when @RenovacionesPorcRenCosecha >= 80 and @RenovacionesPorcRenCosecha < 90 then 110
									when @RenovacionesPorcRenCosecha >= 90 then 120
									else 0
									end)
--select @RenovacionesPorcRenCosecha as '@RenovacionesPorcRenCosecha', @RenovacionesPorcBonoAlcanzable as '@RenovacionesPorcBonoAlcanzable' --comentar

--calcula bono alcanzable
set @RenovacionesBonoAlcanzable = @SCBM_INI * 0.00037
--calcula bono final
set @RenovacionesBonoFinal = @RenovacionesBonoAlcanzable * (@RenovacionesPorcBonoAlcanzable /100)

insert into #Metas (item, Indicador, Meta, BonoAlcanzable, PorcBonoAlcanzado, BonoFinal )
select 
4, 'Renovaciones','MÁS 70%',convert(varchar,@RenovacionesBonoAlcanzable), convert(varchar,@RenovacionesPorcBonoAlcanzable), convert(varchar, @RenovacionesBonoFinal)


insert into tCsRptEMI_LS_Metas (Fecha,CodOficina, item, Indicador, Meta, BonoAlcanzable, PorcBonoAlcanzado, BonoFinal )
select  convert(varchar,@fecha,112), @codoficina, item, Indicador, Meta, BonoAlcanzable, PorcBonoAlcanzado, BonoFinal from #Metas

--regresa los datos
--select * from tCsRptEMI_LS_Metas

--drop table #Met
drop table #Metas











GO