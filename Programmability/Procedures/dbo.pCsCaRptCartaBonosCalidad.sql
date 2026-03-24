SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCaRptCartaBonosCalidad] @codpromotor varchar(20), @fecha smalldatetime
as
begin
set nocount on

--<<<<<<<<<<<<<<<
--declare @codpromotor varchar(20)
--declare @fecha smalldatetime

--set @codpromotor = 'SRJ910416M0416'
--set @fecha = '20200315'
-->>>>>>>>>>>>>>>

set @fecha = @fecha -2
--set @fecha = convert(varchar,@fecha,112)

	--declare @FecIni smalldatetime
	--declare @FecFin smalldatetime
	--select @FecIni = dbo.fdufechaaperiodo(@fecha) + '01', @FecFin = FecFinSem4    
	--from tCsCaRptCartaBonosFechas where periodo = dbo.fdufechaaperiodo(@fecha)
	
	declare @Imor7 int
	declare @ClientesNro money
	declare @SaldoMonto money
	
	create table #Prestamos (codprestamo varchar(25), CodPromotor varchar(20), CodOficina varchar(3))

	truncate table #Prestamos
	insert into #Prestamos
	select distinct codprestamo, CodAsesor, codoficina 
	from tcscartera with(nolock)
	where fecha=@fecha
	and cartera='ACTIVA' and codoficina not in('97','230','231')
	and codprestamo not in (select codprestamo from tCsCarteraAlta)
	and CodAsesor = @codpromotor
	
	select  
	    --a.CodAsesor, a.Promotor, a.nomoficina, @fecha as Fecha --,sucursal
		--,isnull(count(distinct codprestamo),0) as nroptmo
		--,isnull(sum(saldocapital),0.0) as saldocapital
		--,isnull(count(distinct D1a7nroptmo),0) as D1a7nroptmo 
		--,isnull(sum(D1a7saldo),0.0) as D1a7saldo 
		 @Imor7 = (convert(money,isnull(count(distinct D1a7nroptmo),0)) / convert(money,isnull(count(distinct codprestamo),1))) *100
		, @ClientesNro = isnull(count(distinct D1a7nroptmo),0)
		, @SaldoMonto = isnull(sum(D1a7saldo),0.0)
		--,isnull((sum(D1a7saldo)/sum(saldocapital))*100,0.0) as D1a7por
		--,isnull(count(distinct D0a30nroptmo),0) as D0a30nroptmo, isnull(sum(D0a30saldo),0.0) as D0a30saldo, isnull((sum(D0a30saldo)/sum(saldocapital))*100,0.0) as D0a30por
		--,isnull(count(distinct D30aMasNroPtmo),0) as D30aMasNroPtmo, isnull(sum(D30aMasSaldo),0.0) as D30aMasSaldo, isnull((sum(D30aMasSaldo)/sum(saldocapital))*100,0.0) as D30aMasPor
		--,isnull(count(distinct ColNum),0) as ColNum, isnull(sum(ColMonto),0.0) as ColMonto

		from  (
			  SELECT c.CodAsesor, e.nombrecompleto as Promotor, o.nomoficina,-- @f_inicio as FechaInicio,
			   c.Fecha,
			  cd.codusuario,c.CodPrestamo,o.nomoficina sucursal
			  ,cd.saldocapital			    
			  ,case when c.NroDiasAtraso >= 1 and c.NroDiasAtraso<= 7 then cd.codprestamo else null end D1a7nroptmo
			  ,case when c.NroDiasAtraso >= 1 and c.NroDiasAtraso<= 7 then cd.saldocapital else 0 end D1a7saldo
			  
			  --,case when c.NroDiasAtraso >= 0 and c.NroDiasAtraso<= 30 then cd.codprestamo else null end D0a30nroptmo
			  --,case when c.NroDiasAtraso >= 0 and c.NroDiasAtraso<= 30 then cd.saldocapital else 0 end D0a30saldo
			  
			  --,case when c.NroDiasAtraso > 30 then cd.codprestamo else null end D30aMasNroPtmo
			  --,case when c.NroDiasAtraso > 30 then cd.saldocapital else 0 end D30aMasSaldo
			  
			  --,case when c.FechaDesembolso > @f_inicio and c.FechaDesembolso <= @f_actual then cd.codprestamo else null end ColNum
			  --,case when c.FechaDesembolso > @f_inicio and c.FechaDesembolso <= @f_actual then cd.MontoDesembolso else null end ColMonto
		  
			  FROM tCsCartera c with(nolock)
			  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
			  inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
			  inner join tcspadronclientes as e with(nolock) on e.codusuario = c.codasesor
			  where c.fecha=@fecha
			  and c.cartera='ACTIVA'
			  and c.codprestamo in(select codprestamo from #Prestamos)
		) as a
		group by CodAsesor, a.Promotor, a.nomoficina
	

	declare @liquidaciones table(
	Imor7 money,
	ClientesNro int,
	SaldoMonto money
	)	
	insert into @liquidaciones (Imor7, ClientesNro, SaldoMonto) values (@Imor7, @ClientesNro, @SaldoMonto)
	
	select Imor7, ClientesNro, SaldoMonto from @liquidaciones
	
	drop table #Prestamos
end

GO