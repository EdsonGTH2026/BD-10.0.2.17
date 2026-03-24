CREATE TABLE [dbo].[tCaClTecnoCrediticia] (
  [NivelTecnoCred] [varchar](10) NOT NULL,
  [NombreTecnoCred] [varchar](50) NULL,
  [EsPropiedad] [bit] NOT NULL,
  [Opciones] [varchar](10) NULL,
  [Panel] [char](2) NULL,
  [formulario] [varchar](50) NULL,
  [Parametro] [varchar](20) NULL,
  [Descripcion] [varchar](600) NULL,
  [Modulo] [varchar](4) NULL
)
ON [PRIMARY]
GO