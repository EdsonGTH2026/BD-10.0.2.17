SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
---Drop Procedure pCsIntegraUDI

--Exec pCsIntegraUDI '20111216', 'curbiza', '4.677799'

CREATE Procedure [dbo].[pCsIntegraUDI]
	@Fecha		SmallDateTime,
	@Usuario	Varchar(50), 	
	@UDI 		Decimal(18,8)
AS
--Set @Fecha 	= '20090527'
--Set @Usuario 	= 'hguzman'
--Set @UDI 	= 4.260009 

Declare @Firma	Varchar(100)
Declare @Dato	Varchar(50)

Set @Dato = Replace(STR(@UDI, 8, 6), '.', '')
Exec pCsFirmaElectronica @Usuario, 'CS', @Dato, @Firma Out

Declare @TUDI 	Decimal(18,8)
Declare @MaD 		Decimal(13,8)
Declare @MiD 		Decimal(13,8)
Declare @Responsable 	Varchar(50)
Declare @Cadena	Varchar(4000)
Declare @Frase		Varchar(4000)

Delete From tCsCierresMensajes
Where Fecha = @Fecha

SELECT    @MaD = Round(MAX(Diferencia), 3), @MiD = MIN(Diferencia)
FROM         (SELECT     Datos.Fecha, ABS(Datos.UDI - tCsUDIS.UDI) AS Diferencia
                       FROM          (SELECT     Fecha, Fecha - 1 AS Antes, UDI
                                               FROM          tCsUDIS) Datos INNER JOIN
                                              tCsUDIS ON Datos.Antes = tCsUDIS.Fecha) datos


Print @Mad
Print @Mid

SELECT     @Responsable = CURP
FROM         tCsEmpleados
WHERE     (DataNegocio = @Usuario)

SELECT   @TUDI =   UDI
FROM     tCsUDIS
WHERE   (Fecha = @Fecha - 1)

If @UDI 	Is Null Begin Set @UDI 		= 0 	End 
If @Responsable Is Null Begin Set @Responsable 	= '' 	End 

Print @UDI
Print @TUDI

