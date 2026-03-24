CREATE TABLE [dbo].[tClOficinas] (
  [CodOficina] [varchar](4) NOT NULL,
  [Zona] [varchar](3) NULL,
  [SIC] [varchar](3) NULL,
  [NomOficina] [varchar](30) NULL,
  [DescOficina] [varchar](50) NULL,
  [Tipo] [varchar](50) NULL,
  [CodUbiGeo] [varchar](6) NOT NULL,
  [Direccion] [varchar](100) NULL,
  [FechaApertura] [smalldatetime] NULL,
  [FechaCierre] [smalldatetime] NULL,
  [CodUsACargo] [varchar](15) NULL,
  [CodPostal] [varchar](10) NULL,
  [ConsolidadoAhorros] [smalldatetime] NULL,
  [ConsolidadoCartera] [smalldatetime] NULL,
  [Servidor] [varchar](50) NULL,
  [BaseDatos] [varchar](50) NULL,
  [SeConsolida] [int] NULL,
  [Parametro] [bit] NULL,
  [Telmex] [varchar](50) NULL,
  [Maxcom] [varchar](50) NULL,
  [Fax] [varchar](50) NULL,
  [idBanksDelgado] [varchar](10) NULL,
  [CURPSistemas] [varchar](50) NULL,
  [CodoficinaAsociada] [varchar](4) NULL,
  [HAPLunesViernes] [varchar](20) NULL,
  [HAPSabado] [varchar](20) NULL,
  [CtrolRegistro] [bit] NULL CONSTRAINT [DF_tClOficinas_CtrolRegistro] DEFAULT (1),
  [PaginaWeb] [varchar](100) NULL,
  [Correo] [varchar](100) NULL,
  [COFETEL] [varchar](5) NULL,
  [LineaGratuita] [varchar](50) NULL,
  [CodUsuarioCobranza] [varchar](15) NULL,
  [CodLocalidadPatmir] [varchar](15) NULL,
  [EsVirtual] [tinyint] NULL,
  [Codmicro] [int] NULL,
  CONSTRAINT [PK_tClOficinas] PRIMARY KEY CLUSTERED ([CodOficina])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tClOficinas_Tipo]
  ON [dbo].[tClOficinas] ([Tipo])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [marista]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [ope_dalvarador]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tClOficinas] TO [int_mmartinezp]
GO

EXEC sys.sp_addextendedproperty N'MS_Description', N'Control asistencia', 'SCHEMA', N'dbo', 'TABLE', N'tClOficinas', 'COLUMN', N'CtrolRegistro'
GO