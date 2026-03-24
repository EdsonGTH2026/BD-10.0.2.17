CREATE TABLE [dbo].[tCsCFDI_timbre_constancia_fiscal] (
  [ID] [int] IDENTITY,
  [RFC] [varchar](13) NOT NULL,
  [Nombre] [varchar](70) NOT NULL,
  [CodUsuario] [varchar](50) NOT NULL,
  [Xml] [varchar](4000) NOT NULL,
  [Folio] [varchar](10) NOT NULL,
  [UUID] [varchar](50) NOT NULL,
  [Ruta_PDF] [varchar](255) NULL,
  [Constancia_creada] [bit] NOT NULL,
  [Periodo] [int] NOT NULL,
  [Contancia_fecha_creacion] [datetime] NOT NULL,
  [Error] [varchar](4000) NULL,
  [Cancelado] [bit] NULL,
  PRIMARY KEY CLUSTERED ([ID])
)
ON [PRIMARY]
GO