---------------------------------
-- LOG22 - Suivi Traçabilité OF
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

use ln6prddb
select
top 1000
comp.t_pdno as OrdreFabrication, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOrdreFabrication, 
left(comp.t_mitm, 9) as ProjetArticleFabrique, 
substring(comp.t_mitm, 10, len(comp.t_mitm)) as ArticleFabrique, 
comp.t_mser as NumeroSerie, 
comp.t_pono as Position, 
comp.t_seqn as Sequence, 
comp.t_sser as NumeroSerieComposant, 
left(comp.t_sitm, 9) as Projet, 
substring(comp.t_sitm, 10, len(comp.t_sitm)) as Article, 
art.t_dsca as DescriptionArticle, 
art.t_citg as GroupeArticle, 
grpart.t_dsca as DescriptionGroupeArticle, 
comp.t_quse as QuantiteUtilisee 
from ttimfc011500 comp --Composants Tels que Conçus pour Produits Finis
inner join ttisfc001500 ofab on ofab.t_pdno = comp.t_pdno --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = comp.t_sitm --Article Composant
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Article
inner join twhwmd400500 artmag on artmag.t_item = comp.t_sitm --Données Magasins des Articles
where comp.t_sser = ' ' --On ne prend que les numéros de séries composants à vide
and artmag.t_sisf = 1 --Enregistrer la sortie de la série pendant à Oui
/*and left(comp.t_pdno, 2) between @ue_f and @ue_t --On borne sur l'UE définit par l'OF
and comp.t_pdno between @ofab_f and @ofab_t --On borne sur le Numéro d'OF
and ofab.t_osta between @stat_f and @stat_t --On borne sur le Statut de l'OF
*/