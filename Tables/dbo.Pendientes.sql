CREATE TABLE [dbo].[Pendientes] (
  [ConsultaPago] [varchar](9) NOT NULL,
  [Fecha] [smalldatetime] NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [NomOficina] [varchar](30) NULL,
  [Zona] [varchar](3) NULL,
  [NomZon] [varchar](50) NULL,
  [NombreProdCorto] [varchar](50) NULL,
  [Asesor] [varchar](300) NULL,
  [ClienteGrupo] [varchar](50) NULL,
  [Secuencia] [int] NULL,
  [Estado] [varchar](20) NULL,
  [NroDiasAtraso] [int] NULL,
  [NroCuotas] [smallint] NULL,
  [NroCuotasPagadas] [smallint] NULL,
  [NroCuotasPorPagar] [smallint] NULL,
  [FechaDesembolso] [smalldatetime] NULL,
  [FechaVencimiento] [smalldatetime] NULL,
  [MontoDesembolso] [decimal](19, 4) NULL,
  [SaldoCapital] [decimal](19, 4) NULL,
  [CodConcepto] [varchar](5) NOT NULL,
  [SaldoCuota] [money] NULL,
  [SecCuota] [int] NULL,
  [CapitalProgramado] [money] NULL
)
ON [PRIMARY]
GO