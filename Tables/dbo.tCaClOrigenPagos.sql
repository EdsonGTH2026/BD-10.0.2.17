CREATE TABLE [dbo].[tCaClOrigenPagos] (
  [codorigenpago] [varchar](5) NOT NULL,
  [descripcion] [varchar](50) NULL,
  [activo] [bit] NULL,
  [MuestraCJ] [bit] NULL,
  CONSTRAINT [PK_tCaClOrigenPagos] PRIMARY KEY CLUSTERED ([codorigenpago])
)
ON [PRIMARY]
GO