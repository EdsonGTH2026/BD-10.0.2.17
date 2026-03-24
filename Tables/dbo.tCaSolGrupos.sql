CREATE TABLE [dbo].[tCaSolGrupos] (
  [CodSolicitud] [varchar](15) NOT NULL,
  [CodProducto] [char](3) NOT NULL,
  [CodOficina] [varchar](4) NOT NULL,
  [CodGrupo] [char](15) NOT NULL,
  [SecPrestamo] [int] NULL,
  [UltPrestamo] [varchar](15) NULL,
  [CodMoneda] [varchar](2) NULL,
  [MontoSolicita] [money] NULL,
  [CuotaPrestamo] [money] NULL,
  [FechaDesemb] [smalldatetime] NULL,
  [AtrUltPrest] [int] NULL,
  [AtrMaxUltPre] [int] NULL,
  [AtrAcuGrupo] [int] NULL,
  [AtrMaxGrupo] [int] NULL,
  [CodAsesor] [varchar](15) NULL,
  [CodEstado] [varchar](15) NULL,
  CONSTRAINT [PK_tCaSolGrupos] PRIMARY KEY CLUSTERED ([CodSolicitud], [CodProducto], [CodOficina])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[tCaSolGrupos] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaSolGrupos_tCaSolicitud] FOREIGN KEY ([CodSolicitud], [CodProducto], [CodOficina]) REFERENCES [dbo].[tCaSolicitud] ([CodSolicitud], [CodProducto], [CodOficina])
GO