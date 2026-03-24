SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--	Drop Procedure pCsSeguros
--	Exec pCsSeguros 'MLOPEZC', '02', '006LCS0409691'
/*
SELECT  Top 1   Fecha, Usuario, CodAseguradora, NumPoliza
FROM         tCsSeguros
WHERE     (NumPoliza IN
                          (SELECT     MAX(tCsSeguros.NumPoliza) AS Expr1
FROM         tCsSeguros INNER JOIN
                      tCsSegurosBene ON tCsSeguros.CodAseguradora = tCsSegurosBene.CodAseguradora AND tCsSeguros.CodOficina = tCsSegurosBene.CodOficina AND 
                      tCsSeguros.NumPoliza = tCsSegurosBene.NumPoliza
WHERE     (tCsSeguros.CodAseguradora = '01'))) AND (CodAseguradora = '01')
Order by NewID()                            
*/

CREATE Procedure [dbo].[pCsSeguros]
	@Usuario			Varchar(50),
	@CodAseguradora 	Varchar(2),
	@NumPoliza			Varchar(50)
As

Declare @Firma 		Varchar(100)
Declare @Folio		Varchar(100)
Declare @CodOficina Varchar(4)
Declare @Producto	Int

Declare @bDireccion	Bit

Declare @DescOficina	Varchar(100)
Declare @Direccion		Varchar(500)
Declare @PaginaWeb		Varchar(50)
Declare @Telmex			Varchar(50)
Declare @Fax			Varchar(50)
Declare @Firmado		Varchar(100)
Declare @Correo			Varchar(100)
Declare @LineaGratuita	Varchar(50)

Set @Folio = @CodAseguradora + '-' + @NumPoliza
Exec pCsFirmaElectronica @Usuario, 'SE', @Folio, @Firma Out

SELECT   @CodOficina = CodOficina
FROM     tSgUsuarios
WHERE   (Usuario = @Usuario)

Select	@Producto = CodProdSeguro From tCsSeguros
Where	CodAseguradora = @CodAseguradora And NumPoliza = @NumPoliza And CodOficina = @CodOficina

SELECT    @bDireccion		= DireccionAseguradora
FROM      tCsSegurosProd
WHERE     (CodAseguradora	= @CodAseguradora) AND (CodProdSeguro = @Producto)

Update tCsSeguros
Set		Firma			= @Firma,
		Usuario			= @Usuario
Where	CodAseguradora	= @CodAseguradora And NumPoliza = @NumPoliza And CodOficina = @CodOficina

SELECT	@DescOficina	= tClOficinas.DescOficina, 
		@Direccion		= tClOficinas.Direccion + ', ' + vGnlUbigeo.Direccion + ' CP. ' + tClOficinas.CodPostal, 
		@PaginaWeb		= tClOficinas.PaginaWeb, 
		@Telmex			= tClOficinas.Telmex, 
        @Fax			= tClOficinas.Fax, 
        @Firmado		= dbo.fduCambiarFormato(SUBSTRING(vGnlUbigeo.CP2_Municipio, 8, 100)), 
        @Correo			= tClOficinas.Correo,
        @LineaGratuita	= tClOficinas.LineaGratuita
FROM    tClOficinas INNER JOIN vGnlUbigeo ON tClOficinas.CodUbiGeo = vGnlUbigeo.CodUbiGeo
Where   tClOficinas.CodOficina = @CodOficina                       

If @bDireccion = 1
Begin
	SELECT	@DescOficina	= tCsSegurosAseguradora.Descripcion, 
			@Direccion		= tCsSegurosAseguradora.Direccion + ', ' + vGnlUbigeo.Direccion + ' CP. ' + vGnlUbigeo.CodPostal, 
			@PaginaWeb		= tCsSegurosAseguradora.PaginaWeb, 
			@Telmex			= tCsSegurosAseguradora.Telefono, 
			@Fax			= tCsSegurosAseguradora.Fax, 
			@Correo			= tCsSegurosAseguradora.Correo,
			@LineaGratuita	= tCsSegurosAseguradora.LineaGratuita
	FROM    tCsSegurosAseguradora INNER JOIN
			vGnlUbigeo ON tCsSegurosAseguradora.Ubigeo = vGnlUbigeo.CodUbiGeo
	WHERE   (tCsSegurosAseguradora.CodAseguradora = @CodAseguradora)
