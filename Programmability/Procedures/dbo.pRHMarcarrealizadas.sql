SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Christofer Urbizagastegui>
-- Create date: <09,08,2010>
-- =============================================
CREATE PROCEDURE [dbo].[pRHMarcarrealizadas] @codoficina varchar(4),@fecha smalldatetime
AS
BEGIN
	SET NOCOUNT ON;
	
  SELECT h.[Entrada],u.nombrecompleto
  FROM [10.0.2.14].[Finmas].[dbo].[tRhDifHoras] h
  inner join [10.0.2.14].[Finmas].[dbo].tususuarios u on u.codusuario=h.codusuario
  where h.codoficina=@codoficina and h.fecha=@fecha
  
END
GO