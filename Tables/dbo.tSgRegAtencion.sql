CREATE TABLE [dbo].[tSgRegAtencion] (
  [NroReporte] [int] NOT NULL,
  [idarea] [int] NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Hora] [datetime] NOT NULL,
  [Usuario] [varchar](20) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  [CodUsuarioCall] [varchar](20) NULL,
  [NombreCompleto] [varchar](100) NULL,
  [Motivo] [varchar](100) NULL,
  [Observacion] [varchar](200) NULL,
  [Estado] [int] NULL,
  [Referencia] [varchar](15) NULL,
  [FechaUltMov] [smalldatetime] NULL,
  [HoraUltMov] [datetime] NULL,
  [CodInc] [int] NULL,
  [RefExterno] [varchar](20) NULL,
  [AteExterno] [varchar](100) NULL,
  CONSTRAINT [PK_tSgRegAtencion] PRIMARY KEY CLUSTERED ([NroReporte], [idarea])
)
ON [PRIMARY]
GO