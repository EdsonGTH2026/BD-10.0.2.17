CREATE TABLE [dbo].[tCsInterAgencias] (
  [Fecha] [datetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [Direccion] [char](1) NOT NULL,
  [CodOficinaOrigen] [varchar](4) NOT NULL,
  [CodOficinaDestino] [varchar](4) NOT NULL,
  [FechaEnvio] [datetime] NULL,
  [FechaRecepcion] [datetime] NULL,
  [NroTransaccion] [int] NOT NULL,
  [CodSistema] [char](2) NULL,
  [Cuenta] [varchar](30) NULL,
  [FormaManejo] [varchar](3) NULL,
  [NombreCliente] [varchar](500) NULL,
  [Operacion] [varchar](2) NULL,
  [CodMoneda] [tinyint] NULL,
  [Importe] [money] NULL,
  [Comision] [money] NULL,
  [ComisionCobrada] [bit] NULL,
  [ComiDctaMonto] [bit] NULL,
  [CobroOrigenTrans] [bit] NULL,
  [Estado] [char](2) NULL,
  [DigVerifEnviado] [varchar](50) NULL,
  [DigVerifRecibido] [varchar](50) NULL,
  [ITFCliente] [money] NULL,
  [ITFInstitucion] [money] NULL,
  [NumOP] [varchar](20) NULL,
  [Observaciones] [varchar](250) NULL,
  CONSTRAINT [PK_tCsInterAgencias] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [Direccion], [CodOficinaOrigen], [CodOficinaDestino], [NroTransaccion])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de Proceso/Consolidacion', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Oficina consolidada', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'E:nvio, R:ecepcion', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'Direccion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', NULL, 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'CodOficinaOrigen'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', NULL, 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'CodOficinaDestino'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Número de la transacción', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'NroTransaccion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'CA, AH, etc', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'CodSistema'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la cuenta de ahorros o cartera', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'Cuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Forma de manejo de la cuenta de ahorros', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'FormaManejo'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre del cliente', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'NombreCliente'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del tipo de operación.', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'Operacion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'codigo de la moneda', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'CodMoneda'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Importe de la interagencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'Importe'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de la comisión', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'Comision'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si la comisión ha sido cobrada', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'ComisionCobrada'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si la comisión ha sido descontada del monto', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'ComiDctaMonto'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Indica si la comisión ha sido cobrada en origen de la transación', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'CobroOrigenTrans'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Estado de la interagencia', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Digito verificador de la interagencia enviada', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'DigVerifEnviado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Digito verificador de la interagencia recibida', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'DigVerifRecibido'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'ITF que paga el cliente', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'ITFCliente'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'ITF que paga la institución', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'ITFInstitucion'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Numero de la orden de pago', 'SCHEMA', N'dbo', 'TABLE', N'tCsInterAgencias', 'COLUMN', N'NumOP'
GO