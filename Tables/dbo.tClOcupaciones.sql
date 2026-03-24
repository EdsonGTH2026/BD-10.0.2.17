CREATE TABLE [dbo].[tClOcupaciones] (
  [CodOcupacion] [varchar](6) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](150) NULL,
  [CodAlterno] [varchar](25) NULL,
  [Activo] [bit] NOT NULL CONSTRAINT [DF_tClOcupaciones_Activo] DEFAULT (1),
  CONSTRAINT [PK_tClOficios] PRIMARY KEY CLUSTERED ([CodOcupacion])
)
ON [PRIMARY]
GO