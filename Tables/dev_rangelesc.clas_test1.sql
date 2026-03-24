CREATE TABLE [dev_rangelesc].[clas_test1] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  [codsolicitud] [varchar](15) NULL,
  [CodProducto] [varchar](3) NULL,
  [FechaVencimiento] [smalldatetime] NULL,
  [NroDiasAtraso] [int] NULL,
  [NroDiasAcumulado] [int] NULL,
  [SecuenciaCliente] [int] NULL,
  [EstadoCalculado] [varchar](20) NULL,
  [NroDiasMaximo] [int] NULL,
  [ModalidadPlazo] [char](2) NULL,
  [NroCuotas] [smallint] NULL,
  [TasaIntCorriente] [decimal](18, 7) NULL,
  [Monto] [decimal](18, 4) NULL,
  [Desembolso] [smalldatetime] NULL,
  [TipoReprog] [varchar](5) NULL,
  [clasCliente] [int] NOT NULL,
  [fechacorte] [smalldatetime] NULL
)
ON [PRIMARY]
GO