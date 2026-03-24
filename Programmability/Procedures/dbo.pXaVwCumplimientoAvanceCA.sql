SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
----pXaVwCumplimientoAvanceCA '37'
----pCsCboOficinasyZonasVs2 'Z12','',''
CREATE procedure [dbo].[pXaVwCumplimientoAvanceCA] @codoficina varchar(1000)
as
set nocount on
--select * from tcloficinas where nomoficina like '%kantun%'
--declare @codoficina varchar(1000)
----set @codoficina='3,309,310,311,318,325,330,333,334,335,336,337,37,4,431,5,6,8'
--set @codoficina='342,142'
declare @fecini smalldatetime
declare @fecha smalldatetime
--set @fecha='20180320'
select @fecha=fechaconsolidacion from vCsFechaConsolidacion

declare @feciniAnte smalldatetime
declare @fecfinAnte smalldatetime
set @fecini=dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'
set @fecfinAnte=@fecini-1
set @feciniAnte=dbo.fdufechaatexto(@fecfinAnte,'AAAAMM')+'01'

declare @nrosucursales int
select @nrosucursales=count(*) from dbo.fduTablaValores(@codoficina)

declare @nroestimado int
SELECT @nroestimado=Valor FROM tSgConfigGeneral WHERE  (IdConfigGeneral = 1)

declare @Es_CliIniCBM int --A
declare @Es_CredLiq int--B
declare @Es_CredNue int--C
declare @Es_CredRen int--D
declare @Es_CliFinCBM int--E
declare @Es_Crecimiento int--F
declare @Es_MontoProm decimal(16,2)--G
declare @Es_ColoTotal decimal(16,2)--H
declare @Es_SaldoCBM decimal(16,2)--I

select @Es_CliIniCBM = count(c.codprestamo) --nro
,@Es_SaldoCBM = sum(d.saldocapital+d.interesvigente+d.interesvencido) --saldo
from tcscartera c with(nolock) inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.fecha=@fecfinAnte and c.cartera='ACTIVA' and c.nrodiasatraso>=0 and c.nrodiasatraso<=29 and c.codoficina in(select codigo from dbo.fduTablaValores(@codoficina))

select @Es_MontoProm=avg(monto)
from tcspadroncarteradet with(nolock)
where desembolso>=@feciniAnte and desembolso<=@fecfinAnte and codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
--select CEILING(cast(@Es_CliIniCBM as decimal(16,2))*0.2)
set @Es_CredLiq=CEILING(cast(@Es_CliIniCBM as decimal(16,2))*0.2)

select @Es_CredLiq = count(c.codprestamo) --nro
from tcscartera c with(nolock) inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.fecha=@fecfinAnte and c.cartera='ACTIVA' and c.nrodiasatraso>=0 and c.nrodiasatraso<=29 and c.codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
and c.fechavencimiento>=@fecini and c.fechavencimiento<=@fecha

set @Es_CredNue=@nroestimado*@nrosucursales -- donde @nroestimado=30
set @Es_CredRen=CEILING(cast(@Es_CredLiq as decimal(16,2))*0.95)
set @Es_CliFinCBM=@Es_CliIniCBM-@Es_CredLiq+@Es_CredNue+@Es_CredRen
set @Es_Crecimiento=@Es_CliFinCBM-@Es_CliIniCBM
set @Es_ColoTotal=@Es_MontoProm*@Es_CredNue+@Es_MontoProm*@Es_CredRen

declare @Ac_CliIniCBM int --A
declare @Ac_CredLiq int--B
declare @Ac_CredNue int--C
declare @Ac_CredRen int--D
declare @Ac_CliFinCBM int--E
declare @Ac_Crecimiento int--F
declare @Ac_MontoProm decimal(16,2)--G
declare @Ac_ColoTotal decimal(16,2)--H
declare @Ac_SaldoCBM decimal(16,2)--I

set @Ac_CliIniCBM=@Es_CliIniCBM

select @Ac_CredLiq=count(codprestamo)--,@Ac_ColoTotal=sum(monto)
from tcspadroncarteradet with(nolock)
where cancelacion>=@fecini and cancelacion<=@fecha and codoficina in(select codigo from dbo.fduTablaValores(@codoficina))

select @Ac_ColoTotal=isnull(sum(monto),0)
from tcspadroncarteradet with(nolock)
where desembolso>=@fecini and desembolso<=@fecha and codoficina in(select codigo from dbo.fduTablaValores(@codoficina))

---- quitar de nuevos los que renovaron @Ac_CredRen
select @Ac_CredNue=isnull(count(codprestamo),0),@Ac_CredRen=isnull(count(codusuario),0) --nroren
from (
	select p.codprestamo, a.codusuario,max(a.desembolso) desembolso
	from tcspadroncarteradet p with(nolock)
	left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and p.desembolso>a.desembolso
	where p.desembolso>=@fecini and p.desembolso<=@fecha and p.codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
	group by p.codprestamo, p.codusuario,p.desembolso,a.codusuario
) b
set @Ac_CredNue=@Ac_CredNue-@Ac_CredRen

