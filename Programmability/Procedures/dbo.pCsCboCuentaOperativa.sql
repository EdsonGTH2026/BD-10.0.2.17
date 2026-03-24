SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Exec pCsCboCuentaOperativa 105, 'kvalera'
--Exec pCsReporteContrato1 117, 'kvalera', 'ZZZ', '004-CAA000813'
CREATE Procedure [dbo].[pCsCboCuentaOperativa] @Dato Int, @Usuario Varchar(25)
As
--Dato:
--	1	:	Cuentas de Credito.
--	2	:	Certificados y Constancias aperturadas en el día.
--	3	:	Para Cartas de Cobranza.
--	4	:	Libre antes era usado para datos de Servidor Alterno.
--	5	:	Para Plan de Pagos y Zurich.
--	6	:	Para Comite de Créditos.
--	7	:	Para Integrantes del Acta.
--	8	:	Para Adendum de Ahorros.
--	9	:	Seguros Atlas.
--	10	:	Para Registros de Huellas.
--	11	:	Para Registros de Huellas.
--	12	:	Para Registros de Huellas.
--	13	:	Para Registros de Huellas.
--	14	:	Cuenta de Ahorros Aperturadas en el día.

Declare	@Servidor	Varchar(50)
Declare @BaseDatos	Varchar(50)
Declare @Ubicacion 	Varchar(500)
Declare @CUbicacion	Varchar(1000)
Declare @Cadena		Varchar(4000)
Declare @OtroDato	Varchar(500)

Declare @Cad1 		Varchar(4000)
Declare @Cad2 		Varchar(4000)
Declare @Fecha		SmallDateTime

If @Dato > 100 --PARA PRUEBAS VERIFICAR ANTES DE AUMENTAR VALORES A @DATO.
Begin
	Set @Servidor 	= 'DC-FINAMIGO-SRV'
	Set @BaseDatos	= 'Finamigo_Conta_AAs'
	Set @Dato 		= @Dato - 100
End 
Else
Begin
	Set @Servidor 	= 'BD-FINAMIGO-DC'
	Set @BaseDatos	= 'Finmas'
End


CREATE TABLE #Temp (
	[CodPrestamo] 	[varchar] (50) 		COLLATE Modern_Spanish_CI_AI NULL ,
	[Nombre] 		[varchar] (1000) 	COLLATE Modern_Spanish_CI_AI NULL) 

CREATE TABLE #Temp1 (
	[CodPrestamo] 	[varchar] (50) 		COLLATE Modern_Spanish_CI_AI NULL) 

SELECT  @Ubicacion =  Ubicacion
FROM         (SELECT     tSgUsuarios.Usuario, CASE WHEN ltrim(rtrim(isnull(tClZona.Zona, ''))) <> '' THEN ltrim(rtrim(isnull(tClZona.Zona, ''))) 
                                              WHEN tSgUsuarios.TodasOficinas = 1 THEN 'ZZZ' ELSE tSgUsuarios.CodOficina END AS Ubicacion
                       FROM          tSgUsuarios LEFT OUTER JOIN
                                              tClZona ON tSgUsuarios.CodUsuario = tClZona.Responsable) Datos
WHERE     (Usuario = @Usuario)

Exec pGnlCalculaParametros 1, @Ubicacion, 	@CUbicacion 	Out, 	@Ubicacion 	Out,  @OtroDato Out

