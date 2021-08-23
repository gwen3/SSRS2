-----------------------------------
-- MDM05 - Ventes Avances Clients
-----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- dboivin 21/05/2018, ajout des variables pour utilisation hors SSRS
declare @datemod_f date = DATEADD(DD, -30, CAST(CURRENT_TIMESTAMP AS DATE));
declare @datemod_t date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @ov_f nvarchar(9) = ' '
declare @ov_t nvarchar(9) = 'ZZZZZZZZZ'
declare @ue_f nvarchar(2) = '  '
declare @ue_t nvarchar(2) = 'ZZ'
---------------------------------------

select (case left(cde.t_orno, 2) 
when 'AC' 
	then 'Sanicar' 
when 'AD' 
	then 'Ducarme' 
when 'AL' 
	then 'Gifa' 
when 'AM' 
	then 'Gifa' 
when 'AP' 
	then 'Petit Picot' 
when 'EC' 
	then 'Electron' 
when 'LB' 
	then 'Labbe' 
when 'LV' 
	then 'Laval' 
when 'LY' 
	then 'Lyon' 
when 'PN' 
	then 'Paris Nord' 
when 'PS' 
	then 'Paris Sud' 
when 'SM' 
	then 'Lorraine' 
end) as SiteGruau, 
cde.t_orno as CommandeClient, 
dbo.convertenum('td','B61C','a9','bull','sls.hdst',cde.t_hdst,'4') as StatutCommande, 
cde.t_cofc as ServiceVente, 
sven.t_dsca as DescriptionServiceVente, 
cde.t_crep as RepresentantInterne, 
emp.t_nama as NomRepresentantInterne, 
cde.t_ofbp as TiersAcheteur, 
tier.t_nama as NomTiersAcheteur, 
cde.t_oamt as MontantCommande, 
(select top 1 hist.t_trdt from ttdsls450500 hist where hist.t_ofbp = cde.t_ofbp and hist.t_orno = cde.t_orno order by hist.t_trdt) as DateModification 
from ttdsls400500 cde --Commandes Clients
left outer join ttccom100500 tier on tier.t_bpid = cde.t_ofbp --Tiers Acheteur
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Représentant Interne
left outer join ttcmcs065500 sven on sven.t_cwoc = cde.t_cofc --Service Achat
where cde.t_ofbp != '100005506' --Tiers Avance Client, on ne le prend pas car on veut récupérer ceux qui ont été modifiés
and cde.t_orno in (select hist.t_orno from ttdsls450500 hist where hist.t_ofbp = '100005506' and hist.t_orno = cde.t_orno) --On prend les Commandes Clients qui à l'origine était pour une avance client
and (select top 1 hist.t_trdt from ttdsls450500 hist where hist.t_ofbp = cde.t_ofbp and hist.t_orno = cde.t_orno order by hist.t_trdt) between @datemod_f and @datemod_t --On borne sur la Date de Modification
and cde.t_orno between @ov_f and @ov_t --Bornage sur l'Ordre de Vente
and left(cde.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'OV