CREATE TABLE [dbo].[tCaClCheckListDetalle] (
  [Detalle] [varchar](3) NOT NULL,
  [Grupo] [varchar](3) NOT NULL,
  [Tecnologia] [varchar](2) NULL,
  [ParImpar] [varchar](2) NULL,
  [SecMin] [int] NULL,
  [SecMax] [int] NULL,
  [Nombre] [varchar](100) NULL,
  [Descripcion] [varchar](200) NULL,
  [Activo] [char](10) NULL,
  CONSTRAINT [PK_tCaClCheckListDetalle] PRIMARY KEY CLUSTERED ([Detalle], [Grupo])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaClCheckListDetalle] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaClCheckListDetalle_tCaClCheckListGrupo] FOREIGN KEY ([Grupo]) REFERENCES [dbo].[tCaClCheckListGrupo] ([Grupo])
GO