End

/*
Print @Firma
Print @CodAseguradora
Print @NumPoliza
Print @CodOficina 
*/

CREATE TABLE #SSS 
	(
		[CodUsuario]		[char]		(15) COLLATE Modern_Spanish_CI_AI NOT NULL ,
		[NombreCompleto]	[varchar]	(120) COLLATE Modern_Spanish_CI_AI NULL ,
		[FechaNacimiento]	[datetime]	NULL ,
		[Sexo]				[bit]		NOT NULL,
		[Paterno]			[varchar]	(30) COLLATE Modern_Spanish_CI_AI NULL ,
		[Materno]			[varchar]	(30) COLLATE Modern_Spanish_CI_AI NULL ,
		[Nombres]			[varchar]	(50) COLLATE Modern_Spanish_CI_AI NULL,
		[CodDocIden]		[varchar]	(10) COLLATE Modern_Spanish_CI_AI NULL,
		[DI]				[varchar]	(50) COLLATE Modern_Spanish_CI_AI NULL
	) 

-- Se elimina Clientes cuyo codigos no estan relacionado a la base actual de clientes
DELETE FROM tCsSegurosBene
WHERE     ((CodAseguradora + CodOficina + NumPoliza + CodUsuario) IN
                          (SELECT     tCsSegurosBene.CodAseguradora + tCsSegurosBene.CodOficina + tCsSegurosBene.NumPoliza + tCsSegurosBene.CodUsuario
                            FROM          tCsSegurosBene LEFT OUTER JOIN
                                                   vUsUsuarios ON tCsSegurosBene.CodUsuario = vUsUsuarios.CodUsuario
                            WHERE      (vUsUsuarios.CodUsuario IS NULL) AND (tCsSegurosBene.CodAseguradora = @CodAseguradora) AND (tCsSegurosBene.NumPoliza = @NumPoliza) AND 
                                                   (tCsSegurosBene.CodOficina = @CodOficina)))      
Print 'KEMY----------------------'
Insert Into #SSS
SELECT        CodUsuario, NombreCompleto, FechaNacimiento, Sexo, Paterno, Materno, Nombres, CodDocIden, DI
FROM          vUsUsuarios
WHERE        (CodUsuario IN
                             (SELECT DISTINCT tCsSeguros.codusuarioase
                               FROM         tCsSeguros LEFT OUTER JOIN
									  tCsSegurosBene ON tCsSeguros.CodAseguradora = tCsSegurosBene.CodAseguradora AND tCsSeguros.NumPoliza = tCsSegurosBene.NumPoliza AND 
									  tCsSeguros.CodOficina = tCsSegurosBene.CodOficina
                               WHERE        (tCsSeguros.codaseguradora = @CodAseguradora) AND (tCsSeguros.numpoliza = @NumPoliza) AND (tCsSeguros.codoficina = @CodOficina)
                               UNION
                               SELECT DISTINCT tCsSeguros_2.codusuariopag
                               FROM            tCsSeguros AS tCsSeguros_2 INNER JOIN
                                                        tCsSegurosBene AS tCsSegurosBene_2 ON tCsSeguros_2.codaseguradora = tCsSegurosBene_2.codaseguradora AND 
                                                        tCsSeguros_2.numpoliza = tCsSegurosBene_2.numpoliza AND tCsSeguros_2.codoficina = tCsSegurosBene_2.codoficina
                               WHERE        (tCsSeguros_2.codaseguradora = @CodAseguradora) AND (tCsSeguros_2.numpoliza = @NumPoliza) AND (tCsSeguros_2.codoficina = @CodOficina)
                               UNION
                               SELECT DISTINCT tCsSegurosBene_1.codusuario
                               FROM            tCsSeguros AS tCsSeguros_1 INNER JOIN
                                                        tCsSegurosBene AS tCsSegurosBene_1 ON tCsSeguros_1.codaseguradora = tCsSegurosBene_1.codaseguradora AND 
                                                        tCsSeguros_1.numpoliza = tCsSegurosBene_1.numpoliza AND tCsSeguros_1.codoficina = tCsSegurosBene_1.codoficina
                               WHERE        (tCsSeguros_1.codaseguradora = @CodAseguradora) AND (tCsSeguros_1.numpoliza = @NumPoliza) AND (tCsSeguros_1.codoficina = @CodOficina)))

