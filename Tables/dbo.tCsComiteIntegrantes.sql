CREATE TABLE [dbo].[tCsComiteIntegrantes] (
  [Tipo] [varchar](5) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodUsuario] [varchar](50) NOT NULL,
  [Nombre] [varchar](503) NULL,
  [Puesto] [int] NOT NULL,
  [Grupo] [varchar](2) NULL,
  [PMinimo] [numeric](18, 2) NULL,
  [Registro] [datetime] NULL,
  [TipoActa] [varchar](100) NULL,
  CONSTRAINT [PK_tCsComiteIntegrantes] PRIMARY KEY CLUSTERED ([Tipo], [CodOficina], [CodUsuario], [Puesto])
)
ON [PRIMARY]
GO