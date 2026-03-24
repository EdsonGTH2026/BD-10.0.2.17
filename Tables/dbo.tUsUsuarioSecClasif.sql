CREATE TABLE [dbo].[tUsUsuarioSecClasif] (
  [IdUsDatoSec] [int] IDENTITY,
  [CodSistema] [char](2) NULL,
  [CodProducto] [varchar](4) NULL,
  [EsPerNatural] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioSecClasif_EsPerNatural] DEFAULT (1),
  [CodTipoUs] [varchar](5) NULL,
  [Campo] [varchar](20) NOT NULL,
  [Descripcion] [varchar](30) NULL,
  [Mascara] [varchar](20) NOT NULL CONSTRAINT [DF_tUsUsuarioSecClasif_Mascara] DEFAULT (''),
  [Lista] [varchar](250) NULL,
  [MultipleElec] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioSecClasif_MultipleElec] DEFAULT (0),
  [SoloParentesis] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioSecClasif_SoloParentesis] DEFAULT (0),
  [Requerido] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioSecClasif_Requerido] DEFAULT (1),
  [Activo] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioSecClasif_Activo] DEFAULT (1),
  [Grupo] [tinyint] NOT NULL CONSTRAINT [DF_tUsUsuarioSecClasif_Grupo] DEFAULT (0),
  [Orden] [tinyint] NULL,
  CONSTRAINT [PK_tUsUsuarioSecClasif] PRIMARY KEY CLUSTERED ([IdUsDatoSec])
)
ON [PRIMARY]
GO