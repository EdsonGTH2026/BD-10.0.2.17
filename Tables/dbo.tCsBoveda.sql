CREATE TABLE [dbo].[tCsBoveda] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodUsBoveda] [varchar](25) NULL,
  [CierrePreliminar] [bit] NULL,
  [CierreDefinitivo] [bit] NULL,
  [FechaHoraApertura] [datetime] NULL,
  [FechaHoraCierre] [datetime] NULL,
  [Observaciones] [varchar](200) NULL,
  [NumBovTransDia] [int] NOT NULL,
  [NumCajaDia] [tinyint] NOT NULL,
  [SacoBackUpDia] [bit] NOT NULL,
  CONSTRAINT [PK_tCsBoveda1] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina])
)
ON [PRIMARY]
GO