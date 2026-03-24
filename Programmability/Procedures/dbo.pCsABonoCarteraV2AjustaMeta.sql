SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsABonoCarteraV2AjustaMeta] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20150630'

update tCsRptBonoCarteraV2
set bonoapagar=x.BonoMetasAjustado
--select b.*,x.BonoMetasAjustado
from tCsRptBonoCarteraV2 b 
inner join (
	SELECT b.fecha,b.tipocalculo,b.codoficina,b.codasesor
	,case when isnull(nc.PorcMNC_NV,0)>=80 then (b.BonoFinal/2)*(case when nc.PorcMNC_NV>100 then 100 else nc.PorcMNC_NV end)/100 else 0 end 
	 + case when isnull(nc.PorcMDE_NV,0)>=80 then (b.BonoFinal/2)*(case when nc.PorcMDE_NV>100 then 100 else nc.PorcMDE_NV end)/100 else 0 end BonoMetasAjustado
	FROM tCsRptBonoCarteraV2 b
	left outer join (
		SELECT Fecha,codasesor,sum(PorcMNC) PorcMNC_NV,sum(PorcMDE) PorcMDE_NV
		FROM tCsRptBonoCarteraV2 with(nolock)
		where fecha=@fecha and estadoasesor<>'BAJA'
		group by Fecha,codasesor
		having sum(PorcMNC)>=80 or sum(PorcMDE)>=80
	) nc on nc.fecha=b.fecha and nc.codasesor=b.codasesor
	where b.fecha=@fecha and b.estadoasesor<>'BAJA'
) x on b.fecha=x.fecha and b.tipocalculo=x.tipocalculo and b.codoficina=x.codoficina and b.codasesor=x.codasesor
GO