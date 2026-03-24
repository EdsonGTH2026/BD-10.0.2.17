SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsACaDesembolsosDatos] @fecha smalldatetime, @codoficina varchar(5)
as
--declare @fecha smalldatetime
--set @fecha='20190410'
declare @fecini smalldatetime
set @fecini= dbo.fdufechaaperiodo(@fecha) +'01'

select o.nomoficina,p.codoficina,p.desembolso fechadesembolso
,count(p.codprestamo) nroprestamos, sum(p.Monto) monto
from tcspadroncarteradet p with(nolock)
inner join tClOficinas o with(nolock) ON o.CodOficina=p.CodOficina
where p.desembolso>=@fecini and p.desembolso<=@fecha
and p.codoficina<>'97'
group by o.nomoficina,p.codoficina,p.desembolso


GO