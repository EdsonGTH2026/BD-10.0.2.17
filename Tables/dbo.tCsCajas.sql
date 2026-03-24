CREATE TABLE [dbo].[tCsCajas] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [NumCaja] [int] NOT NULL,
  [CodUsCaja] [varchar](15) NULL,
  [CierrePreliminar] [bit] NULL,
  [CierreDefinitivo] [bit] NULL,
  [FechaHoraApertura] [datetime] NULL,
  [FechaHoraCierre] [datetime] NULL,
  [Observaciones] [varchar](200) NULL,
  [NumCajaTrans] [int] NULL,
  [CodPerfil] [smallint] NULL,
  CONSTRAINT [PK_tCsCajas] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [NumCaja])
)
ON [PRIMARY]
GO