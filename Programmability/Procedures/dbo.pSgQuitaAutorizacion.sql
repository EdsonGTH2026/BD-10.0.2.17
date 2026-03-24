SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pSgQuitaAutorizacion] AS
SET NOCOUNT ON

DECLARE @Fecha smalldatetime
select @Fecha = fechaconsolidacion from vCsFechaConsolidacion

DECLARE @codoficina varchar(5)
DECLARE @codoficinades varchar(5)
DECLARE @codusuariosol varchar(20)
DECLARE @codusuariodes varchar(20)
DECLARE @perfilini varchar(20)
DECLARE @perfilfin varchar(20)
DECLARE @fechaauto smalldatetime
DECLARE @hora datetime

DECLARE perfiles CURSOR FOR
select fecha, hora, codoficina,codusuariodes,perfilsol,codusuariosol,perfildes,codoficinades from tSgAdmAutorizaciones
where fechafin= dateadd(day,1,@Fecha)  and estado = 'E'--  '20090708' 
OPEN perfiles

FETCH NEXT FROM perfiles 
INTO @fechaauto, @hora, @codoficina,@codusuariodes,@perfilini,@codusuariosol,@perfilfin,@codoficinades

WHILE @@FETCH_STATUS = 0
BEGIN
		
	exec [10.0.2.14].Finmas.dbo.pCsSgEjecutaAutorizaciones @codusuariosol, @CodOficina, @perfilini
	exec [10.0.2.14].Finmas.dbo.pCsSgEjecutaAutorizaciones @codusuariodes, @CodOficinades, @perfilfin

	update tSgAdmAutorizaciones
	set estado = 'O'
	where fecha=@fechaauto and hora=@hora and codoficina=@codoficina and codusuariosol=@codusuariosol

   FETCH NEXT FROM perfiles 
   INTO @fechaauto, @hora, @codoficina,@codusuariodes,@perfilini,@codusuariosol,@perfilfin,@codoficinades
END

CLOSE perfiles
DEALLOCATE perfiles

SET NOCOUNT OFF
GO