If @Dato In (1)	-- Cuentas de Credito 1 es la base actual del FINMAS y 4 es el Paralelo en el Servidor alterno.
Begin

	Set @Cadena = 'SELECT CodPrestamo, Nombre FROM ['+ @Servidor +'].['+ @BaseDatos +'].dbo.vCaListaCreditosAprobados D '
	Set @Cadena = @Cadena + 'WHERE (CodOficina IN ('+ @CUbicacion +')) ORDER BY CodPrestamo DESC '
	/*
	Set @Cadena = 'SELECT CodPrestamo, Nombre FROM ['+ @Cad1 +'].Finmas.dbo.vCaListaCreditosAprobados vCaListaCreditosAprobados '
	Set @Cadena = @Cadena + 'WHERE (CodPrestamo NOT IN (SELECT DISTINCT CodPrestamo FROM [BD-FINAMIGO-DC].Finmas.dbo.vCsAhorrosCreditos '
	Set @Cadena = @Cadena + 'vCsAhorrosCreditos WHERE (CodCuenta NOT IN ((SELECT Cuenta FROM tCsFirmaDocumentos WHERE Tipo = ''Adendum Ahorros''))))) AND (CodOficina IN ('+ @CUbicacion +')) '
	Set @Cadena = @Cadena + 'ORDER BY CodPrestamo DESC '
	--*/
End
If @Dato In (2, 14)		--  2	= Certificados y Constancias aperturadas en el día.
						-- 14	= Todas las cuentas.
Begin
	If @Dato	= 2 
	Begin 
		Set @Cad1 = 'WHERE (Certificado = 1) OR (Constancia = 1)' 
	End
	Else
	Begin
		Set @Cad1 = '' 
	End
		
	Set @Cadena = 'SELECT vAhCuentasAhorros.CodCuenta AS CodPrestamo, vAhCuentasAhorros.CodCuenta + '' ['' + vAhCuentasAhorros.NombreCompleto + '']'' AS Nombre '
	Set @Cadena	= @Cadena + 'FROM [BD-FINAMIGO-DC].Finmas.dbo.vAhCuentasAhorros vAhCuentasAhorros INNER JOIN '
	Set @Cadena = @Cadena + '[BD-FINAMIGO-DC].Finmas.dbo.tClParametros tClParametros ON vAhCuentasAhorros.CodOficina = tClParametros.CodOficina '
--	Set @Cadena = @Cadena + 'AND vAhCuentasAhorros.FechaApertura = tClParametros.FechaProceso '
	Set @Cadena = @Cadena + 'WHERE (vAhCuentasAhorros.idProducto IN '
	Set @Cadena = @Cadena + '(SELECT idProducto '
	Set @Cadena = @Cadena + 'FROM tAhProductos '
	Set @Cadena = @Cadena + @Cad1 +')) AND (vAhCuentasAhorros.CodOficina IN ('+ @CUbicacion +'))'
	Set @Cadena = @Cadena + ' and (vAhCuentasAhorros.FechaApertura<=tClParametros.FechaProceso) '
	Set @Cadena = @Cadena + ' and (vAhCuentasAhorros.FechaApertura>=dateadd(day,-3,tClParametros.FechaProceso))'

End
If @Dato = 3		-- Para Cartas de Cobranza de Crédito
Begin
	Declare CurCarta Cursor For 
		SELECT     Texto = Replace(Texto1, ' ', ''), Condicion
		FROM         tCsRPTClausulas
		WHERE     (Tipo = 'Carta') AND (Orden = 100) AND (Activo = 1) And Ltrim(Rtrim(Isnull(Texto1, ''))) <> ''
	Open CurCarta
	Fetch Next From CurCarta Into @Cad1, @Cad2
	While @@Fetch_Status = 0
	Begin
		Set @Cadena = 'Insert Into #Temp '
		Set @Cadena = @Cadena + 'SELECT tCsCartera.CodPrestamo, ''[' + @Cad1 + '  '' + tCsCartera.CodPrestamo + ''  '' + ISNULL(tCsCarteraGrupos.NombreGrupo, tCsPadronClientes.NombreCompleto) + '']'' AS Nombre '
		Set @Cadena = @Cadena + 'FROM tCsCartera LEFT OUTER JOIN '
		Set @Cadena = @Cadena + 'tCsPadronClientes ON tCsCartera.CodUsuario = tCsPadronClientes.CodUsuario LEFT OUTER JOIN '
		Set @Cadena = @Cadena + 'tCsCarteraGrupos ON tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo '
		Set @Cadena = @Cadena + 'WHERE (tCsCartera.Fecha IN '
		Set @Cadena = @Cadena + '(SELECT fechaconsolidacion '
		Set @Cadena = @Cadena + 'FROM vcsfechaconsolidacion)) AND '+ @Cad2 +' AND (tCsCartera.CodOficina IN ('+ @CUbicacion +')) AND '
		Set @Cadena = @Cadena + '(tCsCartera.CodPrestamo NOT IN '
		Set @Cadena = @Cadena + '(select codprestamo from [BD-FINAMIGO-DC].Finmas.dbo.vCaPagoRegdia))'
