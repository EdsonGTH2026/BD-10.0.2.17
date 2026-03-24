CREATE TABLE [dbo].[tCaClServicios] (
  [CodServicio] [varchar](6) NOT NULL,
  [DescServicio] [varchar](30) NULL,
  [UsoDesemb] [bit] NOT NULL,
  [UsoPago] [bit] NOT NULL,
  [DiasServicio] [smallint] NULL,
  [TipoComprob] [varchar](6) NULL,
  [PagoAutom] [bit] NOT NULL,
  [MoneContab] [char](1) NULL
)
ON [PRIMARY]
GO