----------------
-- MDM04 - OFs
----------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
(case left(ofab.t_pdno, 2) 
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
ofab.t_pdno as OrdreFabrication, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
ofab.t_prdt as DateDebutFabrication, 
ofab.t_pldt as DateLivraisonPlanifiee, 
ofab.t_apdt as DateDebutReelle, 
ofab.t_cmdt as DateAchevement, 
ofab.t_qrdr as QuantiteOrdre, 
art.t_cuni as Unite, 
ofab.t_qdlv as QuantiteLivree, 
ofab.t_orno as CommandeClient, 
ofab.t_pono as PositionCommandeClient, 
left(ofab.t_mitm, 9) as Projet, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DescriptionArticle, 
art.t_citg as GroupeArticle, 
grpart.t_dsca as DescriptionGroupeArticle, 
ofab.t_prcd as Priorite, 
ofab.t_cwar as Magasin, 
ofab.t_adld as DateLivraisonReelle, 
ofab.t_qntl as QuantiteInitiale, 
ofab.t_plid as Planificateur, 
empplan.t_nama as NomPlanificateur, 
ofab.t_efdt as DateReference, 
ofab.t_sfpl as PilotageAtelier, 
emppilo.t_nama as NomPilotageAtelier, 
ofab.t_cldt as DateCloture 
from ttisfc001500 ofab --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Articles
left outer join ttccom001500 empplan on empplan.t_emno = ofab.t_plid --Employés - Planificateur
left outer join ttccom001500 emppilo on emppilo.t_emno = ofab.t_sfpl --Employés - Pilotage d'Atelier
where left(ofab.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
and ofab.t_efdt between @dateref_f and @dateref_t --Bornage sur la Date de Référence
and ofab.t_prdt between @datedeb_f and @datedeb_t --Bornage sur la Date de Début de Fabrication
and ofab.t_pdno between @ofab_f and @ofab_t --Bornage sur l'Ordre de Fabrication
and ofab.t_osta between @stat_f and @stat_t --Bornage sur le Statut de l'Ordre de Fabrication
order by SiteGruau