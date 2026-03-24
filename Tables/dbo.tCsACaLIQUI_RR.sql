CREATE TABLE [dbo].[tCsACaLIQUI_RR] (
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

CREATE INDEX [ix_codoficina_cancelacion_atrasomaximo_Estado]
  ON [dbo].[tCsACaLIQUI_RR] ([codoficina], [cancelacion], [atrasomaximo], [Estado], [coordinador], [cliente], [codprestamo], [secuenciacliente], [monto], [fechadesembolso], [fechavencimiento], [codprestamonuevo], [codpromotor])
  ON [PRIMARY]
GO

CREATE INDEX [IX_codoficina_estado_atrasomaximo_cancelacion]
  ON [dbo].[tCsACaLIQUI_RR] ([codoficina], [Estado], [atrasomaximo], [cancelacion])
  WITH (FILLFACTOR = 70)
  ON [PRIMARY]
GO

CREATE INDEX [IX_codoficina_Estado_codusuario]
  ON [dbo].[tCsACaLIQUI_RR] ([codoficina], [Estado], [codusuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_codusuario_secuenciacliente]
  ON [dbo].[tCsACaLIQUI_RR] ([codusuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_codusuario_secuenciacliente_V2]
  ON [dbo].[tCsACaLIQUI_RR] ([codusuario], [secuenciacliente])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsACaLIQUI_RR_codoficina_EstadoV2]
  ON [dbo].[tCsACaLIQUI_RR] ([codoficina], [Estado])
  INCLUDE ([codusuario], [nuevomonto], [nuevodesembolso], [codprestamonuevo])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsACaLIQUI_RR_codoficina_EstadoV3]
  ON [dbo].[tCsACaLIQUI_RR] ([codoficina], [Estado])
  INCLUDE ([codusuario], [cliente], [codprestamo], [monto], [cancelacion], [atrasomaximo])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsACaLIQUI_RR_codprestamo]
  ON [dbo].[tCsACaLIQUI_RR] ([codprestamo])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsACaLIQUI_RR_Estado]
  ON [dbo].[tCsACaLIQUI_RR] ([Estado])
  INCLUDE ([region], [codoficina], [sucursal], [coordinador], [codusuario], [cliente], [codprestamo], [secuenciacliente], [monto], [fechadesembolso], [fechavencimiento], [cancelacion], [atrasomaximo], [nuevomonto], [nuevodesembolso], [codprestamonuevo], [telefonomovil], [semana], [codpromotor], [TipoReprog])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tCsACaLIQUI_RR] TO [int_mmartinezp]
GO