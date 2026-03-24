CREATE TABLE [dbo].[tCsClClientesObservaciones] (
  [Observacion] [varchar](2) NOT NULL,
  [Nombre] [varchar](100) NULL,
  [Problema] [varchar](1000) NULL,
  [Solucion] [varchar](1000) NULL,
  [Sentencia1] [varchar](4000) NULL,
  [Sentencia2] [varchar](4000) NULL,
  [Sentencia3] [varchar](4000) NULL,
  [Tipo] [varchar](50) NULL,
  [Activo] [bit] NULL,
  [ActivoCierreOperativo] [bit] NULL,
  [Validacion] [varchar](4000) NULL,
  CONSTRAINT [PK_tCsClientesObservaciones] PRIMARY KEY CLUSTERED ([Observacion])
)
ON [PRIMARY]
GO