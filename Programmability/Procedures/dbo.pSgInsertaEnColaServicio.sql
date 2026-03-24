SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[pSgInsertaEnColaServicio] (
  @Sistema	varchar(5)
, @Tipo		int
, @Destino	varchar(1000)
, @Fecha	smalldatetime
, @Hora		datetime
, @Mensaje	varchar(8000) 

) AS

INSERT INTO tSgCmColaSMS (idcola, CodSistema, NroCelular, Fecha, Hora, TipoMsj, Mensaje)
VALUES (dbo.fSgCorrSolSMS(), @Sistema, @Destino, @Fecha, @Hora, @Tipo, @Mensaje)
GO