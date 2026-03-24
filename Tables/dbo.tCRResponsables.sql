CREATE TABLE [dbo].[tCRResponsables] (
  [Responsable] [varchar](2) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [CodUsuario] [varchar](15) NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tCRResponsables] PRIMARY KEY CLUSTERED ([Responsable])
)
ON [PRIMARY]
GO