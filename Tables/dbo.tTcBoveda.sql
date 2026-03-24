CREATE TABLE [dbo].[tTcBoveda] (
  [CodOficina] [varchar](4) NOT NULL,
  [FechaPro] [smalldatetime] NOT NULL,
  [CodUsBoveda] [char](15) NULL,
  [CierrePreliminar] [bit] NULL,
  [CierreDefinitivo] [bit] NULL,
  [FechaHoraApertura] [datetime] NULL,
  [FechaHoraCierre] [datetime] NULL,
  [Observaciones] [varchar](200) NULL,
  [NumBovTransDia] [int] NOT NULL,
  [NumCajaDia] [tinyint] NOT NULL,
  [SacoBackUpDia] [bit] NOT NULL
)
ON [PRIMARY]
GO