-----------------------------------------
-- FAB08 - Modification Dossier de Prod
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select cout.t_pdno as OrdreFabrication, 
left(ofab.t_mitm, 9) as ProjetFabrique, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as ArticleFabrique, 
artfab.t_dsca as DescriptionArticleFabrique, 
ofab.t_orno as Affaire, 
ov.t_ofbp as TiersAcheteur, 
tier.t_nama as NomTiersAcheteur, 
cout.t_opno as OperationOF, 
cout.t_pono as PositionOF, 
left(cout.t_sitm, 9) as Projet, 
substring(cout.t_sitm, 10, len(cout.t_sitm)) as Article, 
art.t_dsca as DescriptionArticle, 
art.t_cuni as Unite, 
cout.t_cwar as Magasin, 
(select top 1 emp.t_loca from twhwmd302500 emp where emp.t_item = cout.t_sitm and emp.t_cwar = cout.t_cwar) as Emplacement, 
cout.t_ques as QuantiteEstimee, 
cout.t_qucs + cout.t_issu + cout.t_iswh + cout.t_subd as QuantiteActuelle, 
'' as Commentaire, 
'' as Modification 
from tticst001500 cout --Couts Matières Estimés et Réels
inner join ttisfc001500 ofab on ofab.t_pdno = cout.t_pdno --Ordre de Fabrication
inner join ttcibd001500 artfab on artfab.t_item = ofab.t_mitm --Articles Fabriques
inner join ttcibd001500 art on art.t_item = cout.t_sitm --Articles
left outer join ttdsls400500 ov on ov.t_orno = ofab.t_orno --Commandes Clients
left outer join ttccom100500 tier on tier.t_bpid = ov.t_ofbp --Tiers
where left(cout.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE par rapport à l'Ordre de Fabrication
and cout.t_pdno = @of --Bornage sur 1 OF