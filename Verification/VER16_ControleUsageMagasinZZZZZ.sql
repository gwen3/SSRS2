---------------------------------------
-- VER16_Controle Usage Magasin ZZZZZ
---------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(
select 'Nomenclatures' as Source, 
left(nom.t_mitm, 9) as ProjetArticlePere, 
substring(nom.t_mitm, 10, len(nom.t_mitm)) as ArticlePere, 
artpere.t_dsca as DescriptionArticlePere, 
dbo.convertenum('tc','B61C','a9','bull','kitm',artpere.t_kitm,'4') as TypeArticlePere, 
nom.t_pono as Position, 
left(nom.t_sitm, 9) as ProjetArticleFils, 
substring(nom.t_sitm, 10, len(nom.t_sitm)) as ArticleFils, 
artfils.t_dsca as DescriptionArticleFils, 
nom.t_cwar as Magasin, 
nom.t_qana as QuantiteNette, 
nom.t_indt as DateApplication, 
nom.t_exdt as DateExpiration, 
artfils.t_cuni as UniteStockArticleFils, 
artpere.t_cood as CoordinateurTechnique, 
emp.t_nama as NomCoordinateurTechnique, 
donemp.t_mail as MailCoordinateurTechnique 
from ttibom010500 nom --Nomenclatures
inner join ttcibd001500 artpere on artpere.t_item = nom.t_mitm --Articles - Père
inner join ttcibd001500 artfils on artfils.t_item = nom.t_sitm --Articles - Fils
left outer join ttccom001500 emp on emp.t_emno = artpere.t_cood --Employés - Coordinateur Technique
left outer join tbpmdm001500 donemp on donemp.t_emno = artpere.t_cood --Données Employés
where nom.t_cwar = 'ZZZZZZ' --On ne prend que les magasins ZZZZZZ
and (nom.t_exdt < '01/01/1980' or nom.t_exdt >= @dateexpir)
)
union all
(
select 'Nomenclatures Génériques' as Source, 
left(nomgen.t_mitm, 9) as ProjetArticlePere, 
substring(nomgen.t_mitm, 10, len(nomgen.t_mitm)) as ArticlePere, 
artpere.t_dsca as DescriptionArticlePere, 
dbo.convertenum('tc','B61C','a9','bull','kitm',artpere.t_kitm,'4') as TypeArticlePere, 
nomgen.t_pono as Position, 
left(nomgen.t_sitm, 9) as ProjetArticleFils, 
substring(nomgen.t_sitm, 10, len(nomgen.t_sitm)) as ArticleFils, 
artfils.t_dsca as DescriptionArticleFils, 
nomgen.t_cwar as Magasin, 
nomgen.t_qana as QuantiteNette, 
nomgen.t_indt as DateApplication, 
nomgen.t_exdt as DateExpiration, 
artfils.t_cuni as UniteStockArticleFils, 
artpere.t_cood as CoordinateurTechnique, 
emp.t_nama as NomCoordinateurTechnique, 
donemp.t_mail as MailCoordinateurTechnique 
from ttipcf310500 nomgen --Nomenclatures Génériques
inner join ttcibd001500 artpere on artpere.t_item = nomgen.t_mitm --Articles - Père
inner join ttcibd001500 artfils on artfils.t_item = nomgen.t_sitm --Articles - Fils
left outer join ttccom001500 emp on emp.t_emno = artpere.t_cood --Employés - Coordinateur Technique
left outer join tbpmdm001500 donemp on donemp.t_emno = artpere.t_cood --Données Employés
where nomgen.t_cwar = 'ZZZZZZ' --On ne prend que les magasins ZZZZZZ 
and (nomgen.t_exdt < '01/01/1980' or nomgen.t_exdt >= @dateexpir)
)