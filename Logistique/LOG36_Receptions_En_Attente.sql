-------------------------------------------------------------------------
-- LOG36 - Réceptions en attente
-------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(tspa.t_cwar, 2) as Site
,tspa.t_cprj as ProjetPCS
,tspa.t_bpid as CodeTiers 
,tiers.t_nama as NomTiers 
,tspa.t_orno as CommandeFournisseur
,cde.t_sorn as CommandeTiersVendeur
,tspa.t_pono as LigneCommande
,tspa.t_ponb as SeqLigCde
,left(tspa.t_item, 9) as ProjetArticle 
,substring(tspa.t_item, 10, len(tspa.t_item)) as Article 
,art.t_dsca as DesignationArticle 
,tspa.t_date as DateLivraisonPrevue
,tspa.t_qana as QtePlanifiee
,tspa.t_cwar as Magasin
,tspa.t_cuni as UnitStock
,tspa.t_pric as PrixLig
,tspa.t_ccur as Devise
,(tspa.t_pric * tspa.t_qana) as MtARecevoir
,(case
	when (exists(select top 1 lcdeo.t_qoor 
					from ttdpur401500 lcdeo 
					where lcdeo.t_orno = tspa.t_orno and lcdeo.t_pono = tspa.t_pono and lcdeo.t_sqnb = '0'))
		then (select top 1 lcdeo.t_qoor 
					from ttdpur401500 lcdeo 
					where lcdeo.t_orno = tspa.t_orno and lcdeo.t_pono = tspa.t_pono and lcdeo.t_sqnb = '0')
		else lcde.t_qoor
	end
) as QteCde
,(case
	when (exists(select top 1 lcdeo.t_qidl 
					from ttdpur401500 lcdeo 
					where lcdeo.t_orno = tspa.t_orno and lcdeo.t_pono = tspa.t_pono and lcdeo.t_sqnb = '0'))
		then (select top 1 lcdeo.t_qidl 
					from ttdpur401500 lcdeo 
					where lcdeo.t_orno = tspa.t_orno and lcdeo.t_pono = tspa.t_pono and lcdeo.t_sqnb = '0')
		else lcde.t_qidl
	end
) as QteDejaRecue
,lcde.t_cuqp as UnitAchat
,lcde.t_ddta as DateLivPrev
,lcde.t_ddtc as DateLivConf
,cde.t_odat as DateCommande
,lcde.t_cdf_crel as Commentaire_Relance
from twhinp100500 tspa --Transactions de stock planifiées par article
inner join ttccom100500 tiers on tiers.t_bpid = tspa.t_bpid --Tiers
inner join ttcibd001500 art on art.t_item = tspa.t_item --Articles
inner join ttdpur400500 cde on cde.t_orno = tspa.t_orno -- Entête Commande Achats
inner join ttdpur401500 lcde on lcde.t_orno = tspa.t_orno and lcde.t_pono = tspa.t_pono and lcde.t_sqnb  = tspa.t_ponb --Lignes de Commande Achats
where 
tspa.t_koor = 2 --On ne prend que les commandes fournisseurs
and left(tspa.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le magasin
and tspa.t_bpid in (@bpid)
order by tiers.t_nama, tspa.t_orno, tspa.t_pono