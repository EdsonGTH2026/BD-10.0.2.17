SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCaRptCartaBonosProgramados] (@FecInicial smalldatetime,@FecFinal smalldatetime,@CodPromotor varchar(20))
as
BEGIN
set nocount on
--<<<<<<<<<<<<  pruebas

--declare @CodPromotor varchar(20)

--set @FecIni = '20200301'
--set @FecFin = '20200331'
--set @CodPromotor = 'SRJ910416M0416'
-->>>>>>>>>>>>  pruebas


declare @FecIni smalldatetime
declare @FecFin smalldatetime
declare @Fec smalldatetime

select @FecIni = dbo.fdufechaaperiodo(@FecInicial) + '01', @FecFin = FecFinSem4    
from tCsCaRptCartaBonosFechas where periodo = dbo.fdufechaaperiodo(@FecInicial)


declare @PagosProgramados table (
--create table #PagosProgramados(
Fecha smalldatetime,
ProgramadoNro int,
ProgramadoMonto money,
PagadosNro int,
PagadosMonto money,
PagadoParcialNro int,
PagadoParcialMonto money,
SinPagoNro int,
SinPagoMonto money
--PRIMARY KEY (Fecha),
--using INDEX fecha_IND (Fecha)
)


set @Fec = @FecIni
while @Fec <= @FecFin
begin
	insert into @PagosProgramados (fecha, ProgramadoNro, ProgramadoMonto, PagadosNro, PagadosMonto, PagadoParcialNro, PagadoParcialMonto, SinPagoNro, SinPagoMonto) values (@Fec,0,0,0,0,0,0,0,0)
	set @Fec = @Fec +1
end
--select * from #PagosProgramados


set @Fec = @FecIni
while @Fec <= @FecFin
begin
	--Actualiza los pagos programados x fecha
	update x set
	x.ProgramadoNro = isnull(y.ProgramadaNro,0),
	x.ProgramadoMonto = isnull(y.ProgramadoMonto,0),
	x.PagadosNro = isnull(y.PagadoNro,0), 
	x.PagadosMonto = isnull(y.PagadoMonto,0),         
	x.PagadoParcialNro = isnull(y.PagadoParcialNro,0),
	x.PagadoParcialMonto = isnull(y.PagadoParcialMonto,0),   
	x.SinPagoNro = isnull(y.SinPagoNro,0), 
	x.SinPagoMonto = isnull(y.SinPagoMonto,0)
	from @PagosProgramados as x
	inner join (
		SELECT c.Fecha, --a.FechaVencimiento,
		count(a.CodUsuario) as ProgramadaNro,
		sum(a.CAPI) as ProgramadoMonto,
		count(t.CodUsuario) as PagadoNro,
		sum(t.capital) as PagadoMonto,
		count(tp.CodUsuario) as PagadoParcialNro,
		sum(tp.capital) as PagadoParcialMonto,
		(count(a.CodUsuario) - count(t.CodUsuario) - count(tp.CodUsuario)) as SinPagoNro,
		(sum(a.CAPI) - sum(t.capital) - sum(tp.capital)) as SinPagoMonto
		FROM tCsCarteraDet d with(nolock)
		INNER JOIN tCsCartera c with(nolock) ON d.Fecha = c.Fecha AND d.CodPrestamo = c.CodPrestamo
		inner join tcspadroncarteradet as pcd with(nolock) on pcd.codprestamo = c.codprestamo and pcd.CodUsuario = c.CodUsuario
		inner JOIN (
			SELECT distinct pc.Fecha, pc.FechaVencimiento, pc.CodPrestamo, pc.CodUsuario,sum(CASE pc.CodConcepto WHEN 'capi' THEN pc.MontoCuota  ELSE 0 END) AS CAPI
			FROM tCsPadronPlanCuotas as pc with(nolock)
			inner join tcspadroncarteradet as pcd2 with(nolock) on pcd2.codprestamo = pc.CodPrestamo 
			WHERE pc.FechaVencimiento =@Fec --(pc.FechaVencimiento >=@Fec) AND (pc.FechaVencimiento <= @Fec)
			and pcd2.UltimoAsesor = @CodPromotor
			GROUP BY pc.Fecha, pc.FechaVencimiento, pc.CodPrestamo, pc.CodUsuario
		) as a ON d.CodPrestamo=a.CodPrestamo AND d.CodUsuario=a.CodUsuario 
		left join (
			select distinct td.fecha, td.codigocuenta,td.codusuario, td.montocapitaltran as capital
			from tcstransacciondiaria as td with(nolock)
			inner join tcspadroncarteradet as pcd2 with(nolock) on pcd2.codprestamo = td.codigocuenta 
			where td.fecha=@Fec --td.fecha>=@Fec and td.fecha<=@Fec
			and td.codsistema='CA' and td.tipotransacnivel3 in(104,105) and td.extornado=0
			and td.codoficina not in('97','231','230')
			and pcd2.UltimoAsesor = @CodPromotor
		) as t on t.codigocuenta = pcd.codprestamo and t.capital >= a.capi
		
		left join (
			select distinct td.fecha, td.codigocuenta,td.codusuario, td.montocapitaltran as capital
			from tcstransacciondiaria as td with(nolock)
			inner join tcspadroncarteradet as pcd2 with(nolock) on pcd2.codprestamo = td.codigocuenta 
			where td.fecha=@Fec --fecha>=@Fec and fecha<=@Fec
			and td.codsistema='CA' and td.tipotransacnivel3 in(104,105) and td.extornado=0
			and td.codoficina not in('97','231','230')
			and pcd2.UltimoAsesor = @CodPromotor
		) as tp on tp.codigocuenta = pcd.codprestamo and tp.capital < a.capi
		
		WHERE (c.Fecha=@Fec) AND (c.cartera='ACTIVA')
		and pcd.UltimoAsesor = @CodPromotor 
		--group by a.FechaVencimiento
		group by c.Fecha
	) as y on y.Fecha = x.fecha	
	
	set @Fec = @Fec +1
end

select convert(varchar,Fecha,103) as Fecha, ProgramadoNro, ProgramadoMonto, PagadosNro, PagadosMonto, PagadoParcialNro, PagadoParcialMonto, SinPagoNro, SinPagoMonto from @PagosProgramados
	
--drop table #PagosProgramados

END	
GO