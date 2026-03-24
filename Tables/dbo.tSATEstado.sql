CREATE TABLE [dbo].[tSATEstado] (
  [Estado] [char](1) NOT NULL,
  [Nombre] [varchar](50) NULL,
  [Impuesto] [varchar](3) NULL,
  [Consulta] [bit] NULL,
  [Verificado] [bit] NULL,
  [Activo] [bit] NULL,
  CONSTRAINT [PK_tSATEstado] PRIMARY KEY CLUSTERED ([Estado])
)
ON [PRIMARY]
GO