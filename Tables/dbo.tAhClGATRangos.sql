CREATE TABLE [dbo].[tAhClGATRangos] (
  [MontoMin] [money] NOT NULL,
  [MontoMax] [money] NOT NULL,
  [BaseCalculo] [money] NULL,
  CONSTRAINT [PK_tAhClGATRangos] PRIMARY KEY CLUSTERED ([MontoMin], [MontoMax])
)
ON [PRIMARY]
GO