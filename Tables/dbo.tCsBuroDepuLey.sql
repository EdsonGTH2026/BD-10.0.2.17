CREATE TABLE [dbo].[tCsBuroDepuLey] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [Fecha] [smalldatetime] NULL,
  CONSTRAINT [PK_tCsBuroDepuLey] PRIMARY KEY CLUSTERED ([CodPrestamo])
)
ON [PRIMARY]
GO