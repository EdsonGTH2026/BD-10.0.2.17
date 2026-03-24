CREATE TABLE [dbo].[tCPClCiudad] (
  [CodCiudad] [varchar](2) NOT NULL,
  [CodMunicipio] [varchar](3) NOT NULL,
  [CodEstado] [varchar](2) NOT NULL,
  [Ciudad] [varchar](150) NULL,
  [RangoPostal] [varchar](50) NULL,
  CONSTRAINT [PK_tCPClCiudad] PRIMARY KEY CLUSTERED ([CodCiudad], [CodMunicipio], [CodEstado])
)
ON [PRIMARY]
GO