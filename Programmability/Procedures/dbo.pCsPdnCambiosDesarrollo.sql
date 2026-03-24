SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsPdnCambiosDesarrollo

CREATE Procedure [dbo].[pCsPdnCambiosDesarrollo]
@Sistema Varchar(10), @Usuario Varchar(50), @Modificacion Varchar(8000)

As
/*
Declare @Sistema Varchar(10), @Usuario Varchar(50), @Modificacion Varchar(8000)
----------------------------------------------------------------------------------------

Set @Usuario 		= 'KVALERA'
Set @Sistema 		= 'TC'
Set @Modificacion 	= ''
*/
------------------------------------------------------------------------------------------
Declare @verMa 		Int, @verMe Int, @verRe Int
Declare @nSistema	Varchar(100)
Declare @Registro	DateTime
Declare @Paterno	Varchar(50), @Materno Varchar(50), @Nombres Varchar(50)

Set @verMa  	= 0
Set @verMe  	= 0
Set @verRe  	= 0
Set @Registro	= GetDate()

--Set @Registro	= '20091030 ' +  CONVERT(VARCHAR(20), GETDATE(), 114)

Set @Modificacion	= dbo.FduFechaAtexto(@Registro, 'AAAA') +  dbo.FduFechaAtexto(@Registro, 'MM') + dbo.FduFechaAtexto(@Registro, 'DD') + ': ' + Ltrim(Rtrim(@Modificacion)) + Case When Right(Ltrim(Rtrim(@Modificacion)), 1) = '.' Then '' Else '.' End

--Exec  pCsCboPdnSistemasVersiones

Select 	@verMa 		= Substring(Version	, 5, 2),
	@verMe 		= Substring(Version	, 8, 3),
	@verRe 		= Substring(Dato	, 3, 4),
	@nSistema	= Sistema 
from (SELECT     CodSistema + dbo.fduRellena('0', UltVerRevision + 1, 4, 'D') AS Dato, '[' + CAST(UltVerMayor AS varchar(5)) + '.' + CAST(UltVerMenor AS varchar(5)) 
                      + '.' + CAST(UltVerRevision + 1 AS varchar(5)) + '] ' + Nombre AS Nombre,   '[' + CodSistema + ' ' + dbo.fduRellena('0', UltVerMayor, 2, 'D') + '.' + dbo.fduRellena('0', UltVerMenor, 3, 'D') + '.' + dbo.fduRellena('0', UltVerRevision, 4, 'D') 
                      + ']' AS Version, Nombre AS Sistema, FechaUltAct
FROM         [BD-FINAMIGO-DC].Finmas.dbo.tSgSistemas tSgSistemas
WHERE     (Activo = 1)) Sistemas where Substring(Dato, 1, 2) = @Sistema

If @verMa Is Null Begin Set @verMa = 0 End
If @verMe Is Null Begin Set @verMe = 0 End
If @verRe Is Null Begin Set @verRe = 0 End

SELECT  @Usuario 	= CURP, 
	@Paterno	= Paterno,
	@Materno	= Materno,
	@Nombres	= Nombres
FROM         tCsEmpleados
WHERE     (DataNegocio = @Usuario)

If @Usuario Is Null Begin Set @Usuario = '' End

IF Not(@verMa = 0 and @verMe = 0 and  @verRe = 0)
Begin
	If @Usuario <> ''
	Begin
		IF Ltrim(Rtrim(Substring(@Modificacion, 11, 100))) <> '.'
		Begin
			Insert Into tCsPdnSistemasModificacion 
				(Registro, 	Codsistema, 	VerMayor, 	VerMenor, 	VerRevision,	CURPDesarrollo,	SDesarrollo)
			Values	(@Registro, 	@Sistema, 	@verMa,		@verMe,		@verRe,		@Usuario,	@Modificacion)		 
		End
	End
End

SELECT  Sistema = @nSistema, VMayor = @verMa, VMenor = @verMe,  tCsPdnSistemasModificacion.VerRevision As VRevision, 
Produccion = Isnull('Ejecutable puesto en Producción el ' + DATENAME(dw, tCsFirmaElectronica.Registro) 
                      + ' ' + dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'DD') + ' de ' + DATENAME([month], tCsFirmaElectronica.Registro) 
                      + ' de ' + dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'AAAA'), 'Ejecutable esta siendo validado'), tCsPdnSistemasModificacion.SDesarrollo, tCsPdnSistemasModificacion.SProduccion,
	Paterno = @Paterno, Materno = @Materno, Nombres = @Nombres
FROM         tCsFirmaElectronica INNER JOIN
                      tCsPdnPasoProduccion ON tCsFirmaElectronica.Firma = tCsPdnPasoProduccion.SelloElectronico RIGHT OUTER JOIN
                      tCsPdnSistemasModificacion ON tCsPdnPasoProduccion.Sistema = tCsPdnSistemasModificacion.CodSistema AND 
                      tCsPdnPasoProduccion.VMayor = tCsPdnSistemasModificacion.VerMayor AND tCsPdnPasoProduccion.VMenor = tCsPdnSistemasModificacion.VerMenor AND 
                      tCsPdnPasoProduccion.VRevision = tCsPdnSistemasModificacion.VerRevision
WHERE     (tCsPdnSistemasModificacion.CodSistema = @Sistema) AND (tCsPdnSistemasModificacion.VerMayor = @verMa) AND (tCsPdnSistemasModificacion.VerMenor = @VerMe)
GO