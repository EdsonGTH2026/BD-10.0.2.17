SET QUOTED_IDENTIFIER, ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pCsBURO] 
@CodSistema Varchar(2),
@Fecha SmallDateTime
AS

If @CodSistema = 'CA'
Begin
	Select * from BBBBB
End
GO