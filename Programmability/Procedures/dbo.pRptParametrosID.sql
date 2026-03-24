SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pRptParametrosID]
@ID 			Varchar(50),
@Fecha 			SmallDateTime 	OutPut,
@Ubicacion		Varchar(100)	OutPut,
@Nivel1			Varchar(50)		OutPut,
@Nivel2			Varchar(50)		OutPut,
@ClaseCartera	Varchar(100)	OutPut,
@TipoSaldo		Varchar(1000)	OutPut,
@Reporte 		Varchar(50)		OutPut,
@Usuario		Varchar(50)		OutPut

As

SELECT     @Usuario = Valor
FROM         tCsPrID
WHERE     (Id = @Id) AND (Parametro = '@Usuario')

SELECT     @Fecha = Valor, @Reporte = Reporte
FROM         tCsPrID
WHERE     (Id = @Id) AND (Parametro = '@Fecha')
SELECT     @Ubicacion = Valor, @Reporte = Reporte
FROM         tCsPrID
WHERE     (Id = @Id) AND (Parametro = '@Ubicacion')
SELECT     @Nivel1 = Valor, @Reporte = Reporte
FROM         tCsPrID
WHERE     (Id = @Id) AND (Parametro = '@Nivel1')
SELECT     @Nivel2 = Valor, @Reporte = Reporte
FROM         tCsPrID
WHERE     (Id = @Id) AND (Parametro = '@Nivel2')
SELECT     @ClaseCartera = Valor
FROM         tCsPrID
WHERE     (Id = @Id) AND (Parametro = '@ClaseCartera')
SELECT     @TipoSaldo = Valor, @Reporte = Reporte
FROM         tCsPrID
WHERE     (Id = @Id) AND (Parametro = '@TipoSaldo')
SELECT     @Reporte = Valor, @Reporte = Reporte
FROM         tCsPrID
WHERE     (Id = @Id) AND (Parametro = '@Reporte')
GO