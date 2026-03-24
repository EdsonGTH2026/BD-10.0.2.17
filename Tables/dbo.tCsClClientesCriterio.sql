CREATE TABLE [dbo].[tCsClClientesCriterio] (
  [Criterio] [varchar](2) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  [Campo] [varchar](50) NULL,
  [PCantidadFinal] [varchar](5) NULL,
  [PDiferencia] [varchar](5) NULL,
  [PAvance] [varchar](5) NULL,
  [Ponderado] [int] NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsClClientesCriterio] PRIMARY KEY CLUSTERED ([Criterio])
)
ON [PRIMARY]
GO