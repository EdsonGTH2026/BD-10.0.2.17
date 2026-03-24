SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--DROP PROC pCsAAnalisisxRegDatos 
--EXEC pCsAAnalisisxRegDatos '20140312','' 
CREATE PROCEDURE [dbo].[pCsAAnalisisxRegDatos]
               ( @fecha      smalldatetime , 
                 @codoficina varchar(300)  )
AS  
SELECT * FROM tCsRptAnalisisxReg
GO