Print @CodOficina 
Print @CodAseguradora
Print @NumPoliza
                                                           
SELECT     @Firma AS Firma, dbo.fduRellena('0', tCsSeguros.CodOficina, 3, 'D') + '/' + tCsSeguros.CodAseguradora + '-' + dbo.fduRellena('0', tCsSeguros.CodProdSeguro, 3, 'D') 
                      + '-' + tCsSeguros.NumPoliza AS Folio, @DescOficina AS DescOficina, @Direccion AS Direccion, @PaginaWeb AS PaginaWeb, @Telmex AS TelMex, @Fax AS Fax, 
                      @Correo AS Correo, @Firmado AS Firmado, tClEmpresas.DescEmpresa, @LineaGratuita AS LineaGratuita, tCsSegurosAseguradora.Descripcion, 
                      vUsUsuarios.NombreCompleto AS Asegurado, vUsUsuarios.FechaNacimiento, tUsClSexo.Genero, tCsSeguros.Ocupacion, tCsSeguros.fecha AS IngresoSeguro, 
                      tCsSeguros.montoseguro, tCsSeguros.InterruLab, tCsSeguros.Enfermo, vUsUsuarios_1.NombreCompleto AS Beneficiario, tCsSegurosBene.porcentaje, 
                      tCsClParentesco.Descripcion AS Parentesco, tCsSegurosProd.Nota, tCsSegurosProd.Descripcion AS Producto, vUsUsuarios.Paterno AS AP, 
                      vUsUsuarios.Materno AS AM, vUsUsuarios.Nombres AS AN, tCsSeguros.Direccion AS ADireccion, tCsSeguros.Telefono AS ATelefono, 
                      tCsSegurosAseguradora.Administrado, RIGHT(LTRIM(RTRIM(vUsUsuarios.CodUsuario)), 10) AS CodUsuario, LTRIM(RTRIM(vUsUsuarios.CodDocIden)) 
                      + ': ' + LTRIM(RTRIM(vUsUsuarios.DI)) AS Identificacion
FROM         tClEmpresas CROSS JOIN
                      tUsClSexo RIGHT OUTER JOIN
                      tCsSegurosBene INNER JOIN
                          (SELECT     *
                            FROM          [#SSS] AS [#SSS_1]) AS vUsUsuarios_1 ON tCsSegurosBene.CodUsuario = vUsUsuarios_1.CodUsuario LEFT OUTER JOIN
                      tCsClParentesco ON tCsSegurosBene.codparentesco = tCsClParentesco.CodParentesco RIGHT OUTER JOIN
                      tCsSegurosProd INNER JOIN
                      tCsSeguros LEFT OUTER JOIN
                      tCsSegurosAseguradora ON tCsSeguros.CodAseguradora = tCsSegurosAseguradora.CodAseguradora ON 
                      tCsSegurosProd.codprodseguro = tCsSeguros.CodProdSeguro AND tCsSegurosProd.codaseguradora = tCsSeguros.CodAseguradora INNER JOIN
                          (SELECT     *
                            FROM          [#SSS]) AS vUsUsuarios ON tCsSeguros.codusuarioase = vUsUsuarios.CodUsuario ON 
                      tCsSegurosBene.CodAseguradora = tCsSeguros.CodAseguradora AND tCsSegurosBene.NumPoliza = tCsSeguros.NumPoliza AND 
                      tCsSegurosBene.CodOficina = tCsSeguros.CodOficina ON tUsClSexo.Sexo = vUsUsuarios.Sexo                      
WHERE     (tCsSeguros.CodAseguradora = @CodAseguradora) AND (tCsSeguros.NumPoliza = @NumPoliza) AND (tClEmpresas.Activo = 1) AND 
                      (tCsSeguros.CodOficina = @CodOficina)

If @@RowCount = 0
Begin
	 Update tCsSeguros Set Firma = '' Where CodAseguradora =  @CodAseguradora And  NumPoliza = @NumPoliza	
End

Drop Table #SSS
GO