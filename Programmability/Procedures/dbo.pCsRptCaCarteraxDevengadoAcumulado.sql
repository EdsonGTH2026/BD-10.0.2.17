SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsRptCaCarteraxDevengadoAcumulado] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20140916'

declare @primerdia smalldatetime
select @primerdia=primerdia from tclperiodo where primerdia<=@fecha and ultimodia>=@fecha

declare @primerdiaanual smalldatetime
set @primerdiaanual = cast(year(@fecha) as char(4))+'0101'

SELECT pc.Nombreprod producto
,SUM(cd.InteresDevengado) AS DevengadoAcumulado
,SUM(case when cd.Fecha>=@primerdia then cd.InteresDevengado else 0 end) AS DevengadoMes
,SUM(case when cd.Fecha=@fecha then cd.saldocapital+cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido else 0 end) AS SaldocarteraMes
,SUM(case when cd.Fecha=@fecha then cd.sreservacapital+cd.sreservainteres else 0 end) AS EstimacionMes
FROM tCsCartera c with(nolock)  inner join tCsCarteraDet cd with(nolock) 
on c.codprestamo=cd.codprestamo and c.fecha=cd.fecha
left outer join tcspadroncarteraotroprod op on op.codprestamo=c.codprestamo
inner join tcaproducto pc on pc.codproducto=isnull(op.codproducto,c.codproducto)
WHERE (cd.Fecha>=@primerdiaanual) AND (cd.Fecha<=@fecha)
and c.cartera='ACTIVA' and c.codoficina<'100'
GROUP BY pc.Nombreprod
having SUM(cd.InteresDevengado)<>0
GO