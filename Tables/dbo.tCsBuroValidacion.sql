CREATE TABLE [dbo].[tCsBuroValidacion] (
  [Nro] [float] NOT NULL,
  [Nombre] [nvarchar](255) NULL,
  [RFC] [nvarchar](255) NULL,
  [CodUsuario] [varchar](25) NULL,
  [CodPrestamo] [varchar](50) NULL,
  [CodGrupo] [varchar](50) NULL,
  [CodOficina] [varchar](4) NULL,
  [Finamigo] [varchar](255) NULL,
  [Producto] [nvarchar](255) NULL,
  [ClaveOtorgante] [varchar](50) NULL,
  [Fid] [float] NULL,
  [FolioBC] [float] NULL,
  [Consulta] [datetime] NULL,
  [Referencia] [nvarchar](255) NULL,
  [Dirección] [nvarchar](255) NULL,
  [Colonia] [nvarchar](255) NULL,
  [Delegacion] [nvarchar](255) NULL,
  [Ciudad] [nvarchar](255) NULL,
  [Estado] [nvarchar](255) NULL,
  [CodigoPostal] [float] NULL,
  CONSTRAINT [PK_tCsBuroValidacion] PRIMARY KEY CLUSTERED ([Nro])
)
ON [PRIMARY]
GO