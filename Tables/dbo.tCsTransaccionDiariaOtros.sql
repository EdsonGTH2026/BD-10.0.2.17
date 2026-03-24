CREATE TABLE [dbo].[tCsTransaccionDiariaOtros] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodSistema] [char](2) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [NroTransaccion] [varchar](10) NOT NULL,
  [NroCaja] [int] NOT NULL,
  [IdOtroDato] [int] NOT NULL,
  [Dato] [varchar](100) NULL,
  [Descripcion] [varchar](500) NULL,
  [Valor] [varchar](500) NULL,
  CONSTRAINT [PK_tCsTransaccionDiariaOtros] PRIMARY KEY CLUSTERED ([Fecha], [CodSistema], [CodOficina], [NroTransaccion], [NroCaja], [IdOtroDato])
)
ON [PRIMARY]
GO