CREATE TABLE [dbo].[_AltaCAMigrar] (
  [prestamoid] [int] NOT NULL,
  [clasificacion] [varchar](15) NULL,
  [saldocapitalvigente] [money] NULL,
  [saldointeresvigente] [money] NULL,
  [saldocapitalvencido] [money] NULL,
  [saldointeresvencido] [money] NULL,
  [saldointeresorden] [money] NULL,
  [diasatraso] [int] NULL,
  [reservak] [money] NULL,
  [reservaI] [money] NULL,
  CONSTRAINT [PK__AltaCAMigrar] PRIMARY KEY CLUSTERED ([prestamoid])
)
ON [PRIMARY]
GO