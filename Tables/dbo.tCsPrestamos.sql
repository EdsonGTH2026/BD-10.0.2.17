CREATE TABLE [dbo].[tCsPrestamos] (
  [Fecha] [datetime] NOT NULL,
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodSolicitud] [varchar](15) NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodProducto] [char](3) NULL,
  [CodAsesor] [char](15) NULL,
  [CodUsuario] [char](15) NOT NULL,
  [CodGrupo] [char](15) NULL,
  [CodFondo] [varchar](2) NOT NULL,
  [CodTipoCredito] [tinyint] NOT NULL,
  [CodTipoPlaz] [char](1) NOT NULL,
  [Plazo] [int] NOT NULL CONSTRAINT [DF_tCsPrestamos_Plazo] DEFAULT (0),
  [Cuotas] [int] NOT NULL CONSTRAINT [DF_tCsPrestamos_Cuotas] DEFAULT (0),
  [FechaSolicitud] [datetime] NULL,
  [FechaAprobacion] [datetime] NULL,
  [FechaDesembolso] [datetime] NULL,
  [FechaVencimiento] [datetime] NULL,
  [MontoDesembolso] [money] NOT NULL CONSTRAINT [DF_tCsPrestamos_MontoDesembolso] DEFAULT (0),
  [CodMoneda] [varchar](2) NOT NULL,
  [TasaInteres] [money] NOT NULL CONSTRAINT [DF_tCsPrestamos_TasaInteres] DEFAULT (0),
  [ComisionDesembolso] [money] NOT NULL CONSTRAINT [DF_tCsPrestamos_ComisionDesembolso] DEFAULT (0),
  CONSTRAINT [PK_tCsPrestamos] PRIMARY KEY CLUSTERED ([Fecha], [CodPrestamo])
)
ON [PRIMARY]
GO

DECLARE @value SQL_VARIANT = CAST(N'Fecha de Desembolso' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'Fecha'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código de Prestamo' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodPrestamo'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código de Solicitud' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodSolicitud'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código de Oficina' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodOficina'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código de Producto' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodProducto'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código de Asesor' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodAsesor'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código de Usuario' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodUsuario'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código de Grupo' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodGrupo'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código de Fondo' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodFondo'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código del tipo de Crédito' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodTipoCredito'
GO

DECLARE @value SQL_VARIANT = CAST(N'Código del tipo de plazo' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodTipoPlaz'
GO

DECLARE @value SQL_VARIANT = CAST(N'Plazo del crédito' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'Plazo'
GO

DECLARE @value SQL_VARIANT = CAST(N'Cuotas del Crédito' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'Cuotas'
GO

DECLARE @value SQL_VARIANT = CAST(N'Fecha de Solicitud' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'FechaSolicitud'
GO

DECLARE @value SQL_VARIANT = CAST(N'Fecha de Aprobación' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'FechaAprobacion'
GO

DECLARE @value SQL_VARIANT = CAST(N'Fecha de Desembolso' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'FechaDesembolso'
GO

DECLARE @value SQL_VARIANT = CAST(N'Fecha de Vencimiento' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'FechaVencimiento'
GO

DECLARE @value SQL_VARIANT = CAST(N'Monto de Desembolso' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'MontoDesembolso'
GO

DECLARE @value SQL_VARIANT = CAST(N'Codigo de Moneda' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'CodMoneda'
GO

DECLARE @value SQL_VARIANT = CAST(N'Tasa de Interes' AS nvarchar(2000))
EXEC sys.sp_addextendedproperty N'MS_Description', @value, 'SCHEMA', N'dbo', 'TABLE', N'tCsPrestamos', 'COLUMN', N'TasaInteres'
GO