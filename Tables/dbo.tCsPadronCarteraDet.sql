CREATE TABLE [dbo].[tCsPadronCarteraDet] (
  [CodPrestamo] [varchar](25) NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CU] [varchar](20) NULL,
  [CodOficina] [varchar](4) NULL,
  [FechaCorte] [smalldatetime] NULL,
  [CodGrupo] [varchar](15) NULL,
  [Coordinador] [bit] NULL,
  [CodProducto] [varchar](3) NULL,
  [SecuenciaPrestamo] [int] NULL,
  [SecuenciaGrupo] [int] NULL,
  [SecuenciaCliente] [int] NULL,
  [SaldoOriginal] [decimal](18, 4) NULL,
  [SaldoCalculado] [decimal](18, 4) NULL,
  [EstadoOriginal] [varchar](20) NULL,
  [EstadoCalculado] [varchar](20) NULL,
  [PaseVencido] [smalldatetime] NULL,
  [PaseCastigado] [smalldatetime] NULL,
  [CancelacionAnterior] [smalldatetime] NULL,
  [Desembolso] [smalldatetime] NULL,
  [Monto] [decimal](18, 4) NULL,
  [NroCuotas] [int] NULL,
  [Cancelacion] [smalldatetime] NULL,
  [TipoReprog] [varchar](5) NULL,
  [Renegociaciones] [int] NULL,
  [PeriodoAnterior] [varchar](6) NULL,
  [SaldoAnterior] [decimal](13, 4) NULL,
  [CarteraOrigen] [varchar](50) NULL,
  [CarteraActual] [varchar](50) NULL,
  [PrimerAsesor] [varchar](15) NULL,
  [UltimoAsesor] [varchar](15) NULL,
  [Sectorista2] [varchar](15) NULL,
  [S2Inicio] [smalldatetime] NULL,
  [S2Fin] [smalldatetime] NULL,
  [FolioBURO] [varchar](15) NULL,
  [Zurich] [smallint] NULL,
  [EstadoCuenta] [int] NULL,
  [CodVerificador] [varchar](15) NULL,
  [NroDiasMaximo] [int] NULL,
  CONSTRAINT [PK_tCsPadronCartera] PRIMARY KEY CLUSTERED ([CodPrestamo], [CodUsuario])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_cancelacion_codprestamo_fechacorte]
  ON [dbo].[tCsPadronCarteraDet] ([Cancelacion], [CodPrestamo], [FechaCorte])
  WITH (FILLFACTOR = 70)
  ON [PRIMARY]
GO

CREATE INDEX [IX_CarteraActual_CodOficina_Cancelacion]
  ON [dbo].[tCsPadronCarteraDet] ([CarteraActual], [CodOficina], [Cancelacion])
  INCLUDE ([CodPrestamo], [CodProducto])
  ON [PRIMARY]
GO

CREATE INDEX [IX_CodOficina_Cancelacion]
  ON [dbo].[tCsPadronCarteraDet] ([CodOficina], [Cancelacion], [CodPrestamo], [CodUsuario], [CodGrupo], [CodProducto], [Monto])
  ON [PRIMARY]
GO

CREATE INDEX [IX_CodOficina_Desembolso]
  ON [dbo].[tCsPadronCarteraDet] ([CodOficina], [Desembolso], [CodPrestamo], [CodUsuario], [FechaCorte], [Monto], [TipoReprog], [UltimoAsesor])
  ON [PRIMARY]
GO

CREATE INDEX [IX_codprestamo_codoficina]
  ON [dbo].[tCsPadronCarteraDet] ([CodPrestamo], [CodOficina])
  ON [PRIMARY]
GO

CREATE INDEX [IX_codprestamo_desembolso_CodOficina]
  ON [dbo].[tCsPadronCarteraDet] ([CodPrestamo], [Desembolso], [CodOficina])
  WITH (FILLFACTOR = 70)
  ON [PRIMARY]
GO

CREATE INDEX [IX_Desembolso]
  ON [dbo].[tCsPadronCarteraDet] ([Desembolso], [CodPrestamo], [CodUsuario], [CodProducto], [Monto])
  ON [PRIMARY]
GO

CREATE INDEX [IX_desembolso_codoficina_codusuario]
  ON [dbo].[tCsPadronCarteraDet] ([Desembolso], [CodOficina], [CodUsuario])
  WITH (FILLFACTOR = 70)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronCarteraDet_CodOficina_PaseCastigado]
  ON [dbo].[tCsPadronCarteraDet] ([CodOficina], [PaseCastigado])
  INCLUDE ([CodPrestamo], [FechaCorte], [Desembolso])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronCarteraDet_CodUsuario]
  ON [dbo].[tCsPadronCarteraDet] ([CodUsuario])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronCarteraDet_DesembolsoTipoReprogCodOficinaUltimoAsesorSecuenciaClienteMonto]
  ON [dbo].[tCsPadronCarteraDet] ([Desembolso], [TipoReprog], [CodOficina], [UltimoAsesor], [SecuenciaCliente], [Monto])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronCarteraDet_EstadoCalculado]
  ON [dbo].[tCsPadronCarteraDet] ([EstadoCalculado])
  INCLUDE ([CodPrestamo])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronCarteraDet_FechaCorte_codoficina]
  ON [dbo].[tCsPadronCarteraDet] ([FechaCorte], [CodOficina])
  WITH (FILLFACTOR = 70)
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsPadronCarteraDet_PresUsuarioSecPrestSecGrupoSecClienteSalCalcEstadoCalcPasVencPasCastigCancelSalAnt]
  ON [dbo].[tCsPadronCarteraDet] ([CodPrestamo], [CodUsuario], [SecuenciaPrestamo], [SecuenciaGrupo], [SecuenciaCliente], [SaldoCalculado], [EstadoCalculado], [PaseVencido], [PaseCastigado], [Cancelacion], [SaldoAnterior])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [ope_dalvarador]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tCsPadronCarteraDet] TO [int_mmartinezp]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'guarda el numero de renegociaciones de un credito sea por renovacion o reprogramacion', 'SCHEMA', N'dbo', 'TABLE', N'tCsPadronCarteraDet', 'COLUMN', N'Renegociaciones'
GO