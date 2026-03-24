CREATE TABLE [dbo].[tSgUsuariosCLine] (
  [NickUsuario] [varchar](20) NOT NULL,
  [tiponick] [int] NULL,
  [codusuario] [char](15) NULL,
  [email] [varchar](100) NULL,
  [NroCelular] [varchar](15) NULL,
  [FechaAlta] [smalldatetime] NULL,
  [FechaVigencia] [smalldatetime] NULL,
  [CambiaContrasena] [bit] NOT NULL CONSTRAINT [DF_tSgUsuariosCLine_CambiaContrasena] DEFAULT (1),
  [RenuevaVigencia] [bit] NOT NULL CONSTRAINT [DF_tSgUsuariosCLine_RenuevaVigencia] DEFAULT (1),
  [Activo] [bit] NULL CONSTRAINT [DF_tSgUsuariosCLine_Activo] DEFAULT (1),
  [CodOficina] [varchar](4) NULL,
  [claveacceso] [varchar](100) NULL,
  [claveverificacion] [varchar](100) NULL,
  [nroenvio] [int] NULL CONSTRAINT [DF_tSgUsuariosCLine_nroenvio] DEFAULT (0),
  [RContrato] [varchar](200) NULL,
  CONSTRAINT [PK_tSgUsuariosCLine] PRIMARY KEY CLUSTERED ([NickUsuario])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'1:documento identidad;2:numero cuenta de ahorros', 'SCHEMA', N'dbo', 'TABLE', N'tSgUsuariosCLine', 'COLUMN', N'tiponick'
GO