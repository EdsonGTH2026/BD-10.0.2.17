SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaSolicitudesDiaReRe]
as
Declare @Fecha 		SmallDateTime
Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion

create table #sol (
	codsolicitud varchar(15) NOT NULL,
	codoficina varchar(4) NOT NULL,
	codestadoactual int NULL,
	estadoactual varchar(30) NOT NULL,
	Menor15 int NOT NULL,
	Mayor15 int NOT NULL,
	montoaprobado money NULL,
	codusuario varchar(20) NOT NULL,
	fechadesembolso smalldatetime NULL,
	codproducto char(3) NOT NULL
)
insert into #sol
exec [10.0.2.14].finmas.dbo.pXaSolicitudesDiaReRe

update #sol
set codusuario=cl.codusuario
from #sol p with(nolock)
inner join tcspadronclientes cl with(nolock) on p.codusuario=cl.codorigen

create table #liqreno(codsolicitud varchar(25) not null,codoficina varchar(4),desembolso smalldatetime,codusuario varchar(15),cancelacion smalldatetime)
insert into #liqreno
select p.codsolicitud,p.codoficina,p.fechadesembolso,p.codusuario,max(a.cancelacion) cancelacion
from #sol p with(nolock)
left outer join tcspadroncarteradet a with(nolock) on p.codusuario=a.codusuario and a.cancelacion<=p.fechadesembolso
--and p.codproducto = (case when a.codproducto ='370' then '370' else '170' end)
group by p.codsolicitud,p.codoficina,p.fechadesembolso,p.codusuario
having max(a.cancelacion) is not null

select s.*,l.*
from #sol s
left outer join #liqreno l with(nolock) on l.codsolicitud=s.codsolicitud and l.codoficina=s.codoficina

drop table #sol
drop table #liqreno

GO

GRANT EXECUTE ON [dbo].[pXaSolicitudesDiaReRe] TO [marista]
GO