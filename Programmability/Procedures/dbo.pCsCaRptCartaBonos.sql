SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE procedure [dbo].[pCsCaRptCartaBonos] @codpromotor varchar(20)
as
set nocount on

--<<<<<<<<<<<<<<<
--declare @codpromotor varchar(20)
--set @codpromotor = 'MMJ2707691' 
--set @codpromotor = 'CRJ780519F99R1'
-->>>>>>>>>>>>>>>

declare @codoficina varchar(500)
--set @codoficina='8'
declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion
--set @fecha = '20200315'
--SELECT dateadd(ms,-3,DATEADD(mm, DATEDIFF(m,0,@fecha )+1, 0));

declare @FechaInicial smalldatetime
declare @FechaSemana1 smalldatetime
declare @FechaSemana2 smalldatetime
declare @FechaSemana3 smalldatetime
declare @FechaSemana4 smalldatetime

select @FechaInicial = cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)-1
select @FechaSemana1 = cast(dbo.fdufechaaperiodo(@fecha)+'07' as smalldatetime)  --semana 1
select @FechaSemana2 = cast(dbo.fdufechaaperiodo(@fecha)+'15' as smalldatetime)  --mitad de mes
select @FechaSemana3 = cast(dbo.fdufechaaperiodo(@fecha)+'22' as smalldatetime)  --semana 3
select @FechaSemana4 = cast(dbo.fdufechaaperiodo(dateadd(m,1,@fecha)) + '01' as smalldatetime) -1

--declare @fechas table(sec int,etiqueta varchar(20),fecha smalldatetime)
--insert into @fechas values(1,'Inicio Mes',@FechaInicial)
--insert into @fechas values(2,'Semana1',@FechaSemana1)
--insert into @fechas values(3,'Semana2',@FechaSemana2)
--insert into @fechas values(4,'Semana3',@FechaSemana3)
--insert into @fechas values(5,'Semana4',@FechaSemana4)
--select * from @fechas --comentar

--declare @sucursales table(codigo varchar(4))
--insert into @sucursales
--select codigo 
--from dbo.fduTablaValores(@codoficina)

create table #Prestamos (codprestamo varchar(25), CodPromotor varchar(20), CodOficina varchar(3))

create table #cuadro (
	id int identity,
	Etiqueta varchar(20),
	CodPromotor varchar(20),
	Promotor varchar(30),
	Oficina varchar(30),
	FechaInicio smalldatetime,
	FechaFin smalldatetime,
	NroPtmo int,
	SaldoCapital money,
	D1a7NroPtmo int,
	D1a7Saldo money,
	D1a7Porc money,
	D1a7Imor money,
	
	D0a30NroPtmo int,
	D0a30Saldo money,
	D0a30Porc money,
	D0a30Imor money,
	
	D30aMasNroPtmo int,
	D30aMasSaldo money,
	D30aMasPorc money,
	D30aMasImor money,
	
	--TotalNroPtmo int,
	--TotalSaldo money,
	
	ColSemNum  int,    
	ColSemMonto money,
	
	Nivel varchar(1) null,
	MetaMensual int null,
	MetaQuincelanal int null,
	MetaSemanal int null,
	MetaBonoMensual money null,
	
	ColSemAlcPorc money null,
	ColQ1AlcPromPorc money null,
	ColQ2AlcPromPorc money null,
	
	ColoBonoGanado60Q1 money null,
	ColoBonoGanado40Q2 money null,
	
	CaliBonoGanado60Q1 money null,
	CaliBonoGanado40Q2 money null,
	
	RenBonoGanadoPorc money null,
	RenBonoGanado60Q1 money null,
	RenBonoGanado40Q2 money null,
	
	ColoPremio Varchar(100) null,
	CaliPremio Varchar(100)  null,
	RenPremio Varchar(100)  null,
	ColoPenalizacion Varchar(100) null
)

