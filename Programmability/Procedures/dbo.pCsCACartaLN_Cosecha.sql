SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsCACartaLN_Cosecha] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on
/*
--COMENTAR
Declare @fecha smalldatetime
declare @codoficina varchar(4)

set @fecha='20180515'
set @codoficina='37'
*/

Declare @fecini smalldatetime
Declare @fecini2 smalldatetime
Declare @fecano smalldatetime

declare @ncreBM decimal(8,2)
declare @ncreAM decimal(8,2)

set @fecha = convert(varchar,@fecha,112)
set @fecini = dbo.fdufechaatexto(@fecha,'AAAAMM')+'01'
set @fecano = dbo.fdufechaatexto(dateadd(year,-1,@fecha),'AAAAMM')+'01'

set @fecini2 = dateadd(day,-1,@fecini)

--################################################################### COSECHA
PRINT '##################################################################'
PRINT '########################### COSECHA ##############################'
/* Liquidado en el mes */
declare @FechaIniMenos3Meses smalldatetime
set @FechaIniMenos3Meses = dateadd(month,-3,@fecini)


--Limpia la tabla Final
delete from tCsRptEMI_LS_Cosecha where Fecha = convert(varchar,@fecha,112) and CodOficina = @codoficina

--Inserta los datso en la tabla Final
insert into tCsRptEMI_LS_Cosecha (Fecha, CodOficina, periodo, nroliqui, nroreno, PorReno )

select 
convert(varchar,@fecha,112), @codoficina,
c.periodo, 
count(c.codprestamo) as nroliqui,
count(r.codprestamo) as nroreno,
round((count(r.codprestamo)/cast(count(c.codprestamo) as decimal(8,2)))*100,2) as PorReno
from 
(
	Select 
	dbo.fdufechaatexto(p.cancelacion,'AAAAMM') as Periodo, p.codprestamo, p.codusuario, p.primerasesor --count(p.codprestamo) as nroliqui
	from tcspadroncarteradet p with(nolock)
	where p.cancelacion>=@FechaIniMenos3Meses 
	and p.cancelacion<=@fecha
	and p.codoficina = @codoficina 
	and p.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
) as c 
left join
(
	Select dbo.fdufechaatexto(p.desembolso,'AAAAMM') as Periodo, p.codprestamo, p.codusuario, p.primerasesor --count(p.codprestamo) as nroreno
	from tcspadroncarteradet p with(nolock)
	where p.desembolso>=@FechaIniMenos3Meses 
	and p.desembolso<=@fecha
	and p.codoficina = @codoficina 
	and p.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR
) as r
on r.periodo = c.periodo and r.codusuario = c.codusuario
group by c.periodo

--REgresa los datos
--select * from tCsRptEMI_LS_Cosecha where Fecha = convert(varchar,@fecha,112) and CodOficina = @codoficina


GO