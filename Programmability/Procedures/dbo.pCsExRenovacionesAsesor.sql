SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsExRenovacionesAsesor] @fecha smalldatetime,@codasesor varchar(15)
as
--Declare @fecha smalldatetime
--set @fecha='20140429'
--declare @codasesor varchar(15)
--set @codasesor='CSA1010881'

declare @periodo varchar(6)
declare @primerdia smalldatetime
select @periodo=periodo,@primerdia=primerdia from tclperiodo where primerdia<=@fecha and ultimodia>=@fecha

declare @fechanterior smalldatetime
select @fechanterior=ultimodia from tclperiodo where periodo=dbo.fdufechaaperiodo(dateadd(day,-1,@primerdia))


select ac.codprestamo,cl.nombrecompleto cliente
from(
  SELECT c.fecha, c.codprestamo, c.codasesor
  ,cd.codusuario
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  inner join tcspadroncarteradet p with(nolock) on p.codprestamo=cd.codprestamo and p.codusuario=cd.codusuario
  where c.fecha=@fecha
  and c.cartera='ACTIVA' 
  And c.codproducto <> '164'
  and c.codasesor=@codasesor
  and c.nrodiasatraso<61
  and dbo.fdufechaaperiodo(c.fechadesembolso)=@periodo and p.secuenciacliente<>1 and p.primerasesor=c.codasesor
) ac
left outer join (
  SELECT c.fecha, c.codprestamo, c.codasesor, sum(cd.saldocapital) saldocapital
  FROM tCsCartera c with(nolock)
  inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo
  where c.fecha=@fechanterior
  and c.cartera='ACTIVA' 
  and c.codproducto <> '164'
  and c.codasesor=@codasesor
  group by c.fecha, c.codprestamo, c.codasesor
) an
on ac.codprestamo=an.codprestamo and ac.codasesor=an.codasesor
inner join tcspadronclientes cl with(nolock) on cl.codusuario=ac.codusuario
where an.fecha is null
GO