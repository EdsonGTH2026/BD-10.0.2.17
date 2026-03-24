CREATE TABLE [dbo].[ClientesCaracteristica] (
  [CodUsuario] [varchar](15) NULL,
  [Sistema] [varchar](2) NOT NULL,
  [Ubigeo] [varchar](6) NULL,
  [Zona] [varchar](50) NOT NULL,
  [Sexo] [bit] NULL,
  [ClienteNuevo] [char](1) NOT NULL,
  [RubroNegocio] [varchar](100) NULL,
  [Cartera] [varchar](29) NOT NULL
)
ON [PRIMARY]
GO