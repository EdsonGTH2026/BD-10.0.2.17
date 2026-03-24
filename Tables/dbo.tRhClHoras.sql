CREATE TABLE [dbo].[tRhClHoras] (
  [CodOficina] [varchar](3) NOT NULL,
  [CodHorario] [int] NOT NULL,
  [IdDia] [int] NOT NULL,
  [IdTurno] [int] NOT NULL,
  [IdMarcado] [int] NOT NULL,
  [InicioMarcado] [datetime] NULL,
  [Marcado] [datetime] NULL,
  [LimiteMarcado] [datetime] NULL,
  [Tolerancia] [int] NULL,
  [HorasLaborales] [datetime] NULL,
  [MarcarRestraso] [int] NULL,
  [Activa] [bit] NOT NULL,
  CONSTRAINT [PK_tRhClHoras] PRIMARY KEY CLUSTERED ([CodOficina], [CodHorario], [IdDia], [IdTurno], [IdMarcado])
)
ON [PRIMARY]
GO