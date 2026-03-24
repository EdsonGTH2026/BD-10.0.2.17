CREATE TABLE [dbo].[tCsARenovaAnticipaPreCal] (
  [codprestamo] [char](19) NOT NULL,
  [codproducto] [char](3) NULL,
  [codoficina] [varchar](4) NOT NULL,
  [Cliente] [varchar](250) NULL,
  [fechadesembolso] [smalldatetime] NOT NULL,
  [Desembolso] [money] NOT NULL,
  [deuda2] [money] NULL,
  [MontoDisponibleRenovacion] [money] NULL,
  [Diasmora] [smallint] NULL,
  [Estado] [varchar](15) NOT NULL,
  [cuotas] [tinyint] NOT NULL,
  [cuotaspendientes] [int] NULL,
  [codtipoplaz] [char](1) NOT NULL,
  [sucursal] [varchar](50) NULL,
  [region] [varchar](50) NOT NULL,
  [celular] [varchar](20) NULL,
  [Promotor] [varchar](200) NULL,
  [Edad] [smalldatetime] NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsARenovaAnticipaPreCal] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsARenovaAnticipaPreCal] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsARenovaAnticipaPreCal] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsARenovaAnticipaPreCal] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsARenovaAnticipaPreCal] TO [Int_dreyesg]
GO