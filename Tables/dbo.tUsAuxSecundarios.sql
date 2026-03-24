CREATE TABLE [dbo].[tUsAuxSecundarios] (
  [NombreTerminal] [varchar](20) NOT NULL,
  [Nombre] [varchar](20) NULL,
  [Campo] [varchar](20) NOT NULL,
  [Descripcion] [varchar](30) NULL,
  [Mascara] [varchar](20) NOT NULL CONSTRAINT [DF_tUsAuxSecundarios_Mascara] DEFAULT (''),
  [Lista] [varchar](250) NULL,
  [MultipleElec] [bit] NOT NULL CONSTRAINT [DF_tUsAuxSecundarios_MultipleElec] DEFAULT (0),
  [SoloParentesis] [bit] NOT NULL CONSTRAINT [DF_tUsAuxSecundarios_SoloParentesis] DEFAULT (0),
  [Requerido] [bit] NOT NULL CONSTRAINT [DF_tUsAuxSecundarios_Requerido] DEFAULT (1),
  [Grupo] [tinyint] NOT NULL CONSTRAINT [DF_tUsAuxSecundarios_Grupo] DEFAULT (0),
  [Orden] [tinyint] NULL,
  [Valor] [varchar](100) NULL,
  [CodGrabar] [varchar](100) NULL,
  CONSTRAINT [PK_tUsAuxSecundarios] PRIMARY KEY CLUSTERED ([NombreTerminal], [Campo])
)
ON [PRIMARY]
GO