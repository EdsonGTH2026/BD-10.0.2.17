CREATE TABLE [dbo].[tTcClServicios] (
  [CodServicio] [int] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](150) NULL,
  [FechaRegistro] [datetime] NULL,
  [Estado] [varchar](10) NULL,
  [ContaCodigo] [varchar](25) NULL,
  [SeContabiliza] [bit] NULL
)
ON [PRIMARY]
GO