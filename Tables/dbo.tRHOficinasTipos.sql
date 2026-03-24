CREATE TABLE [dbo].[tRHOficinasTipos] (
  [Periodo] [varchar](6) NOT NULL,
  [Modulo] [varchar](4) NOT NULL,
  [Codoficina] [varchar](4) NOT NULL,
  [Clientes] [decimal](15, 4) NULL,
  [Monto] [decimal](15, 4) NULL,
  CONSTRAINT [PK_tRHOficinasTipos] PRIMARY KEY CLUSTERED ([Periodo], [Modulo], [Codoficina])
)
ON [PRIMARY]
GO