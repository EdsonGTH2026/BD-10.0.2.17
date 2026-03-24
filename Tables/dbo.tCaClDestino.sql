CREATE TABLE [dbo].[tCaClDestino] (
  [CodDestino] [varchar](15) NOT NULL,
  [PadreDestino] [varchar](15) NULL,
  [Grupo] [varchar](30) NULL,
  [DescDestino] [varchar](50) NULL,
  [SHF] [int] NULL,
  CONSTRAINT [PK_tCaClDestino] PRIMARY KEY CLUSTERED ([CodDestino])
)
ON [PRIMARY]
GO