SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pXaCAPagosDelDia] @codusuario varchar(25)  
as  
set nocount on  
 exec [10.0.2.14].finmas.dbo.pXaCAPagosDelDia  @codusuario
GO