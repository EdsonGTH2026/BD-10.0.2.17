CREATE TABLE [dbo].[tCPClEstado] (
  [CodEstado] [char](2) NOT NULL,
  [Estado] [varchar](150) NULL,
  [Crystal] [varchar](100) NULL,
  [INTF] [varchar](4) NULL,
  [SHF] [char](2) NULL,
  [COFETEL] [varchar](5) NULL,
  [SITI] [varchar](50) NULL,
  [RangoPostal] [varchar](50) NULL,
  [ID10] [char](1) NULL,
  CONSTRAINT [PK_tCPClEstado] PRIMARY KEY CLUSTERED ([CodEstado])
)
ON [PRIMARY]
GO