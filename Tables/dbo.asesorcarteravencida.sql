CREATE TABLE [dbo].[asesorcarteravencida] (
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOriginal] [varchar](15) NULL,
  [CodOrigen] [varchar](15) NULL,
  [CodOficina] [varchar](4) NULL,
  CONSTRAINT [PK_asesorcarteravencida] PRIMARY KEY CLUSTERED ([CodUsuario])
)
ON [PRIMARY]
GO