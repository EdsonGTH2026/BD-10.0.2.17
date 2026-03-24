CREATE TABLE [dbo].[tClListasGenerales] (
  [CodSistema] [varchar](2) NOT NULL,
  [Modulo] [varchar](50) NOT NULL,
  [Orden] [varchar](50) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](150) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tClListasGenerales] PRIMARY KEY CLUSTERED ([CodSistema], [Modulo], [Orden])
)
ON [PRIMARY]
GO