select @Ac_CliFinCBM = count(c.codprestamo) --nro
,@Ac_SaldoCBM = sum(d.saldocapital+d.interesvigente+d.interesvencido) --saldo
from tcscartera c with(nolock) inner join tcscarteradet d with(nolock) on c.fecha=d.fecha and c.codprestamo=d.codprestamo
where c.fecha=@fecha and c.cartera='ACTIVA' and c.nrodiasatraso>=0 and c.nrodiasatraso<=29 and c.codoficina in(select codigo from dbo.fduTablaValores(@codoficina))

select @Ac_MontoProm=isnull(avg(monto),0)
from tcspadroncarteradet with(nolock)
where desembolso>=@fecini and desembolso<=@fecha and codoficina in(select codigo from dbo.fduTablaValores(@codoficina))

set @Ac_Crecimiento=@Ac_CliFinCBM-@Ac_CliIniCBM

select *
into #tabla
from (
select 2 n,'Clientes iniciales CBM' 'Et',@Es_CliIniCBM 'Estimado',@Ac_CliIniCBM	  'Hoy',0							'Real',0													 'Alcance' union
select 3 n,'Créditos liquidados' 'Et',@Es_CredLiq	   'Estimado',@Ac_CredLiq	  'Hoy',@Ac_CredLiq-@Es_CredLiq		'Real',cast(round(COALESCE((cast(@Ac_CredLiq as decimal(16,2))/NULLIF(@Es_CredLiq,0)),0)*100,2) as decimal(16,2)) 'Alcance' union
select 4 n,'Créditos nuevos' 'Et',@Es_CredNue		   'Estimado',@Ac_CredNue	  'Hoy',@Ac_CredNue-@Es_CredNue		'Real',cast(round(COALESCE((cast(@Ac_CredNue as decimal(16,2))/NULLIF(@Es_CredNue,0)),0)*100,2) as decimal(16,2)) 'Alcance' union
select 5 n,'Créditos renovados' 'Et',@Es_CredRen	   'Estimado',@Ac_CredRen	  'Hoy',@Ac_CredRen-@Es_CredRen		'Real',cast(round(COALESCE((cast(@Ac_CredRen as decimal(16,2))/NULLIF(@Es_CredRen,0)),0)*100,2) as decimal(16,2)) 'Alcance' union
select 6 n,'Créditos finales CBM' 'Et',@Es_CliFinCBM   'Estimado',@Ac_CliFinCBM	  'Hoy',@Ac_CliFinCBM-@Es_CliFinCBM	'Real',cast(round(COALESCE((cast(@Ac_CliFinCBM as decimal(16,2))/NULLIF(@Es_CliFinCBM,0)),0)*100,2) as decimal(16,2)) 'Alcance' union
select 7 n,'Crecimiento' 'Et',@Es_Crecimiento		   'Estimado',@Ac_Crecimiento 'Hoy',@Ac_Crecimiento-@Es_Crecimiento 'Real',cast(round(COALESCE((cast(@Ac_Crecimiento as decimal(16,2))/NULLIF(@Es_Crecimiento,0)),0)*100,2) as decimal(16,2)) 'Alcance' union
select 9 n,'Monto promedio' 'Et',@Es_MontoProm		   'Estimado',@Ac_MontoProm	  'Hoy',@Ac_MontoProm-@Es_MontoProm	'Real',0 'Alcance' union
select 10 n,'Colocación total' 'Et',@Es_ColoTotal	   'Estimado',@Ac_ColoTotal	  'Hoy',@Ac_ColoTotal-@Es_ColoTotal	'Real',cast(round(COALESCE((@Ac_ColoTotal/NULLIF(@Es_ColoTotal,0)),0)*100,2) as decimal(16,2)) 'Alcance' union
select 12 n,'Saldo CBM' 'Et',@Es_SaldoCBM			   'Estimado',@Ac_SaldoCBM	  'Hoy',@Ac_SaldoCBM-@Es_SaldoCBM		'Real',cast(round(COALESCE((@Ac_SaldoCBM/NULLIF(@Es_SaldoCBM,0)),0)*100,2)-100 as decimal(16,2)) 'Alcance'
) a

select 1 n,'Clientes' 'Et','Estimado' Estimado,'Hoy' Hoy,'Real vs Estimado' as 'Real','% Alcance' 'Alcance'										union
select n,et,cast(estimado as varchar(20)) ,cast(hoy as varchar(20)),cast([real] as varchar(20)),cast(alcance as varchar(20)) from #tabla		union
select 8 n,'Colocación' 'Et','Estimado' Estimado,'Hoy' Hoy,'Real vs Estimado' as 'Real','% Alcance' 'Alcance'									union
select 11 n,'Saldo en cartera' 'Et','Inicial' Estimado,'Hoy' Hoy,'Crecimiento' as 'Real','% Crecimiento' 'Alcance'

drop table #tabla
GO

GRANT EXECUTE ON [dbo].[pXaVwCumplimientoAvanceCA] TO [marista]
GO