CREATE TABLE [dbo].[tCaSolClientes] (
  [CodSolicitud] [varchar](15) NOT NULL,
  [CodProducto] [char](3) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodCliente] [char](15) NOT NULL,
  [Coordinador] [bit] NULL,
  [MontoCliente] [money] NULL,
  [CodDestino] [varchar](15) NULL,
  [CodTipoPlan] [char](1) NULL,
  [MontoCuota] [money] NULL,
  [EstadoCliente] [varchar](10) NULL,
  [MontoClienteAnt] [money] NULL CONSTRAINT [DF_tCaSolClientes_MontoClienteAnt] DEFAULT (0),
  [Destino] [varchar](150) NULL CONSTRAINT [DF_tCaSolClientes_Destino] DEFAULT (''),
  [CodCuenta] [varchar](25) NULL,
  [FraccionCta] [varchar](8) NULL,
  [Renovado] [tinyint] NULL,
  CONSTRAINT [PK_tCaSolClientes] PRIMARY KEY CLUSTERED ([CodSolicitud], [CodProducto], [CodOficina], [CodCliente])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaSolClientes] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolClientes_tCaSolicitud] FOREIGN KEY ([CodSolicitud], [CodProducto], [CodOficina]) REFERENCES [dbo].[tCaSolicitud] ([CodSolicitud], [CodProducto], [CodOficina])
GO

ALTER TABLE [dbo].[tCaSolClientes] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolClientes_tUsUsuarios] FOREIGN KEY ([CodCliente]) REFERENCES [dbo].[tUsUsuarios] ([CodUsuario])
GO