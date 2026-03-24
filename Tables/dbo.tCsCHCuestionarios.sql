CREATE TABLE [dbo].[tCsCHCuestionarios] (
  [Codigo] [int] NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [NroEncuesta] [int] NULL,
  [Estado] [bit] NULL,
  [Fecha] [smalldatetime] NULL,
  [Leyenda] [varchar](500) NULL,
  CONSTRAINT [PK_tCsCHCuestionarios] PRIMARY KEY CLUSTERED ([Codigo])
)
ON [PRIMARY]
GO