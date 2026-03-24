CREATE TABLE [dbo].[tSgModulos] (
  [CodModulo] [char](3) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](50) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tSgModulos] PRIMARY KEY CLUSTERED ([CodModulo])
)
ON [PRIMARY]
GO