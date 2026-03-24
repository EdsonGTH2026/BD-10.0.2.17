SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACALiquidados] @fecha smalldatetime,@codoficina varchar(2000)
as
--declare @codoficina varchar(2000)
--set @codoficina='101,107,108,114,117,119,120,122,123,129,139,15,157,158,159,19,198,21,22,25,28,301,307,308,317,319,320,322,323,329,33,339,6,8'
--declare @fecha smalldatetime
--set @fecha='20180306'

declare @fecini smalldatetime
set @fecini=dbo.fdufechaaperiodo(dateadd(month,-3,@fecha))+'01'

select o.nomoficina sucursal,p.codprestamo,cl.nombrecompleto,p.cancelacion,pro.nombrecompleto cordinador
,cr.nuevodesembolso,isnull(cr.codprestamo,'') nuevoprestamo
from tcspadroncarteradet p with(nolock)
inner join tcloficinas o with(nolock) on p.codoficina=o.codoficina
inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
left outer join(
	select codprestamo,codusuario,desembolso nuevodesembolso
	from tcspadroncarteradet
	where desembolso>=@fecini
) cr on cr.codusuario=p.codusuario and cr.nuevodesembolso>=p.cancelacion
left outer join tcspadronclientes pro with(nolock) on pro.codusuario=p.ultimoasesor
where p.cancelacion>=@fecini and p.cancelacion<=@fecha
and (p.codgrupo not in('ALTA3','ALTA5','ALTA6','ALTA7','ALTA8','ALTA9') or p.codgrupo is null)
and p.codoficina not in('97','230','231')
and p.codoficina in(
	select codigo from dbo.fduTablaValores(@codoficina)
)
GO