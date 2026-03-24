CREATE TABLE [dbo].[tCsCarteraSuCe] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  CONSTRAINT [PK_tCsCarteraSuCe] PRIMARY KEY CLUSTERED ([CodPrestamo])
)
ON [PRIMARY]
GO