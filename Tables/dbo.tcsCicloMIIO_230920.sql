CREATE TABLE [dbo].[tcsCicloMIIO_230920] (
  [CodPrestamo] [varchar](29) NOT NULL,
  [ciclo] [int] NULL,
  [codusuario] [varchar](25) NULL
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tcsCicloMIIO_230920] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tcsCicloMIIO_230920] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tcsCicloMIIO_230920] TO [rie_blozanob]
GO