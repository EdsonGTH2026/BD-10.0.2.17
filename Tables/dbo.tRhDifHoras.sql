CREATE TABLE [dbo].[tRhDifHoras] (
  [CodOficina] [varchar](3) NOT NULL,
  [CodUsuario] [char](15) NOT NULL,
  [idSecuencia] [int] NOT NULL,
  [Fecha] [datetime] NOT NULL,
  [Entrada] [datetime] NOT NULL,
  [Salida] [datetime] NULL,
  [Diferencia] [float] NULL,
  [Procesado] [bit] NULL CONSTRAINT [DF_tRhDifHoras_Aprobado] DEFAULT (0),
  [idObsEntrada] [int] NULL,
  [idObsSalida] [int] NULL,
  [CodHorario] [int] NULL,
  [IdTurno] [int] NULL,
  [Modificado] [bit] NULL,
  [iddia] [int] NULL,
  CONSTRAINT [PK_tRhDifHoras] PRIMARY KEY CLUSTERED ([CodOficina], [CodUsuario], [idSecuencia])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tRhDifHoras_FechaUsuarioSecuencia]
  ON [dbo].[tRhDifHoras] ([Fecha], [CodUsuario], [idSecuencia])
  ON [PRIMARY]
GO