SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE Procedure [dbo].[pCsCierreLog]
	@Fecha 		SmallDateTime, 
	@Proceso	Varchar(200)
AS
--Set @Fecha 	= '20091227'
--Set @Proceso	= 'Valida Cierre Anterior'

Declare @Sello 			Varchar(50)
Declare @Contador1		Int
Declare @Contador2		Int
Declare @Observacion	Varchar(1000)

Declare @PInicio		Varchar(100)
Declare @P1				Varchar(100)
Declare @P2				Varchar(100)

--Set @PInicio	= 'Activa solicitudes desaparecidas'
--Set @P1			= 'Respaldando Transacciones Ahorros FINMAS'
--Set @P2			= 'Valida Condiciones Iniciales de Cierre'

-- Set @PInicio	= 'Activa solicitudes desaparecidas'
Set @PInicio	= '001 - Conso - Verifica Condiciones Iniciales'
Set @P1			= 'Genera tCs Operativo'
Set @P2			= 'Valida Condiciones Iniciales de Cierre'


Set @Proceso	= ltrim(rtrim(@Proceso))
Set @PInicio	= ltrim(rtrim(@PInicio))
Set @P1			= ltrim(rtrim(@P1))
Set @P2			= ltrim(rtrim(@P2))

--Se utiliza la UDI ya que es un requisito incial de todo cierre.
SELECT @Sello  = SelloElectronico
FROM   tCsUDIS
WHERE  Fecha = @Fecha

Set @Observacion = 'Registro Inicial del proceso'	

If @Sello is null 
Begin  
	Exec pCsFirmaElectronica 'KVALERA', 'CS', 'ND', @Sello Out
	Set @Observacion = 'No se puede determinar el Sello Electronico Correcto del Cierre'
End 

SELECT @Contador1 = COUNT(*) 
FROM   tCsCierresLog
WHERE  Fecha = @Fecha

Set @Contador2 = @Contador1 + 1

If @Contador2 = 1
Begin 
	If @PInicio <> @Proceso
	Begin 
	    Set @Contador2 =  'SE HA DETECTADO QUE SE ESTA INICIANDO EL CIERRE, PERO LA ESTRUCTURA DEL DTS NO ES CORRECTA'
	End
End

--Print @Proceso
--Print @P2

If @Proceso = @P2 
Begin
--	Print 'Compara'
--	Print @Contador2
	Delete From tCsCierresLog
	Where Descripcion = @P2 And Fecha = @Fecha
	If (Select Ltrim(rtrim(Descripcion)) from tCsCierresLog Where Identificador = @Contador2 - 1 And Fecha = @Fecha) <>  @P1
	Begin 
		Set @Contador2 =  'SE HA DETECTADO QUE SE ESTA EN EL SEGUNDO DTS, PERO LA ESTRUCTURA DEL DTS NO ES CORRECTA'
	End
End

Insert Into tCsCierresLog 
       (SelloElectronico,  Fecha, Identificador, Inicio   , Descripcion,  Observacion)
Values (@Sello          , @Fecha, @Contador2   , Getdate(), @Proceso   , @Observacion)

Update tCsCierresLog
Set Fin = GetDate(), Observacion = 'Registro Final'
Where SelloElectronico = @Sello And Fecha = @Fecha And Identificador = @Contador1 And Observacion = 'Registro Inicial del Proceso'

Update tCsCierresLog
Set Fin = GetDate()
Where SelloElectronico = @Sello And Fecha = @Fecha And Identificador = @Contador1 And Observacion <> 'Registro Inicial del Proceso'

GO