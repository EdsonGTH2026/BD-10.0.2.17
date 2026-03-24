SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACaCosechasBaseOficina]
as
--truncate table tCsACaCosechasBaseOficina
--insert into tCsACaCosechasBaseOficina
--select t3.CodOficina,t3.Trimestre,sum(t3.Monto) as SumDesembolso_C1,          --1
--count(t3.CodUsuario) as NumDesembolsos_C2,  --2
--sum(t3.Saldo2) as SumSaldo_C3,              --3
--sum(t3.ContarSaldo2) as NumSaldoMayor0_C4, --4
--(sum(t3.Saldo2)/ sum(t3.Monto) ) as 'CER@4 Saldo', --C5,      --3/1
--(convert(money,sum(t3.ContarSaldo2)) / convert(money,count(t3.CodUsuario)))  as 'CER@4 Numero' --C6  --4/2
--from tCsCaCosechasBase  as t3
--group by t3.CodOficina, t3.Trimestre
--order by t3.CodOficina, t3.Trimestre

GO