-------------------------------------------------------------------------
-- LOG26 - Commandes Fournisseurs Non Réceptionnées dont Projet Facturé
-------------------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(tspa.t_cwar, 2) as SiteViaMagasin, 
tspa.t_cprj as ProjetPCS, 
tspa.t_ccur as Devise, 
tspa.t_bpid as CodeTiers, 
tier.t_nama as NomTiers, 
tierfac.t_cfsg as GroupeFinancier, 
tspa.t_orno as CommandeFournisseur, 
left(tspa.t_item, 9) as ProjetArticle, 
substring(tspa.t_item, 10, len(tspa.t_item)) as Article, 
art.t_dsca as DesignationArticle, 
tspa.t_date as DateLivraisonPrevue, 
(select sum(lcde.t_oamt) from ttdpur401500 lcde where lcde.t_orno = tspa.t_orno and lcde.t_pono = tspa.t_pono and lcde.t_ddte < '01/01/1980') as Montant, 
(select top 1 encours.t_trdt from ttipcs300500 encours where encours.t_tror = 2 and encours.t_fitr = 125 and encours.t_koor = 3 and encours.t_cprj_f = tspa.t_cprj and encours.t_cprj_t = tspa.t_cprj order by encours.t_trdt desc) as DateFacturationPCS, 
month((select top 1 encours.t_trdt from ttipcs300500 encours where encours.t_tror = 2 and encours.t_fitr = 125 and encours.t_koor = 3 and encours.t_cprj_f = tspa.t_cprj and encours.t_cprj_t = tspa.t_cprj order by encours.t_trdt desc)) as MoisFacturationPCS, 
(select count(*) from twhinp100500 tspacli where tspacli.t_koor = 3 and tspacli.t_cprj = tspa.t_cprj and tspacli.t_kotr = 2) as NombreCommandesClientsNonLivrees --On compte le nombre de commandes clients qui ont des sorties planifiées
from twhinp100500 tspa --Transactions de stock planifiées par article
inner join ttccom100500 tier on tier.t_bpid = tspa.t_bpid --Tiers
inner join ttccom122500 tierfac on tierfac.t_ifbp = tspa.t_bpid --Tiers Facturant
inner join ttcibd001500 art on art.t_item = tspa.t_item --Articles
where left(tspa.t_item, 9) != '' --On ne prend que les articles ayant un code projet
and (tspa.t_koor = 2 or tspa.t_koor = 8) --On ne prend que les commandes fournisseurs ou les propositions de commandes fournisseurs
and (select top 1 encours.t_trdt from ttipcs300500 encours where encours.t_tror = 2 and encours.t_fitr = 125 and encours.t_koor = 3 and encours.t_cprj_f = tspa.t_cprj and encours.t_cprj_t = tspa.t_cprj order by encours.t_trdt desc) is not null --On ne prend que les lignes qui ont une date de facturation
and ((left(tspa.t_cwar, 2) between @ue_f and @ue_t) or left(tspa.t_cwar, 2) = 'ZZ') --Bornage sur l'UE définie par le magasin, on ramène systématiquement les magasins ZZZZZZ
and (select count(*) from twhinp100500 tspacli where tspacli.t_koor = 3 and tspacli.t_cprj = tspa.t_cprj and tspacli.t_kotr = 2) = 0 --On ne garde que les lignes à 0, ticket 46242
order by tspa.t_cprj