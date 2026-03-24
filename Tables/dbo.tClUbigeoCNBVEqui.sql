CREATE TABLE [dbo].[tClUbigeoCNBVEqui] (
  [codlocalidadsiti] [varchar](15) NOT NULL,
  [codubigeo] [varchar](6) NOT NULL,
  [activo] [bit] NULL CONSTRAINT [DF_tClUbigeoCNBVEqui_activo] DEFAULT (1),
  CONSTRAINT [PK_tClUbigeoCNBVEqui] PRIMARY KEY CLUSTERED ([codlocalidadsiti], [codubigeo])
)
ON [PRIMARY]
GO

GRANT SELECT ON [dbo].[tClUbigeoCNBVEqui] TO [rie_jaguilar]
GO

GRANT SELECT ON [dbo].[tClUbigeoCNBVEqui] TO [rie_sbravoa]
GO

GRANT
  INSERT,
  SELECT
ON [dbo].[tClUbigeoCNBVEqui] TO [jarriagaa]
GO

GRANT SELECT ON [dbo].[tClUbigeoCNBVEqui] TO [rie_ldomingueze]
GO

GRANT SELECT ON [dbo].[tClUbigeoCNBVEqui] TO [rie_jalvarezc]
GO

GRANT SELECT ON [dbo].[tClUbigeoCNBVEqui] TO [rie_blozanob]
GO

GRANT SELECT ON [dbo].[tClUbigeoCNBVEqui] TO [public]
GO