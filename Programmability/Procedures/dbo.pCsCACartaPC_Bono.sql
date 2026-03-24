SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACartaPC_Bono] @fecha smalldatetime,@codpromotor varchar(15),@codoficina varchar(4)
as
set nocount on

--COMENTAR
/*
Declare @fecha smalldatetime
declare @codpromotor varchar(15)
declare @codoficina varchar(4)

set @fecha='20180515'
set @codpromotor='CGM891025M5RR3'
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

print '###################################################################################################'
print '######################################### BONO ####################################################'
print '###################################################################################################'
--###################################################


/* Bono preliminar */
--declare @PorBono money --> viene de cuadro cartera
--set @PorBono=50
--declare @MetaPorBono money --> viene de cuadro cartera
--set @MetaPorBono=0
--declare @bonoSaldoCA decimal(8,2)--> se declaro en "cartera en riesgo"
--declare @bonoSaldoVF decimal(8,2)--> se declaro en "cartera en riesgo"
--set @bonoSaldoCA=120
--set @bonoSaldoVF=100

declare @nivel int
select @nivel = Nivel from tCsRptEMIPC_Promotor where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina

declare @PorBono decimal(8,2)
select @PorBono = PorBono from tCsRptEMIPC_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina

declare @bonoSaldoCA decimal(8,2)
select @bonoSaldoCA = Estatus from tCsRptEMIPC_CarteraRiesgo where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina and etiqueta = 'Saldos'

declare @bonoSaldoVF decimal(8,2)
select @bonoSaldoVF = Estatus from tCsRptEMIPC_CarteraRiesgo where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina and etiqueta = 'Saldos VF'

--select * from tCsRptEMIPC_CarteraRiesgo
declare @MetaPorBono money
select @MetaPorBono = pormeta from tCsRptEMIPC_ColocacionMes where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina

declare @CAsaldo money
select @CAsaldo = CreSalMay500 from tCsRptEMIPC_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina and item = 1

declare @CAnrocre int
select @CAnrocre = CreSalMay500 from tCsRptEMIPC_Cartera where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina and item = 2

--select * from tCsRptEMIPC_Cartera
declare @CApstatus money
select @CApstatus = PEstatus from tCsRptEMIPC_CarteraRiesgo where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina and etiqueta = 'Saldo'

create table #bono(
	item tinyint,
	Tipo char(1),
	valor varchar(50),
	descripcion varchar(200),
	monto money
)

declare @ValorTbl money--decimal(8,2)
--select @ValorTbl = dbo.dfuCACartaTableroBono (208,3)
select @ValorTbl = dbo.dfuCACartaTableroBono (@ncreBM, @ncreAM)


insert into #bono
values(1,'A','$ '+convert(varchar(50),@ValorTbl,1),'Valor de tablero',@ValorTbl)
insert into #bono
values(2,'A','% alcanzado','Meta',0)
insert into #bono
--values(3,'A','%'+convert(varchar(50),@PorBono,1),'Crecimiento',@PorBono)
values(3,'A',convert(varchar(50),@PorBono,1) + '%','Crecimiento',@PorBono)
insert into #bono
--values(4,'A',case when @MetaPorBono=0 then 'NA' else convert(varchar(50),@MetaPorBono,1) end,'Colocación de créditos nuevos',@MetaPorBono)
values(4,'A',case when @MetaPorBono=0 and @nivel in (1,2) then '0%' 
                  when @MetaPorBono=0 and @nivel in (3,4) then 'NA'
                  else convert(varchar(50),@MetaPorBono,1) + '%' end,'Colocación de créditos nuevos',@MetaPorBono)

insert into #bono
values(5,'A',convert(varchar(50),@bonoSaldoCA,1)+'%','Calidad de Cartera propia',@bonoSaldoCA)
insert into #bono
values(6,'A',convert(varchar(50),@bonoSaldoVF,1)+'%','Calidad de Cartera Verificada',@bonoSaldoVF)

Declare @desempeno money
set @desempeno=@ValorTbl

--if(@PorBono<>0) set @desempeno=(@PorBono/100)*@desempeno
--if(@MetaPorBono<>0) set @desempeno=(@MetaPorBono/100)*@desempeno
--if(@bonoSaldoCA<>0) set @desempeno=(@bonoSaldoCA/100)*@desempeno
--if(@bonoSaldoVF<>0) set @desempeno=(@bonoSaldoVF/100)*@desempeno

