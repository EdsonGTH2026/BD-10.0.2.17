CREATE TABLE [dbo].[tCsCALIQRRVisitas] (
  [codusuario] [varchar](15) NOT NULL,
  [fecha] [smalldatetime] NULL,
  [clasificacion] [tinyint] NULL,
  [estado] [tinyint] NULL,
  CONSTRAINT [PK_tCsCALIQRRVisitas] PRIMARY KEY CLUSTERED ([codusuario])
)
ON [PRIMARY]
GO