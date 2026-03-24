CREATE TABLE [dbo].[tCsACaLIQUI_RR_QA] (
  [region] [varchar](50) NULL,
  [codoficina] [varchar](4) NOT NULL,
  [sucursal] [varchar](30) NULL,
  [coordinador] [varchar](300) NULL,
  [codusuario] [varchar](15) NOT NULL,
  [cliente] [varchar](300) NULL,
  [codprestamo] [varchar](25) NOT NULL,
  [secuenciacliente] [int] NULL,
  [monto] [decimal](18, 4) NULL,
  [fechadesembolso] [smalldatetime] NULL,
  [fechavencimiento] [smalldatetime] NULL,
  [cancelacion] [smalldatetime] NULL,
  [atrasomaximo] [int] NULL,
  [Estado] [varchar](11) NOT NULL,
  [nuevomonto] [decimal](18, 4) NULL,
  [nuevodesembolso] [smalldatetime] NULL,
  [codprestamonuevo] [varchar](25) NULL,
  [telefonomovil] [varchar](50) NULL,
  [semana] [int] NULL,
  [codpromotor] [varchar](15) NULL,
  [TipoReprog] [varchar](10) NULL
)
ON [PRIMARY]
GO