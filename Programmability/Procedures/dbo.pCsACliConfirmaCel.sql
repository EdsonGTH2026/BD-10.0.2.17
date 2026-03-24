SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsACliConfirmaCel] @fecha smalldatetime
as
--declare @fecha smalldatetime
--set @fecha='20181030'

declare @periodo varchar(6)
set @periodo=dbo.fdufechaaperiodo(@fecha)

truncate table tCsACliConfirmaCel

insert into tCsACliConfirmaCel
exec [10.0.2.14].finmas.dbo.pCsACliActualizaCelular @periodo

GO