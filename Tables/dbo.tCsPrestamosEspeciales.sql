CREATE TABLE [dbo].[tCsPrestamosEspeciales] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [Zona] [varchar](3) NULL,
  [Juicio] [bit] NULL,
  CONSTRAINT [PK_tCsPrestamosEspeciales] PRIMARY KEY CLUSTERED ([CodPrestamo])
)
ON [PRIMARY]
GO