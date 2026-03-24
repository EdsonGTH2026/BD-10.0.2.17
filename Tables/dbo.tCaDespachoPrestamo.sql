CREATE TABLE [dbo].[tCaDespachoPrestamo] (
  [IdDespacho] [int] NOT NULL,
  [CodPrestamo] [varchar](20) NOT NULL,
  [Atraso] [varchar](20) NULL,
  [FechaRegistro] [smalldatetime] NULL,
  [Activo] [tinyint] NOT NULL,
  CONSTRAINT [PK_tCaDespachoPrestamo] PRIMARY KEY CLUSTERED ([IdDespacho], [CodPrestamo])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCaDespachoPrestamo] TO [jmartinezc]
GO

GRANT SELECT ON [dbo].[tCaDespachoPrestamo] TO [jarriagaa]
GO

ALTER TABLE [dbo].[tCaDespachoPrestamo] WITH NOCHECK
  ADD CONSTRAINT [FK_tCaDespachoPrestamo_tCaClDespacho] FOREIGN KEY ([IdDespacho]) REFERENCES [dbo].[tCaClDespacho] ([IdDespacho])
GO