If @UDI > 0 And Abs(@UDI - @TUDI) > 0 and Abs(@UDI - @TUDI) <= @MaD --@Fecha>='20130726' and @Fecha<='20130810'  
Begin
	Delete From tCsUDIS
	Where Fecha = @Fecha
	
	Delete From [10.0.2.14].finmas.dbo.tCsUDIS
	Where Fecha = @Fecha
	
	Insert Into tCsUDIS (Fecha, UDI, SelloElectronico) VALUES (@Fecha, @UDI, @Firma)		
	Insert Into [10.0.2.14].finmas.dbo.tCsUDIS (Fecha, UDI) VALUES (@Fecha, @UDI)		
	
	If @@Error = 0
	Begin
		--If @Fecha > (Select FechaConsolidacion From vcsfechaconsolidacion)
		--Begin
		--	Update tAhClGATRangos
		--	Set MaximoMostrar = 400000 * @UDI
		--End		
		Set @Cadena = 'Sello Electronico del Proceso: ' + @Firma
		Insert Into tCsCierresMensajes Values(@Fecha, 0, @Cadena)
		
		Set @Cadena = 'Proceso de Registro de UDI se Realizo Correctamente'
		Insert Into tCsCierresMensajes Values(@Fecha, 1, @Cadena)
		--Set @Cadena = 'Fecha 		: '  + Cast(@Fecha as Varchar(100))
		--Insert Into tCsCierresMensajes Values(@Fecha, 2, @Cadena)
		Set @Cadena = 'Valor de la UDI 	: '  + Cast(@UDI as Varchar(100))
		Insert Into tCsCierresMensajes Values(@Fecha, 3, @Cadena)
		
		Delete From tCsCierres Where Fecha = @Fecha 
		If NOT EXISTS (Select 1 From tCsCierres Where Fecha = @Fecha )
		Begin Insert Into tCsCierres(Fecha, Cargado, Cerrado, Responsable) Values (@Fecha, 0, 0, @Responsable) End
		Update 	tCsCierres Set SelloelEctronico = @Firma Where Fecha = @Fecha 

		If @@Error = 0
		Begin
		
			Print @Fecha
			Print @Responsable
		
			Set @Cadena = 'Registro de responsable de Cierre Correcto'
			Insert Into tCsCierresMensajes Values(@Fecha, 4, @Cadena)			
			
			Insert Into tCsCierresMensajes
			SELECT     *
			FROM         (SELECT     @Fecha AS fecha, 5 AS Oficina, 'Usuario: ' + DataNegocio AS cadena
			                       FROM          tCsEmpleados
			                       WHERE      (CURP = @Responsable)
			                       UNION
			                       SELECT     @Fecha AS fecha, 6 AS Oficina, 'Nombre: ' + Paterno + ' ' + Materno + ', ' + Nombres AS Expr1
			                       FROM         tCsEmpleados
			                       WHERE     (CURP = @Responsable)
			                       UNION
			                       SELECT     @Fecha AS fecha, 7 AS Oficina, 'Puesto: ' + tCsClPuestos.Descripcion AS Expr1
			                      	FROM         tCsEmpleados INNER JOIN
									tCsClPuestos ON tCsEmpleados.CodPuesto = tCsClPuestos.Codigo		                       
			                       WHERE     (CURP = @Responsable)) Datos

			Set @Cadena = 'Frase del día: '
			Insert Into tCsCierresMensajes Values(@Fecha, 8, @Cadena)
			Exec pCsFrase @Frase Out
			Insert Into tCsCierresMensajes Values(@Fecha, 9, @Frase)
			--Exec pCsCierresBK 1, @Fecha, '001'
			--Exec pCsCierresBK 1, @Fecha, '002'
			--Exec pCsCierresBK 1, @Fecha, '003'
			--REGISTRO DE UN DIA COMO HOY
			/*Insert Into tCsCierresMensajes (Fecha, CodOficina, Mensaje)
			SELECT    @Fecha, '10', 'Un día como hoy en ' + CAST(Año AS Varchar(4)) + ' : ' + Descripcion AS Frase
			FROM         tCsFraseDia
			WHERE     (Mes = Month(@Fecha)) AND (Dia = Day(@Fecha))
			*/

		End
		Else
		Begin
			Set @Cadena = 'Registro de responsable de Cierre Incorrecto'
			Insert Into tCsCierresMensajes Values(@Fecha, 4, @Cadena)
			Set @Cadena = 'Coordinar con el personal de sistemas para que indique las causas'
			Insert Into tCsCierresMensajes Values(@Fecha, 5, @Cadena)		
		End
	End
	Else
	Begin
		Set @Cadena = 'Proceso de Registro de UDI se Realizo Incorrectamente'
		Insert Into tCsCierresMensajes Values(@Fecha, 1, @Cadena)
		Set @Cadena = 'Coordinar con el personal de sistemas para que indique las causas'
		Insert Into tCsCierresMensajes Values(@Fecha, 2, @Cadena)		
	End	
		
End
Else
Begin
	Set @Cadena = 'El Valor de la UDI esta fuera del rango aceptado'
	Insert Into tCsCierresMensajes Values(@Fecha, 1, @Cadena)
	Set @Cadena = 'Coordinar con el personal de sistemas para que indique las causas'
	Insert Into tCsCierresMensajes Values(@Fecha, 2, @Cadena)
	Set @Cadena = 'La página Web donde se encuentra el Valor de la UDI es:'
	Insert Into tCsCierresMensajes Values(@Fecha, 3, @Cadena)
	Set @Cadena = 'http://www.sat.gob.mx/sitio_internet/asistencia_contribuyente/informacion_frecuente/valor_udis/'
	Insert Into tCsCierresMensajes Values(@Fecha, 4, @Cadena)
End

SELECT Top 20     Mensaje
FROM         tCsCierresMensajes
WHERE     (Fecha = @Fecha)
ORDER BY CodOficina
GO