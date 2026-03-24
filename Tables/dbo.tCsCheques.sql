CREATE TABLE [dbo].[tCsCheques] (
  [Fecha] [datetime] NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodSistema] [char](2) NOT NULL,
  [CodCajero] [varchar](15) NOT NULL,
  [CodTipoEnt] [char](2) NOT NULL,
  [CodEntidad] [char](3) NOT NULL,
  [TipoCheque] [bit] NULL,
  [NumCheque] [varchar](25) NOT NULL,
  [Estado] [varchar](20) NOT NULL,
  [FechaEstado] [datetime] NULL,
  [CodMoneda] [tinyint] NULL,
  [MontoOper] [money] NULL,
  [MontoITF] [money] NULL,
  [MontoComision] [money] NULL,
  [CodMonedaComision] [tinyint] NULL,
  [CodCuenta] [varchar](50) NOT NULL,
  [NumCuenta] [varchar](25) NOT NULL,
  [Nombre] [varchar](200) NULL,
  [FechaRechazo] [datetime] NULL,
  [FechaHoraReal] [datetime] NULL,
  CONSTRAINT [PK_tCsCheques] PRIMARY KEY CLUSTERED ([Fecha], [CodOficina], [CodSistema], [CodCajero], [CodTipoEnt], [CodEntidad], [NumCheque], [Estado], [CodCuenta], [NumCuenta])
)
ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'fecha de consolidacion', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'Fecha'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo de la Oficina de la cuenta', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'CodOficina'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Sistema que genero el cheque: AH, CA, etc', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'CodSistema'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Codigo del Cajero que realiza la operacion', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'CodCajero'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'CodTipoEnt y CodEntidad: Banco al cual pertenece el cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'CodTipoEnt'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'CodTipoEnt y CodEntidad: Banco al cual pertenece el cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'CodEntidad'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'0:Comercial o Normal; 1:Cheque de Gerencia (tgrFormaPagoGral.ChequeConfirmado)', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'TipoCheque'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'El numero del cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'NumCheque'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'RECIBIDO, ENVIADO, CONFIRMADO, ANULADO (en ese orden)', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'Estado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Fecha de registro o cambio de estado', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'FechaEstado'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Moneda del cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'CodMoneda'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto del cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'MontoOper'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto del ITF', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'MontoITF'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Monto de la comision, si existe', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'MontoComision'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Moneda de la comision', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'CodMonedaComision'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Cuenta de AH o Credito a la que afecta el cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'CodCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Numero de la cuenta de la CRSM a la que se deposita el cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'NumCuenta'
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Nombre a quien se gira el cheque', 'SCHEMA', N'dbo', 'TABLE', N'tCsCheques', 'COLUMN', N'Nombre'
GO