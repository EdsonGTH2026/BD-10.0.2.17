CREATE TABLE [dbo].[_CAPtmostmp] (
  [codprestamo] [varchar](25) NULL
)
ON [PRIMARY]
GO

GRANT
  DELETE,
  INSERT,
  SELECT,
  UPDATE
ON [dbo].[_CAPtmostmp] TO [marista]
GO

GRANT SELECT ON [dbo].[_CAPtmostmp] TO [rie_ldomingueze]
GO