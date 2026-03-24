CREATE TABLE [dbo].[tCsRptDesembolsosDia] (
  [codoficina] [varchar](4) NOT NULL,
  [nomoficina] [varchar](100) NULL,
  [producto] [varchar](100) NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [Ciclo] [int] NOT NULL,
  [nombrecompleto] [varchar](200) NULL,
  [fechadesembolso] [datetime] NOT NULL,
  [montodesembolso] [money] NOT NULL,
  [plazo] [int] NOT NULL,
  [cuotas] [int] NOT NULL,
  [TasaIntCorriente] [money] NULL,
  [GarantiaAH] [money] NOT NULL,
  [GarantiaOtras] [money] NOT NULL,
  [desembolsousuario] [money] NOT NULL,
  [codgrupo] [char](15) NOT NULL,
  [nombregrupo] [varchar](200) NOT NULL
)
ON [PRIMARY]
GO