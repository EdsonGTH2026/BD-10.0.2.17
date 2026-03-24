SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE procedure [dbo].[pCsCaRepAvanceMetasPromotor2] @fecha smalldatetime, @codoficina varchar(4)
as
set nocount on

	exec pCsCaRepAvanceMetasPromotor @Fecha 
GO

GRANT EXECUTE ON [dbo].[pCsCaRepAvanceMetasPromotor2] TO [public]
GO