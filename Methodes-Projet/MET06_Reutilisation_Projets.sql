-----------------------------------------
-- MET06 - Réutilisations de Projets
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
prjdet.t_cprj as Projet
,prj.t_seak as DescriptionProjet
,dbo.convertenum('tc','B61C','a9','bull','psts',prjdet.t_psts,'4') as StatutProjet
,prjdet.t_psta as PhaseProjet
,phaseprj.t_dsca as DescriptionPhase_Projet
,ofab.t_pdno as OrdreDeFab
,dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOrdreDeFab
,left(ofab.t_mitm, 9) as ProjetArticle
,substring(ofab.t_mitm, 10, len(ofab.t_mitm)) as Article
,art.t_dsca as DescriptionArticle
from ttisfc001500 ofab
inner join ttipcs030500 prjdet on prjdet.t_cprj = ofab.t_cprj --Détail Projet
inner join ttipcs020500 prj on prj.t_cprj = prjdet.t_cprj --Projet
inner join ttipcs024500 phaseprj on phaseprj.t_psta = prjdet.t_psta --Phases Projet
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
where 
left(prjdet.t_cprj,2) between @ue_f and @ue_t
and substring(ofab.t_mitm, 10, len(ofab.t_mitm)) like 'ETUDESP%'
and ofab.t_osta between '1' and '6'
and prjdet.t_psta >= '5'
