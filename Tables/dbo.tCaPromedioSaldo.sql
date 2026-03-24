CREATE TABLE [dbo].[tCaPromedioSaldo] (
  [fecha] [smalldatetime] NOT NULL,
  [rango] [varchar](12) NOT NULL,
  [categoria] [varchar](15) NOT NULL,
  [saldoCtera] [money] NULL,
  [ptmosCtera] [money] NULL,
  [promSaldo_Ctera] [money] NOT NULL,
  [saldo170] [money] NULL,
  [nroPtmos170] [money] NULL,
  [promSaldo_170] [money] NOT NULL,
  [saldo370] [money] NULL,
  [nroPtmos370] [money] NULL,
  [promSaldo_370] [money] NOT NULL,
  [imor31] [money] NULL,
  [imor31_170] [money] NULL,
  [imor31_370] [money] NULL
)
ON [PRIMARY]
GO