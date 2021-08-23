----------------------------
-- ACH03 - Lignes à 0 ou 1
----------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select lig.t_orno as CommandeFournisseur
,lig.t_pono as LigneCommandeFournisseur
,lig.t_sqnb as SequenceCommandeFournisseur
,dbo.convertenum('td','B61C','a9','bull','gen.oltp',lig.t_oltp,'4') as TypeLigneCommande
,lig.t_otbp as TiersVendeur
,tiers.t_nama as NomTiersVendeur
,left(lig.t_item, 9) as ProjetArticle
,substring(lig.t_item, 10, len(lig.t_item)) as Article
,art.t_dsca as DescriptionArticle
,lig.t_qoor as QuantiteCommandee
,lig.t_cuqp as UniteAchat
,lig.t_cvqp as FacteurConversionUniteAchat
,lig.t_pric as Prix
,lig.t_ddtb as DateReceptionCourantePlanifiee
,dbo.convertenum('td','B61C','a9','bull','pur.corg',lig.t_corg,'4') as OrigineCommande
,dbo.convertenum('td','B61C','a9','bull','gen.porg',lig.t_porg,'4') as OriginePrix
,dbo.convertenum('tc','B61C','a9','bull','stsd',lig.t_stsd,'4') as StatutFacturation
,dbo.convertenum('tc','B61C','a9','bull','inup.by',lig.t_btsp,'4') as StatutImputationStock
,dbo.convertenum('td','B61C','a9','bull','pur.hdst',cde.t_hdst,'4') as StatutCommande
,cde.t_ccon as Acheteur
,emp.t_nama as NomAcheteur
,cde.t_cofc as ServiceAchat
,srv.t_dsca as DescriptionServiceAchat
,cde.t_odat as DateCommande 
from ttdpur401500 lig --Lignes de Commandes Fournisseurs
inner join ttdpur400500 cde on lig.t_orno = cde.t_orno --Commandes Fournisseurs
inner join ttcmcs065500 srv on srv.t_cwoc = cde.t_cofc --Départements
left outer join ttccom001500 emp on emp.t_emno = cde.t_ccon --Employés ; Acheteur
inner join ttcibd001500 art on art.t_item = lig.t_item --Articles
inner join ttccom100500 tiers on tiers.t_bpid = lig.t_otbp --Tiers ; Fournisseur
where left(lig.t_orno, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par les OA
and lig.t_pric between @pric_f and @pric_t --Bornage sur le Prix
and cde.t_hdst in (@stat) --Bornage sur le Statut de la Commande
and lig.t_clyn = 2 --On ne prend pas les Commandes Annulées
