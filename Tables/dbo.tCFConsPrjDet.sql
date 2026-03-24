CREATE TABLE [dbo].[tCFConsPrjDet] (
  [idCons] [int] NOT NULL CONSTRAINT [DF_tCFConsPrjDet_idPK] DEFAULT (0),
  [CodActDet] [varchar](6) NOT NULL,
  [Archivo] [varchar](200) NOT NULL CONSTRAINT [DF_tCFConsPrjDet_Archivo] DEFAULT (''),
  [NRegistros] [int] NOT NULL CONSTRAINT [DF_tCFConsPrjDet_NRegistros] DEFAULT (0),
  [CRC] [varchar](10) NOT NULL CONSTRAINT [DF_tCFConsPrjDet_CRC] DEFAULT (''),
  CONSTRAINT [PK_tCFConsPrjDet] PRIMARY KEY CLUSTERED ([idCons], [CodActDet])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCFConsPrjDet]
  ADD CONSTRAINT [FK_tCFConsPrjDet_tCFConsPrj] FOREIGN KEY ([idCons]) REFERENCES [dbo].[tCFConsPrj] ([idCons])
GO