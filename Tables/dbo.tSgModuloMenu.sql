CREATE TABLE [dbo].[tSgModuloMenu] (
  [CodModulo] [char](3) NOT NULL,
  [CodSistema] [char](2) NOT NULL,
  [Opcion] [varchar](10) NOT NULL,
  [RutaIconoNoSel] [varchar](100) NULL,
  [RutaIconoSel] [varchar](100) NULL,
  CONSTRAINT [PK_tSgModuloMenu] PRIMARY KEY CLUSTERED ([CodModulo], [CodSistema], [Opcion])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tSgModuloMenu] WITH NOCHECK
  ADD CONSTRAINT [FK_tSgModuloMenu_tSgMenus] FOREIGN KEY ([CodSistema], [Opcion]) REFERENCES [dbo].[tSgOptions] ([CodSistema], [Opcion])
GO

ALTER TABLE [dbo].[tSgModuloMenu]
  ADD CONSTRAINT [FK_tSgModuloMenu_tSgModulos] FOREIGN KEY ([CodModulo]) REFERENCES [dbo].[tSgModulos] ([CodModulo])
GO