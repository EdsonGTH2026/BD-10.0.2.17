SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCaRptCartaBonosColocacion] (@codpromotor varchar(20), @fecha smalldatetime)
as
BEGIN
set nocount on

--declare @codpromotor varchar(20)
--set @codpromotor = 'SRJ910416M0416'

create table #Colocacion(
S1_periodo varchar(20) null,
S1_nuevo_nro int null,
S1_nuevo_monto money null,
S1_renov_nro int null,
S1_renov_monto money null,
S1_react_nro int null,
S1_react_monto money null,

S2_periodo varchar(20) null,
S2_nuevo_nro int null,
S2_nuevo_monto money null,
S2_renov_nro int null,
S2_renov_monto money null,
S2_react_nro int null,
S2_react_monto money null,

S3_periodo varchar(20) null,
S3_nuevo_nro int null,
S3_nuevo_monto money null,
S3_renov_nro int null,
S3_renov_monto money null,
S3_react_nro int null,
S3_react_monto money null,

S4_periodo varchar(20) null,
S4_nuevo_nro int null,
S4_nuevo_monto money null,
S4_renov_nro int null,
S4_renov_monto money null,
S4_react_nro int null,
S4_react_monto money null,

Total_Nro int null,
Total_Monto money null
)

declare @FechaInicial smalldatetime
declare @FechaSemana1 smalldatetime
declare @FechaSemana2 smalldatetime
declare @FechaSemana3 smalldatetime
declare @FechaSemana4 smalldatetime

--select @FechaInicial = cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1
--select @FechaSemana1 = cast(dbo.fdufechaaperiodo(@fecha)+'07' as smalldatetime)  --semana 1
--select @FechaSemana2 = cast(dbo.fdufechaaperiodo(@fecha)+'15' as smalldatetime)  --mitad de mes
--select @FechaSemana3 = cast(dbo.fdufechaaperiodo(@fecha)+'22' as smalldatetime)  --semana 3
--select @FechaSemana4 = cast(dbo.fdufechaaperiodo(dateadd(m,1,@fecha)) + '01' as smalldatetime) -1

select @FechaInicial = dbo.fdufechaaperiodo(@fecha) + '01', @FechaSemana1 = FecFinSem1, @FechaSemana2 = FecFinSem2, @FechaSemana3 = FecFinSem3, @FechaSemana4 = FecFinSem4    
from tCsCaRptCartaBonosFechas where periodo = dbo.fdufechaaperiodo(@fecha)

declare @co_reno_nro int
declare @co_reno_monto money
declare @co_reac_nro int
declare @co_reac_monto money
declare @co_nuev_nro int
declare @co_nuev_monto money
--Crear tabla temporal
create table #co(nro int,monto money, tipo varchar(15))

--============= semana 1
truncate table #co
insert into #co 
exec pXaCAColocionCartaPromotor @codpromotor,@FechaInicial,@FechaSemana1
--exec pXaCAColocionCartaPromotor 'GCC3012991','20190501','20190505'
--select * from #colocacion

set @co_reno_nro=0
set @co_reno_monto=0
set @co_reac_nro=0
set @co_reac_monto=0
set @co_nuev_nro=0
set @co_nuev_monto=0

select @co_reno_nro=nro from #co where tipo='RENOVACION'
select @co_reno_monto=monto from #co where tipo='RENOVACION'
select @co_reac_nro=nro from #co where tipo='REACTIVACION'
select @co_reac_monto=monto from #co where tipo='REACTIVACION'
select @co_nuev_nro=nro from #co where tipo='NUEVO'
select @co_nuev_monto=monto from #co where tipo='NUEVO'

insert into #Colocacion (S1_periodo,S1_nuevo_nro,S1_nuevo_monto,S1_renov_nro,S1_renov_monto,S1_react_nro,S1_react_monto) 
values (
( right('0'+convert(varchar,datepart(dd,@FechaInicial)),2) +'/'+ right('0'+convert(varchar,datepart(mm,@FechaInicial)),2)) + ' al ' +
( right('0'+convert(varchar,datepart(dd,@FechaSemana1)),2) +'/'+ right('0'+convert(varchar,datepart(mm,@FechaSemana1)),2)),
@co_reno_nro,@co_reno_monto,@co_reac_nro,@co_reac_monto,@co_nuev_nro,@co_nuev_monto )

--============= semana 2
set @FechaInicial = @FechaSemana1 +1
truncate table #co
insert into #co 
exec pXaCAColocionCartaPromotor @codpromotor, @FechaInicial, @FechaSemana2
--exec pXaCAColocionCartaPromotor 'GCC3012991','20190501','20190505'
--select * from #colocacion

set @co_reno_nro=0
set @co_reno_monto=0
set @co_reac_nro=0
set @co_reac_monto=0
set @co_nuev_nro=0
set @co_nuev_monto=0

