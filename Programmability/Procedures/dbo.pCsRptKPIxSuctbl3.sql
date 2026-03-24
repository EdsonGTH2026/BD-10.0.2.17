SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
create procedure [dbo].[pCsRptKPIxSuctbl3] @fecha smalldatetime, @codoficina varchar(5)
as   
set nocount on 

--declare @fecha smalldatetime  
--select @fecha=fechaconsolidacion from vcsfechaconsolidacion

select  
fecha,nomoficina,codoficina,
ptmos1a7ini,ptmos8a15ini,ptmos16a30ini,ptmos31ini,ptmosTotalini,
sal1a7ini,sal8a15ini,sal16a30ini,sal31ini,salTotalini,
ptmos1a7fin,ptmos8a15fin,ptmos16a30fin,ptmos31fin,ptmosTotalfin,
sal1a7fin,sal8a15fin,sal16a30fin,sal31fin,salTotalfin,
varPtmos1a7,varPtmos8a15,varPtmos16a30,varPtmos131,varPtmosTotal,
varSaldo1a7,varSaldo8a15,varSaldo16a30,varSaldo31,varSaldoTotal,
cosecha1,colocacionC1,porRecuperaC1,Deterioro0a15C1,Deterioro16C1,
cosecha2,colocacionC2,porRecuperaC2,Deterioro0a15C2,Deterioro16C2,cosecha3,
colocacionC3,porRecuperaC3,Deterioro0a15C3,Deterioro16C3,
cosecha4,colocacionC4,porRecuperaC4,Deterioro0a15C4,Deterioro16C4,
cosecha5,colocacionC5,porRecuperaC5,Deterioro0a15C5,Deterioro16C5,
cosecha6,colocacionC6,porRecuperaC6,Deterioro0a15C6,Deterioro16C6,
cosecha7,colocacionC7,porRecuperaC7,Deterioro0a15C7,Deterioro16C7,
cosecha8,colocacionC8,porRecuperaC8,Deterioro0a15C8,Deterioro16C8,
cosecha9,colocacionC9,porRecuperaC9,Deterioro0a15C9,Deterioro16C9,
cosecha10,colocacionC10,porRecuperaC10,Deterioro0a15C10,Deterioro16C10,
cosecha11,colocacionC11,porRecuperaC11,Deterioro0a15C11,Deterioro16C11,
cosecha12,colocacionC12,porRecuperaC12,Deterioro0a15C12,Deterioro16C12
from fnmgconsolidado.dbo.tcaCartaGerente with(nolock)
where fecha=@fecha
and codoficina=@codoficina
GO