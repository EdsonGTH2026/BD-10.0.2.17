CREATE TABLE [dbo].[tCsMesPlanCuotas] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodPrestamo] [char](19) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [NumeroPlan] [tinyint] NOT NULL,
  [SecCuota] [tinyint] NOT NULL,
  [CodConcepto] [varchar](5) NOT NULL,
  [DiasAtrCuota] [smallint] NOT NULL,
  [FechaInicio] [smalldatetime] NOT NULL,
  [FechaVencimiento] [smalldatetime] NOT NULL,
  [FechaPagoConcepto] [smalldatetime] NULL,
  [SecPago] [int] NOT NULL,
  [EstadoCuota] [varchar](10) NULL,
  [EstadoConcepto] [varchar](10) NOT NULL,
  [MontoCuota] [money] NOT NULL,
  [MontoDevengado] [money] NOT NULL,
  [MontoPagado] [money] NOT NULL,
  [MontoCondonado] [money] NOT NULL,
  CONSTRAINT [PK_tCsMesPlanCuotasvs2] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [CodPrestamo], [CodUsuario], [NumeroPlan], [SecCuota], [CodConcepto]) WITH (FILLFACTOR = 60)
)
ON [PRIMARY]
GO