CREATE TABLE [dbo].[tUsUsuarioPrinClasif] (
  [IdUsDatoPrin] [int] IDENTITY,
  [CodSistema] [char](2) NULL,
  [CodProducto] [varchar](4) NULL,
  [EsPerNatural] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioPrinClasif_EsPerNatural] DEFAULT (1),
  [CodTipoUs] [varchar](5) NULL,
  [Campo] [varchar](17) NOT NULL,
  [Descripcion] [varchar](30) NULL,
  [Requerido] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioPrinClasif_Requerido] DEFAULT (1),
  [Orden] [smallint] NULL,
  [Activo] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioPrinClasif_Activo] DEFAULT (1),
  [Fijo] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioPrinClasif_Fijo] DEFAULT (0),
  CONSTRAINT [PK_tUsUsuarioPrinClasif] PRIMARY KEY CLUSTERED ([IdUsDatoPrin])
)
ON [PRIMARY]
GO