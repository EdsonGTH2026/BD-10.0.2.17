CREATE TABLE [dbo].[tCsRhControl] (
  [Fecha] [smalldatetime] NOT NULL,
  [Codusuario] [varchar](15) NOT NULL,
  [codoficina] [varchar](4) NULL,
  [idsecuencia] [int] NULL,
  [Entrada] [datetime] NULL,
  [Salida] [datetime] NULL,
  [idobsentrada] [int] NULL,
  [idobssalida] [int] NULL,
  [codhorario] [int] NULL,
  [codturno] [int] NULL,
  [iddia] [int] NULL,
  [exismarca] [bit] NULL CONSTRAINT [DF_tCsRhControl_exismarca] DEFAULT (1),
  [ttrabajo] [float] NULL CONSTRAINT [DF_tCsRhControl_ttrabajo] DEFAULT (0),
  [tatrazo] [float] NULL CONSTRAINT [DF_tCsRhControl_tatrazo] DEFAULT (0),
  [tadelanto] [float] NULL CONSTRAINT [DF_tCsRhControl_tadelanto] DEFAULT (0),
  [idianomarca] [int] NULL,
  [codpuesto] [int] NULL,
  CONSTRAINT [PK_tCsRhControl] PRIMARY KEY CLUSTERED ([Fecha], [Codusuario])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsRhControl_exismarca]
  ON [dbo].[tCsRhControl] ([Fecha], [exismarca], [codoficina], [codhorario], [codturno], [iddia])
  ON [PRIMARY]
GO