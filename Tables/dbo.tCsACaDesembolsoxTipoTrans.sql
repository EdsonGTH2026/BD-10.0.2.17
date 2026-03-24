CREATE TABLE [dbo].[tCsACaDesembolsoxTipoTrans] (
  [codprestamo] [varchar](20) NULL,
  [codoficina] [varchar](4) NULL,
  [montodesembolso] [money] NULL,
  [fechadesembolso] [smalldatetime] NULL,
  [codsolicitud] [varchar](20) NULL,
  [tipooperacion] [varchar](15) NULL,
  [cliente] [varchar](250) NULL,
  [tipocredito] [varchar](15) NULL
)
ON [PRIMARY]
GO