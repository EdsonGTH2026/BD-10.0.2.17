CREATE TABLE [dbo].[tCsAhCuenta] (
  [CodCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL,
  [Renovado] [tinyint] NOT NULL,
  [CodUsTitular] [varchar](15) NULL
)
ON [PRIMARY]
GO