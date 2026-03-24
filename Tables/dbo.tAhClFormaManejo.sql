CREATE TABLE [dbo].[tAhClFormaManejo] (
  [FormaManejo] [int] NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Descripcion] [varchar](100) NULL,
  [Activo] [int] NULL,
  CONSTRAINT [PK_tAhClFormaManejo] PRIMARY KEY CLUSTERED ([FormaManejo])
)
ON [PRIMARY]
GO