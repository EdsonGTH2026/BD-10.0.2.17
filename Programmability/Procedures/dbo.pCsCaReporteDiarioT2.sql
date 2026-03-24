SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

/* TABLA2. INTE DEVENGADO Y COBRADO / COBRANZA */

Create Procedure [dbo].[pCsCaReporteDiarioT2]  @fecha smalldatetime
as 
set nocount on

--declare @fecha smalldatetime
--set @fecha='20220723'

select fecha,intCobradoRenov,intCobradoSinre,DevengadoRenov,DevengadoSinre
,Programado0a7_s,Programado8a30_s,Programado31m_s,CapPagado0a7_s,CapPagado8a30_s
,CapPagado31m_s
,intProgramado0a7_s
,intProgramado8a30_s
,intProgramado31m_s,intPagado0a7_s,intPagado8a30_s,intPagado31m_s
,saldoDPF_Fin,saldoDPF_Ini,saldoVista_Fin,saldoVista_Ini,saldoGarantia_Fin,saldoGarantia_Ini,Captacion_Fin
,Captacion_Ini,PlazoFijo_tasaAnual,Cartera_tasaAnual,gastoxinteres
from FNMGConsolidado.dbo.tCaReporteDiario
where fecha=@fecha
GO