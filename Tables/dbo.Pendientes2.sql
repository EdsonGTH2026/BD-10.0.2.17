CREATE TABLE [dbo].[Pendientes2] (
  [Fecha] [datetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [SecCuota] [smallint] NOT NULL,
  [Pagado] [money] NULL,
  [CodConcepto] [varchar](5) NOT NULL,
  [CapitalPagado] [money] NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodProducto] [char](3) NULL,
  [Asesor] [varchar](120) NULL,
  [ClienteGrupo] [varchar](50) NULL,
  [Estado] [varchar](10) NOT NULL,
  [MontoDesembolso] [money] NOT NULL,
  [FechaDesembolso] [datetime] NOT NULL,
  [FechaVencimiento] [datetime] NULL,
  [FechaPago] [smalldatetime] NULL,
  [EstadoCuota] [varchar](20) NULL
)
ON [PRIMARY]
GO