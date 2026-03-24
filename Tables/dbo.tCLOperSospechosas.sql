CREATE TABLE [dbo].[tCLOperSospechosas] (
  [IdOperSospechosa] [int] NOT NULL,
  [DescOperSospechosa] [varchar](50) NULL,
  [TransMontoMNal] [money] NOT NULL,
  [TransMontoMExt] [money] NOT NULL,
  [MesMontoMNal] [money] NULL,
  [MesMontoMExt] [money] NULL,
  [PerNatural] [bit] NULL
)
ON [PRIMARY]
GO