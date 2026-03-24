CREATE TABLE [dbo].[tSATExentasPadron] (
  [Generado] [datetime] NOT NULL,
  [Consulta] [smallint] NOT NULL,
  [Empresa] [varchar](5) NOT NULL,
  [Corte] [smalldatetime] NOT NULL,
  [Archivo] [varchar](8) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [RFC] [varchar](13) NOT NULL,
  [Estado] [char](1) NOT NULL,
  [Activo] [bit] NULL,
  [NombreCompleto] [varchar](100) NULL,
  [CambiarOperativa] [bit] NULL,
  CONSTRAINT [PK_tSATExentasPadron] PRIMARY KEY CLUSTERED ([Archivo], [CodUsuario], [RFC])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tSATExentasPadron_EstadoCodUsuarioRFC]
  ON [dbo].[tSATExentasPadron] ([Estado], [CodUsuario], [RFC])
  ON [PRIMARY]
GO