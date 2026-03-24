SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsRptCaEncabezadoPorPromotor] (@codpromotor varchar(250))
as

--declare @codpromotor varchar(250)
declare @fecha smalldatetime
declare @fecini smalldatetime
--declare @codoficina varchar(4)
--set @fecha ='20160609'
select @fecha = fechaconsolidacion from vcsfechaconsolidacion
set @fecini =  cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime) -1  --'20160601'
--set @codoficina='10'
--set @codpromotor = 'DUARTE LEMUS ROCIO'

select t2.*
,(case when t2.NroDiasAtraso>=0 and t2.NroDiasAtraso<=29 then t2.saldo else 0 end ) as Saldo0a29
,(case when t2.NroDiasAtraso>=0 and t2.NroDiasAtraso<=29 and t2.saldo>0 then t2.codusuario else null end ) as Contar0a29
,(case when t2.NroDiasAtraso>=30 then t2.saldo else 0 end) as Saldom30
,(case when t2.NroDiasAtraso>=30 and t2.saldo>0 then t2.codusuario else null end) as Contarm30
into #base
from tCsCaCosechasBase t2
--where codoficina=@codoficina
where promotorreporte=@codpromotor

create table #rep(
	periodo smalldatetime,
	codoficina varchar(4),
	Saldo0a29 decimal(16,2),
	Contar0a29 int,
	Saldom30 decimal(16,2),
	Contarm30 int
)

insert into #rep
select @fecha,codoficina,sum(Saldo0a29) Saldo0a29,count(Contar0a29) Contar0a29,sum(Saldom30) Saldom30,count(Contarm30) Contarm30
from #base
group by codoficina

delete from #base 
where desembolso>=@fecini

insert into #rep
--select @fecini-1 fecha,codoficina,sum(Saldo0a29) Saldo0a29,count(Contar0a29) Contar0a29,sum(Saldom30) Saldom30,count(Contarm30) Contarm30
--from #base
--group by codoficina

select fecha,codoficina,sum(Saldo0a29) Saldo0a29,count(Contar0a29) Contar0a29,sum(Saldom30) Saldom30,count(Contarm30) Contarm30
from (
	select c.fecha,c.codoficina,c.CodPrestamo, cd.CodUsuario, c.NroDiasAtraso,saldo = cd.SaldoCapital + (cd.InteresVigente*1.16) + (cd.InteresVencido*1.16),Estado
	,(case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=29 then cd.SaldoCapital + (cd.InteresVigente*1.16) + (cd.InteresVencido*1.16) else 0 end ) as Saldo0a29
	,(case when c.NroDiasAtraso>=0 and c.NroDiasAtraso<=29 and cd.SaldoCapital + (cd.InteresVigente*1.16) + (cd.InteresVencido*1.16)>0 then cd.codusuario else null end) as Contar0a29
	,(case when c.NroDiasAtraso>=30 then cd.SaldoCapital + (cd.InteresVigente*1.16) + (cd.InteresVencido*1.16) else 0 end) as Saldom30
	,(case when c.NroDiasAtraso>=30 and cd.SaldoCapital + (cd.InteresVigente*1.16) + (cd.InteresVencido*1.16)>0 then cd.codusuario else null end) as Contarm30
	from tcscartera as c with(nolock)
	inner join tcscarteradet as cd with(nolock) on cd.Fecha = c.Fecha and cd.CodPrestamo = c.CodPrestamo
	where c.codprestamo in (select distinct codprestamo from #base) and c.fecha=@fecini
) x
group by fecha,codoficina

select periodo,case when periodo=@fecha then 'Hoy' else 'Inicial' end Titulo,codoficina,Saldo0a29,Contar0a29,Saldom30,Contarm30
from #rep

drop table #base
drop table #rep


GO