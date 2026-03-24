SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create function [dbo].[dfuCACartaTableroBono] (@ncreBM decimal(8,2),@ncreAM decimal(8,2))
	returns decimal(8,2)
as
begin
--Declare @ncreBM decimal(8,2)
--Declare @ncreAM decimal(8,2)
--set @ncreBM=295
--set @ncreAM=40

declare @A326 decimal(8,2)
set @A326=85

--=MAX(
--SI(B$323/($A321+B$323)>20%,0
--	,SI(B$323/($A321+B$323)>10%,(3000*$A321*85%/12-3000*($A321+B$323)*0.2/12-3000*B$323/12-$A$326*($A321+B$323))*0.2
--		,SI(B$323/($A321+B$323)>2%,(3000*$A321*85%/12-3000*($A321+B$323)*0.2/12-3000*B$323/12-$A$326*($A321+B$323))*0.4
--			,SI($A321<150,(3000*$A321*85%/12-3000*($A321+B$323)*0.2/12-3000*B$323/12-$A$326*($A321+B$323))*0.5
--				,(3000*$A321*85%/12-3000*($A321+B$323)*0.2/12-3000*B$323/12-$A$326*($A321+B$323))*0.55
--			)
--		)
--	)	
--)
--,0)

--=MAX(
--select @ncreAM/(@ncreBM+@ncreAM)
return 
--select
--SI(
case when @ncreAM/(@ncreBM+@ncreAM)>0.2 then 0 else
	--,SI(
	case when @ncreAM/(@ncreBM+@ncreAM)>0.1 then (3000*@ncreBM*0.85/12-3000*(@ncreBM+@ncreAM)*0.2/12-3000*@ncreAM/12-@A326*(@ncreBM+@ncreAM))*0.2 else
		--,SI(
		case when @ncreAM/(@ncreBM+@ncreAM)>0.02 then (3000*@ncreBM*0.85/12-3000*(@ncreBM+@ncreAM)*0.2/12-3000*@ncreAM/12-@A326*(@ncreBM+@ncreAM))*0.4 else
			--,SI(
			case when @ncreBM<150 then (3000*@ncreBM*0.85/12-3000*(@ncreBM+@ncreAM)*0.2/12-3000*@ncreAM/12-@A326*(@ncreBM+@ncreAM))*0.5 else
				(3000*@ncreBM*0.85/12-3000*(@ncreBM+@ncreAM)*0.2/12-3000*@ncreAM/12-@A326*(@ncreBM+@ncreAM))*0.55
			end
			--)
		end
		--)
	end
	--)
end
--)
--,0)


end
GO