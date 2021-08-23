------------------------------------------
-- MET07 - Paramétrage Post Conso Heures
------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

(select 'Req1' as Requete
,opgam.t_cwoc as CentreCharge
,cc.t_dsca as DescriptionCentreCharge
,opgam.t_tano as Tache
,tache.t_dsca as DescriptionTache
,left(gam.t_mitm, 9) as ProjetArticleFabrique
,substring(gam.t_mitm, 10, len(gam.t_mitm)) as ArticleFabrique
,art.t_csig as CodeSignal
,(case 
when gam.t_stor = 1
	then gam.t_strc
else gam.t_opro
end) as Gamme
,opgam.t_opno as Operation
,opgam.t_seqn as Sequence
,dbo.convertenum('tc','B61C','a9','bull','yesno',opgam.t_bfls, '4') as PostConsommation
,opgam.t_indt as DateApplication
,opgam.t_exdt as DateExpiration
,dbo.convertenum('tc','B61C','a9','bull','yesno',prdart.t_bfhr, '4') as PostConsommerHeures
from ttirou102500 opgam --Opérations de Gammes
left outer join ttirou101500 gam on (case when gam.t_stor = 1 then gam.t_strc else gam.t_opro end) = opgam.t_opro --Codes Gamme par article
left outer join ttiipd001500 prdart on prdart.t_item = gam.t_mitm --Données de Production des Articles
left outer join ttirou001500 cc on cc.t_cwoc = opgam.t_cwoc --Centre de Charge
left outer join ttirou003500 tache on tache.t_tano = opgam.t_tano --Tache
left outer join ttcibd001500 art on art.t_item = gam.t_mitm --Articles
where left(opgam.t_cwoc, 2) between @ue_f and @ue_t --Bornage sur l'UE défini par le Centre de Charge
and opgam.t_indt <= getdate() --On prend les dates d'application avant la date du jour
and opgam.t_exdt > getdate() --On prend les dates d'application avant la date du jour
and prdart.t_bfhr = 2 --PostConsommerHeures à Non
and opgam.t_bfls = 1 --PostConsommation à Oui
and opgam.t_cwoc in (@cc) --Bornage sur le Centre de Charge
and opgam.t_opro != '     0' --On exclu la gamme 0
and ((@exartspe = 1 and left(gam.t_mitm, 9) = ' ') or (@exartspe = 2)) --Bornage pour exclure les articles spé
)
union
(
select 'Req2' as Requete
,gam.t_cwoc as CentreCharge
,cc.t_dsca as DescriptionCentreCharge
,gam.t_tano as Tache
,tache.t_dsca as DescriptionTache
,left(gam.t_mitm, 9) as ProjetArticleFabrique
,substring(gam.t_mitm, 10, len(gam.t_mitm)) as ArticleFabrique
,art.t_csig as CodeSignal
,gam.t_opro as Gamme
,gam.t_opno as Operation
,gam.t_seqn as Sequence
,dbo.convertenum('tc','B61C','a9','bull','yesno',gam.t_bfls, '4') as PostConsommation
,gam.t_indt as DateApplication
,gam.t_exdt as DateExpiration
,dbo.convertenum('tc','B61C','a9','bull','yesno',prdart.t_bfhr, '4') as PostConsommerHeures
from ttirou102500 gam --Opérations de Gammes
left outer join ttiipd001500 prdart on prdart.t_item = gam.t_mitm --Données de Production des Articles
left outer join ttirou001500 cc on cc.t_cwoc = gam.t_cwoc --Centre de Charge
left outer join ttirou003500 tache on tache.t_tano = gam.t_tano --Tache
left outer join ttcibd001500 art on art.t_item = gam.t_mitm --Articles
where left(gam.t_cwoc, 2) between @ue_f and @ue_t --Bornage sur l'UE défini par le Centre de Charge
and gam.t_indt <= getdate() --On prend les dates d'application avant la date du jour
and gam.t_exdt > getdate() --On prend les dates d'application avant la date du jour
and prdart.t_bfhr = 2 --PostConsommerHeures à Non
and gam.t_bfls = 1 --PostConsommation à Oui
and gam.t_cwoc in (@cc) --Bornage sur le Centre de Charge
and ((@exartspe = 1 and left(gam.t_mitm, 9) = ' ') or (@exartspe = 2)) --Bornage pour exclure les articles spé
)