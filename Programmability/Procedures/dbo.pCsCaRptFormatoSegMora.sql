SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[pCsCaRptFormatoSegMora] @codasesor	varchar(20)
AS
BEGIN	
	SET NOCOUNT ON;

declare @fecha smalldatetime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion--'20110503'

create table #cartera (
  fecha smalldatetime,
  codprestamo varchar(25),
  nombrecompleto varchar(200),
  fecdesemb smalldatetime,
  ciclo int,
  nrocuotasporpagar int,
  asesor varchar(200),
  nrodiasatraso int,
  capitalriesgo decimal(10,2),
  saldo decimal(10,2)
)

insert into #cartera (codprestamo,nombrecompleto,fecdesemb,ciclo,nrocuotasporpagar,asesor,nrodiasatraso, capitalriesgo)
SELECT CodPrestamo,nombrecompleto,desembolso,secuenciaprestamo,nrocuotasporpagar,
asesor, nrodiasatraso, sum(capitalriesgo) capitalriesgo from (
SELECT pcd.CodPrestamo,cl.nombrecompleto,pcd.desembolso,pcd.secuenciagrupo secuenciaprestamo,c.nrocuotasporpagar,
ase.nombrecompleto asesor, c.nrodiasatraso, cd.saldocapital+cd.otroscargos+cd.impuestos+cd.cargomora 
+ cd.InteresVigente + cd.InteresVencido + cd.InteresCtaOrden + cd.MoratorioVigente
+ cd.MoratorioVencido + cd.MoratorioCtaOrden saldo, 
case when c.nrodiasatraso>0 and c.nrodiasatraso<90 then cd.saldocapital else 0 end capitalriesgo
FROM tCsPadronCarteraDet pcd
inner join tcscarteradet cd on pcd.fechacorte=cd.fecha and pcd.codprestamo=cd.codprestamo
and pcd.codusuario=cd.codusuario
inner join tcscartera c on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
inner join tcspadronclientes cl on cl.codusuario = c.codusuario
inner join tcspadronclientes ase on ase.codusuario = c.codasesor
  where pcd.UltimoAsesor=@codasesor and c.nrodiasatraso<>0
  and pcd.estadocalculado not in ('CANCELADO')) b
group by CodPrestamo,nombrecompleto,desembolso,secuenciaprestamo,nrocuotasporpagar,
asesor, nrodiasatraso

update #cartera
set fecha=@Fecha

select c.fecha,c.codprestamo,c.nombrecompleto,c.fecdesemb,c.ciclo,c.nrocuotasporpagar,c.asesor,c.nrodiasatraso, c.capitalriesgo
,pl.saldo
from #cartera c
inner join (SELECT codoficina, codprestamo, sum(MontoDevengado-MontoPagado-MontoCondonado) saldo 
FROM tCsPadronPlanCuotas p where p.fechavencimiento<=@fecha 
group by codoficina, codprestamo) pl on pl.codprestamo=c.codprestamo

drop table #cartera

END
GO