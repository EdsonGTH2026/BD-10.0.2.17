CREATE TABLE [dbo].[tUsClTipoPropiedad] (
  [CodTipoPro] [char](3) NOT NULL,
  [TipoPro] [varchar](20) NULL,
  [Orden] [tinyint] NULL,
  [SHF] [int] NULL,
  [INTF] [int] NULL,
  [Activo] [bit] NOT NULL,
  CONSTRAINT [PK_tUsClTipoPropiedad] PRIMARY KEY CLUSTERED ([CodTipoPro])
)
ON [PRIMARY]
GO