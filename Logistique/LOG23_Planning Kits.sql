--------------------------
-- LOG23 - Planning Kits
--------------------------

/*
declare @ue_f nvarchar(2) = '  ';
declare @ue_t nvarchar(2) = 'ZZ';
declare @planif_f date = DATEADD(DD, -30, CAST(CURRENT_TIMESTAMP AS DATE));
declare @planif_t date = DATEADD(DD, 30, CAST(CURRENT_TIMESTAMP AS DATE));
declare @stat_f nvarchar(2) = '1';
declare @stat_t nvarchar(2) = '99';
declare @ofab_f nvarchar(9) = '';
declare @ofab_t nvarchar(9) = '';
declare @dateachev_f date = DATEADD(DD, -30, CAST(CURRENT_TIMESTAMP AS DATE));
declare @dateachev_t date = DATEADD(DD, 30, CAST(CURRENT_TIMESTAMP AS DATE));
declare @impBL nvarchar(1) = '1';
*/

if (@impBL = 1)
(select '' as Avancement, 
ofab.t_pldt as DateLivraisonPlanifiee, 
dbo.F_NUMERO_SEMAINE_ISO(ofab.t_pldt) as NumeroSemaineDateLivraisonPlanifiee, 
lcde.t_prdt as DateMADCPrevue, 
ofab.t_orno as CommandeClient, 
tiera.t_nama as NomTiersAcheteur, 
ofab.t_prdt as DateDebutFabrication, 
ofab.t_pdno as OrdreFabrication, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOrdreFabrication, 
'' as EngagementDelaiFabrication, 
ofab.t_qrdr as QuantiteOrdre, 
ofab.t_qdlv as QuantiteLivree, 
left(ofab.t_mitm, 9) as ProjetArticle, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DesignationArticle, 
dbo.convertenum('tc','B61C','a9','bull','yesno',cde.t_tmex,'4') as MurQualite, 
'' as CommentairesManquants, 
ofab.t_cmdt as DateAchevement, 
lcde.t_dldt as DateLivraison, 
expe.t_pdat as DateImpressionBL, 
art.t_wght as Poids, 
art.t_cwun as UnitePoids, 
artmag.t_dpth as LongueurArticle, 
artmag.t_wdth as LargeurArticle, 
'' as MetragePourTransport, 
adrl.t_nama as NomAdresseLivree, 
adrl.t_namb as Nom2AdresseLivree, 
adrl.t_hono as NumeroAdresseLivree, 
adrl.t_namc as RueAdresseLivree, 
adrl.t_pstc as CodePostalAdresseLivree, 
vill.t_dsca as NomVilleLivree, 
adrl.t_cste as DepartementAdresseLivree, 
adrl.t_ccty as PaysAdresseLivree, 
cde.t_odat as DateCommande, 
cde.t_crep as RepresentantInterne, 
repint.t_nama as NomRepresentantInterne, 
(select top 1 ncmr.t_ncmr from tqmncm100500 ncmr where ncmr.t_cprj = ofab.t_orno) as NumeroNCMR, 
artlcde.t_citg as GroupeArticleCommande, 
grpart.t_dsca as DescriptionGroupeArticleCommande, 
lcde.t_cdec as ConditionsLivraison, 
cliv.t_dsca as DescriptionConditionsLivraison, 
artmag.t_hght as HauteurArticle, 
(case 
when (lcde.t_stad = ' ' or lcde.t_stad is null) and left(ofab.t_mitm, 9) != ' '
	then (select mag.t_cadr from ttcmcs003500 mag where mag.t_cwar = concat(left(ofab.t_mitm, 2), 'PARC'))
else 
	lcde.t_stad
end) as CodeAdresseLivree, 
ofab.t_apdt as DateReelleDebutFabrication, 
art.t_cuni as Unite, 
ofab.t_prcd as Priorite, 
ofab.t_cwar as Magasin, 
ofab.t_plid as Planificateur, 
emp.t_nama as NomPlanificateur, 
ofab.t_rdld as DateLivraisonDemandee, 
ofab.t_pono as PositionCommandeClient, 
dbo.F_NUMERO_SEMAINE_ISO(lcde.t_dldt) as NumeroSemaineDateLivraison, 
lcde.t_ofbp as TiersAcheteur 
from ttisfc001500 ofab --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttccom001500 emp on emp.t_emno = ofab.t_plid --Employés - Planificateur
left outer join ttdsls401500 lcde on lcde.t_orno = ofab.t_orno and lcde.t_pono = ofab.t_pono and lcde.t_sqnb = (select top 1 lcde2.t_sqnb from ttdsls401500 lcde2 where lcde2.t_orno = ofab.t_orno and lcde2.t_pono = ofab.t_pono order by lcde2.t_sqnb desc) --Lignes de Commandes Clients
left outer join ttccom100500 tiera on tiera.t_bpid = lcde.t_ofbp --Tier Acheteur
left outer join ttcmcs041500 cliv on cliv.t_cdec = lcde.t_cdec --Conditions de Livraison
left outer join ttdsls411500 artlcde on artlcde.t_orno = ofab.t_orno and artlcde.t_pono = ofab.t_pono and artlcde.t_sqnb = '0' --Données Articles de la Ligne de Commande Client
left outer join ttcmcs023500 grpart on grpart.t_citg = artlcde.t_citg --Groupes Articles
left outer join ttccom130500 adrl on adrl.t_cadr = (case 
when (lcde.t_stad = ' ' or lcde.t_stad is null) and left(ofab.t_mitm, 9) != ' ' 
	then (select mag.t_cadr from ttcmcs003500 mag where mag.t_cwar = concat(left(ofab.t_mitm, 2), 'PARC'))
else 
	lcde.t_stad
end) --Adresse Livrée
left outer join ttccom139500 vill on vill.t_city = adrl.t_ccit and vill.t_ccty = adrl.t_ccty and vill.t_cste = adrl.t_cste --Ville - Adresse Livrée
left outer join ttdsls400500 cde on cde.t_orno = ofab.t_orno --Commande Client
left outer join ttdsls406500 livcde on livcde.t_orno = ofab.t_orno and livcde.t_pono = ofab.t_pono and livcde.t_sqnb = lcde.t_sqnb --Lignes de Livraisons de Commandes Clients
left outer join twhwmd400500 artmag on artmag.t_item = ofab.t_mitm --Données Magasins des Articles
left outer join twhinh430500 expe on expe.t_shpm = livcde.t_shpm --Expéditions
left outer join ttccom001500 repint on repint.t_emno = cde.t_crep --Employés - Représentant Interne
where left(ofab.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
and ofab.t_plid between @planif_f and @planif_t --Bornage sur le Planificateur
and ofab.t_osta between @stat_f and @stat_t --Bornage sur le Statut de l'OF
and ofab.t_pdno between @ofab_f and @ofab_t --Bornage sur l'Ordre de Fabrication
and (ofab.t_cmdt between @dateachev_f and @dateachev_t or ofab.t_cmdt < '01/01/1980') --Bornage sur la Date d'Achèvement, on prend également celles qui sont vides
and expe.t_pdat < '01/01/1980' --On ne prend que les BL qui n'ont pas été envoyé
)
else
(select '' as Avancement, 
ofab.t_pldt as DateLivraisonPlanifiee, 
dbo.F_NUMERO_SEMAINE_ISO(ofab.t_pldt) as NumeroSemaineDateLivraisonPlanifiee, 
lcde.t_prdt as DateMADCPrevue, 
ofab.t_orno as CommandeClient, 
tiera.t_nama as NomTiersAcheteur, 
ofab.t_prdt as DateDebutFabrication, 
ofab.t_pdno as OrdreFabrication, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOrdreFabrication, 
'' as EngagementDelaiFabrication, 
ofab.t_qrdr as QuantiteOrdre, 
ofab.t_qdlv as QuantiteLivree, 
left(ofab.t_mitm, 9) as ProjetArticle, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article, 
art.t_dsca as DesignationArticle, 
dbo.convertenum('tc','B61C','a9','bull','yesno',cde.t_tmex,'4') as MurQualite, 
'' as CommentairesManquants, 
ofab.t_cmdt as DateAchevement, 
lcde.t_dldt as DateLivraison, 
expe.t_pdat as DateImpressionBL, 
art.t_wght as Poids, 
art.t_cwun as UnitePoids, 
artmag.t_dpth as LongueurArticle, 
artmag.t_wdth as LargeurArticle, 
'' as MetragePourTransport, 
adrl.t_nama as NomAdresseLivree, 
adrl.t_namb as Nom2AdresseLivree, 
adrl.t_hono as NumeroAdresseLivree, 
adrl.t_namc as RueAdresseLivree, 
adrl.t_pstc as CodePostalAdresseLivree, 
vill.t_dsca as NomVilleLivree, 
adrl.t_cste as DepartementAdresseLivree, 
adrl.t_ccty as PaysAdresseLivree, 
cde.t_odat as DateCommande, 
cde.t_crep as RepresentantInterne, 
repint.t_nama as NomRepresentantInterne, 
(select top 1 ncmr.t_ncmr from tqmncm100500 ncmr where ncmr.t_cprj = cde.t_orno) as NumeroNCMR, 
artlcde.t_citg as GroupeArticleCommande, 
grpart.t_dsca as DescriptionGroupeArticleCommande, 
lcde.t_cdec as ConditionsLivraison, 
cliv.t_dsca as DescriptionConditionsLivraison, 
artmag.t_hght as HauteurArticle, 
(case 
when (lcde.t_stad = ' ' or lcde.t_stad is null) and left(ofab.t_mitm, 9) != ' '
	then (select mag.t_cadr from ttcmcs003500 mag where mag.t_cwar = concat(left(ofab.t_mitm, 2), 'PARC'))
else 
	lcde.t_stad
end) as CodeAdresseLivree, 
ofab.t_apdt as DateReelleDebutFabrication, 
art.t_cuni as Unite, 
ofab.t_prcd as Priorite, 
ofab.t_cwar as Magasin, 
ofab.t_plid as Planificateur, 
emp.t_nama as NomPlanificateur, 
ofab.t_rdld as DateLivraisonDemandee, 
ofab.t_pono as PositionCommandeClient, 
dbo.F_NUMERO_SEMAINE_ISO(lcde.t_dldt) as NumeroSemaineDateLivraison, 
lcde.t_ofbp as TiersAcheteur 
from ttisfc001500 ofab --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttccom001500 emp on emp.t_emno = ofab.t_plid --Employés - Planificateur
left outer join ttdsls401500 lcde on lcde.t_orno = ofab.t_orno and lcde.t_pono = ofab.t_pono and lcde.t_sqnb = (select top 1 lcde2.t_sqnb from ttdsls401500 lcde2 where lcde2.t_orno = ofab.t_orno and lcde2.t_pono = ofab.t_pono order by lcde2.t_sqnb desc) --Lignes de Commandes Clients
left outer join ttccom100500 tiera on tiera.t_bpid = lcde.t_ofbp --Tier Acheteur
left outer join ttcmcs041500 cliv on cliv.t_cdec = lcde.t_cdec --Conditions de Livraison
left outer join ttdsls411500 artlcde on artlcde.t_orno = ofab.t_orno and artlcde.t_pono = ofab.t_pono and artlcde.t_sqnb = '0' --Données Articles de la Ligne de Commande Client
left outer join ttcmcs023500 grpart on grpart.t_citg = artlcde.t_citg --Groupes Articles
left outer join ttccom130500 adrl on adrl.t_cadr = (case 
when (lcde.t_stad = ' ' or lcde.t_stad is null) and left(ofab.t_mitm, 9) != ' ' 
	then (select mag.t_cadr from ttcmcs003500 mag where mag.t_cwar = concat(left(ofab.t_mitm, 2), 'PARC'))
else 
	lcde.t_stad
end) --Adresse Livrée
left outer join ttccom139500 vill on vill.t_city = adrl.t_ccit and vill.t_ccty = adrl.t_ccty and vill.t_cste = adrl.t_cste --Ville - Adresse Livrée
left outer join ttdsls400500 cde on cde.t_orno = ofab.t_orno --Commande Client
left outer join ttdsls406500 livcde on livcde.t_orno = ofab.t_orno and livcde.t_pono = ofab.t_pono and livcde.t_sqnb = lcde.t_sqnb --Lignes de Livraisons de Commandes Clients
left outer join twhwmd400500 artmag on artmag.t_item = ofab.t_mitm --Données Magasins des Articles
left outer join twhinh430500 expe on expe.t_shpm = livcde.t_shpm --Expéditions
left outer join ttccom001500 repint on repint.t_emno = cde.t_crep --Employés - Représentant Interne
where left(ofab.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par l'Ordre de Fabrication
and ofab.t_plid between @planif_f and @planif_t --Bornage sur le Planificateur
and ofab.t_osta between @stat_f and @stat_t --Bornage sur le Statut de l'OF
and ofab.t_pdno between @ofab_f and @ofab_t --Bornage sur l'Ordre de Fabrication
and (ofab.t_cmdt between @dateachev_f and @dateachev_t or ofab.t_cmdt < '01/01/1980') --Bornage sur la Date d'Achèvement, on prend également celles qui sont vides
)