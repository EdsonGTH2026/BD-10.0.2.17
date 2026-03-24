CREATE TABLE [dbo].[tCsFondoSaldos] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodFondo] [tinyint] NULL,
  [NemFondo] [varchar](15) NOT NULL,
  [NroDiasAtraso] [int] NULL,
  [SaldoCapital] [decimal](38, 4) NULL,
  [Vigente] [decimal](38, 4) NULL,
  [Vencido] [decimal](38, 4) NULL,
  [CVigente] [decimal](38, 4) NULL,
  [CVencido] [decimal](38, 4) NULL,
  [NroCuotas] [smallint] NULL,
  [CuotaActual] [int] NULL,
  [NroCuotasPagadas] [smallint] NULL,
  [NroCuotasPorPagar] [smallint] NULL,
  [Proceso] [varchar](8) NOT NULL,
  [Tecnologia] [char](1) NULL,
  [Veridico] [varchar](50) NULL,
  [FechaDesembolso] [smalldatetime] NULL,
  [Monto] [decimal](38, 4) NULL,
  [CodGrupo] [varchar](15) NULL,
  [CodAsesor] [varchar](15) NULL,
  [Participantes] [int] NULL
)
ON [PRIMARY]
GO