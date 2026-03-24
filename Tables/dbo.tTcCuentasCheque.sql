CREATE TABLE [dbo].[tTcCuentasCheque] (
  [IdCuenta] [int] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodEntidadTipo] [varchar](3) NOT NULL,
  [CodEntidad] [varchar](3) NOT NULL,
  [NroCuenta] [varchar](30) NOT NULL,
  [CodMoneda] [varchar](2) NULL,
  [Saldo] [money] NOT NULL,
  [SaldoMin] [money] NOT NULL,
  [Estado] [char](2) NULL,
  [TipoCuenta] [char](2) NULL,
  [Nombre] [varchar](80) NULL,
  [CodArt] [varchar](10) NULL,
  [ContaCodigo] [varchar](25) NOT NULL,
  [ParaGiros] [bit] NULL,
  [CodEmpresa] [tinyint] NULL,
  [CodTipoOperCheque] [varchar](4) NULL,
  [CodProducto] [char](3) NULL,
  [MinCheque] [smallint] NOT NULL
)
ON [PRIMARY]
GO