insert into #cuadro(Etiqueta, CodPromotor, Promotor, Oficina, FechaInicio, FechaFin) values('Inicio Mes', @codpromotor, '', '', @FechaInicial ,@FechaInicial)
insert into #cuadro(Etiqueta, CodPromotor, Promotor, Oficina, FechaInicio, FechaFin) values('Semana1',@codpromotor,'', '', @FechaInicial + 1, @FechaSemana1)
insert into #cuadro(Etiqueta, CodPromotor, Promotor, Oficina, FechaInicio, FechaFin) values('Semana2',@codpromotor,'', '', @FechaSemana1 + 1, @FechaSemana2)
insert into #cuadro(Etiqueta, CodPromotor, Promotor, Oficina, FechaInicio, FechaFin) values('Semana3',@codpromotor,'', '', @FechaSemana2 + 1, @FechaSemana3)
insert into #cuadro(Etiqueta, CodPromotor, Promotor, Oficina, FechaInicio, FechaFin) values('Semana4',@codpromotor,'', '', @FechaSemana3 + 1, @FechaSemana4)

--select * from #cuadro --comentar

declare @n int
declare @x int
select @n=count(*) from #cuadro

Declare @f_actual smalldatetime
Declare @f_inicio smalldatetime
Declare @e varchar(20)

--select * from #cuadro order by CodPromotor, etiqueta --comentar

