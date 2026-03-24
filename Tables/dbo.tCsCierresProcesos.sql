CREATE TABLE [dbo].[tCsCierresProcesos] (
  [Identificador] [int] NOT NULL,
  [Proceso] [varchar](100) NOT NULL,
  [Descripcion] [varchar](100) NULL,
  [Inicio] [datetime] NULL,
  [Fin] [datetime] NULL,
  [Demora] [int] NULL,
  [Registro] [datetime] NULL,
  [Activo] [int] NULL,
  CONSTRAINT [PK_tCsCierresProcesos] PRIMARY KEY CLUSTERED ([Identificador], [Proceso])
)
ON [PRIMARY]
GO