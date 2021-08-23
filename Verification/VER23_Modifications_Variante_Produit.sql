-------------------------------------------------------------------------
-- VER23 - Modifications_Variante_Produit
-------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

--declare @UE_f nvarchar(1) = ''
--declare @UE_t nvarchar(1) = 'ZZ'
--declare @exnv nvarchar(1) = '2'
--
-- (1)  A partir de la version actuelle de la variante
(select 
varp.t_refo as OrdreRef
,dbo.convertenum('tc','B61U','a','stnd','reft',varp.t_reft,'4') as Type_OrdreRef
,varp.t_refp as PosOrdreRef
,varp.t_item as ArticleGenerique
,varp.t_reft as TypeVariante
,varp.t_cpva as Variante
,varp.t_dsca as DescriptionVariante
,dbo.convertenum('tc','B61','a','','yesno',varp.t_vali,'4') as Variante_Correcte
,varp.t_pcfd as DateConfig
,varp.t_cdf_dmaj as DateDerMod
,convert(varchar,varp.t_cdf_dmaj,108) as HeureDerMod
,varp.t_cdf_umaj as ModifiePar
,optvar.t_opts as Groupe_Options
,optvar.t_sern as Sequence
,optvar.t_cpft as Caracteristique
,isnull(optvar.t_copt,'') as OptionActuelle
,isnull(optvar2.t_copt,'') as OptionAvant
,dbo.textnumtotext(optvar.t_txta,'4') as Texte_Option_Actuelle
,(case
	when dbo.textnumtotext(optvar.t_txta,'4') != dbo.textnumtotextSRVSQLPRD2(optvar2.t_txta,'4')
		then dbo.textnumtotextSRVSQLPRD2(optvar2.t_txta,'4')
		else iif(optvar.t_txta = 0,'','Texte identique à la variante actuelle')
end)  as Texte_Option_Avant
,(case 
	when isnull(optvar2.t_copt,'') = ''
		then 'Ajout Caratéristique'
		else iif(isnull(optvar.t_copt,'') = '','Suppression Caractéristique',iif(optvar.t_copt != optvar2.t_copt,'Option Différente','Texte différent'))
end) as Type_Modification
from 
ttipcf500500 varp -- Variantes de Produit
inner join ttipcf520500 optvar on optvar.t_cpva = varp.t_cpva --Options par variante de produit
inner join SRVSQLPRD2.ln6prddb.dbo.ttipcf520500 optvar2 on optvar2.t_cpft = optvar.t_cpft and optvar2.t_cpva = varp.t_cpva 
where 
left(varp.t_refo,2) between @ue_f and @ue_t
and varp.t_cdf_dmaj >= CONVERT (date, GETDATE())
and ((@exnv = '1' and DATEADD(hh,12,varp.t_pcfd) < varp.t_cdf_dmaj) or @exnv = '2')
and ((optvar.t_copt != optvar2.t_copt) or dbo.textnumtotext(optvar.t_txta,'4') != dbo.textnumtotextSRVSQLPRD2(optvar2.t_txta,'4'))
)
--
UNION
--
-- (2)  A partir de la copie de la variante
(select 
varp.t_refo as OrdreRef
,dbo.convertenum('tc','B61U','a','stnd','reft',varp.t_reft,'4') as Type_OrdreRef
,varp.t_refp as PosOrdreRef
,varp.t_item as ArticleGenerique
,varp.t_reft as TypeVariante
,varp.t_cpva as Variante
,varp.t_dsca as DescriptionVariante
,dbo.convertenum('tc','B61','a','','yesno',varp.t_vali,'4') as Variante_Correcte
,varp.t_pcfd as DateConfig
,varp.t_cdf_dmaj as DateDerMod
,convert(varchar,varp.t_cdf_dmaj,108) as HeureDerMod
,varp.t_cdf_umaj as ModifiePar
,optvar.t_opts as Groupe_Options
,optvar.t_sern as Sequence
,optvar.t_cpft as Caracteristique
,isnull(optvar2.t_copt,'') as OptionActuelle
,isnull(optvar.t_copt,'') as OptionAvant
,(case
	when dbo.textnumtotext(optvar.t_txta,'4') != dbo.textnumtotext(optvar2.t_txta,'4')
		then dbo.textnumtotext(optvar2.t_txta,'4')
		else ''
end)  as Texte_Option_Actuelle
,dbo.textnumtotextSRVSQLPRD2(optvar.t_txta,'4') as Texte_Option_Avant

,'Suppression Caratéristique' as Type_Modification
from 
SRVSQLPRD2.ln6prddb.dbo.ttipcf500500 varp2
inner join SRVSQLPRD2.ln6prddb.dbo.ttipcf520500 optvar on optvar.t_cpva = varp2.t_cpva 
inner join ttipcf500500 varp on varp.t_cpva = varp2.t_cpva
inner join ttipcf520500 optvar2 on optvar2.t_cpft = optvar.t_cpft and optvar2.t_cpva = varp.t_cpva 
where
left(varp.t_refo,2) between @ue_f and @ue_t
and varp.t_cdf_dmaj >= CONVERT (date, GETDATE())
and ((@exnv = '1' and DATEADD(hh,12,varp.t_pcfd) < varp.t_cdf_dmaj) or @exnv = '2')
and optvar2.t_cpft is NULL and optvar2.t_cpva is NULL)
order by varp.t_cpva, optvar.t_opts, optvar.t_sern