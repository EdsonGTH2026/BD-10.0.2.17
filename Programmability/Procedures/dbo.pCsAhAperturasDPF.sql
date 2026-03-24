SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE  [dbo].[pCsAhAperturasDPF] @fecI smalldatetime, @fecF smalldatetime
as
--declare @fecI  smalldatetime
--declare @fecF  smalldatetime
--set @fecI='20170101'
--set @fecF='20170130'

	select a.codoficina,o.nomoficina sucursal,a.codproducto,p.Abreviatura,cl.nombrecompleto 'NombreCliente',a.codcuenta,a.fraccioncta,a.renovado,a.fecapertura
	,a.feccancelacion 'FechaCierre',ah.saldocuenta,ah.TasaInteres,ah.Plazo
	from tcspadronahorros a with(nolock)
	inner join tcspadronclientes cl with(nolock) on cl.codusuario=a.codusuario
	inner join tcsahorros ah with(nolock) on ah.codcuenta=a.codcuenta and ah.fraccioncta=a.fraccioncta and ah.renovado=a.renovado and ah.fecha=a.fechacorte
	inner join tcloficinas o with(nolock) on o.codoficina=a.codoficina
	LEFT OUTER JOIN	tAhProductos p with(nolock) ON a.CodProducto = p.idProducto
	where a.estadocalculado<>'CC' and a.fecapertura>=@fecI and a.fecapertura<=@fecF
GO