CREATE TABLE [dbo].[tTcOperCuentaTmp] (
  [CodOficina] [varchar](4) NOT NULL,
  [CodEntidadTipo] [varchar](3) NOT NULL,
  [CodEntidad] [varchar](3) NOT NULL,
  [NroCuenta] [varchar](30) NOT NULL,
  [NroOper] [decimal] NOT NULL,
  [TipoOper] [char](2) NULL,
  [Monto] [money] NULL,
  [CodConcepto] [int] NULL,
  [NroDocumento] [char](10) NULL,
  [Obs] [varchar](150) NULL,
  [Fecha] [smalldatetime] NULL,
  [CodEmpresa] [tinyint] NULL,
  [CodFondo] [varchar](2) NULL,
  [Operacion] [char](4) NULL,
  [OperConciliada] [bit] NOT NULL,
  [CodUsuario] [char](15) NULL,
  [CuentaTraspaso] [varchar](30) NULL
)
ON [PRIMARY]
GO