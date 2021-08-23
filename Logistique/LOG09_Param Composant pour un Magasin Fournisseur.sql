-----------------------------------------
-- LOG09 - Param Composant pour un Magasin Fournisseur - Sert à piéger les écarts de Paramétrage des Composants à Transférer dans le Magasin du fournisseur sous-traitant
-----------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(nome.t_mitm, 9) as ProjetCompose, 
substring(nome.t_mitm, 10, len(nome.t_mitm)) as ArticleCompose, 
artpere.t_dsca as DescriptionArticleCompose, 
artpere.t_csig as CodeSignalArticleCompose, 
nome.t_pono as Position, 
nome.t_seqn as NumeroSequence, 
left(nome.t_sitm, 9) as ProjetComposant, 
substring(nome.t_sitm, 10, len(nome.t_sitm)) as ArticleComposant, 
isnull(artplanfils.t_plid, '') as Planificateur, 
isnull(emp.t_nama, '') as NomPlanificateur, 
dbo.convertenum('tc','B61C','a9','bull','kitm',artfils.t_kitm,4) as TypeArticleComposant, 
artfils.t_dsca as DescriptionComposant, 
nome.t_qana as QuantiteNette, 
nome.t_cwar as Magasin, 
artplanfils.t_cwar as MagasinComposantPlan, 
(case 
when artfils.t_kitm = 2 --Type Article Acheté
	then isnull((select top 1 empart.t_loca from twhwmd302500 empart where empart.t_item = nome.t_sitm and empart.t_cwar = artplanfils.t_cwar order by empart.t_prio), '') 
else '' 
end) as EmplacementFixeComposant, 
@cwar as ApprovisionnerLeMagasin, 
(case 
when magart.t_sups is null 
	then '' 
else 
	dbo.convertenum('tc','B61C','a9','bull','sups',magart.t_sups,4) 
end) as SystemeAppro, 
(case 
when magart.t_sfwh is null 
	then '' 
else 
	dbo.convertenum('tc','B61C','a9','bull','yesno',magart.t_sfwh,4) 
end) as ApproDepuis, 
isnull(magart.t_supw, '') as MagAppro, 
isnull(magart.t_scom, 0) as SocieteAppro 
from ttibom010500 nome --Nomenclatures
left outer join tcprpd100500 artplanpere on artplanpere.t_plni = concat(@clus, nome.t_mitm) --Articles Planification Père
left outer join tcprpd100500 artplanfils on artplanfils.t_plni = concat(@clus, nome.t_sitm) --Articles Planification Fils
inner join ttcibd001500 artpere on artpere.t_item = nome.t_mitm --Article Père
inner join ttcibd001500 artfils on artfils.t_item = nome.t_sitm --Article Fils
left outer join ttccom001500 emp on emp.t_emno = artplanfils.t_plid --Employés
left outer join twhwmd210500 magart on magart.t_cwar = @cwar and magart.t_item = nome.t_sitm --Magasin Données Article
where nome.t_indt <= @date_f --Date d'Application de la Nomenclature
and nome.t_exdt >= @date_t --Date d'Expiration de la Nomenclature
and nome.t_mitm between @mitm_f and @mitm_t --Bornage sur l'Article
and artplanpere.t_plid between @plid_f and @plid_t --Bornage sur le Planificateur
and exists (select top 1 stkart.t_item from twhwmd215500 stkart where stkart.t_item = nome.t_mitm and (stkart.t_ltdt >= @date_trans or stkart.t_ltdt < '1980-01-01')) --On vérifie qu'il y a bien eu une transaction de stock dans la date demandée
and left(nome.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le Magasin