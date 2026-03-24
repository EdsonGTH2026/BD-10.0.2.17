SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

create procedure [dbo].[pCsPrestamoElimina]
    @CodPrestamo char(19)
as

set nocount on

delete tcscartera where codprestamo = @codprestamo
delete tcscarteradet where codprestamo = @codprestamo
delete tcspadroncarteradet where codprestamo = @codprestamo
GO