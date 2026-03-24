CREATE TABLE [dbo].[tCsCierresConfig] (
  [Codigo] [varchar](3) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  [Valor] [varchar](50) NULL,
  [Servidor] [varchar](20) NULL,
  [DatoHistorico] [varchar](50) NULL,
  [Veces] [int] NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCsCierresConfig] PRIMARY KEY CLUSTERED ([Codigo])
)
ON [PRIMARY]
GO