--Vuelve a recorrer todo los periodos y actualiza a cada promotor con sus datos
set @x=1
while(@x<@n+1)
begin
	--select @f_actual=fecha,@e=etiqueta from @fechas where sec=@x
	--select @f_anterior=fecha from #cuadro where id =@x-1
	select @e = Etiqueta, @f_inicio = FechaInicio, @f_actual = FechaFin from #cuadro where id = @x
	--set @f_anterior = isnull(@f_anterior,@f_actual) 
	
	--select @f_inicio as  '@@f_inicio', @f_actual as '@f_actual'

	truncate table #Prestamos
	insert into #Prestamos
	select distinct codprestamo, CodAsesor, codoficina 
	from tcscartera with(nolock)
	where fecha=@f_actual
	and cartera='ACTIVA' and codoficina not in('97','230','231')
	and codprestamo not in (select codprestamo from tCsCarteraAlta)
	--and codoficina in(select codigo from @sucursales)
	and CodAsesor = @codpromotor
	

	--insert into #cuadro (Etiqueta,CodPromotor,Promotor, Oficina, FechaInicio,FechaFin,nroptmo,saldocapital,D1a7nroptmo,D1a7saldo,D1a7porc,D0a30nroptmo,D0a30saldo,D0a30porc,ColSemNum,ColSemMonto)
	--select #cuadro.etiqueta, b.* 
	update #cuadro set
	Promotor = isnull(b.Promotor,''),
	Oficina = isnull(b.nomoficina,''),
	NroPtmo = isnull(b.nroptmo,0),    
	SaldoCapital = isnull(b.saldocapital,0),         
	D1a7NroPtmo = isnull(b.D1a7nroptmo,0),
	D1a7Saldo  = isnull(b.D1a7saldo,0),           
	D1a7Porc   = isnull(b.D1a7por,0), 
	--D1a7Imor   = ((isnull(b.D1a7por,0)/isnull(b.nroptmo,1)) * 100),           
	D0a30NroPtmo = isnull(b.D0a30nroptmo,0),
	D0a30Saldo = isnull(b.D0a30saldo,0),           
	D0a30Porc  = isnull(b.D0a30por,0),  	
	D30aMasNroPtmo = isnull(b.D30aMasNroPtmo,0), 
	D30aMasSaldo = isnull(b.D30aMasSaldo,0), 
	D30aMasPorc  = isnull(b.D30aMasPor,0),	         
	ColSemNum  = isnull(b.ColNum,0), 
	ColSemMonto  = isnull(b.ColMonto,0)         
	from
	#cuadro 
	left join
	(
		select @e etiqueta, a.CodAsesor, a.Promotor, a.nomoficina, @f_inicio as FechaInicio, @f_actual as FechaFin --,sucursal
		,isnull(count(distinct codprestamo),0) as nroptmo
		,isnull(sum(saldocapital),0.0) as saldocapital
		,isnull(count(distinct D1a7nroptmo),0) as D1a7nroptmo, isnull(sum(D1a7saldo),0.0) as D1a7saldo, isnull((sum(D1a7saldo)/sum(saldocapital))*100,0.0) as D1a7por
		,isnull(count(distinct D0a30nroptmo),0) as D0a30nroptmo, isnull(sum(D0a30saldo),0.0) as D0a30saldo, isnull((sum(D0a30saldo)/sum(saldocapital))*100,0.0) as D0a30por
		,isnull(count(distinct D30aMasNroPtmo),0) as D30aMasNroPtmo, isnull(sum(D30aMasSaldo),0.0) as D30aMasSaldo, isnull((sum(D30aMasSaldo)/sum(saldocapital))*100,0.0) as D30aMasPor
		,isnull(count(distinct ColNum),0) as ColNum, isnull(sum(ColMonto),0.0) as ColMonto

		from  (
			  SELECT c.CodAsesor, e.nombrecompleto as Promotor, o.nomoficina, @f_inicio as FechaInicio, c.Fecha,cd.codusuario,c.CodPrestamo,o.nomoficina sucursal
			  ,cd.saldocapital
			    
			  ,case when c.NroDiasAtraso >= 1 and c.NroDiasAtraso<= 7 then cd.codprestamo else null end D1a7nroptmo
			  ,case when c.NroDiasAtraso >= 1 and c.NroDiasAtraso<= 7 then cd.saldocapital else 0 end D1a7saldo
			  
			  ,case when c.NroDiasAtraso >= 0 and c.NroDiasAtraso<= 30 then cd.codprestamo else null end D0a30nroptmo
			  ,case when c.NroDiasAtraso >= 0 and c.NroDiasAtraso<= 30 then cd.saldocapital else 0 end D0a30saldo
			  
			  ,case when c.NroDiasAtraso > 30 then cd.codprestamo else null end D30aMasNroPtmo
			  ,case when c.NroDiasAtraso > 30 then cd.saldocapital else 0 end D30aMasSaldo
			  
			  ,case when c.FechaDesembolso > @f_inicio and c.FechaDesembolso <= @f_actual then cd.codprestamo else null end ColNum
			  ,case when c.FechaDesembolso > @f_inicio and c.FechaDesembolso <= @f_actual then cd.MontoDesembolso else null end ColMonto
		  
			  FROM tCsCartera c with(nolock)
			  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
			  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
			  inner join tcspadronclientes as e with(nolock) on e.codusuario = c.codasesor
			  where c.fecha=@f_actual
			  and c.cartera='ACTIVA'
			  and c.codprestamo in(select codprestamo from #Prestamos)
		) as a
		group by CodAsesor, a.Promotor, a.nomoficina
	) as b on b.etiqueta = #cuadro.etiqueta
	where #cuadro.id = @x
	
	set @x=@x+1
end

 --select * from #cuadro order by CodPromotor, etiqueta  --Comentar

--Actualiza el nombre de promotor 
 update #cuadro set
 Promotor = (select  NombreCompleto from tcspadronclientes where codusuario = #cuadro.CodPromotor)

--Actualiza Imor@7 quincena 1
update #cuadro set
D1a7Imor = (convert(money,(select D1a7NroPtmo from #cuadro where Etiqueta = 'Semana1') + (select D1a7NroPtmo from #cuadro where Etiqueta = 'Semana2')) / convert(money,(select NroPtmo from #cuadro where Etiqueta = 'Semana1') + (select NroPtmo from #cuadro where Etiqueta = 'Semana2'))) * 100
where Etiqueta in ('Semana1','Semana2') 

--Actualiza Imor@7 quincena 2
update #cuadro set
D1a7Imor = (convert(money,(select D1a7NroPtmo from #cuadro where Etiqueta = 'Semana3') + (select D1a7NroPtmo from #cuadro where Etiqueta = 'Semana4')) / convert(money,(select NroPtmo from #cuadro where Etiqueta = 'Semana3') + (select NroPtmo from #cuadro where Etiqueta = 'Semana4'))) * 100
where Etiqueta in ('Semana3','Semana4') 

--=============================================================================
create table #promotores (id int identity, codpromotor varchar(25))
--Inserta la tabla temporal con los promotores
insert into #promotores (codpromotor)
select codpromotor from #cuadro group by codpromotor 

declare @TotPromotores int
declare @IdPromotor int
--declare @codpromotor varchar(20)
select @TotPromotores = count(*) from #promotores

--==============================================================================
--Barre todos los promotores y les inserta los peridos que pudieran faltar

--set @IdPromotor = 1
--while @IdPromotor <= @TotPromotores
--begin
--	select @codpromotor = codpromotor from #promotores where id = @IdPromotor
	
--	set @x=1
--	while(@x<@n+1)
--	begin
--		select @f_actual=fecha,@e=etiqueta from @fechas where sec=@x
--		select @f_anterior=fecha from @fechas where sec=@x-1
--		set @f_anterior = isnull(@f_anterior,@f_actual) 
		
--		if not exists(select * from #cuadro where CodPromotor = @codpromotor and etiqueta = @e)
--		begin
--			insert into #cuadro (Etiqueta,CodPromotor,FechaInicio,FechaFin,
--			D1a7NroPtmo, D1a7Saldo, D1a7Porc, D0a30NroPtmo, D0a30Saldo, D0a30Porc, ColSemNum, ColSemMonto )
--			select distinct @e etiqueta, @codpromotor, (@f_anterior+1) as FechaInicio, @f_actual as FechaFin,
--			0,0,0,0,0,0,0,0
--		end
		
--		set @x = @x +1
--	end
--	set @IdPromotor = @IdPromotor + 1
--end

-- select * from #cuadro order by CodPromotor, etiqueta  --Comentar

--==============================================================================
set @IdPromotor = 1
while @IdPromotor <= @TotPromotores
begin
	select @codpromotor = codpromotor from #promotores where id = @IdPromotor
	
	--============== Actualiza el Nivel que le corresponde segun la Cartera Vigente a Inicio de Mes
	--select 
	update #cuadro set
	nivel = (select 
			case  
			when D0a30saldo >= 0 and D0a30saldo <= 300000 then 'A'
			when D0a30saldo >= 300001 and D0a30saldo <= 600000 then 'B'
			when D0a30saldo >= 600001 and D0a30saldo <= 900000 then 'C'
			when D0a30saldo >= 900001 and D0a30saldo <= 1200000 then 'D'
			when D0a30saldo >= 1200001 and D0a30saldo <= 1500000 then 'E'
			when D0a30saldo >= 1500001 and D0a30saldo <= 2000001 then 'F'
			when D0a30saldo >= 2000001 and D0a30saldo <= 2500001 then 'G'
			when D0a30saldo >= 2500001 and D0a30saldo <= 20000000 then 'H'
			else '?'
			end
			from #cuadro where codpromotor = @codpromotor and etiqueta = 'Inicio Mes')
	where codpromotor = @codpromotor 
	
	--===================== Actualiza las Metase segun el nivel
	update #cuadro set
	MetaMensual = case when nivel = 'A' then 20
						when nivel = 'B' then 32
						when nivel = 'C' then 40
						when nivel = 'D' then 52
						when nivel = 'E' then 60
						when nivel = 'F' then 72
						when nivel = 'G' then 80
						when nivel = 'H' then 80 END,
	MetaQuincelanal  = case when nivel = 'A' then 10
						when nivel = 'B' then 16
						when nivel = 'C' then 20
						when nivel = 'D' then 26
						when nivel = 'E' then 30
						when nivel = 'F' then 36
						when nivel = 'G' then 40
						when nivel = 'H' then 40 END,
	MetaSemanal  = case when nivel = 'A' then 5
						when nivel = 'B' then 8
						when nivel = 'C' then 10
						when nivel = 'D' then 13
						when nivel = 'E' then 15
						when nivel = 'F' then 18
						when nivel = 'G' then 20
						when nivel = 'H' then 20 END,
	MetaBonoMensual = case when nivel = 'A' then 1000
						when nivel = 'B' then 2500
						when nivel = 'C' then 4000
						when nivel = 'D' then 6000
						when nivel = 'E' then 8500
						when nivel = 'F' then 12000
						when nivel = 'G' then 15500
						when nivel = 'H' then 17500 END
	where codpromotor = @codpromotor 

	--================== Alctualiza la Colocacion Alcance Porcentaje por semana
	update #cuadro set
	ColSemAlcPorc = (100.0/MetaSemanal) * ColSemNum
	where codpromotor = @codpromotor and  etiqueta <> 'Inicio Mes'

	--================== Actualiza el promedio de Alcance por quincena
	update #cuadro set
	ColQ1AlcPromPorc = (select isnull(sum(colsemAlcPorc),0)/2 from #cuadro where etiqueta in ('Semana1','Semana2') and codpromotor = @codpromotor)
	where codpromotor = @codpromotor and etiqueta in ('Semana1','Semana2') 
	
	update #cuadro set
	ColQ2AlcPromPorc = (select isnull(sum(colsemAlcPorc),0)/2 from #cuadro where etiqueta in ('Semana3','Semana4') and codpromotor = @codpromotor)
	where codpromotor = @codpromotor and etiqueta in ('Semana3','Semana4') 
	
	--Se catualiza para que no sea mayor a 100
	update #cuadro set
	ColQ1AlcPromPorc = (case when ColQ1AlcPromPorc > 100 then 100.0	else ColQ1AlcPromPorc end)
	where codpromotor = @codpromotor and etiqueta in ('Semana1','Semana2') 
	
	update #cuadro set
	ColQ2AlcPromPorc = (case when ColQ2AlcPromPorc > 100 then 100.0	else ColQ2AlcPromPorc end)
	where codpromotor = @codpromotor and etiqueta in ('Semana3','Semana4')
	
	--============================================
	--POR COLOCACIÓN – Valor 35% del bono
	--* Se promediaran las 2 semanas del la quincena y ese será el dato final. Las ultimas dos semanas, el maximo alcance podrá ser 100%.
	--* Cumplimiento de al menos el 98% otorga el 35%
	--* Si es menor a 98% pero es mayor al 85%, se otorgará 15%
	
	--se calcula Bono Ganado Colocacion Quincena 1
	update #cuadro set
	ColoBonoGanado60Q1 = (MetaBonoMensual * (case when ColQ1AlcPromPorc >= 98 then 0.35 when ColQ1AlcPromPorc > 85 and ColQ1AlcPromPorc <98 then 0.15 else 0 end)) * 0.6
	where codpromotor = @codpromotor and etiqueta in ('Semana1','Semana2') 
	
	--se calcula Bono Ganado Colocacion Quincena 2
	update #cuadro set
	ColoBonoGanado40Q2 = (MetaBonoMensual * (case when ColQ2AlcPromPorc >= 98 then 0.35 when ColQ2AlcPromPorc > 85 and ColQ2AlcPromPorc <98 then 0.15 else 0 end)) * 0.4
	where codpromotor = @codpromotor and etiqueta in ('Semana3','Semana4') 
	
	--=============================================
	--POR CALIDAD – Valor 40% del bono
	-- *iMor@7 menor o igual al 5%. = 40%
	-- *Si es mayor al 5% pero es menor o igual a10% solo se otorgará 20% del bono
	
	--se calcula Bono Ganado Calidad Quincena 1
	update #cuadro set
	CaliBonoGanado60Q1 = (MetaBonoMensual * (case when D1a7Porc <= 5.0 then 0.4 when D1a7Porc > 5.0 and D1a7Porc <= 10.0 then 0.20 else 0 end)) * 0.6
	where codpromotor = @codpromotor and etiqueta in ('Semana1','Semana2') 
	
	--se calcula Bono Ganado Calidad Quincena 2
	update #cuadro set
	CaliBonoGanado40Q2 = (MetaBonoMensual * (case when D1a7Porc <= 5.0 then 0.4 when D1a7Porc > 5.0 and D1a7Porc <= 10.0 then 0.20 else 0 end)) * 0.4
	where codpromotor = @codpromotor and etiqueta in ('Semana3','Semana4')
	 	
	set @IdPromotor = @IdPromotor +1
end

--select * from #promotores

--================== CALCUA BONO POR RENOVACIONES =========================================
	--POR RENOVACIÓN – Valor 25% del bono
	-- *Renovar al menos el 80% de los clientes que liquidan en el mes
	-- *Si es menor a 80% pero es mayor a 70%, se otorgará 15% del bono 

-----------------------
--declare @oficinas varchar(50)
set @codoficina ='0'

select @codoficina = @codoficina + ', ' + o.codoficina
from(
	select distinct codoficina from #Prestamos 
) as o
--select @codoficina	
	
-----------------------	
declare @FecIniRen smalldatetime
declare @FecFinRen smalldatetime

create table #Renovaciones(
codoficina varchar(3) null,
Oficina varchar(100) null,                                           
cancelacion  smalldatetime null,           
codprestamo varchar(20) null,              
cliente  varchar(100) null,                                                                                                                                                                                                                                                                                                    
MaxAtraso  int null,
monto    money null,             
CodPromotor  varchar(20) null,   
promotor  varchar(100) null,                                                                                                                                                                                                                                                                                                   
CodPrestamoNew   varchar(20) null,         
FecDesembolsoNew   varchar(10) null,             
MontoDesembolsoNew  money null,                      
CodUsuarioCli varchar(20) null,  
CodUsuarioPro varchar(20) null,  
Status varchar(20) null,
SecuenciaProductivo int null,
SecuenciaConsumo int null
)

declare @TotCancelados int
declare @TotRenovados int
declare @PorcRen money

set @IdPromotor = 1
while @IdPromotor <= @TotPromotores
begin
	select @codpromotor = codpromotor from #promotores where id = @IdPromotor
	
	--==================== 
	select @FecIniRen = FechaInicio from #cuadro where CodPromotor = @codpromotor and Etiqueta = 'Semana1'
	select @FecFinRen = FechaFin from #cuadro where CodPromotor = @codpromotor and Etiqueta = 'Semana4'
	
	truncate table #Renovaciones
	insert #Renovaciones
	exec pCsCaFlujoSeguimientoRenovacion @FecIniRen,@FecFinRen, @codoficina,@codpromotor 
	
	set @TotCancelados = 0
	set @TotRenovados = 0
	select @TotCancelados = count(*) from #Renovaciones       --Cancelados
	select @TotRenovados = count(*) from #Renovaciones where CodPrestamoNew <> '' --Renovados
	
	set @PorcRen =0.0
	if @TotCancelados > 0 
	begin
		set @PorcRen = (100.0/@TotCancelados) * @TotRenovados
	end
	
	--se Actualiza el Bono Ganado x Renovacion 
	update #cuadro set
	RenBonoGanadoPorc = @PorcRen,
	RenBonoGanado60Q1 = (MetaBonoMensual * (case when @PorcRen >= 80.0 then 0.25 when @PorcRen > 70.0 and @PorcRen < 80.0 then 0.15 else 0 end)) * 0.6,
	RenBonoGanado40Q2 = (MetaBonoMensual * (case when @PorcRen >= 80.0 then 0.25 when @PorcRen > 70.0 and @PorcRen < 80.0 then 0.15 else 0 end)) * 0.4
	where codpromotor = @codpromotor and etiqueta in ('Semana1','Semana2','Semana3','Semana4')	
	
	set @IdPromotor = @IdPromotor + 1
end

--select * from #Renovaciones
--================== CALCULA PREMIOS ==========================

update #cuadro set
ColoPremio = 'Sin premio Colocacion',
CaliPremio = 'Sin premio Calidad',
RenPremio = 'Sin premio Renovacion',
ColoPenalizacion = 'Sin penalizacion'

declare @CarteraInicial money
declare @CarteraFinal money
declare @CrecimientoCartera money
declare @BonoGanadoQ1 money
declare @BonoGanadoQ2 money
declare @Nivel varchar(1)
declare @PremioCartera money
declare @CastigoCartera money

select @CarteraInicial = D0a30Saldo from #cuadro where Etiqueta = 'Inicio Mes'
select @CarteraFinal = D0a30Saldo from #cuadro where Etiqueta = 'Semana4'

select @BonoGanadoQ1 = ColoBonoGanado60Q1 from #cuadro where Etiqueta = 'Semana1'
select @BonoGanadoQ2 = ColoBonoGanado40Q2 from #cuadro where Etiqueta = 'Semana3'
select @Nivel = Nivel from #cuadro where Etiqueta = 'Semana4' 

if @CarteraInicial > 0
begin
	set @CrecimientoCartera = (100/@CarteraInicial) * @CarteraFinal
	--select @CrecimientoCartera as '@CrecimientoCartera'
	
	if @Nivel in ('A','B','C') and @CrecimientoCartera >110.0 
	begin
		set @PremioCartera = (@BonoGanadoQ1 + @BonoGanadoQ2) * 0.10
	end 
	if @Nivel in ('D') and @CrecimientoCartera >105.0 
	begin
		set @PremioCartera = (@BonoGanadoQ1 + @BonoGanadoQ2) * 0.10
	end 	
	if @Nivel in ('F') and @CrecimientoCartera >103.0 
	begin
		set @PremioCartera = (@BonoGanadoQ1 + @BonoGanadoQ2) * 0.10
	end 
	
	if @Nivel in ('A','B','C') and @CrecimientoCartera < 100.0 
	begin
		set @CastigoCartera = (@BonoGanadoQ1 + @BonoGanadoQ2) * 0.20
	end 
	
	--select @PremioCartera as  '@PremioCartera'
	--select @CastigoCartera as  '@CastigoCartera'
	
	if @PremioCartera > 0
	begin
		update #cuadro set
		ColoPremio = 'Premio 10% mas x crecimiento, 10%'
	end
	
	if @CastigoCartera > 0
	begin
		update #cuadro set
		ColoPenalizacion = 'Sin penalizacion'
	end
	
end

select  
id, Etiqueta, CodPromotor, Promotor, Oficina,  
( right('0'+convert(varchar,datepart(dd,FechaInicio)),2) +'/'+ right('0'+convert(varchar,datepart(mm,FechaInicio)),2)) as FechaInicio, 
( right('0'+convert(varchar,datepart(dd,FechaFin)),2) +'/'+ right('0'+convert(varchar,datepart(mm,FechaFin)),2))  as FechaFin, 
NroPtmo, SaldoCapital, 
D1a7NroPtmo, D1a7Saldo, D1a7Porc, D1a7Imor,
D0a30NroPtmo, D0a30Saldo, D0a30Porc, D0a30Imor,
D30aMasNroPtmo, D30aMasSaldo, D30aMasPorc, D30aMasImor, 
ColSemNum, ColSemMonto, Nivel, MetaMensual, MetaQuincelanal, MetaSemanal, MetaBonoMensual, ColSemAlcPorc, ColQ1AlcPromPorc, ColQ2AlcPromPorc, ColoBonoGanado60Q1, ColoBonoGanado40Q2, CaliBonoGanado60Q1, CaliBonoGanado40Q2, RenBonoGanadoPorc, RenBonoGanado60Q1, RenBonoGanado40Q2, ColoPremio, CaliPremio, RenPremio, ColoPenalizacion
from #cuadro order by id -- CodPromotor, etiqueta

--################################################# Borra las tablas
drop table #Prestamos
drop table #cuadro
--drop table #promotores
drop table #Renovaciones

GO