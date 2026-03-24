SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--SOLICITUDES GENERADAS POR SUCURSAL DESDE EL DIA 01 DEL MES
CREATE procedure [dbo].[pCsSolGenPorSucDesdeDiaUnoMes] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on
---COBRANZA POR DIA--

--declare @fecha smalldatetime
--set @fecha = '20190522'
 
declare @fecini smalldatetime
set @fecini = dbo.fdufechaaperiodo( @fecha) + '01'
--select @fecini

select c.codoficina, o.NomOficina AS sucursal, 
c.codsolicitud, c.montoaprobado, c.fechasolicitud, CodAsesor
,e.nombrecompleto promotor
from [10.0.2.14].finmas.dbo.tcasolicitud c 
INNER JOIN [10.0.2.14].finmas.dbo.tClOficinas o  ON c.CodOficina=o.CodOficina 
LEFT OUTER JOIN [10.0.2.14].finmas.dbo.tUsUsuarios e  ON e.CodUsuario=c.CodAsesor
where fechasolicitud >= @fecini and len (c.codsolicitud)<=12

GO