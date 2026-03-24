CREATE TABLE [dbo].[tBsiTransaccionCodigo] (
  [CodigoTransaccion] [varchar](8) NOT NULL,
  [Descripcion] [varchar](40) NULL,
  [CodigoTipo] [char](1) NULL,
  [ReporteExepcion] [char](1) NULL,
  [CodigoGrupo] [varchar](8) NULL,
  [Registro] [datetime] NULL,
  CONSTRAINT [PK_tBsiCodigoTransaccion] PRIMARY KEY CLUSTERED ([CodigoTransaccion])
)
ON [PRIMARY]
GO