/*
		Set @Cadena = @Cadena + '(SELECT DISTINCT tCaPagoReg.CodPrestamo '
		Set @Cadena = @Cadena + 'FROM [BD-FINAMIGO-DC].Finmas.dbo.tCaPagoReg tCaPagoReg INNER JOIN '
		Set @Cadena = @Cadena + '[BD-FINAMIGO-DC].Finmas.dbo.tClParametros tClParametros ON tCaPagoReg.CodOficina = tClParametros.CodOficina AND '
		Set @Cadena = @Cadena + 'tCaPagoReg.FechaPago = tClParametros.FechaProceso '
		Set @Cadena = @Cadena + 'WHERE (tCaPagoReg.Extornado = 0))) '
*/
		Print @Cadena
		Exec (@Cadena)
	Fetch Next From CurCarta Into  @Cad1, @Cad2
	End 
	Close 		CurCarta
	Deallocate 	CurCarta
	Set @Cadena = 'Select * from #Temp'
End 
If @Dato = 5		-- Para Plan de Pagos y Zurich 
Begin

	Set @Cadena = 'SELECT DISTINCT tCsFirmaElectronica.Dato AS CodPrestamo, ''['' + tCsFirmaElectronica.Dato + ''] '' + Cliente.Cliente AS Nombre FROM '
	Set @Cadena = @Cadena + 'tCsFirmaElectronica INNER JOIN tCsFirmaReporte ON tCsFirmaElectronica.Firma = tCsFirmaReporte.Firma INNER JOIN (SELECT '
	Set @Cadena = @Cadena + 'CodOficina, FechaProceso FROM ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tClParametros AS tClParametros) AS vCsFechaConsolidacion '
	Set @Cadena = @Cadena + 'ON tCsFirmaReporte.Fecha1 = vCsFechaConsolidacion.FechaProceso AND tCsFirmaReporte.CodOficina = vCsFechaConsolidacion.CodOficina '
	Set @Cadena = @Cadena + 'INNER JOIN (SELECT I.Firma, ISNULL(G.G, I.I) AS Cliente FROM (SELECT Firma, MAX(Sujeto) AS I FROM tCsFirmaReporteDetalle '
	Set @Cadena = @Cadena + 'WHERE (Grupo IN (''A'')) GROUP BY Firma) AS I INNER JOIN (SELECT Firma, MAX(Nacionalidad) AS G FROM tCsFirmaReporteDetalle AS '
	Set @Cadena = @Cadena + 'tCsFirmaReporteDetalle_1 WHERE (Grupo IN (''G'')) AND (Identificador = ''1'') GROUP BY Firma) AS G ON I.Firma = G.Firma) AS '
	Set @Cadena = @Cadena + 'Cliente ON tCsFirmaReporte.Firma = Cliente.Firma INNER JOIN ['+ @Servidor +'].['+ @BaseDatos +'].dbo.tCaPrestamos AS '
	Set @Cadena = @Cadena + 'tCaPrestamos ON tCsFirmaElectronica.Dato = tCaPrestamos.CodPrestamo WHERE (tCsFirmaElectronica.Sistema = ''CA'') AND '
	Set @Cadena = @Cadena + '(tCsFirmaReporte.CodOficina IN ('+ @CUbicacion +')) AND (tCaPrestamos.Estado = ''APROBADO'') AND (tCsFirmaElectronica.Usuario '
	Set @Cadena = @Cadena + '= '''+ @Usuario +''') '

End
If @Dato In(6,7)		-- 6: Para Comite de Créditos, 7:Para Integrantes del Acta
Begin			
	SELECT   @CUbicacion  = CodOficina
	FROM     tSgUsuarios
	WHERE    (Usuario = @Usuario)
	
	IF @Dato = 6
	Begin	
		Set @Cadena		= 'SELECT CodPrestamo, Nombre From ['+ @Servidor +'].['+ @BaseDatos +'].dbo.vCaComiteDia vCaComiteDia Where CodOficina IN ('+ @CUbicacion +') '
	End
	If @Dato = 7
	Begin
		If Not((SELECT Count(*) FROM tCsComiteIntegrantes WHERE (CodOficina = @CUbicacion )) 					> 0 And
		   (SELECT DATEDIFF([minute], MAX(Registro), GETDATE()) FROM tCsComiteIntegrantes WHERE (CodOficina = @CUbicacion ))	< 1)
		Begin
			Declare curFragmento1 Cursor For 
				SELECT     TipoActa
				FROM         [BD-FINAMIGO-DC].Finmas.dbo.tCaComiteTipo A
				WHERE     (Activo = 1)		
			Open curFragmento1
			Fetch Next From curFragmento1 Into @Cad2
			While @@Fetch_Status = 0
			Begin 
				Delete From tCsComiteIntegrantes
				Where CodOficina = @CUbicacion  And Tipo = @Cad2

				Print @CUbicacion
				Print @Cad2

				Insert Into tCsComiteIntegrantes
				SELECT  Tipo = @Cad2,  CodOficina = @CUbicacion , Codigo = ltrim(rtrim(Datos.Codigo)), Datos.Nombre, Datos.Puesto, tCaComiteIntegrantePermitido.Grupo, tCaComiteIntegrantePermitido.PMinimo, Registro = GetDate(), tCaComiteTipo.Nombre AS TipoActa
				FROM         (SELECT DISTINCT 
				                                              CodAsesor AS Codigo, Nombre = NomAsesor + ' (' + CASE WHEN Agencia = 1 AND 
				                                              Puesto <> 41 THEN 'Reponsable de Agencia' ELSE Ltrim(rtrim(CodPuesto)) END + ')', Puesto = CASE WHEN Agencia = 1 AND 
				                                              Puesto <> 41 THEN 41 ELSE Puesto END
				                       FROM          (SELECT     tCaClAsesores.CodOficina, tCaClAsesores.CodAsesor, tCaClAsesores.NomAsesor, ISNULL(tCsClPuestos.Descripcion, 'No definido') 
				                                                                      AS CodPuesto, 0 AS Agencia, Puesto = Isnull(tCsClPuestos.Codigo, 0)
				                                               FROM          tCsEmpleados INNER JOIN
				                                                                      tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario INNER JOIN
				                                                                      tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo RIGHT OUTER JOIN
				                                                                      [BD-FINAMIGO-DC].Finmas.dbo.tCaClAsesores tCaClAsesores ON tCsPadronClientes.CodOrigen = tCaClAsesores.CodAsesor
				                                               WHERE      (tCaClAsesores.Activo = 1) And (tCsEmpleados.Estado = 1)
				                                               UNION
				                                               SELECT     tCaClParametros.CodOficina, tCaClParametros.CodEncargadoCA, tUsUsuarios.NombreCompleto, ISNULL(tCsClPuestos.Descripcion, 
				                                                                     'No definido') AS CodPuesto, 1 AS Agencia, Puesto = Isnull(tCsClPuestos.Codigo, 0)
				                                               FROM         tCsEmpleados INNER JOIN
				                                                                     tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario INNER JOIN
				                                                                     tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo RIGHT OUTER JOIN
				                                                                     [BD-FINAMIGO-DC].Finmas.dbo.tCaClParametros tCaClParametros INNER JOIN
				                                                                     [BD-FINAMIGO-DC].Finmas.dbo.tUsUsuarios tUsUsuarios ON tCaClParametros.CodEncargadoCA = tUsUsuarios.CodUsuario ON 
				                                                                     tCsPadronClientes.CodOrigen = tUsUsuarios.CodUsuario
				                                               UNION
				                                               SELECT     CodOficina = @CUbicacion , tCsPadronClientes.CodOrigen, tCsPadronClientes.NombreCompleto, tCsClPuestos.Descripcion, 0 AS Agencia, 
				                                                                     CodPuesto = Isnull(tCsClPuestos.Codigo, 0)
				                                               FROM         tCsEmpleados INNER JOIN
				                                                                     tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario INNER JOIN
				                                                                     tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo
				                                               WHERE     (tCsEmpleados.CodPuesto IN (34, 32, 30, 26, 39, 38)) AND (tCsEmpleados.Estado = 1)
				                                               UNION
				                                               SELECT     tClOficinas.CodOficina, tCsPadronClientes.CodOrigen, tCsPadronClientes.NombreCompleto, tCsClPuestos.Descripcion, 0 AS agencia, 
				                                                                     CodPuesto = Isnull(tCsClPuestos.Codigo, 0)
				                                               FROM         tClOficinas INNER JOIN
				                                                                     tClZona ON tClOficinas.Zona = tClZona.Zona INNER JOIN
				                                                                     tCsPadronClientes ON tClZona.Responsable = tCsPadronClientes.CodUsuario INNER JOIN
				                                                                     tCsEmpleados ON tCsPadronClientes.CodUsuario = tCsEmpleados.Codusuario INNER JOIN
				                                                                     tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo) Datos
				                       WHERE      (CodOficina = @CUbicacion )) Datos INNER JOIN
				                      [BD-FINAMIGO-DC].Finmas.dbo.tCaComiteIntegrantePermitido tCaComiteIntegrantePermitido ON Datos.Puesto = tCaComiteIntegrantePermitido.CodPuesto INNER JOIN
				                      [BD-FINAMIGO-DC].Finmas.dbo.tCaComiteTipo tCaComiteTipo ON tCaComiteIntegrantePermitido.TipoActa = tCaComiteTipo.TipoActa
				WHERE     (tCaComiteIntegrantePermitido.TipoActa = @Cad2)
				ORDER BY Datos.Puesto DESC
			Fetch Next From curFragmento1 Into @Cad2
			End 
			Close 		curFragmento1
			Deallocate 	curFragmento1
		End		
		Set @Cadena = 'Select * from (SELECT DISTINCT CodUsuario As CodPrestamo, Nombre FROM tCsComiteIntegrantes WHERE (CodOficina = ''' + @CUbicacion  + '''))Datos Order by nombre'
	End
End

If @Dato In(8) -- Para Adendum de Ahorros.
Begin
	SELECT   @CUbicacion  = CodOficina
	FROM         tSgUsuarios
	WHERE     (Usuario = @Usuario)
	
	--Exec pCsCboAHCA	@CUbicacion
	
	Set @Cadena = 'SELECT * FROM (SELECT DISTINCT CodCuenta AS Codigo, ''['' + CodCuenta + ''] '' + NombreCompleto AS Nombre FROM tCsCboAHCA with(nolock) WHERE (CodOficina = ' + @CUbicacion + ')) Datos ORDER BY SUBSTRING(Nombre, 23, 100)'
End
If @Dato In (9) --Para Seguros Atlas
Begin
	SELECT   @CUbicacion  = CodOficina
	FROM         tSgUsuarios
	WHERE     (Usuario = @Usuario)
	Print getdate()
	Set @Cadena = 'Insert Into #Temp1 (CodPrestamo) SELECT DISTINCT  CodPrestamo FROM [BD-FINAMIGO-DC].Finmas.dbo.vCaDiaCancelaciones WHERE (CodOficina = ''' + @CUbicacion  + ''')'
	Print @Cadena
	Exec (@Cadena)
	Print getdate()

	Select @Fecha = FechaConsolidacion From vCsFechaConsolidacion
	
	Delete From tClListasGenerales
	Where CodSistema = 'CA' And Modulo = 'ATLAS' And Left(Nombre, 19) In (Select Codprestamo From #Temp1)
			
	DELETE FROM         tClListasGenerales
	WHERE     (CodSistema = 'CA') AND (Modulo = 'ATLAS') AND (RIGHT(Nombre, 13) IN
                          (SELECT     tCsSeguros.NumPoliza
                            FROM          tCsSeguros INNER JOIN
                                                   tCsSegurosBene ON tCsSeguros.CodAseguradora = tCsSegurosBene.CodAseguradora AND tCsSeguros.CodOficina = tCsSegurosBene.CodOficina AND 
                                                   tCsSeguros.NumPoliza = tCsSegurosBene.NumPoliza
                            WHERE      (tCsSeguros.CodAseguradora = '02') AND (LEN(tCsSeguros.Firma) = 45) AND (tCsSeguros.Fecha = '20110301' Or tCsSeguros.Fecha >= @Fecha)))
                            

	Set @Cadena = 'Select Nombre as Codigo, Descripcion As NombreCompleto From tClListasGenerales Where CodSistema = ''CA'' And Modulo = ''ATLAS'' And '
	Set @Cadena = @Cadena + 'Left(Nombre, 3) = dbo.fduRellena(''0'', '''+ @CUbicacion  +''', 3, ''D'') Order by Descripcion Asc '

End
If @Dato >= 10 And @Dato <= 13 --- Para Listado de Autorización de huellas.
Begin
	SELECT   @CUbicacion  = CodOficina
	FROM         tSgUsuarios
	WHERE     (Usuario = @Usuario)

	Set @Cad1 = 'BD-FINAMIGO-DC'
		
	If @Dato = 10 -- A--E
	Begin
		Set @Cadena = 'Select CodUsuario, NombreCompleto from ['+ @Cad1 +'].Finmas.dbo.vUsHuellasAutorizacion Where Codoficina IN('+ @CUbicacion +') And Left(NombreCompleto, 1) '
		Set @Cadena = @Cadena + '>= '' '' and Left(NombreCompleto, 1) <= ''E'' order by nombreCompleto '
	End	
	If @Dato = 11 -- F--L
	Begin
		Set @Cadena = 'Select CodUsuario, NombreCompleto from ['+ @Cad1 +'].Finmas.dbo.vUsHuellasAutorizacion Where Codoficina IN('+ @CUbicacion +') And Left(NombreCompleto, 1) '
		Set @Cadena = @Cadena + '>= ''F'' and Left(NombreCompleto, 1) <= ''L'' order by nombreCompleto '
	End	
	If @Dato = 12 -- M--P
	Begin
		Set @Cadena = 'Select CodUsuario, NombreCompleto from ['+ @Cad1 +'].Finmas.dbo.vUsHuellasAutorizacion Where Codoficina IN('+ @CUbicacion +') And Left(NombreCompleto, 1) '
		Set @Cadena = @Cadena + '>= ''M'' and Left(NombreCompleto, 1) <= ''P'' order by nombreCompleto '
	End	
	If @Dato = 13 -- Q--Z
	Begin
		Set @Cadena = 'Select CodUsuario, NombreCompleto from ['+ @Cad1 +'].Finmas.dbo.vUsHuellasAutorizacion Where Codoficina IN('+ @CUbicacion +') And Left(NombreCompleto, 1) '
		Set @Cadena = @Cadena + '>= ''Q'' and Left(NombreCompleto, 1) <= ''Z'' order by nombreCompleto '
	End	
End

Print @Cadena
Exec (@Cadena)
Print getdate()
Drop Table #Temp
Drop Table #Temp1
GO