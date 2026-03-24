CREATE TABLE [dbo].[tCaProdPerfilCliente] (
  [CodProducto] [char](3) NOT NULL,
  [Masculino] [bit] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_Masculino] DEFAULT (0),
  [Femenino] [bit] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_Femenino] DEFAULT (0),
  [EdadMinima] [tinyint] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_EdadMinima] DEFAULT (0),
  [EdadMaxima] [tinyint] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_EdadMaxima] DEFAULT (0),
  [VinculadoInstit] [bit] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_VinculadoInstit] DEFAULT (0),
  [VinculadoFami] [bit] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_VinculadoFami] DEFAULT (0),
  [AntiguedadNeg] [tinyint] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_AntiguedadNeg] DEFAULT (0),
  [ResidenciaUs] [tinyint] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_ResidenciaUs] DEFAULT (0),
  [PersonaNatural] [bit] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_PersonaNatural] DEFAULT (0),
  [PersonaJuridica] [bit] NOT NULL CONSTRAINT [DF_tCaProdPerfilCliente_PersonaJuridica] DEFAULT (0),
  [CodAutoriza] [char](6) NULL,
  CONSTRAINT [PK_tCaPerfilCliente] PRIMARY KEY CLUSTERED ([CodProducto])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaProdPerfilCliente] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaProdPerfilCliente_tCaProducto] FOREIGN KEY ([CodProducto]) REFERENCES [dbo].[tCaProducto] ([CodProducto])
GO