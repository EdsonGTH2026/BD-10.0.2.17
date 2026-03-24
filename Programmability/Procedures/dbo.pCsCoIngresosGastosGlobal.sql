SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsCoIngresosGastosGlobal]  @periodo varchar(200)  as

exec [10.0.1.15].finamigo_conta_pro.dbo.pCsCoIngresosGastosGlobal @periodo
GO