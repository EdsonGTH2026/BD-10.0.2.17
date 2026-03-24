CREATE TABLE [dbo].[tCoClAsieCont] (
  [CodServicioAsie] [varchar](7) NOT NULL,
  [CodTipoOpera] [varchar](3) NOT NULL,
  [NroAsiento] [smallint] NOT NULL,
  [CodAsiento] [varchar](10) NULL,
  [Descripcion] [varchar](50) NULL,
  [GlosaGral] [varchar](300) NOT NULL,
  [Activo] [bit] NULL,
  [CodTipoAsiento] [smallint] NULL,
  [GenCruceOfi] [bit] NULL,
  [DesagregaxOfi] [bit] NULL,
  [DesagregaxOpera] [bit] NOT NULL,
  [CodCbte] [tinyint] NULL,
  [EsElegido] [bit] NOT NULL
)
ON [PRIMARY]
GO