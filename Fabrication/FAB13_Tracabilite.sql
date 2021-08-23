------------------------
-- FAB13 - Traçabilité
------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select traca.t_ntra as Tracabilite
,traca.t_stat as CodeStatutTracabilite
,dbo.convertenum('br','B61C','a9','bull','gru.stat',traca.t_stat,4) as StatutTracabilite
,traca.t_cwar as Magasin
,traca.t_pkdf as DefinitionEmballage
,traca.t_node as Noeud
,traca.t_qttr as QuantiteTracabilite
,traca.t_qtca as QuantiteComposeAssociee
,traca.t_ntrp as TracabiliteParent
,traca.t_huid as NumeroUM
,traca.t_shpm as NumeroExpedition
,comptra.t_pdno as OrdreFabrication
,comptra.t_qtcp as QuantiteNumeroSerieCompose
,left(comptra.t_mitm, 9) as ProjetArticleCompose
,substring(comptra.t_mitm, 10, len(comptra.t_mitm)) as ArticleCompose
,artcompose.t_dsca as DescriptionArticleCompose
,comptra.t_nosl_m as NumeroSerieCompose
,comptra.t_stat as CodeStatutCompose
,dbo.convertenum('br','B61C','a9','bull','gru.stat',comptra.t_stat,4) as StatutCompose
,comptra.t_nctr as NombreComposantATracer
,comptra.t_ncta as NombreComposantTrace
,compcomp.t_pono as Position
,left(compcomp.t_sitm, 9) as ProjetArticleComposant
,substring(compcomp.t_sitm, 10, len(compcomp.t_sitm)) as ArticleComposant
,artcomposant.t_dsca as DescriptionArticleComposant
,compcomp.t_nosl_c as NumeroSerieComposant
,compcomp.t_gtra as CodeTypeComposantTracabilite
,dbo.convertenum('br','B61C','a9','bull','gru.tra',compcomp.t_gtra,4) as TypeComposantTracabilite
,compcomp.t_user as Utilisateur
,compcomp.t_dcre as DateCreation
from tbrgru900500 traca -- lien composé - composants
left outer join tbrgru901500 comptra on comptra.t_ntra = traca.t_ntra --Lien Composé - N° Traçabilité
left outer join ttcibd001500 artcompose on artcompose.t_item = comptra.t_mitm --Article - Composé
left outer join tbrgru902500 compcomp on compcomp.t_nosl_m = comptra.t_nosl_m and compcomp.t_pdno = comptra.t_pdno and compcomp.t_opno = comptra.t_opno -- lien composé - N° de traçabilité -- N° de série composé
left outer join ttcibd001500 artcomposant on artcomposant.t_item = compcomp.t_sitm --Article - Composé
where left(traca.t_ntra, 2) between @ue_f and @ue_t --Bornage sur l'UE définie par le numéro de traçabilité
and traca.t_ntra between @traca_f and @traca_t --Bornage sur le numéro de traçabilité
and compcomp.t_dcre between @date_f and @date_t --Bornage sur la date de Création
and traca.t_stat in (@stat) --Bornage sur le statut de traçabilité
and comptra.t_nosl_m like concat('%', @numsercompose, '%') --Bornage sur le numéro de série composé
and compcomp.t_nosl_c like concat('%', @numsercomposant, '%') --Bornage sur le numéro de série composant
order by Tracabilite, Position