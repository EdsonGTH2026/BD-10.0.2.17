SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCAaRenovar_Test] @codoficina varchar(4),@codasesor varchar(15)
as
set nocount on
--declare @codoficina varchar(4)
--set @codoficina=4--37

--declare @codasesor varchar(15)
--set @codasesor='4MLB2111751'--'CGM891025M5RR3'

declare @fecha smalldatetime
select @fecha=fechaconsolidacion from vcsfechaconsolidacion

create table #CA(
	origen varchar(15),
	cliente varchar(200),
	fechavencimiento smalldatetime,
	codprestamo varchar(25),
	diasmora int,
	fechafesembolso smalldatetime,
	montofesembolso money,
	cuotas int,
	codsolicitud varchar(25),
	codoficina varchar(4),
	codproducto char(3),
	codasesor varchar(15),
	newcodsolicitud varchar(25)
)

insert into #CA
--exec [10.0.2.14].finmas.dbo.pXaCAaRenovar @codoficina--> Producción
exec [10.0.2.14].finmas_20190315ini.dbo.pXaCAaRenovar @codoficina--> Pruebas

select * from (
	select c.origen,c.cliente,dbo.fdufechaatexto(c.fechavencimiento,'DD/MM/AAAA') fechavencimiento,c.codprestamo,c.diasmora
	,dbo.fdufechaatexto(c.fechafesembolso,'DD/MM/AAAA') fechafesembolso,c.montofesembolso
	,c.cuotas,c.codsolicitud,c.codoficina,c.codproducto,c.codasesor,c.newcodsolicitud
	,case when (e.codusuario is null or e.codpuesto<>66) then 'HUERFANO' else cl.nombrecompleto end promotor
	,pd.secuenciacliente + 1 ciclo
	from #CA c
	inner join tcspadronclientes cl on cl.codorigen=c.codasesor
	left outer join tcsempleadosfecha e with(nolock) on e.codusuario=cl.codusuario and e.fecha=@fecha--'20190205'---->huerfano
	inner join tcspadroncarteradet pd with(nolock) on pd.codprestamo=c.codprestamo
) a
where codasesor=@codasesor or promotor='HUERFANO'

drop table #CA

GO