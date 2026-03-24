CREATE TABLE [dbo].[tCsSegurosAseguradora] (
  [CodAseguradora] [varchar](2) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  [Direccion] [varchar](100) NULL,
  [Ubigeo] [varchar](10) NULL,
  [PaginaWeb] [varchar](50) NULL,
  [Correo] [varchar](50) NULL,
  [Telefono] [varchar](50) NULL,
  [Fax] [varchar](50) NULL,
  [Activo] [bit] NULL,
  [PasaCaja] [bit] NULL,
  [ImprimeConsen] [bit] NULL,
  [Administrado] [varchar](100) NULL,
  [LineaGratuita] [varchar](50) NULL,
  [acciones] [varchar](5) NULL,
  [nrobenef] [int] NULL,
  [edadminbenef] [int] NULL,
  CONSTRAINT [PK_tCsSegurosAseguradora] PRIMARY KEY CLUSTERED ([CodAseguradora])
)
ON [PRIMARY]
GO