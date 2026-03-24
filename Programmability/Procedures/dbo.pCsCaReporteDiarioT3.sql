SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* TABLA3. SALDO CARTERA VIGENTE  */

Create Procedure [dbo].[pCsCaReporteDiarioT3]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

declare @fecini smalldatetime
set @fecini =cast(dbo.fdufechaaperiodo(@fecha)+'01' as smalldatetime)  

select c.fecha fecha
,sum(t.saldocapital)saldoTotal
from tcscarteradet t with(nolock)
inner join tcscartera c with(nolock) on c.fecha=t.fecha and c.codprestamo=t.codprestamo
where c.codoficina not in('97','231') and c.estado='VIGENTE'
and t.fecha>=@fecini
and t.fecha<=@fecha
group by  c.fecha
order by c.fecha
GO