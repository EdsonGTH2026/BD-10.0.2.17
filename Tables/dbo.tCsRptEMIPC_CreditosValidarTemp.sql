CREATE TABLE [dbo].[tCsRptEMIPC_CreditosValidarTemp] (
  [CodPrestamo] [varchar](20) NOT NULL,
  [CodUsuario] [varchar](20) NOT NULL,
  [Desembolso] [smalldatetime] NOT NULL,
  [PrestamoSiaf] [varchar](20) NOT NULL,
  [Coordinador] [varchar](30) NOT NULL,
  [Verificador] [varchar](40) NOT NULL,
  [DiasMora] [int] NOT NULL,
  [MontoDesembolso] [money] NOT NULL,
  [SaldoNeto] [money] NOT NULL,
  CONSTRAINT [PK_tCsRptEMIPC_CreditosValidarTemp] PRIMARY KEY CLUSTERED ([CodPrestamo], [CodUsuario])
)
ON [PRIMARY]
GO