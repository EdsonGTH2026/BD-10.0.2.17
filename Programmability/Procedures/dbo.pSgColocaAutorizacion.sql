SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pSgColocaAutorizacion] AS
SET NOCOUNT ON

DECLARE @Fecha smalldatetime
select @Fecha = fechaconsolidacion from vCsFechaConsolidacion

DECLARE @codoficina varchar(20)
DECLARE @codusuariosol varchar(20)
DECLARE @codusuariodes varchar(20)
DECLARE @perfilejecutado varchar(20)
DECLARE @fechaauto smalldatetime
DECLARE @hora datetime

DECLARE perfiles CURSOR FOR
select fecha, hora, codoficina,codusuariodes,perfilejecutado,codusuariosol from tSgAdmAutorizaciones
where fechaini= dateadd(day,2,@Fecha) and estado = 'A'--'20090708'
OPEN perfiles

FETCH NEXT FROM perfiles 
INTO @fechaauto, @hora, @codoficina,@codusuariodes,@perfilejecutado,@codusuariosol

WHILE @@FETCH_STATUS = 0
BEGIN
		
	exec [10.0.2.14].Finmas.dbo.pCsSgEjecutaAutorizaciones   @codusuariodes, @CodOficina, @perfilejecutado

	update tSgAdmAutorizaciones
	set estado = 'E'
	where fecha=@fechaauto and hora=@hora and codoficina=@codoficina and codusuariosol=@codusuariosol

   FETCH NEXT FROM perfiles 
   INTO @fechaauto, @hora, @codoficina,@codusuariodes,@perfilejecutado,@codusuariosol
END

CLOSE perfiles
DEALLOCATE perfiles

SET NOCOUNT OFF
GO