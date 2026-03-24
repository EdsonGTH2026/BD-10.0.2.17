CREATE TABLE [dbo].[tCsABitacoraCobranza] (
  [Codprestamo] [char](19) NOT NULL,
  [Item] [int] NOT NULL,
  [Fecha] [smalldatetime] NOT NULL,
  [Hora] [datetime] NOT NULL,
  [Relacion] [varchar](50) NULL,
  [Nombrecompleto] [varchar](200) NULL,
  [Observacion] [varchar](8000) NULL,
  [Dictamen] [varchar](50) NULL,
  [Tipo] [tinyint] NULL,
  [FechaUltEdicion] [datetime] NULL,
  [domicilio] [varchar](300) NULL,
  [telefono] [varchar](15) NULL,
  [promotor] [varchar](120) NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsABitacoraCobranza] TO [Int_dreyesg]
GO