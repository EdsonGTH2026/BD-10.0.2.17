CREATE TABLE [dbo].[tCsCboAH] (
  [Sistema] [varchar](2) NOT NULL,
  [CodUsCuenta] [varchar](15) NOT NULL,
  [CodCuenta] [varchar](25) NOT NULL,
  [CodOficina] [varchar](4) NULL,
  [idManejo] [smallint] NULL,
  [NombreCompleto] [varchar](120) NULL,
  [idTipoProd] [smallint] NULL,
  [FechaApertura] [smalldatetime] NULL
)
ON [PRIMARY]
GO