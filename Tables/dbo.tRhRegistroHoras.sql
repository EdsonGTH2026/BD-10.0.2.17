CREATE TABLE [dbo].[tRhRegistroHoras] (
  [FechaHora] [datetime] NOT NULL,
  [CodOficina] [varchar](3) NOT NULL,
  [CodUsuario] [char](15) NOT NULL,
  [CodHorario] [int] NOT NULL,
  [IdTurno] [int] NOT NULL,
  [EntradaSalida] [bit] NULL,
  [idObservacion] [int] NULL,
  [idSecuencia] [int] NULL,
  [Modificado] [bit] NOT NULL CONSTRAINT [DF_tRhRegistroHoras_Modificado] DEFAULT (0),
  [CodAdm] [varchar](25) NULL,
  [FechModifica] [datetime] NULL,
  [UltimoValor] [datetime] NULL,
  [Procesado] [bit] NULL CONSTRAINT [DF_tRhRegistroHoras_Procesado] DEFAULT (0),
  [iddia] [int] NULL,
  CONSTRAINT [PK_tRhRegistroHoras] PRIMARY KEY CLUSTERED ([FechaHora], [CodOficina], [CodUsuario], [CodHorario], [IdTurno])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tRhRegistroHoras]
  ADD CONSTRAINT [FK_tRhRegistroHoras_tRhClObsMarcado] FOREIGN KEY ([idObservacion]) REFERENCES [dbo].[tRhClObsMarcado] ([IdObservacion])
GO