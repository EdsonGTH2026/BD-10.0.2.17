SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pCsRptCaCosechasPorOficina] (@codoficina varchar(3))
as

	select 
	t3.CodOficina,
	t3.sucursal,
	t3.PromotorReporte,
	t3.Trimestre,
	sum(t3.Monto) as SumDesembolso_C1,          --1
	count(t3.CodUsuario) as NumDesembolsos_C2,  --2
	sum(t3.Saldo2) as SumSaldo_C3,              --3
	sum(t3.ContarSaldo2) as NumSaldoMayor0_C4, --4
	(sum(t3.Saldo2)/ sum(t3.Monto) ) as 'CER@4 Saldo', --C5,      --3/1
    --convert(varchar,(sum(t3.Saldo2)/ sum(t3.Monto) )) as 'CER@4 Saldo', --C5,      --3/1
	(convert(money,sum(t3.ContarSaldo2)) / convert(money,count(t3.CodUsuario)))  as 'CER@4 Numero' --C6  --4/2	

	,(case 
	when (sum(t3.Saldo2)/ sum(t3.Monto)) >=0.0 and (sum(t3.Saldo2)/ sum(t3.Monto)) <=0.4 then 'EXELENTE'
	when (sum(t3.Saldo2)/ sum(t3.Monto)) >=0.4 and (sum(t3.Saldo2)/ sum(t3.Monto)) <=0.6  then 'ACEPTABLE'
	else 'NO ACEPTABLE'
	end
	 ) as StatusSaldo
	
	,(case 
	when (convert(money,sum(t3.ContarSaldo2)) / convert(money,count(t3.CodUsuario))) >=0.0 and (convert(money,sum(t3.ContarSaldo2)) / convert(money,count(t3.CodUsuario))) <=0.4 then 'EXELENTE'
	when (convert(money,sum(t3.ContarSaldo2)) / convert(money,count(t3.CodUsuario))) >=0.4 and (convert(money,sum(t3.ContarSaldo2)) / convert(money,count(t3.CodUsuario))) <=0.6  then 'ACEPTABLE'
	else 'NO ACEPTABLE'
	end
	 ) as StatusNumero
	
	from 
	
	tCsCaCosechasBase  as t3
	where t3.CodOficina = @codoficina
and t3.PromotorReporte <> 'HUERFANO'
	
	group by t3.CodOficina,t3.sucursal,t3.PromotorReporte, t3.Trimestre
	order by t3.CodOficina, t3.Trimestre
GO