CREATE TABLE [dbo].[tUsClDocIdentidad] (
  [CodDocIden] [varchar](5) NOT NULL,
  [DocIdentidad] [varchar](50) NULL,
  [Mascara] [varchar](20) NOT NULL,
  [CodGrupoSuf] [tinyint] NOT NULL,
  [PosSufijo] [char](1) NOT NULL,
  [NumCarSufijo] [tinyint] NOT NULL,
  [Orden] [tinyint] NULL,
  [Activo] [bit] NOT NULL,
  [ControlarMaxMask] [bit] NOT NULL,
  [AutoNumerico] [bit] NOT NULL,
  CONSTRAINT [PK_tUsClDocIdentidad] PRIMARY KEY CLUSTERED ([CodDocIden])
)
ON [PRIMARY]
GO