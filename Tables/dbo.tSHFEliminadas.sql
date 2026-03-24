CREATE TABLE [dbo].[tSHFEliminadas] (
  [CodPrestamo] [varchar](50) NOT NULL,
  [Periodo] [varchar](6) NULL,
  CONSTRAINT [PK_tSHFEliminadas] PRIMARY KEY CLUSTERED ([CodPrestamo])
)
ON [PRIMARY]
GO