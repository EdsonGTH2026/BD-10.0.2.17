CREATE TABLE [dbo].[tTcClFacturaParam] (
  [CodOficina] [varchar](4) NOT NULL,
  [FacPermiDiasAtras] [tinyint] NOT NULL,
  [FacPermiDiasAdel] [tinyint] NOT NULL,
  [NumBloqueDoc] [int] NOT NULL,
  [IdFactura] [int] NOT NULL,
  [MinFacturaAlarma] [smallint] NOT NULL,
  [MontoEsBase] [bit] NOT NULL,
  [IncEditable] [bit] NOT NULL
)
ON [PRIMARY]
GO