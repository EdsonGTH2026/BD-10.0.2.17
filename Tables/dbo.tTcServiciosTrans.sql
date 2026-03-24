CREATE TABLE [dbo].[tTcServiciosTrans] (
  [NroTrans] [numeric] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [NroCaja] [int] NOT NULL,
  [CodServicio] [int] NOT NULL,
  [TipoServicio] [smallint] NOT NULL,
  [Fecha] [datetime] NULL,
  [CodCajero] [varchar](15) NOT NULL,
  [Observacion] [varchar](255) NOT NULL,
  [MontoTotal] [money] NOT NULL,
  [CodMoneda] [varchar](2) NULL,
  [TipoCambio] [money] NOT NULL,
  [IdFactura] [numeric](10) NOT NULL,
  [MontoComision] [money] NULL,
  [IdFacturaComision] [money] NULL,
  [Estado] [varchar](10) NOT NULL,
  [Itf] [money] NULL,
  [FechaHoraReal] [datetime] NOT NULL,
  [CodFondo] [varchar](2) NULL,
  CONSTRAINT [PK_tTcServiciosTrans] PRIMARY KEY CLUSTERED ([NroTrans], [CodOficina], [NroCaja])
)
ON [PRIMARY]
GO