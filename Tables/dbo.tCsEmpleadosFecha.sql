CREATE TABLE [dbo].[tCsEmpleadosFecha] (
  [Fecha] [smalldatetime] NOT NULL,
  [CodUsuario] [varchar](15) NOT NULL,
  [CodEmpleado] [varchar](10) NULL,
  [CodOficina] [varchar](4) NULL,
  [CodPuesto] [int] NULL,
  CONSTRAINT [PK_tCsEmpleadosFecha] PRIMARY KEY CLUSTERED ([Fecha], [CodUsuario])
)
ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleadosFecha_CodPuesto]
  ON [dbo].[tCsEmpleadosFecha] ([CodPuesto])
  INCLUDE ([Fecha], [CodUsuario], [CodOficina])
  ON [PRIMARY]
GO

CREATE INDEX [IX_tCsEmpleadosFecha_CodUsuario_CodPuesto]
  ON [dbo].[tCsEmpleadosFecha] ([CodUsuario], [CodPuesto])
  INCLUDE ([Fecha])
  ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosFecha] TO [marista]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosFecha] TO [mchavezs2]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosFecha] TO [rie_sbravoa]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosFecha] TO [ope_lvegav]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosFecha] TO [ope_lcoronas]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosFecha] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosFecha] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosFecha] TO [Int_dreyesg]
GO

GRANT SELECT ON [dbo].[tCsEmpleadosFecha] TO [int_mmartinezp]
GO