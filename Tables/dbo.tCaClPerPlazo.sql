CREATE TABLE [dbo].[tCaClPerPlazo] (
  [CodTipoPlaz] [char](1) NOT NULL,
  [PerTipoPlaz] [smallint] NOT NULL,
  [DescPerPlaz] [varchar](15) NOT NULL,
  CONSTRAINT [PK_tCAClPerPlazo] PRIMARY KEY CLUSTERED ([CodTipoPlaz], [PerTipoPlaz])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaClPerPlazo]
  ADD CONSTRAINT [FK_tCAClPerPlazo_tCAClTipoPlaz] FOREIGN KEY ([CodTipoPlaz]) REFERENCES [dbo].[tCAClTipoPlaz] ([CodTipoPlaz]) ON UPDATE CASCADE
GO