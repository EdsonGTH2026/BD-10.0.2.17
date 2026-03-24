SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsRptCaCarteraCP] (@CodPromotor as varchar(20))
AS

--declare @CodPromotor as varchar(20)
--set @CodPromotor = 'ABG2507911'

/*
create table #veri(
codprestamo varchar(25),
codverificador varchar(15),
codverificadorData varchar(15)
)

insert #veri (codprestamo,codverificador)

SELECT p.codprestamo,s.codverificador
FROM [10.0.2.14].[Finmas].[dbo].[tCaSolicitud] s
inner join [10.0.2.14].[Finmas].[dbo].[tCaprestamos] p on p.codsolicitud=s.codsolicitud and p.codoficina=s.codoficina
where s.codverificador is not null

--select v.*,cl.codusuario

update #veri
set codverificadorData=cl.codusuario
from #veri v
inner join tcspadronclientes cl on cl.codorigen=v.codverificador
*/

---------------

select 
--t3.CodOficina,
t3.PromotorReporte,
--t3.codverificadorData,
t3.Trimestre,
sum(t3.Monto) as SumDesembolso_C1,          --1
count(t3.CodUsuario) as NumDesembolsos_C2,  --2
sum(t3.Saldo2) as SumSaldo_C3,              --3
sum(t3.ContarSaldo2) as NumSaldoMayor0_C4, --4
(sum(t3.Saldo2)/ sum(t3.Monto) ) as C5,      --3/1
(convert(money,sum(t3.ContarSaldo2)) / convert(money,count(t3.CodUsuario)))  as C6  --4/2

from (

	select pcd.CodPrestamo, pcd.CodUsuario ,pcd.CodOficina, pcd.CodProducto,
	pcd.Desembolso, pcd.Monto, pcd.PrimerAsesor, pcd.UltimoAsesor,
	pcd.Estadocalculado,
	t2.NroDiasAtraso,t2.saldo,t2.Estado,
    f.[Promotor reporte] as PromotorReporte
--,v.codverificadorData

	,case  
		when datepart(MM,pcd.Desembolso) >= 1 and datepart(MM,pcd.Desembolso) <= 3 then '1' + 'T - ' + convert(varchar, datepart(yyyy,pcd.Desembolso))
		when datepart(MM,pcd.Desembolso) >= 4 and datepart(MM,pcd.Desembolso) <= 6 then '2' + 'T - ' + convert(varchar, datepart(yyyy,pcd.Desembolso))
		when datepart(MM,pcd.Desembolso) >= 7 and datepart(MM,pcd.Desembolso) <= 9 then '3' + 'T - ' + convert(varchar, datepart(yyyy,pcd.Desembolso))
		when datepart(MM,pcd.Desembolso) >= 10 and datepart(MM,pcd.Desembolso) <= 12 then '4' + 'T - ' + convert(varchar, datepart(yyyy,pcd.Desembolso))
		else ''
		end as Trimestre,
		
	(case when t2.NroDiasAtraso >= 4 then t2.saldo
	else 0
	end ) as Saldo2,
	
	(case when t2.saldo > 0 and t2.NroDiasAtraso >= 4 then 1
	else 0
	end ) as ContarSaldo2

	from tcspadroncarteradet as pcd with(nolock)
	left join (
		select
		c.CodPrestamo, cd.CodUsuario, c.NroDiasAtraso,
		saldo = cd.SaldoCapital + (cd.InteresVigente*1.16) + (cd.InteresVencido*1.16),
		Estado
		from tcscartera as c with(nolock)
		inner join tcscarteradet as cd with(nolock) on cd.Fecha = c.Fecha and cd.CodPrestamo = c.CodPrestamo
		where c.fecha = '20160608'
	) as t2 on t2.CodPrestamo = pcd.CodPrestamo and t2.CodUsuario = pcd.CodUsuario
	left outer join (select distinct codprestamo,[Promotor reporte] from _PromotorFijo with(nolock) ) f on f.codprestamo=pcd.codprestamo
	
--left outer join #veri v on v.codprestamo=pcd.codprestamo
	where pcd.CodOficina not in ('42','97', '98')
	and pcd.CodProducto not in ('167','168')
	and pcd.Desembolso >= '20140101'

	and f.[Promotor reporte] = @CodPromotor

) as t3
--group by t3.CodOficina, t3.Trimestre
--order by t3.CodOficina, t3.Trimestre

--group by t3.codverificadorData, t3.Trimestre
--order by t3.codverificadorData, t3.Trimestre

group by t3.PromotorReporte, t3.Trimestre
order by t3.PromotorReporte, t3.Trimestre


--drop table #veri



GO