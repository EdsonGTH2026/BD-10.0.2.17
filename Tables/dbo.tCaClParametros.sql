CREATE TABLE [dbo].[tCaClParametros] (
  [CodOficina] [varchar](4) NOT NULL,
  [FechaProceso] [smalldatetime] NOT NULL,
  [CodSistema] [char](1) NOT NULL,
  [NemCartera] [varchar](5) NOT NULL,
  [Proceso] [tinyint] NOT NULL,
  [Decimales] [tinyint] NOT NULL,
  [DiasFechaFija] [int] NOT NULL,
  [CtrlFechaVen] [bit] NOT NULL,
  [TipoInteres] [char](1) NOT NULL,
  [Redondeo] [tinyint] NOT NULL,
  [CodEncargadoCA] [char](15) NULL,
  [NroActa] [int] NULL,
  [FechaNroActa] [smalldatetime] NULL,
  [CodFondoLinea] [varchar](2) NULL,
  [CodEncargadoBG] [char](15) NULL,
  [AsignarFondo] [bit] NOT NULL,
  [SolicitudSinFondo] [bit] NOT NULL,
  [PorcGarantia] [money] NOT NULL
)
ON [PRIMARY]
GO