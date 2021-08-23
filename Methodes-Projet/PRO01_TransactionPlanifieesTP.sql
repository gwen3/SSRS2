---------------------------------------
-- PRO01 - Transactions Planifiées TP
---------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select tmatpla.t_cprj as Projet, 
prj.t_pmng as ChefProjet, 
empcp.t_nama as NomChefProjet, 
geprj.t_dsca as DescriptionProjet, 
dbo.convertenum('tp','B61C','a9','bull','pdm.psts',prj.t_psts,'4') as StatutProjet, 
left(tmatpla.t_item, 9) as ProjetArticle, 
substring(tmatpla.t_item, 10, len(tmatpla.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
tmatpla.t_date as DateLivraisonPlanifiee, 
dbo.convertenum('tc','B61C','a9','bull','koor',tmatpla.t_koor,'4') as TypeOrdre, 
tmatpla.t_orno as NumeroCommande, 
tmatpla.t_pono as Position, 
dbo.convertenum('tc','B61C','a9','bull','kotr',tstk.t_kotr,'4') as TypeTransactionStock, 
dbo.convertenum('tc','B61C','a9','bull','koor',tstk.t_koor,'4') as TypeOrdreOrigineStock, 
tstk.t_qana as QuantitePlanifiee, 
tstk.t_orno as Ordre, 
tstk.t_cwar as Magasin, 
tstk.t_date as DateTransaction, 
tmatpla.t_sqnb as Sequence, 
cde.t_otbp as Tiers, 
tier.t_nama as NomTiers, 
cde.t_otcn as Contact, 
cont.t_fuln as NomContact, 
cont.t_telp as TelephoneContact, 
tmatpla.t_quan as Quantite, 
art.t_cuni as Unite, 
dbo.convertenum('tc','B61C','a9','bull','kotr',tmatpla.t_kotr,'4') as TypeTransaction, 
tmatpla.t_buyr as Acheteur, 
empa.t_nama as NomAcheteur, 
tmatpla.t_plid as Planificateur, 
empp.t_nama as NomPlanificateur, 
tmatpla.t_dwar as MagasinProjet, 
mag.t_dsca as NomMagasinProjet, 
tmatpla.t_cact as Activite, 
act.t_desc as NomActivite, 
tmatpla.t_ccco as ElementCout 
from ttppss600500 tmatpla --Transactions de Matières Planifiées
left outer join ttppdm600500 prj on prj.t_cprj = tmatpla.t_cprj --Projets
left outer join ttccom001500 empcp on empcp.t_emno = prj.t_pmng --Employés - Chef de Projets
left outer join ttcmcs052500 geprj on geprj.t_cprj = tmatpla.t_cprj --Gestion de Projets
left outer join twhinp100500 tstk on tstk.t_item = tmatpla.t_item and tstk.t_koor = 1 and tstk.t_kotr = 1 --Transactions de Stock Planifiées
left outer join ttdpur400500 cde on cde.t_orno = tmatpla.t_orno and tmatpla.t_koor = 2 --Commandes Fournisseurs, on ne fait le lien que si c'est le cas
left outer join ttccom100500 tier on tier.t_bpid = cde.t_otbp --Tiers
left outer join ttccom140500 cont on cont.t_ccnt = cde.t_otcn --Contacts
left outer join ttcibd001500 art on art.t_item = tmatpla.t_item --Articles
left outer join ttccom001500 empa on empa.t_emno = tmatpla.t_buyr --Employés - Acheteur
left outer join ttccom001500 empp on empp.t_emno = tmatpla.t_plid --Employés - Planificateur
left outer join ttcmcs003500 mag on mag.t_cwar = tmatpla.t_dwar --Magasins
left outer join ttppss200500 act on act.t_cprj = tmatpla.t_cprj and act.t_cact = tmatpla.t_cact --Activites
where left(tmatpla.t_cprj, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le Projet
and tmatpla.t_cprj between @prj_f and @prj_t --Bornage sur le Projet
and prj.t_pmng between @chef_f and @chef_t --Bornage sur le Chef de Projet