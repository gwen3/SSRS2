---------------------------
-- FIN01 - Produits Finis
---------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(stkartmag.t_item, 9) as ProjetArticle, 
substring(stkartmag.t_item, 10, len(stkartmag.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
stk.t_serl as NumeroChassis, 
stk.t_oser as CodeOrigine, 
dbo.convertenum('wh','B61C','a9','bull','ltc.olot',stk.t_oser,'4') as Origine, 
stk.t_orno as OrdreFab, 
(case 
when art.t_seri = 1 --Article sérialisé
	then stk.t_rdat
when art.t_seri = 2 --Article non sérialisé
	then (select top 1 trans.t_trdt from twhinr110500 trans where trans.t_item = stkartmag.t_item and trans.t_cwar = stkartmag.t_cwar order by trans.t_trdt desc)
end) as DateReception, 
stk.t_ornv as CommandeClient, 
stk.t_ponv as LigneCommandeClient, 
ligcom.t_ofbp as TiersAcheteur, 
tiers.t_nama as NomTiersAcheteur, 
art.t_citg as GroupeArticle, 
stk.t_qhnd as QteStock, 
cout.t_amtc_1 as CoutMatiere, 
cout.t_aopc_1 as CoutMO, 
cout.t_acpr_1 as CoutTotal, 
ligcom.t_pric as Prix, 
cde.t_refa as ReferenceA, 
cde.t_refb as ReferenceB, 
stkartmag.t_cwar as Magasin, 
cout2.t_pric_1 as PrixOPVChassis, 
cde.t_crep as Representant, 
emp.t_nama as NomRepresentant, 
ligcom.t_prdt as DateMADCPrevue 
from twhwmd215500 stkartmag --Stock des Articles par Magasin
left outer join twhltc500500 stk on stk.t_item = stkartmag.t_item and stk.t_cwar = stkartmag.t_cwar and stk.t_qhnd > 0 --Numéro de Série par Magasin
inner join ttcibd001500 art on art.t_item = stkartmag.t_item --Articles
left outer join ttdsls400500 cde on cde.t_orno = stk.t_ornv and ((cde.t_crep between @emp_f and @emp_t) or (cde.t_crep = ' ')) --Lignes Commandes Clients ; Bornage sur les représentants
left outer join ttdsls401500 ligcom on ligcom.t_orno = stk.t_ornv and ligcom.t_pono = stk.t_ponv --Lignes Commandes Clients
left outer join ttccom100500 tiers on tiers.t_bpid = ligcom.t_ofbp --Tiers
left outer join tticpr007500 cout on cout.t_item = stkartmag.t_item --Données d'établissement des coûts de revient
left outer join twhltc502500 cout2 on cout2.t_item = stkartmag.t_item and cout2.t_serl = stk.t_serl and cout2.t_cwar = stkartmag.t_cwar and cout2.t_cpcp = 'MATIER' and cout2.t_item like '%CHASSIS%' and cout2.t_trdt = (select top 1 t_trdt from twhltc502500 a where a.t_item = stkartmag.t_item and a.t_serl = stk.t_serl and a.t_cwar = stkartmag.t_cwar and a.t_cpcp = 'MATIER' and a.t_item like '%CHASSIS%' order by t_trdt desc) and cout2.t_seqn = (select top 1 t_seqn from twhltc502500 b where b.t_item = stkartmag.t_item and b.t_serl = stk.t_serl and b.t_cwar = stkartmag.t_cwar and b.t_cpcp = 'MATIER' and b.t_item like '%CHASSIS%' and b.t_trdt = cout2.t_trdt order by t_trdt desc) --Détails des Coûts de Transaction de Prix et N°
left outer join ttccom001500 emp on emp.t_emno = cde.t_crep --Employés
--left outer join tticst010500 cout on cout.t_pdno = stk.t_orno and cout.t_cstv = 1 --Cout unitaire produit fini
--left outer join ttisfc001500 ofab on ofab.t_orno = stk.t_orno --Ordre de Fabrication
where stkartmag.t_qhnd > 0 --Bornage sur les chassis en stock
and stkartmag.t_cwar like '__PARC' --Bornage sur le magasin PARC
--and art.t_citg != 'IAP003' --On exclu le groupe article IAP003, critère enlevé suite demande Terence
--and art.t_citg != '   991' --On exclu le groupe article 991, critère enlevé suite demande Terence
and stkartmag.t_item != '         CHASSIS' --On exclu l'article Châssis
and left(stkartmag.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'unité d'entreprise