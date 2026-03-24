SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--Drop Procedure pCsMensajePaseTramo 

CREATE Procedure [dbo].[pCsMensajePaseTramo] 
	@NroDiasAtraso	Int,
	@Registros		Int,
	@Prueba			Bit
As
Declare @Fecha	SmallDateTime
Declare @Dato	Varchar(10)
Declare @EnvioC	Bit
Select	@Fecha = FechaConsolidacion From vCsFechaConsolidacion

--If @Prueba = 1
--Begin
--	Set @Fecha	= DateAdd(day, -1, @Fecha)	
--End

Set @Dato		= dbo.fduFechaAtexto(DateAdd(Day, 1, @Fecha),'DD') + '/' + dbo.fduFechaAtexto(DateAdd(Day, 1, @Fecha),'MM') + '/' + dbo.fduFechaAtexto(DateAdd(Day, 1, @Fecha),'AAAA')

Declare @Oficina		Varchar(4)
Declare @Contador		Int
Declare @Contador1		Int
Declare @Cadena			Varchar(8000)
Declare @Cadena1		Varchar(8000)
Declare @Mensaje		Varchar(8000)
Declare @Correo			Varchar(100)
Declare @Correo1		Varchar(100)
Declare @Correo2		Varchar(100)
Declare @Correo3		Varchar(100)
Declare @html			Varchar(8000)
Declare @cf				Varchar(10)
Declare @Hora 			Varchar(15)
Declare @Envio 			Varchar(8)
Declare @Ejemplo		Varchar(4)
Declare @Tramo			Varchar(30)
Declare @Vencimiento	SmallDateTime

Set @Tramo = '[' + dbo.fduRellena('0', @NroDiasAtraso + 1, 3, 'D') + '-' + dbo.fduRellena('0', @NroDiasAtraso + 31 - Case When @NroDiasAtraso = 0 Then 1 Else 0 End, 3, 'D')  + ']'

If @NroDiasAtraso = 0 Begin Set @Vencimiento = DateAdd(Day, 3	, @Fecha) End
If @NroDiasAtraso > 0 Begin Set @Vencimiento = DateAdd(Day, 50	, @Fecha) End

SELECT  @Ejemplo = MAX(CodOficina) 
FROM         (SELECT     CodOficina, COUNT(*) AS Contador
                       FROM          tCsCartera
                       WHERE      (Fecha = @Fecha) AND (Cartera = 'ACTIVA') AND (NroDiasAtraso = @NroDiasAtraso) AND (Isnull(tCsCartera.ProximoVencimiento, @Fecha) <= @Vencimiento)
                       GROUP BY CodOficina) Datos
WHERE     (Contador IN
                          (SELECT     MAX(Contador) AS Contador
                            FROM          (SELECT     CodOficina, COUNT(*) AS Contador
                                                    FROM          tCsCartera
                                                    WHERE      (Fecha = @Fecha) AND (Cartera = 'ACTIVA') AND (NroDiasAtraso = @NroDiasAtraso) AND (Isnull(tCsCartera.ProximoVencimiento, @Fecha) <= @Vencimiento)
                                                    GROUP BY CodOficina) Datos))

Declare curOficina Cursor For 
	SELECT     CodOficina
	FROM         tClOficinas
	--Where CodOficina = @Ejemplo
