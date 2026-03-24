SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create Function [dbo].[fduMD5] (@Dato Text)
Returns char(32) as
Begin
	Declare @Kemy char(32)
	Exec master.dbo.xp_md5 @Dato, -1, @Kemy output
	Return @Kemy
End
GO