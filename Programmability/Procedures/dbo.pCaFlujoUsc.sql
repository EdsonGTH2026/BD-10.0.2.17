SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCaFlujoUsc] @codusuario_finmas varchar(15)
as
declare @codusuario_data varchar(15)

select @codusuario_data=codusuario from tcspadronclientes with(nolock) where codorigen=@codusuario_finmas

declare @NroDiasMaximo_data int
set @NroDiasMaximo_data = (select top 1 NroDiasMaximo from tcspadroncarteradet as x with(nolock)
														where x.codusuario = @codusuario_data
														and x.estadocalculado = 'CANCELADO' 
														order by  x.cancelacion desc)

select p.codusuario,cl.codorigen,max(p.secuenciacliente) secuenciacliente
,max(p.monto) MaxMonto
,@NroDiasMaximo_data as nrodiasmaximo
from tcspadroncarteradet p with(nolock)
inner join tcspadronclientes cl with(nolock) on cl.codusuario=p.codusuario
where p.codusuario=@codusuario_data
group by p.codusuario,cl.codorigen
GO