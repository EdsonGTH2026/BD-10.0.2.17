SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsPdnPaseProduccion

CREATE Procedure [dbo].[pCsPdnPaseProduccion]
@Usuario 	As Varchar(50),
@Dato		As Varchar(50),
@Ambiente	As Varchar(100)
As
--Set @Usuario 	= 'KVALERA'
--Set @Dato	= 'AH0097'
--Set @Ambiente	= '[DC-FINAMIGO-SRV].Finmas_Cambios01' 

Declare @Firma		Varchar(50)
Declare @Responsable	Varchar(50)
Declare @Sistema 	Varchar(4)
Declare @Revision	Int
Declare @Cuerpo1	Varchar(8000)
Declare @Cuerpo2	Varchar(8000)

--Set @Dato 	= Ltrim(Rtrim(@sistema)) + dbo.FduRellena('0', @Revision, 4, 'D')
Set @Sistema 	= Substring(@Dato, 1, 2)
Set @Revision	= Cast(Substring(@Dato, 3, 4) As Int)

Declare @Servidor	Varchar(100)
Declare @BaseDatos	Varchar(100)

Exec pCsFirmaElectronica @Usuario, 'CS', @Dato, @Firma Out

SELECT     @Responsable = CURP
FROM         tCsEmpleados
WHERE     (DataNegocio = @Usuario)

Insert Into tCsPdnPasoProduccion (CURP, SelloElectronico, Sistema, VMayor, VMenor, VRevision, Ambiente)
SELECT     CURP = @Responsable, Firma = @Firma, CodSistema, UltVerMayor, UltVerMenor, @Revision, @Ambiente
FROM       [BD-FINAMIGO-DC].Finmas.dbo.tSgSistemas tSgSistemas
WHERE     (CodSistema = @Sistema)

SELECT  @Cuerpo1 =   'Siendo las ' + SUBSTRING(CONVERT(VARCHAR(20), tCsFirmaElectronica.Registro, 114), 1, 8) + ' horas de día ' + DATENAME(dw, tCsFirmaElectronica.Registro) 
                      + ' ' + dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'DD') + ' de ' + DATENAME([month], tCsFirmaElectronica.Registro) 
                      + ' de ' + dbo.fduFechaATexto(tCsFirmaElectronica.Registro, 'AAAA') 
                      + ' se hace constar por la presente el Pase a Producción del Sistema de ' + UPPER(tSgSistemas.Nombre) + ' V. ' + CAST(tCsPdnPasoProduccion.VMayor AS Varchar(5)) 
                      + '.' + CAST(tCsPdnPasoProduccion.VMenor AS varchar(5)) + '.' + CAST(tCsPdnPasoProduccion.VRevision AS varchar(5)) 
                      + ' con las siguientes características:' 
FROM         tCsFirmaElectronica INNER JOIN
                      tCsPdnPasoProduccion ON tCsFirmaElectronica.Firma = tCsPdnPasoProduccion.SelloElectronico INNER JOIN
                      tSgSistemas ON tCsPdnPasoProduccion.Sistema = tSgSistemas.CodSistema
WHERE     (tCsFirmaElectronica.Firma = @Firma)

Update tCsPdnPasoProduccion
Set Cuerpo = @Cuerpo1
Where SelloElectronico = @Firma

UPDATE 	[BD-FINAMIGO-DC].Finmas.dbo.tSgSistemas
SET 	UltVerRevision = @Revision, FechaUltAct = Getdate()
WHERE 	CodSistema = @Sistema

UPDATE    tSgSistemas
SET              Nombre = O.nombre, Descripcion = o.descripcion, ultvermayor = o.ultvermayor, ultvermenor = o.ultvermenor, ultverrevision = o.ultverrevision, 
                      fechaultact = o.fechaultact, Fechareg = o.fechareg, Activo = o.activo, Fechainactivo = o.fechainactivo
FROM         [BD-FINAMIGO-DC].Finmas.dbo.tSgSistemas O INNER JOIN
                      tSgSistemas ON O.CodSistema = tSgSistemas.CodSistema

SELECT     tCsPdnPasoProduccion.CURP, tCsPdnPasoProduccion.SelloElectronico, tCsPdnPasoProduccion.Sistema, tCsPdnPasoProduccion.VMayor, 
                      tCsPdnPasoProduccion.VMenor, tCsPdnPasoProduccion.VRevision, tCsPdnPasoProduccion.Ambiente, tCsPdnPasoProduccion.Cuerpo, tCsEmpleados.Paterno, 
                      tCsEmpleados.Materno, tCsEmpleados.Nombres, tCsFirmaElectronica.Registro, tSgSistemas.Nombre, tCsPdnSistemasModificacion.SDesarrollo,  tCsPdnPasoProduccion.Cuerpo
FROM         tCsPdnPasoProduccion INNER JOIN
                      tCsEmpleados ON tCsPdnPasoProduccion.CURP = tCsEmpleados.CURP INNER JOIN
                      tCsFirmaElectronica ON tCsPdnPasoProduccion.SelloElectronico = tCsFirmaElectronica.Firma INNER JOIN
                      tSgSistemas ON tCsPdnPasoProduccion.Sistema = tSgSistemas.CodSistema INNER JOIN
                      tCsPdnSistemasModificacion ON tCsPdnPasoProduccion.Sistema = tCsPdnSistemasModificacion.CodSistema AND 
                      tCsPdnPasoProduccion.VMayor = tCsPdnSistemasModificacion.VerMayor AND tCsPdnPasoProduccion.VMenor = tCsPdnSistemasModificacion.VerMenor AND 
                      tCsPdnPasoProduccion.VRevision = tCsPdnSistemasModificacion.VerRevision
Where tCsPdnPasoProduccion.SelloElectronico = @Firma

/*
SELECT     CodSistema, Nombre, UltVerRevision
FROM         [BD-FINAMIGO-SRV].Finmas.dbo.tSgSistemas tSgSistemas
WHERE     (Activo = 1)
*/
GO