select @co_reno_nro=nro from #co where tipo='RENOVACION'
select @co_reno_monto=monto from #co where tipo='RENOVACION'
select @co_reac_nro=nro from #co where tipo='REACTIVACION'
select @co_reac_monto=monto from #co where tipo='REACTIVACION'
select @co_nuev_nro=nro from #co where tipo='NUEVO'
select @co_nuev_monto=monto from #co where tipo='NUEVO'

update #Colocacion set 
S2_periodo = ( right('0'+convert(varchar,datepart(dd,@FechaInicial)),2) +'/'+ right('0'+convert(varchar,datepart(mm,@FechaInicial)),2)) + ' al ' +
( right('0'+convert(varchar,datepart(dd,@FechaSemana2)),2) +'/'+ right('0'+convert(varchar,datepart(mm,@FechaSemana2)),2)),
S2_nuevo_nro = @co_reno_nro,
S2_nuevo_monto = @co_reno_monto,
S2_renov_nro = @co_reac_nro,
S2_renov_monto = @co_reac_monto,
S2_react_nro = @co_nuev_nro,
S2_react_monto =@co_nuev_monto

--============= semana 3
set @FechaInicial = @FechaSemana2 +1
truncate table #co
insert into #co 
exec pXaCAColocionCartaPromotor @codpromotor,@FechaInicial,@FechaSemana3
--exec pXaCAColocionCartaPromotor 'GCC3012991','20190501','20190505'
--select * from #colocacion

set @co_reno_nro=0
set @co_reno_monto=0
set @co_reac_nro=0
set @co_reac_monto=0
set @co_nuev_nro=0
set @co_nuev_monto=0

select @co_reno_nro=nro from #co where tipo='RENOVACION'
select @co_reno_monto=monto from #co where tipo='RENOVACION'
select @co_reac_nro=nro from #co where tipo='REACTIVACION'
select @co_reac_monto=monto from #co where tipo='REACTIVACION'
select @co_nuev_nro=nro from #co where tipo='NUEVO'
select @co_nuev_monto=monto from #co where tipo='NUEVO'

update #Colocacion set 
S3_periodo = ( right('0'+convert(varchar,datepart(dd,@FechaInicial)),2) +'/'+ right('0'+convert(varchar,datepart(mm,@FechaInicial)),2)) + ' al ' +
( right('0'+convert(varchar,datepart(dd,@FechaSemana3)),2) +'/'+ right('0'+convert(varchar,datepart(mm,@FechaSemana3)),2)),
S3_nuevo_nro = @co_reno_nro,
S3_nuevo_monto = @co_reno_monto,
S3_renov_nro = @co_reac_nro,
S3_renov_monto = @co_reac_monto,
S3_react_nro = @co_nuev_nro,
S3_react_monto =@co_nuev_monto

--============= semana 4
set @FechaInicial = @FechaSemana3 +1
truncate table #co
insert into #co 
exec pXaCAColocionCartaPromotor @codpromotor,@FechaInicial,@FechaSemana4
--exec pXaCAColocionCartaPromotor 'GCC3012991','20190501','20190505'
--select * from #colocacion

set @co_reno_nro=0
set @co_reno_monto=0
set @co_reac_nro=0
set @co_reac_monto=0
set @co_nuev_nro=0
set @co_nuev_monto=0

select @co_reno_nro=nro from #co where tipo='RENOVACION'
select @co_reno_monto=monto from #co where tipo='RENOVACION'
select @co_reac_nro=nro from #co where tipo='REACTIVACION'
select @co_reac_monto=monto from #co where tipo='REACTIVACION'
select @co_nuev_nro=nro from #co where tipo='NUEVO'
select @co_nuev_monto=monto from #co where tipo='NUEVO'

update #Colocacion set 
S4_periodo = ( right('0'+convert(varchar,datepart(dd,@FechaInicial)),2) +'/'+ right('0'+convert(varchar,datepart(mm,@FechaInicial)),2)) + ' al ' +
( right('0'+convert(varchar,datepart(dd,@FechaSemana4)),2) +'/'+ right('0'+convert(varchar,datepart(mm,@FechaSemana4)),2)),
S4_nuevo_nro = @co_reno_nro,
S4_nuevo_monto = @co_reno_monto,
S4_renov_nro = @co_reac_nro,
S4_renov_monto = @co_reac_monto,
S4_react_nro = @co_nuev_nro,
S4_react_monto =@co_nuev_monto

--============= Actualiza los Totales
update #Colocacion set 
Total_Nro = (S1_nuevo_nro+S1_renov_nro+S1_react_nro + S2_nuevo_nro+S2_renov_nro+S2_react_nro + S3_nuevo_nro+S3_renov_nro+S3_react_nro + S4_nuevo_nro+S4_renov_nro+S4_react_nro),
Total_Monto = (S1_nuevo_monto+S1_renov_monto+S1_react_monto + S2_nuevo_monto+S2_renov_monto+S2_react_monto + S3_nuevo_monto+S3_renov_monto+S3_react_monto + S4_nuevo_monto+S4_renov_monto+S4_react_monto)


--Regresa conulta
select * from #Colocacion
drop table #co
drop table #Colocacion

END
GO