set @desempeno=(@PorBono/100)*@desempeno
--if (@MetaPorBono<>0 and @nivel in (1,2)) set @desempeno=(@MetaPorBono/100)*@desempeno
if (@nivel in (1,2)) set @desempeno=(@MetaPorBono/100)*@desempeno
set @desempeno=(@bonoSaldoCA/100)*@desempeno
set @desempeno=(@bonoSaldoVF/100)*@desempeno

--select @desempeno
insert into #bono
values(7,'A','$'+convert(varchar(50),@desempeno,1),'Bono por desempeño',@desempeno)

--Viene de un cuadro anterior
--declare @CAnrocre int
--declare @CAsaldo money
--set @CAnrocre=209
--set @CAsaldo=1426451.4908

declare @gestionCA money
select @gestionCA=case when @CAsaldo>=140000 and @CAsaldo<280000 then
				case when @CAnrocre>=50 then 250 else 0 end
			when @CAsaldo>=280000 and @CAsaldo<360000 then
				case when @CAnrocre>=90 then 500 
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=360000 and @CAsaldo<450000 then
				case when @CAnrocre>=120 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=450000 and @CAsaldo<540000 then
				case when @CAnrocre>=150 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=540000 and @CAsaldo<640000 then
				case when @CAnrocre>=180 then 2000
					 when @CAnrocre>=150 and @CAnrocre<180 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=640000 and @CAsaldo<720000 then
				case when @CAnrocre>=210 then 2500
					 when @CAnrocre>=180 and @CAnrocre<210 then 2000
					 when @CAnrocre>=150 and @CAnrocre<180 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=720000 and @CAsaldo<800000 then
				case when @CAnrocre>=240 then 3000
					 when @CAnrocre>=210 and @CAnrocre<240 then 2500
					 when @CAnrocre>=180 and @CAnrocre<210 then 2000
					 when @CAnrocre>=150 and @CAnrocre<180 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			when @CAsaldo>=800000 then
				case when @CAnrocre>=270 then 3500
					 when @CAnrocre>=240 and @CAnrocre<240 then 3000
					 when @CAnrocre>=210 and @CAnrocre<240 then 2500
					 when @CAnrocre>=180 and @CAnrocre<210 then 2000
					 when @CAnrocre>=150 and @CAnrocre<180 then 1500
					 when @CAnrocre>=120 and @CAnrocre<150 then 1000
					 when @CAnrocre>=90 and @CAnrocre<120 then 500
					 when @CAnrocre>=50 and @CAnrocre<90 then 250
					 else 0 end
			else 0 --No esta en ninun rango
			end

insert into #bono
values(8,'B','$'+convert(varchar(50),@gestionCA,1),'Valor por gestión de cartera',@gestionCA)

insert into #bono
values(9,'B','% alcanzado','Meta',0)

--declare @CApstatus money --> se declaro en "cartera en riesgo"
--set @CApstatus=1.29

declare @CACalidad money
select @CACalidad = case when @CApstatus<=1 then 120
			when @CApstatus>1 and @CApstatus<=4 then 100
			when @CApstatus>4 and @CApstatus<=6 then 80
			when @CApstatus>6 then 70 end

insert into #bono
values(10,'B',convert(varchar(50),@CACalidad,1)+'%','Calidad de cartera propia',@CACalidad)

if(@CACalidad<>0) set @gestionCA=(@CACalidad/100)*@gestionCA

insert into #bono
values(11,'B','$'+convert(varchar(50),@gestionCA,1),'Calidad de cartera propia',@gestionCA)

declare @bonofinal money
select @bonofinal=sum(monto) from #bono where item in (7,11)

insert into #bono
values(12,'C','$'+convert(varchar(50),@bonofinal,1),'Bono total final',@bonofinal)

--select * from #bono  --COMENTAR

--OSC
delete from tCsRptEMIPC_Bono where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina
insert into tCsRptEMIPC_Bono (Fecha, CodPromotor, CodOficina, Tipo, item, Tipo2, valor, descripcion, monto )
select @fecha, @codpromotor, @codoficina, 'BONO', item, Tipo, valor, descripcion, monto from #bono 

drop table #bono

--regresa resultado
--select * from tCsRptEMIPC_Bono where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina

GO