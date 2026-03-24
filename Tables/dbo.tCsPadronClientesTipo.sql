CREATE TABLE [dbo].[tCsPadronClientesTipo] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [Tipo] [varchar](50) NOT NULL,
  [Titular] [bit] NULL,
  [Activo] [bit] NULL,
  [Conclusion] [bit] NULL,
  [Conyuge] [varchar](20) NULL,
  [Usuario] [varchar](20) NULL,
  [Referencia] [varchar](50) NULL,
  [Registro] [smalldatetime] NULL,
  [CodOficina] [varchar](4) NULL,
  [NombreCompleto] [varchar](100) NULL,
  [Activacion] [smalldatetime] NULL,
  [Inactivacion] [smalldatetime] NULL,
  [CodOficinaFinal] [varchar](4) NULL,
  [SecuenciaGeneral] [int] NULL,
  [SecuenciaOficina] [smallint] NULL,
  CONSTRAINT [PK_tCsPadronClientesTipo] PRIMARY KEY CLUSTERED ([Fecha], [CodUsuario], [Tipo])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronClientesTipo]
  ON [dbo].[tCsPadronClientesTipo] ([CodOficinaFinal])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronClientesTipo_1]
  ON [dbo].[tCsPadronClientesTipo] ([Fecha], [CodOficina])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronClientesTipo_2]
  ON [dbo].[tCsPadronClientesTipo] ([Registro])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO