CREATE TABLE [dbo].[tCPClMunicipio] (
  [CodMunicipio] [varchar](3) NOT NULL,
  [CodEstado] [varchar](2) NOT NULL,
  [SHF] [varchar](3) NULL,
  [Municipio] [varchar](150) NULL,
  [RangoPostal] [varchar](50) NULL,
  [ID10] [varchar](2) NULL,
  [DelMun] [varchar](50) NULL,
  [SITI] [varchar](100) NULL,
  CONSTRAINT [PK_tCPClMunicipio] PRIMARY KEY CLUSTERED ([CodMunicipio], [CodEstado])
)
ON [PRIMARY]
GO