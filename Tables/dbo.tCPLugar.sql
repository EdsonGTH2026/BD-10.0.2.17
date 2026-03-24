CREATE TABLE [dbo].[tCPLugar] (
  [IdLugar] [int] NOT NULL,
  [Lugar] [varchar](150) NULL,
  [Zona] [varchar](50) NULL,
  [CodTipoLugar] [varchar](2) NULL,
  [CodigoPostal] [varchar](10) NULL,
  [CodMunicipio] [varchar](3) NOT NULL,
  [CodEstado] [varchar](2) NOT NULL,
  [CodCiudad] [varchar](2) NULL,
  [Oficina] [varchar](5) NULL,
  [ID10] [varchar](3) NULL,
  [SITI] [varchar](8) NULL,
  CONSTRAINT [PK_tCPLugar] PRIMARY KEY CLUSTERED ([IdLugar], [CodMunicipio], [CodEstado])
)
ON [PRIMARY]
GO