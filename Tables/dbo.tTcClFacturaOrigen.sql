CREATE TABLE [dbo].[tTcClFacturaOrigen] (
  [CodSistema] [char](2) NOT NULL,
  [CodOrigen] [char](3) NOT NULL,
  [DescOrigen] [varchar](20) NULL,
  [Activa] [bit] NOT NULL
)
ON [PRIMARY]
GO