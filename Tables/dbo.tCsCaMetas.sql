CREATE TABLE [dbo].[tCsCaMetas] (
  [Fecha] [smalldatetime] NOT NULL,
  [TipoCodigo] [tinyint] NOT NULL,
  [Meta] [tinyint] NOT NULL,
  [Codigo] [varchar](25) NOT NULL,
  [Monto] [money] NULL,
  [Descripcion] [varchar](20) NULL,
  CONSTRAINT [PK_tCsCaMetas] PRIMARY KEY CLUSTERED ([Fecha], [TipoCodigo], [Meta], [Codigo]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO

GRANT
  DELETE,
  INSERT,
  SELECT,
  UPDATE
ON [dbo].[tCsCaMetas] TO [marista]
GO

GRANT
  DELETE,
  INSERT,
  SELECT,
  UPDATE
ON [dbo].[tCsCaMetas] TO [public]
GO