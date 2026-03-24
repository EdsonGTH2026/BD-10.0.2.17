CREATE TABLE [dbo].[tclUbigeoDGRV] (
  [ESTADO_ID] [char](2) NULL,
  [ESTADO_DSC] [varchar](50) NULL,
  [MUNICIPIO_ID] [char](5) NULL,
  [MUNICIPIO_DSC] [varchar](100) NULL,
  [LOCALIDAD_ID] [char](10) NOT NULL,
  [LOCALIDAD_DSC] [varchar](150) NULL,
  [ELEGIBLE] [char](1) NULL
)
ON [PRIMARY]
GO