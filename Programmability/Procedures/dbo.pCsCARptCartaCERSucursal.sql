SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop procedure pCsCARptCartaCERSucursal
create procedure [dbo].[pCsCARptCartaCERSucursal] @fecha smalldatetime,@codoficina varchar(4)
as
--declare @fecha smalldatetime
--set @fecha='20160430'
	/*ENCABEZADO DEL REPORTE*/
	SELECT o.codoficina,o.nomoficina sucursal
	,sum(case when (c.nrodiasatraso>=0 and c.nrodiasatraso<=29) then d.saldocapital+d.interesvigente+d.interesvencido else 0 end) S0a29
	,sum(case when c.nrodiasatraso>=30 and c.nrodiasatraso<=59 then d.saldocapital+d.interesvigente+d.interesvencido else 0 end) S30a59
	,sum(case when c.nrodiasatraso>=60 then d.saldocapital+d.interesvigente+d.interesvencido else 0 end) S60
	,sum(d.saldocapital+d.interesvigente+d.interesvencido) SCartera

	,count(case when (c.nrodiasatraso>=0 and c.nrodiasatraso<=29) then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end) N0a29
	,count(case when c.nrodiasatraso>=30 and c.nrodiasatraso<=59 then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end) N30a59
	,count(case when c.nrodiasatraso>=60 then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end) N60
	,count((case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end)) NCartera

	,(sum(case when c.nrodiasatraso>=4 then d.saldocapital+d.interesvigente+d.interesvencido else 0 end)/sum(d.saldocapital+d.interesvigente+d.interesvencido))*100 CER4
	,(sum(case when c.nrodiasatraso>=60 then d.saldocapital+d.interesvigente+d.interesvencido else 0 end)/sum(d.saldocapital+d.interesvigente+d.interesvencido))*100 CER60

	,(cast(count(case when c.nrodiasatraso>=4 then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end) as decimal(16,2))/cast(count((case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end)) as decimal(16,2)))*100 CER4n
	,(cast(count(case when c.nrodiasatraso>=60 then (case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end) else null end) as decimal(16,2))/cast(count((case when d.saldocapital+d.interesvigente+d.interesvencido=0 then null else d.codusuario end)) as decimal(16,2)))*100 CER60n

	FROM tCsCartera c with(nolock)
	inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
	inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=d.codprestamo and pd.codusuario=d.codusuario
	inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina
	where c.fecha=@fecha and c.fechadesembolso>='20140101'
	and c.codproducto not in(167,168)
	and c.codoficina<100
	and c.codoficina=@codoficina
	group by o.codoficina,o.nomoficina
GO