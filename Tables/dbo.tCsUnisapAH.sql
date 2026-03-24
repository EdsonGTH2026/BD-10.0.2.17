CREATE TABLE [dbo].[tCsUnisapAH] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodCuenta] [varchar](25) NOT NULL,
  [FraccionCta] [varchar](8) NOT NULL,
  [Renovado] [tinyint] NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [NombreCompleto] [varchar](300) NULL,
  [DescTipoProd] [varchar](150) NULL,
  [FechaApertura] [datetime] NULL,
  [FechaVencimiento] [datetime] NULL,
  [Plazo] [varchar](50) NULL,
  [PagoRendimiento] [int] NULL,
  [TasaInteres] [money] NULL,
  [SaldoBruto] [money] NULL,
  [IntAcumulado1] [money] NULL,
  [SaldoTotal] [money] NULL,
  [MontoDPF] [money] NULL,
  [IntAcumulado] [money] NULL,
  [DevengadoMes] [money] NULL,
  [SaldoPromedio] [money] NULL,
  [NomOficina] [varchar](30) NULL,
  [Ubigeo] [varchar](6) NULL,
  [FechaAlta] [smalldatetime] NULL,
  [Nomproducto] [varchar](250) NULL,
  [municipio] [varchar](100) NULL,
  CONSTRAINT [PK_tCsUnisapAH] PRIMARY KEY CLUSTERED ([Fecha], [CodCuenta], [FraccionCta], [Renovado], [CodUsuario])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsUnisapAH]
  ON [dbo].[tCsUnisapAH] ([CodCuenta])
  WITH (FILLFACTOR = 80)
  ON [PRIMARY]
GO