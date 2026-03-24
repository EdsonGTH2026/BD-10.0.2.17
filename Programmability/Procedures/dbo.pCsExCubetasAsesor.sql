SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsExCubetasAsesor] @fecha smalldatetime,@codasesor varchar(15),@n int
as
--declare @fecha smalldatetime
--set @fecha ='20131231'
--declare @codasesor varchar(15)
--set @codasesor='MHJ2410851'--'CSA1010881'
--declare @n int
--set @n=1

declare @s varchar(4000)
set @s = 'SELECT c.Fecha, replicate(''0'',2-len(c.CodOficina)) + rtrim(c.CodOficina) + '' '' + o.nomoficina sucursal '
set @s = @s + ',c.CodPrestamo,cd.codusuario,cl.nombrecompleto cliente '
set @s = @s + ',cd.saldocapital + cd.interesvigente+cd.interesvencido+cd.moratoriovigente+cd.moratoriovencido saldocartera '
set @s = @s + ',cd.saldocapital,cd.montodesembolso '
set @s = @s + 'FROM tCsCartera c with(nolock) inner join tcscarteradet cd with(nolock) on c.fecha=cd.fecha and c.codprestamo=cd.codprestamo '
set @s = @s + 'inner join tcloficinas o with(nolock) on o.codoficina=c.codoficina '
set @s = @s + 'inner join tcspadronclientes cl with(nolock) on cl.codusuario=cd.codusuario '
set @s = @s + 'where c.fecha='''+dbo.fduFechaATexto(@fecha,'AAAAMMDD')+''' and c.cartera=''ACTIVA'' '
set @s = @s + 'and c.codasesor='''+@codasesor+''' '

if (@n=1) set @s = @s + 'and c.Estado<>''VENCIDO'' and c.NroDiasAtraso=0 '
if (@n=2) set @s = @s + 'and c.Estado<>''VENCIDO'' and c.NroDiasAtraso>0 and c.NroDiasAtraso<8'
if (@n=3) set @s = @s + 'and c.Estado<>''VENCIDO'' and c.NroDiasAtraso>=8 and c.NroDiasAtraso<16'
if (@n=4) set @s = @s + 'and c.Estado<>''VENCIDO'' and c.NroDiasAtraso>=16 and c.NroDiasAtraso<31'
if (@n=5) set @s = @s + 'and c.Estado<>''VENCIDO'' and c.NroDiasAtraso>=31 and c.NroDiasAtraso<61'
if (@n=6) set @s = @s + 'and c.Estado<>''VENCIDO'' and c.NroDiasAtraso>=61 and c.NroDiasAtraso<90'
if (@n=7) set @s = @s + 'and c.Estado=''VENCIDO'' '

print @s
exec(@s)
GO