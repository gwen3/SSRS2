----------------------------------------
-- MDM02 - Lignes de Commandes Clients
----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
(case left(lcdecli.t_orno, 2) 
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
lcdecli.t_orno as NumeroCommande, 
lcdecli.t_pono as PositionCommande, 
lcdecli.t_sqnb as SequenceCommande, 
dbo.convertenum('td','B61C','a9','bull','sls.oltp',lcdecli.t_oltp,'4') as TypeLigneCommande, 
dbo.convertenum('td','B61C','a9','bull','sls.hdst',cdecli.t_hdst,'4') as StatutCommande, 
cdecli.t_cofc as ServiceVente, 
sven.t_dsca as DescriptionServiceVente, 
cdecli.t_crep as RepresentantInterne, 
emp.t_nama as NomRepresentantInterne, 
lcdecli.t_ofbp as Tiers, 
tier.t_nama as NomTiers, 
left(lcdecli.t_item, 9) as ProjetArticle, 
substring(lcdecli.t_item, 10, len(lcdecli.t_item)) as Article, 
art.t_dsca as DesignationArticle, 
art.t_citg as GroupeArticle, 
grpart.t_dsca as DescriptionGroupeArticle, 
lcdecli.t_odat as DateCommande, 
lcdecli.t_qoor as QuantiteCommandee, 
lcdecli.t_pric as PrixLigne, 
cdecli.t_oamt as MontantCommande 
from ttdsls401500 lcdecli --Lignes de Commandes Clients
left outer join ttccom100500 tier on tier.t_bpid = lcdecli.t_ofbp --Tiers Acheteur
left outer join ttcibd001500 art on art.t_item = lcdecli.t_item --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Articles
inner join ttdsls400500 cdecli on cdecli.t_orno = lcdecli.t_orno --Commandes Clients
left outer join ttccom001500 emp on emp.t_emno = cdecli.t_crep --Représentant Interne
left outer join ttcmcs065500 sven on sven.t_cwoc = cdecli.t_cofc --Service Achat
where lcdecli.t_oltp != 3 --On ne prend pas les séquences de reliquats
and left(lcdecli.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise définit par la commande fournisseur
and lcdecli.t_odat between @datecde_f and @datecde_t --Bornage sur la Date de Commande
order by NumeroCommande, PositionCommande