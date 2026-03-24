CREATE TABLE [dbo].[RieBaseSMS] (
  [codusuario] [varchar](20) NULL,
  [msj] [varchar](160) NULL,
  [estado] [tinyint] NULL
)
ON [PRIMARY]
GO

GRANT
  DELETE,
  INSERT,
  SELECT,
  UPDATE
ON [dbo].[RieBaseSMS] TO [ayescasc]
GO