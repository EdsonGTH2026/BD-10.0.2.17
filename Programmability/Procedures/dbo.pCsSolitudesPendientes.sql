SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--drop  procedure pCsSolitudesPendientes
create procedure [dbo].[pCsSolitudesPendientes] @codoficina varchar(200)
as
	exec [10.0.2.14].finmas.dbo.pCsSolitudesPendientes @codoficina
GO