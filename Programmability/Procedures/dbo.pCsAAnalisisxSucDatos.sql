SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsAAnalisisxSucDatos
--EXEC pCsAAnalisisxSucDatos '20140312',''
CREATE PROCEDURE [dbo].[pCsAAnalisisxSucDatos]
               ( @fecha      smalldatetime , 
                 @codoficina varchar(300)  )
AS  
SELECT * FROM tCsRptAnalisisxSuc
GO