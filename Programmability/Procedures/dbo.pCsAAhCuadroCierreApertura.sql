SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsAAhCuadroCierreApertura] @Fecini smalldatetime,@Fecfin smalldatetime
as
--declare @Fecini smalldatetime
--set @Fecini='20170701'
--declare @Fecfin smalldatetime
--set @Fecfin='20170731'

--drop table #aper
create table #aper(--80
	codcuenta varchar(30),
	fraccioncta varchar(2),
	renovado	tinyint,
	codusuario varchar(15),
	fecha smalldatetime,
	esrenovacion tinyint,
	saldocuenta money,
	plazo int
)
insert into #aper
select a.codcuenta,a.fraccioncta,a.renovado,a.codusuario,a.fecapertura,case when n.codcuenta is null then 0 else 1 end esrenovacion,ah.saldocuenta,ah.plazo
from tcspadronahorros a with(nolock)
left outer join tcspadronahorros n with(nolock) on a.codusuario=n.codusuario and a.fecapertura=n.feccancelacion
inner join tcsahorros ah with(nolock) on ah.codcuenta=a.codcuenta and ah.fraccioncta=a.fraccioncta and ah.renovado=a.renovado and ah.fecha=a.fecapertura
where a.fecapertura>=@Fecini and a.fecapertura<=@Fecfin
and substring(a.codcuenta,5,1)='2'
group by a.codcuenta,a.fraccioncta,a.renovado,a.codusuario,a.fecapertura,case when n.codcuenta is null then 0 else 1 end,ah.saldocuenta,ah.plazo
--select * from #aper

--drop table #cierre
create table #cierre(--102
	codcuenta varchar(30),
	fraccioncta varchar(2),
	renovado	tinyint,
	codusuario varchar(15),
	fecha smalldatetime,
	esrenovacion tinyint,
	saldocuenta money,
	plazo int
)
insert into #cierre
select n.codcuenta,n.fraccioncta,n.renovado,n.codusuario,n.feccancelacion,1 esrenovacion,ah.saldocuenta,ah.plazo
from tcspadronahorros n with(nolock)
inner join #aper a with(nolock) on a.codusuario=n.codusuario and a.fecha=n.feccancelacion
inner join tcsahorros ah with(nolock) on ah.codcuenta=n.codcuenta and ah.fraccioncta=n.fraccioncta and ah.renovado=n.renovado and ah.fecha=n.fecapertura
group by n.codcuenta,n.fraccioncta,n.renovado,n.codusuario,n.feccancelacion,ah.saldocuenta,ah.plazo

insert into #cierre
select a.codcuenta,a.fraccioncta,a.renovado,a.codusuario,a.feccancelacion,0 esrenovacion,ah.saldocuenta,ah.plazo
from tcspadronahorros a with(nolock)
left outer join #cierre c with(nolock) on a.codcuenta=c.codcuenta and a.fraccioncta=c.fraccioncta and a.renovado=c.renovado
inner join tcsahorros ah with(nolock) on ah.codcuenta=a.codcuenta and ah.fraccioncta=a.fraccioncta and ah.renovado=a.renovado and ah.fecha=a.fechacorte
where a.feccancelacion>=@Fecini and a.feccancelacion<=@Fecfin
and substring(a.codcuenta,5,1)='2'
and c.codcuenta is null

select Operacion,esrenovacion,etiqueta,plazo,sum(saldocuenta) saldocuenta
from (
	select 'Cierres' Operacion,case when esrenovacion=0 then 'Retiro real' else 'Renovacion' end esrenovacion
	,case when SaldoCuenta<130000 then '0 a 130000'
						when SaldoCuenta>=130000 and SaldoCuenta<1000000 then '130,000 a 1,000,000'
						when SaldoCuenta>=1000000 and SaldoCuenta<3000000 then '1,000,000.01 a 3,000,000'
						when SaldoCuenta>=3000000 then 'mayor a 3,000,000.01' else 'No definido' end etiqueta
	,saldocuenta
	,case when plazo>=0 and plazo<=30 then 'Vencimiento 0-30'
				when plazo>30 and plazo<=60 then 'Vencimiento 31-60'
				when plazo>60 and plazo<=90 then 'Vencimiento 61-90'
				when plazo>90 then 'Vencimiento mayor 91'
				else 'No definido' end plazo
	from #cierre
) a
group by Operacion,esrenovacion,etiqueta,plazo
union all
select Operacion,esrenovacion,etiqueta,plazo,sum(saldocuenta) saldocuenta
from (
	select 'Aperturas' Operacion,case when esrenovacion=0 then 'Captacion real' else 'Renovacion' end esrenovacion
	,case when SaldoCuenta<130000 then '0 a 130000'
						when SaldoCuenta>=130000 and SaldoCuenta<1000000 then '130,000 a 1,000,000'
						when SaldoCuenta>=1000000 and SaldoCuenta<3000000 then '1,000,000.01 a 3,000,000'
						when SaldoCuenta>=3000000 then 'mayor a 3,000,000.01' else 'No definido' end etiqueta
	,saldocuenta
	,case when plazo>=0 and plazo<=30 then 'Vencimiento 0-30'
				when plazo>30 and plazo<=60 then 'Vencimiento 31-60'
				when plazo>60 and plazo<=90 then 'Vencimiento 61-90'
				when plazo>90 then 'Vencimiento mayor 91'
				else 'No definido' end plazo
	from #aper
) a
group by Operacion,esrenovacion,etiqueta,plazo


drop table #cierre
drop table #aper

GO

GRANT EXECUTE ON [dbo].[pCsAAhCuadroCierreApertura] TO [marista]
GO