SET QUOTED_IDENTIFIER ON

SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[pSgInsertaEnColaSMS] (
 @Sistema varchar(5)
, @Numero varchar(15)
, @Fecha smalldatetime
, @Hora datetime
, @Mensaje varchar(200) )
AS

INSERT INTO tSgCmColaSMS
(idcola, CodSistema, NroCelular, Fecha, Hora, TipoMsj, Mensaje)
VALUES (dbo.fSgCorrSolSMS(), @Sistema, @Numero, @Fecha, @Hora, 1, @Mensaje)
GO