CREATE TABLE [dbo].[tTaTipoMovimientos] (
  [CodTipoMov] [varchar](3) NOT NULL,
  [Descripcion] [varchar](200) NULL,
  [Operacion] [char](1) NULL,
  [EstadoCuenta] [varchar](50) NULL,
  [Orden] [int] NULL,
  CONSTRAINT [PK_tTaTipoMovimientos] PRIMARY KEY CLUSTERED ([CodTipoMov])
)
ON [PRIMARY]
GO