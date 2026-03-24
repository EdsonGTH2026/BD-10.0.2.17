CREATE TABLE [dbo].[tCsPrRubro] (
  [Rubro] [varchar](2) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  CONSTRAINT [PK_tCsPrRubro] PRIMARY KEY CLUSTERED ([Rubro])
)
ON [PRIMARY]
GO