CREATE TABLE [dbo].[tCsCarteraDetOrden] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodPrestamo] [char](19) NOT NULL,
  [Estado] [varchar](20) NULL,
  [SaldoInteres] [money] NOT NULL,
  [InteresVigente] [money] NULL,
  [InteresVencido] [money] NULL,
  [InteresCtaOrden] [money] NULL,
  [InteresDevengado] [money] NULL,
  CONSTRAINT [PK_tCsCarteraDetOrden] PRIMARY KEY CLUSTERED ([Fecha], [CodPrestamo]) WITH (FILLFACTOR = 80)
)
ON [PRIMARY]
GO