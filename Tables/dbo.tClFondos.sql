CREATE TABLE [dbo].[tClFondos] (
  [CodFondo] [varchar](2) NOT NULL,
  [CodEntero] AS (convert(int,[codfondo])),
  [NemFondo] [varchar](15) NOT NULL,
  [DescFondo] [varchar](100) NOT NULL,
  [Contrato] [varchar](50) NULL,
  [CodFuenteFin] [char](2) NOT NULL,
  [Redescuento] [varchar](2) NULL,
  [R21Estimacion] [bit] NULL,
  [R21Porcentaje] [int] NULL,
  [R21Gobierno] [bit] NULL,
  [CCCapital] [varchar](3) NULL,
  [CCInteres] [varchar](3) NULL,
  CONSTRAINT [PK_tClFondos] PRIMARY KEY CLUSTERED ([CodFondo])
)
ON [PRIMARY]
GO