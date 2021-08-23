---------------------------
-- MET03 - Cont Herit Nom
---------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(nom.t_mitm, 9) as ProjetArticleTete, 
substring(nom.t_mitm, 10, len(nom.t_mitm)) as ArticleTete, 
arttete.t_dsca as DescriptionArticleTete, 
nom.t_pono as Position, 
nom.t_seqn as Seq, 
left(nom.t_sitm, 9) as Projet, 
substring(nom.t_sitm, 10, len(nom.t_sitm)) as Article, 
art.t_dsca as DescriptionArticle, 
nom.t_cwar as Magasin, 
nom.t_cpha as CodeFantome, 
dbo.convertenum('tc','B61C','a9','bull','yesno',nom.t_cpha,'4') as Fantome, 
nom.t_iwip as CodeHeritage, 
dbo.convertenum('tc','B61C','a9','bull','yesno',nom.t_iwip,'4') as Heritage, 
arttete.t_cood as CoordinateurTechniqueArticleTete, 
emp.t_nama as NomCoordinateur 
from ttibom010500 nom --Nomenclatures
left outer join ttcibd001500 arttete on arttete.t_item = nom.t_mitm --Articles Tete
left outer join ttcibd001500 art on art.t_item = nom.t_sitm --Articles
left outer join ttccom001500 emp on emp.t_emno = arttete.t_cood --Employés
where left(nom.t_mitm, 9) between @prj_f and @prj_t --Bornage sur le Projet de l'Article de Tête
and substring(nom.t_mitm, 10, len(nom.t_mitm)) between @art_f and @art_t --Bornage sur l'Article de Tête
and arttete.t_cood between @cood_f and @cood_t --Bornage sur le Coordinateur Technique de l'Article de Tête
and nom.t_iwip between @heri_f and @heri_t --Bornage sur l'Héritage à Oui ou Non
--Suppression du critère sur l'UE car les lots fantômes peuvent être utilisés par tous les sites, et les autres sites ne peuvent alors plus vérifier
--left(nom.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le magasin
