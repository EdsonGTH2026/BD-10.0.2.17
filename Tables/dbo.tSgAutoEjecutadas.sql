CREATE TABLE [dbo].[tSgAutoEjecutadas] (
  [IdAutoEjecutada] [int] NOT NULL,
  [IdAutoGenerada] [int] NULL,
  [CodAutoriza] [char](6) NULL,
  [Campo1] [varchar](100) NULL,
  [Campo2] [varchar](100) NULL,
  [Motivo] [varchar](200) NULL,
  [Valor] [varchar](20) NULL,
  [FechaHora] [datetime] NULL,
  [Terminal] [varchar](20) NULL,
  [CodUsuario] [char](15) NOT NULL,
  [Exito] [bit] NULL CONSTRAINT [DF_tSgAutoEjecutadas_Exito] DEFAULT (1),
  [Usado] [varchar](30) NULL,
  [ObservacionUso] [varchar](200) NULL,
  [ClaveDictada] [varchar](20) NULL,
  [CodOficina] [varchar](4) NULL,
  CONSTRAINT [PK_tSgAutoEjecutadas] PRIMARY KEY CLUSTERED ([IdAutoEjecutada])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Graba un registro cuando se ejecuto una autorización como registro de auditoría.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Identificador de autorización ejecutada', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'IdAutoEjecutada'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Referencia a la creacion de autoriZacion en lugar de origen', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'IdAutoGenerada'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la autoriZacion generada.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'CodAutoriza'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Campo1 asociado a la definición de la autorización', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'Campo1'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Campo2 asociado a la definición de la autorización', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'Campo2'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Motivo de uso de autoriZacion.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'Motivo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Valor que pone en campo que requiere autoriZacion.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'Valor'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha y Hora en que se ejecuto.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'FechaHora'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Terminal desde la que se ejecuto.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'Terminal'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Usuario que utiliZo la autoriZacion.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'CodUsuario'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Si se puso la clave con exito.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'Exito'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'no entiendo todavia para que.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'Usado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Observacion interna al uso de la autoriZacion.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'ObservacionUso'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'dictada en caso de que se haya dado por telefono.', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'ClaveDictada'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la oficina', 'SCHEMA', N'dbo', 'TABLE', N'tSgAutoEjecutadas', 'COLUMN', N'CodOficina'
GO