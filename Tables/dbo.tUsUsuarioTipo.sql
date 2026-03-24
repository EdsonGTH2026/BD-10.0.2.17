CREATE TABLE [dbo].[tUsUsuarioTipo] (
  [CodUsuario] [char](15) NOT NULL,
  [CodTipoUs] [varchar](5) NOT NULL,
  [FechaIng] [datetime] NOT NULL,
  [Activo] [bit] NOT NULL CONSTRAINT [DF_tUsUsuarioTipo_Activo] DEFAULT (1),
  [FechaRet] [datetime] NULL,
  CONSTRAINT [PK_tUsUsuarioTipo] PRIMARY KEY CLUSTERED ([CodUsuario], [CodTipoUs], [FechaIng])
)
ON [PRIMARY]
GO