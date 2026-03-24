SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRieDesembolsosPeriodo] @fecini smalldatetime, @fecfin smalldatetime
as
select codprestamo,codusuario,codoficina,secuenciacliente,desembolso
into #desembolsos
from tcspadroncarteradet d with(nolock)
where desembolso>=@fecini and desembolso<=@fecfin
and tiporeprog<>'RENOV'
--2,618

select d.codprestamo
, case when d.secuenciacliente in(0,1) then 'Nuevo' else
		case when dbo.fdufechaaperiodo(d.desembolso)=dbo.fdufechaaperiodo(l.cancelacion) then 'Renovacion' else 'Reactivacion' end 
end etiqueta
from #desembolsos d with(nolock)
left outer join tcspadroncarteradet l with(nolock) on l.codusuario=d.codusuario and l.secuenciacliente=d.secuenciacliente-1

drop table #desembolsos
GO