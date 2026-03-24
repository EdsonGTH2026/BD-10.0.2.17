CREATE TABLE [dbo].[tCcConsultaLog] (
  [IdLog] [int] IDENTITY,
  [IdCC] [int] NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Tipo] [varchar](1) NOT NULL,
  [NumProducto] [varchar](3) NOT NULL,
  [Estado] [varchar](10) NOT NULL,
  [Comentario] [varchar](100) NULL,
  CONSTRAINT [PK_tCcRespuestaIndicador] PRIMARY KEY CLUSTERED ([IdLog], [IdCC])
)
ON [PRIMARY]
GO