Open curOficina
Fetch Next From curOficina Into @Oficina
While @@Fetch_Status = 0
Begin 
	Set @Correo		= ''
	Set @Correo1	= ''
	Set @Correo2	= ''
	Set @Correo3	= ''
	
	SELECT   @Correo = Ltrim(rtrim(MAX(Correo)))
	FROM         (SELECT     vCsResponsables.GerenteAgencia, vCsResponsables.CodOficina, tCsPadronClientes.CodUsuario, CASE RTRIM(LTRIM(ISNULL(tCsEmpleados.Correo, ''))) 
												  WHEN '' THEN tClOficinas.Correo ELSE RTRIM(LTRIM(ISNULL(tCsEmpleados.Correo, ''))) END AS Correo
						   FROM          tClOficinas INNER JOIN
												  vCsResponsables ON tClOficinas.CodOficina = vCsResponsables.CodOficina LEFT OUTER JOIN
												  tCsEmpleados RIGHT OUTER JOIN
												  tCsPadronClientes ON tCsEmpleados.Codusuario = tCsPadronClientes.CodUsuario ON 
												  vCsResponsables.GerenteAgencia = tCsPadronClientes.NombreCompleto) Datos
	WHERE     (CodOficina = @Oficina)
	GROUP BY CodOficina
	/*
	SELECT    @Correo3 = Ltrim(rtrim(tCsEmpleados.Correo))
	FROM         tClZona INNER JOIN
						  tCsEmpleados ON tClZona.Responsable = tCsEmpleados.CodUsuario INNER JOIN
						  tClOficinas ON tClZona.Zona = tClOficinas.Zona
	WHERE     (tClOficinas.CodOficina = @Oficina)
	
	If @Correo3 IS null Begin Set @Correo3 = '' End
	If rtrim(Ltrim(@Correo3)) <> '' And rtrim(Ltrim(@Correo)) <> ''
	Begin
		Set  @Correo = @Correo + ';' + @Correo3
	End
	If rtrim(Ltrim(@Correo3)) <> '' And rtrim(Ltrim(@Correo)) = ''
	Begin
		Set  @Correo = @Correo3
	End
	*/
	If @Oficina = @Ejemplo And @Prueba = 0
	Begin
		SELECT     @Correo1 = Correo
		FROM       tCsEmpleados
		WHERE     (CodPuesto IN (32)) AND (Estado = 1) -- Director Comercial
		SELECT     @Correo1 = @Correo1 + ';' + Correo
		FROM       tCsEmpleados
		WHERE     (CodPuesto IN (33)) AND (Estado = 1) -- Director de Sistemas
		SELECT     @Correo2 = Correo
		FROM       tCsEmpleados
		WHERE     (CodPuesto IN (54)) AND (Estado = 1) -- Coordinador de Sistemas
		--WHERE     (CodPuesto IN (29)) AND (Estado = 1) -- Coordinador de Sistemas
		--WHERE     (CodPuesto IN (34)) AND (Estado = 1) -- Director General
		Set @Correo2 = @Correo2 + ';' + 'kvalera@financierafinamigo.com.mx'
		--Set @Correo2 = 'kvalera@financierafinamigo.com.mx'
	End
	Set @EnvioC = 1
	Print 'Ejemplo	: ' 	+ @Ejemplo 
	Print 'Oficina	: ' 	+ @Oficina 
	Print 'Prueba	: ' 	+ Cast(@Prueba as Varchar(10))
	Print '------------------------------------------------------------------------------------------------'
	Print 'Correo	: ' + @Correo
	Print 'Correo1 	: ' + @Correo1
	Print 'Correo2 	: ' + @Correo2
	If @Oficina = @Ejemplo And @Prueba = 1
	Begin	
		Set @EnvioC	= 1
		Set @Correo 	= 'kvalera@financierafinamigo.com.mx'		 
	End
	If @Oficina <> @Ejemplo And @Prueba = 1
	Begin	
		Set @EnvioC	= 0 
		Set @Correo 	= 'kvalera@financierafinamigo.com.mx'
	End
	Print '------------------------------------------------------------------------------------------------'
	Print 'Correo : ' + @Correo
	Print '------------------------------------------------------------------------------------------------'
	Set @Contador	= 0
	Set @Contador1	= 0
	Set @Cadena1	= ''

	Set @Correo 	= Case When Substring(Ltrim(Rtrim(@Correo)), 	1, 1) 	= ';' Then Ltrim(rtrim(Substring(Ltrim(Rtrim(@Correo)), 2, 500))) 	Else Ltrim(Rtrim(@Correo)) End
	Set @Correo1 	= Case When Substring(Ltrim(Rtrim(@Correo1)), 	1, 1) 	= ';' Then Ltrim(rtrim(Substring(Ltrim(Rtrim(@Correo1)), 2, 500))) 	Else Ltrim(Rtrim(@Correo1)) End
	Set @Correo2 	= Case When Substring(Ltrim(Rtrim(@Correo2)), 	1, 1) 	= ';' Then Ltrim(rtrim(Substring(Ltrim(Rtrim(@Correo2)), 2, 500))) 	Else Ltrim(Rtrim(@Correo2)) End

	Declare curTipo Cursor For 
		Select NroDiasAtraso, Cadena from ( 
		SELECT  NroDiasAtraso, ProximoVencimiento, '<TD>' + CodPrestamo + '</TD><TD align="middle">'+ Case DateDiff(day, @Fecha, ProximoVencimiento)
																																		When -1	Then 'Anteayer'
																																		When 0	Then 'Ayer'
																																		When 1	Then 'Hoy' 
																																		When 2	Then 'Mañana'
																																		When 3	Then 'Pasado Mañana' 
																																		Else	dbo.fduFechaAtexto(ProximoVencimiento, 'DD') + '/' +
																																				dbo.fduFechaAtexto(ProximoVencimiento, 'MM') + '/' +
																																				dbo.fduFechaAtexto(ProximoVencimiento, 'AA') 
																																		End +'</TD><TD>' + RTRIM(LTRIM(ClienteGrupo)) + '</TD><TD align="middle">' + Ltrim(rtrim(Cast(CuotasAtrasadas As Varchar(5)))) + '/' + Ltrim(rtrim(Cast(NroCuotas As Varchar(5)))) 
								+ '</TD><TD align="right">' + '$' + dbo.fduNumeroTexto(SUM(Cuota), 2) + '</TD><TD>' + Direccion + '</TD>' AS Cadena
		FROM            (SELECT   ProximoVencimiento, NroDiasAtraso, CodOficina, CodPrestamo, ClienteGrupo, NroCuotas, CuotasAtrasadas, Cuota, MAX(Direccion) AS Direccion
								  FROM            (SELECT        ProximoVencimiento, tCsCartera.NroDiasAtraso, tCsCartera.CodOficina, tCsCartera.CodPrestamo, ISNULL(tCsCarteraGrupos.NombreGrupo, tCsPadronClientes.NombreCompleto) 
																					  AS ClienteGrupo, tCsCartera.NroCuotas, tCsCartera.CuotaActual - tCsCartera.NroCuotasPagadas - Case When @NroDiasAtraso = 0 Then 1 Else 0 End AS CuotasAtrasadas, Cuotas.Cuota, 
																					  '[Tl. ' + ISNULL(tCsPadronClientes_1.TelefonoDirFamPri, tCsPadronClientes_1.TelefonoDirNegPri) 
																					  + '] ' + ISNULL(tCsPadronClientes_1.DireccionDirFamPri + ISNULL(tCsPadronClientes_1.NumExtFam, '') 
																					  + ' ' + ISNULL(tCsPadronClientes_1.NumIntFam, ''), tCsPadronClientes_1.DireccionDirNegPri + ISNULL(tCsPadronClientes_1.NumExtNeg, '') 
																					  + ' ' + ISNULL(tCsPadronClientes_1.NumIntNeg, '')) AS Direccion
															FROM            tCsCartera INNER JOIN
																						  (SELECT        CodPrestamo, SecCuota, SUM(MontoCuota - MontoPagado - MontoCondonado) AS Cuota
																							FROM            tCsPadronPlanCuotas
																							WHERE        (CodOficina = @Oficina)
																							GROUP BY CodPrestamo, SecCuota) AS Cuotas ON tCsCartera.CodPrestamo = Cuotas.CodPrestamo AND 
																					  tCsCartera.CuotaActual >= Cuotas.SecCuota INNER JOIN
																					  tCsPadronCarteraDet ON tCsCartera.CodPrestamo = tCsPadronCarteraDet.CodPrestamo INNER JOIN
																					  tCsPadronClientes AS tCsPadronClientes_1 ON tCsPadronCarteraDet.CodUsuario = tCsPadronClientes_1.CodUsuario LEFT OUTER JOIN
																					  tCsCarteraGrupos ON tCsCartera.CodGrupo = tCsCarteraGrupos.CodGrupo LEFT OUTER JOIN
																					  tCsPadronClientes ON tCsCartera.CodUsuario = tCsPadronClientes.CodUsuario
															WHERE        (tCsCartera.Fecha = @Fecha) AND (tCsCartera.Cartera = 'ACTIVA') AND (Isnull(tCsCartera.ProximoVencimiento, @Fecha) <= @Vencimiento) AND 
																		 (tCsCartera.CodOficina = @Oficina) And (tCsCartera.NroDiasAtraso = @NroDiasAtraso)) AS Datos
								  GROUP BY ProximoVencimiento, NroDiasAtraso, CodOficina, CodPrestamo, ClienteGrupo, NroCuotas, CuotasAtrasadas, Cuota) AS Datos
		GROUP BY NroDiasAtraso, ProximoVencimiento, CodOficina, CodPrestamo, ClienteGrupo, NroCuotas, CuotasAtrasadas, Direccion) Datos	
		Order By NroDiasAtraso, ProximoVencimiento
	Open curTipo
	Fetch Next From curTipo Into @NroDiasAtraso, @Cadena
	While @@Fetch_Status = 0
	Begin 
		Print '@Cadena : ' +  @Cadena
		Set @Contador		= @Contador + 1
		Set @Contador1		= @Contador1 + 1
		If @Contador % 2	= 0 Begin Set @cf = '"#FFFFFF"' End 
		Else 
		Begin 
			Set @cf = Case 
							When @NroDiasAtraso = 0	And CharIndex('Pasado Mañana', @Cadena, 1)								> 0	Then '"#74DF00"'
							When @NroDiasAtraso = 0	And CharIndex('Mañana', @Cadena, 1)										> 0	Then '"#9AFE2E"'
							When @NroDiasAtraso = 0	And CharIndex('Hoy', @Cadena, 1)										> 0	Then '"#BEF781"'
							When @NroDiasAtraso = 0	And CharIndex('Anteayer', @Cadena, 1)									> 0	Then '"#E3F6CE"'
							When @NroDiasAtraso = 0	And CharIndex('Ayer', @Cadena, 1)										> 0	Then '"#D0F5A9"'
							When @NroDiasAtraso = 0																				Then '"#BEF781"'
							
							When @NroDiasAtraso >= 1  And @NroDiasAtraso <= 30	AND CharIndex('Pasado Mañana', @Cadena, 1)	> 0	Then '"#F7FE2E"'
							When @NroDiasAtraso >= 1  And @NroDiasAtraso <= 30	AND CharIndex('Mañana', @Cadena, 1)			> 0	Then '"#F4FA58"'
							When @NroDiasAtraso >= 1  And @NroDiasAtraso <= 30	AND CharIndex('Hoy', @Cadena, 1)			> 0	Then '"#F3F781"'
							When @NroDiasAtraso >= 1  And @NroDiasAtraso <= 30	AND CharIndex('Anteayer', @Cadena, 1)		> 0	Then '"#F5F6CE"'
							When @NroDiasAtraso >= 1  And @NroDiasAtraso <= 30	AND CharIndex('Ayer', @Cadena, 1)			> 0	Then '"#F2F5A9"'
							When @NroDiasAtraso >= 1  And @NroDiasAtraso <= 30													Then '"#F3F781"'
							
							When @NroDiasAtraso >= 31 And @NroDiasAtraso <= 60	AND CharIndex('Pasado Mañana', @Cadena, 1)	> 0	Then '"#FE9A2E"'
							When @NroDiasAtraso >= 31 And @NroDiasAtraso <= 60	AND CharIndex('Mañana', @Cadena, 1)			> 0	Then '"#FAAC58"'
							When @NroDiasAtraso >= 31 And @NroDiasAtraso <= 60	AND CharIndex('Hoy', @Cadena, 1)			> 0	Then '"#F7BE81"'
							When @NroDiasAtraso >= 31 And @NroDiasAtraso <= 60	AND CharIndex('Anteayer', @Cadena, 1)		> 0	Then '"#F6E3CE"'
							When @NroDiasAtraso >= 31 And @NroDiasAtraso <= 60	AND CharIndex('Ayer', @Cadena, 1)			> 0	Then '"#F5D0A9"'
							When @NroDiasAtraso >= 31 And @NroDiasAtraso <= 60													Then '"#F7BE81"'
														
							When @NroDiasAtraso >= 61 And CharIndex('Pasado Mañana', @Cadena, 1)							> 0	Then '"#FE2E2E"'
							When @NroDiasAtraso >= 61 And CharIndex('Mañana', @Cadena, 1)									> 0	Then '"#FA5858"'
							When @NroDiasAtraso >= 61 And CharIndex('Hoy', @Cadena, 1)										> 0	Then '"#F78181"'
							When @NroDiasAtraso >= 61 And CharIndex('Anteayer', @Cadena, 1)									> 0	Then '"#F6CECE"'
							When @NroDiasAtraso >= 61 And CharIndex('Ayer', @Cadena, 1)										> 0	Then '"#F5A9A9"'
							When @NroDiasAtraso >= 61																			Then '"#F78181"'																				
					 End 
		End
		Set @Cadena1		= @Cadena1 + '<TR bgcolor='+ @cf +'><TD align="middle">' + Ltrim(rtrim(Cast(@Contador as Varchar(5)))) + '</TD>' + @Cadena + '</TR>' 
		Set @html			= '<TABLE BORDER="1"><font face="Courier New" size=2><TR><TH align="center" colspan="6" bgcolor="'+ @cf +'">Créditos que si no pagan pasarán al tramo: '+ @Tramo +'</TH></TR><TR><TH>Nr.</TH><TH>Pagaré</TH><TH>Vencimiento</TH><TH>Cliente-Grupo</TH><TH>Atrasos</TH><TH>Cuota</TH><TH>Ubicación</TH></TR>' 
		
		--Print '@Cadena1	: ' +  @Cadena1
		--Print '@html	: ' +  @html
		Print @Contador1
		If @Contador1		= @Registros
		Begin
			Set @Mensaje	= @html + @Cadena1 + '</font></TABLE>'
			Set @Envio 		= dbo.fdufechaatexto(getdate(), 'AAAAMMDD')
			Set @Hora		= CONVERT(VARCHAR(20), GETDATE(), 114)
			
			IF @Prueba = 1
			Begin
				Print @Mensaje
			End
			
			If @EnvioC = 1
			Begin
				Print @Mensaje
				If ltrim(rtrim(Isnull(@Mensaje, ''))) <> '' And Ltrim(rtrim(@Correo)) <> '' And CharIndex('@', @Correo, 1) > 1 And CharIndex('.', @Correo, 1) > 2 
				Begin			
					Set @Mensaje = @Dato + ' Créditos que pasarán al tramo: '+ @Tramo +'|' + Replace(@Mensaje, Char(10), '<BR>')
					
					Exec pSgInsertaEnColaServicio 'DN',3, @Correo,@Envio,@Hora,@Mensaje
					If Ltrim(rtrim(@Correo1)) <> '' And CharIndex('@', @Correo1, 1) > 1 And CharIndex('.', @Correo1, 1) > 2
					Begin
						Exec pSgInsertaEnColaServicio 'DN',3, @Correo1,@Envio,@Hora,@Mensaje
					End
					If Ltrim(rtrim(@Correo2)) <> '' And CharIndex('@', @Correo2, 1) > 1 And CharIndex('.', @Correo2, 1) > 2
					Begin
						Exec pSgInsertaEnColaServicio 'DN',3, @Correo2,@Envio,@Hora,@Mensaje
					End
				End
				Else
				Begin
					Print 'No se envío ningun correo, revise si esta bien escrito'
				End
			End
			Set @Contador1	= 0
			Set @Cadena1	= ''	
		End
	Fetch Next From curTipo Into @NroDiasAtraso, @Cadena
	End 
	Close 		curTipo
	Deallocate 	curTipo	
	If @Contador1		< @Registros and @Contador1 > 0
	Begin
		Set @Mensaje	= @html + @Cadena1 + '</font></TABLE>'
		Set @Envio 		= dbo.fdufechaatexto(getdate(), 'AAAAMMDD')
		Set @Hora		= CONVERT(VARCHAR(20), GETDATE(), 114)
		
		IF @Prueba = 1
		Begin
			Print @Mensaje
		End
		
		If @EnvioC = 1
		Begin
			Print @Mensaje
			If ltrim(rtrim(Isnull(@Mensaje, ''))) <> '' And Ltrim(rtrim(@Correo)) <> '' And CharIndex('@', @Correo, 1) > 1 And CharIndex('.', @Correo, 1) > 2 
			Begin				
				Set @Mensaje = @Dato + ' Créditos que pasarán al tramo: '+ @Tramo +'|' + Replace(@Mensaje, Char(10), '<BR>')
				Exec pSgInsertaEnColaServicio 'DN',3, @Correo,@Envio,@Hora,@Mensaje
				If Ltrim(rtrim(@Correo1)) <> '' And CharIndex('@', @Correo1, 1) > 1 And CharIndex('.', @Correo1, 1) > 2
				Begin
					Exec pSgInsertaEnColaServicio 'DN',3, @Correo1,@Envio,@Hora,@Mensaje
				End
				If Ltrim(rtrim(@Correo2)) <> '' And CharIndex('@', @Correo2, 1) > 1 And CharIndex('.', @Correo2, 1) > 2
				Begin
					Exec pSgInsertaEnColaServicio 'DN',3, @Correo2,@Envio,@Hora,@Mensaje
				End
			End
			Else
			Begin
				Print 'No se envío ningun correo, revise si esta bien escrito'
			End	
		End	
	End	
Fetch Next From curOficina Into @Oficina
End 
Close 		curOficina
Deallocate 	curOficina
GO