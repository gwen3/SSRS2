------------------------------------------
-- INV06 - Inventaire En Cours Vehicules
------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select cout.t_pdno as OrdreFabrication, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4')	as StatutOrdre, 
left(ofab.t_mitm, 9) as ProjetFabrique, 
substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as ArticleFabrique, 
artfab.t_dsca as DescriptionArticleFabrique, 
ofab.t_orno as Affaire, 
ov.t_ofbp as TiersAcheteur, 
tier.t_nama as NomTiersAcheteur, 
cout.t_opno as OpeOF, 
left(cout.t_sitm, 9) as Projet, 
substring(cout.t_sitm, 10, len(cout.t_sitm)) as Article, 
art.t_dsca as DescriptionArticle, 
art.t_citg as GrpArt, 
art.t_cuni as Ute, 
cout.t_qucs + cout.t_issu + cout.t_iswh + cout.t_subd as QtePrev, 
(case 
when left(cout.t_sitm, 9) = ' '
	then substring(cout.t_sitm, 10, len(cout.t_sitm))
else cout.t_sitm 
end) as ArticleCAB, 
cout.t_qucs as QteSortieInform, 
'' as QteMonteeInv, 
'' as Commentaire 
from tticst001500 cout --Couts Matières Estimés et Réels
inner join ttisfc001500 ofab on ofab.t_pdno = cout.t_pdno --Ordre de Fabrication
inner join ttcibd001500 artfab on artfab.t_item = ofab.t_mitm --Articles Fabriques
inner join ttcibd001500 art on art.t_item = cout.t_sitm --Articles
left outer join ttdsls400500 ov on ov.t_orno = ofab.t_orno --Commandes Clients
left outer join ttccom100500 tier on tier.t_bpid = ov.t_ofbp --Tiers
where ofab.t_osta between @stat_f and @stat_t --Bornage sur le Statut
and left(cout.t_pdno, 2) between @ue_f and @ue_t --Bornage sur l'UE par rapport à l'Ordre de Fabrication
and cout.t_pdno between @ofab_f and @ofab_t --Bornage sur 1 OF
