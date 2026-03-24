CREATE TABLE [dbo].[tRhClHorarios] (
  [CodOficina] [varchar](3) NOT NULL,
  [CodHorario] [int] NOT NULL,
  [Descripcion] [varchar](50) NULL,
  [Nocturno] [bit] NOT NULL CONSTRAINT [DF_tRhClHorarios_Nocturno] DEFAULT (0),
  [Activo] [bit] NULL,
  [Intermedio] [bit] NULL CONSTRAINT [DF_tRhClHorarios_Intermedio_1] DEFAULT (0),
  CONSTRAINT [PK_tRhClHorarios] PRIMARY KEY CLUSTERED ([CodOficina], [CodHorario])
)
ON [PRIMARY]
GO