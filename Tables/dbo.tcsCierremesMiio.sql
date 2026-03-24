CREATE TABLE [dbo].[tcsCierremesMiio] (
  [Fecha] [smalldatetime] NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CodPrestamo] [varchar](29) NOT NULL,
  [Desembolso] [smalldatetime] NULL,
  [NroDiasAtraso] [int] NULL,
  [SaldoCapital] [money] NULL,
  [mes] [smalldatetime] NULL,
  [cer] [int] NULL,
  [mescosecha] [smalldatetime] NULL
)
ON [PRIMARY]
GO