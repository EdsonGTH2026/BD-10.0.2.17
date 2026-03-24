SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsCACartaPC_Promotor] @fecha smalldatetime,@codpromotor varchar(15),@codoficina varchar(4)
as
set nocount on

--COMENTAR
/*
Declare @fecha smalldatetime
declare @codpromotor varchar(15)
declare @codoficina varchar(4)

set @fecha='20180515'
set @codpromotor='CGM891025M5RR3'
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

print '############################# DATOS PROMOTOR ####################################'
print '############################# DATOS PROMOTOR ####################################'

--########################################### NIVEL
declare @nivel int
declare @saldocartera money
select 
--@saldocartera=sum(d.saldocapital+ (d.interesvigente+d.interesvencido)*1.16) --saldo
@saldocartera= sum(case when c.nrodiasatraso<=29 and (d.saldocapital+(d.interesvigente+d.interesvencido)*1.16) >= 500 then d.saldocapital+(d.interesvigente+d.interesvencido)*1.16 else 0 end) 
from tcscartera c with(nolock)
inner join tcscarteradet d with(nolock) on c.codprestamo=d.codprestamo and c.codusuario=d.codusuario and c.fecha=d.fecha
where c.fecha= @fecini2 --@fecha
and c.codasesor=@codpromotor
and c.codoficina=@codoficina
and c.cartera='ACTIVA'
and c.codprestamo not in (select CodPrestamo from tCsRptEMIPC_CreditosEliminados where FechaInicial <= @fecha and FechaFinal >= @fecha and activo = 1)  --OSC, VALIDAR

set @nivel = case when @saldocartera<=800000 then 1 
				  when @saldocartera>800000 and @saldocartera<=1000000 then 2
				  when @saldocartera>1000000 and @saldocartera<=1200000 then 3
				  when @saldocartera>1200000 then 4 else 0 end

--Actualiza el Nivel del Promotor
--update tCsRptEMIPC_Promotor set
--Nivel = convert(varchar,@nivel)
--where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina


/* ################################################ DATOS PROMOTOR */

declare @Promotor varchar(50)
declare @Oficina varchar(50)

select @Promotor = NombreCompleto from tCsPadronClientes where codusuario = @codpromotor
select @Oficina = NomOficina from tClOficinas where codoficina = @codoficina

delete from tCsRptEMIPC_Promotor where convert(varchar,Fecha,112) = convert(varchar,@fecha,112) and CodPromotor = @codpromotor and CodOficina = @codoficina

insert into tCsRptEMIPC_Promotor (Fecha, CodPromotor, CodOficina, Promotor, Oficina, Nivel)
values (@fecha, @codpromotor, @codoficina, @Promotor, @Oficina, convert(varchar,@nivel))

--Regresa los datos
--select * from tCsRptEMIPC_Promotor where Fecha = @fecha and CodPromotor = @codpromotor and CodOficina = @codoficina



GO