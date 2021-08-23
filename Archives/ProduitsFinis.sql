-------------------
-- Produits Finis
-------------------

select left(stkartmag.t_item, 9) as ProjetArticle, 
substring(stkartmag.t_item, 10, len(stkartmag.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
stk.t_serl as NumeroChassis, 
stk.t_oser as CodeOrigine, 
dbo.convertenum('wh','B61C','a9','bull','ltc.olot',stk.t_oser,'4') as Origine, 
stk.t_orno as OrdreFab, 
stk.t_rdat as DateReception, 
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


(select sum(prstd.t_amnt_1 * coutest.t_ques) from tticst001500 coutest inner join ttisfc001500 ofab on ofab.t_orno = stk.t_orno --Ordre de Fabrication
left outer join tticpr301500 don on don.t_item = stkartmag.t_item and don.t_indt < 
(case 
when (ofab.t_cada = 0)
	then (select a.t_cada from ttisfc001500 a where a.t_pdno = ofab.t_pdno)
when (ofab.t_cada != 0) 
	then (select b.t_aldt from tticst001500 b where b.t_pdno = ofab.t_pdno)	
end) --Données établissement cout de revient article p
left outer join tticpr300500 prstd on prstd.t_item = don.t_item and prstd.t_indt = don.t_indt and prstd.t_seqn = don.t_seqn --Prix de revient standard par article
left outer join ttcmcs048500 pr on pr.t_cpcp = prstd.t_cpcp --Element prix de revient
  where coutest.t_pdno = stk.t_orno

(case 
when (pr.t_cref = 1) 
	then (prstd.t_amnt_1 * coutest.t_ques) 
when (pr.t_cref = 3) 
	then (prstd.t_amnt_1 * coutest.t_ques) 
end) as MO_EST_SE, 
(case 
when (pr.t_cref = 1) 
	then (prstd.t_amnt_1 * coutest.t_ques) 
when (pr.t_cref = 3) 
	then (prstd.t_nuni * coutest.t_ques) 
end) as HR_MO_EST_SE 




from twhwmd215500 stkartmag 
left outer join twhltc500500 stk on stk.t_item = stkartmag.t_item and stk.t_cwar = stkartmag.t_cwar and stk.t_qhnd > 0 
inner join ttcibd001500 art on art.t_item = stkartmag.t_item --Articles
left outer join ttdsls401500 ligcom on ligcom.t_orno = stk.t_ornv and ligcom.t_pono = stk.t_ponv --Lignes Commandes Clients
left outer join ttccom100500 tiers on tiers.t_bpid = ligcom.t_ofbp --Tiers
left outer join tticpr007500 cout on cout.t_item = stkartmag.t_item --Données d'établissement des coûts de revient



left outer join tticst001500 coutest on coutest.t_pdno = stk.t_orno --Couts matières estimés et réels
inner join ttisfc001500 ofab on ofab.t_orno = stk.t_orno --Ordre de Fabrication
left outer join tticpr301500 don on don.t_item = stkartmag.t_item and don.t_indt < 
(case 
when (ofab.t_cada = 0)
	then (select a.t_cada from ttisfc001500 a where a.t_pdno = ofab.t_pdno)
when (ofab.t_cada != 0) 
	then (select b.t_aldt from tticst001500 b where b.t_pdno = ofab.t_pdno)	
end) --Données établissement cout de revient article p
left outer join tticpr300500 prstd on prstd.t_item = don.t_item and prstd.t_indt = don.t_indt and prstd.t_seqn = don.t_seqn --Prix de revient standard par article
left outer join ttcmcs048500 pr on pr.t_cpcp = prstd.t_cpcp --Element prix de revient
where stkartmag.t_qhnd > 0 --Bornage sur les chassis en stock
and stkartmag.t_cwar like '__PARC' --Bornage sur le magasin PARC
and art.t_citg != 'IAP003' --On exclu le groupe article IAP003
and art.t_citg != '   991' --On exclu le groupe article 991
and stkartmag.t_item != '         CHASSIS' --On exclu l'article Châssis
and left(stkartmag.t_cwar, 2) between @ue_f and @ue_t; --Bornage sur l'unité d'entreprise
