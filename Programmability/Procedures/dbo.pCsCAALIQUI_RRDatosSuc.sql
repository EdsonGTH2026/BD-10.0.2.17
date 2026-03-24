SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCAALIQUI_RRDatosSuc] @fecha smalldatetime,@codoficina varchar(1000)
as
set nocount on
	--declare @codoficina varchar(500)
	--set @codoficina='15,21,3,301,101,302,102,303,103,304,104,307,107,308,108,309,109,310,110,311,111,315,115,317,117,318,118,319,119,320,120
	--,321,121,322,122,323,123,324,124,325,125,326,126,327,127,329,129,33,330,130,332,132,333,133,334,134,335,135,336,136
	--,337,137,339,139,341,141,342,142,344,144,37,131,4,41,430,431,432,232,433,233,5,6,8,25,114,28'
		
--declare @codoficina varchar(1000)
--set @codoficina='302'
----set @codoficina='%'

declare @oficinas table(codoficina varchar(4))
insert into @oficinas
select codigo
from dbo.fdutablavalores(@codoficina)

create table #dir(codusuario varchar(20),direccion varchar(1000))
insert into #dir
select codusuario,isnull(c.direcciondirfampri,c.direcciondirnegpri) + ' ' + isnull(c.numextfam,c.numextneg) + ' ' + isnull(c.numintfam,c.numintneg)
	+ ',CP.' + isnull(c.codpostalfam,c.codpostalneg) 
	+ ',' + u.descubigeo +','+m.descubigeo+','+e.descubigeo direccion
--select top 100 *
from tcspadronclientes c with(nolock)
left outer join tclubigeo u with(nolock) on u.codubigeo=isnull(c.codubigeodirfampri,c.codubigeodirnegpri)
left outer join tclubigeo m with(nolock) on m.codarbolconta=substring(u.codarbolconta,1,19) and m.codubigeotipo='MUNI'
left outer join tclubigeo e with(nolock) on e.codarbolconta=substring(u.codarbolconta,1,13) and e.codubigeotipo='ESTA'
where c.codusuario in(
	select codusuario from tCsACaLIQUI_RR with(nolock) where (codoficina in(select codoficina from @oficinas)
	or @codoficina='%'
	) and estado not in('Reactivado','Renovado')
)
--2,039
--select top 10 * from tclubigeo where codubigeotipo='MUNI'

select l.*,d.direccion
from tCsACaLIQUI_RR l with(nolock)
left outer join #dir d with(nolock) on l.codusuario=d.codusuario
--where codoficina in(select codigo from dbo.fduTablaValores(@codoficina))
where (codoficina in(select codoficina from @oficinas)
or @codoficina='%'
)
and estado not in('Reactivado','Renovado')

drop table #dir
GO