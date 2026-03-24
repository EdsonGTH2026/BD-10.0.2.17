SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
-- Drop Procedure pCsCaDesembolsosRecuperaciones 
-- Exec pCsCaDesembolsosRecuperacionesVs2  '20140424'
CREATE PROCEDURE  [dbo].[pCsCaDesembolsosRecuperacionesVs2Res] @Fecha SmalldateTime
AS
--declare @Fecha SmalldateTime
--set @Fecha='20140620'

declare @periodo varchar(6)
set @periodo=dbo.fduFechaAPeriodo(@fecha)

SELECT dbo.fdufechaaperiodo(desembolso) periodo
,count(distinct(case when secuenciacliente=1 then codprestamo else null end)) nrodesemanualN
,count(distinct(case when secuenciacliente=1 then codusuario else null end)) nrodesemanualNClie
,sum(case when secuenciacliente=1 then monto else null end) montodesemanualN
,count(distinct(case when secuenciacliente>1 then codprestamo else null end)) nrodesemanualR
,count(distinct(case when secuenciacliente>1 then codusuario else null end)) nrodesemanualRClie
,sum(case when secuenciacliente>1 then monto else null end) montodesemanualR
,count(distinct(codprestamo)) nro
,count(distinct(codusuario)) nroClie
,sum(monto) monto
FROM tCsPadronCarteraDet with(nolock)
where desembolso>=substring(@periodo,1,4)+'0101' and desembolso<=@fecha
and TipoReprog='SINRE' and codoficina<>'98'
group by dbo.fdufechaaperiodo(desembolso)
order by dbo.fdufechaaperiodo(desembolso) desc
GO