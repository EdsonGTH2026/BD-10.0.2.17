CREATE TABLE [dbo].[tClFuenteFin] (
  [CodFuenteFin] [char](2) NOT NULL,
  [NemFuenteFin] [varchar](15) NOT NULL,
  [DescFuenteFin] [varchar](50) NOT NULL,
  [Activo] [bit] NOT NULL,
  [Orden] [int] NOT NULL,
  [ActivoConta] [bit] NOT NULL,
  [ContaCodigo] [varchar](5) NOT NULL
)
ON [PRIMARY]
GO