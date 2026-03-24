SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCboClaseAhorro]

As 
SELECT DISTINCT Cast(tAhClTipoProducto.idTipoProd As Varchar(10)) AS Cartera, tAhClTipoProducto.DescTipoProd AS Descripcion
FROM         tAhClTipoProducto INNER JOIN
                      tAhProductos ON tAhClTipoProducto.idTipoProd = tAhProductos.idTipoProd
UNION
SELECT     Cartera = 'TODAS', Descripcion = 'TODAS'
GO