CREATE TABLE [dbo].[tCsBsRangos] (
  [iCodIndicador] [int] NOT NULL,
  [ItemColor] [int] NOT NULL,
  [Color] [varchar](50) NULL,
  [Descripcion] [varchar](200) NULL,
  CONSTRAINT [PK_tCsBsRangos] PRIMARY KEY CLUSTERED ([iCodIndicador], [ItemColor])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCsBsRangos] WITH NOCHECK
  ADD CONSTRAINT [FK_tCsBsRangos_tCsBsIndicadores] FOREIGN KEY ([iCodIndicador]) REFERENCES [dbo].[tCsBsIndicadores] ([iCodIndicador]) ON DELETE CASCADE ON UPDATE CASCADE
GO