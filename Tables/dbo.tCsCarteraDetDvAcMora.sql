CREATE TABLE [dbo].[tCsCarteraDetDvAcMora] (
  [fecha] [smalldatetime] NOT NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [codusuario] [varchar](15) NOT NULL,
  [DevAcumMoratorio] [money] NULL,
  [Vigente] [money] NULL,
  [Vencido] [money] NULL,
  [CtaOrden] [money] NULL,
  CONSTRAINT [PK_tCsCarteraDetDvAcMora] PRIMARY KEY CLUSTERED ([fecha], [codprestamo], [codusuario])
)
ON [PRIMARY]
GO