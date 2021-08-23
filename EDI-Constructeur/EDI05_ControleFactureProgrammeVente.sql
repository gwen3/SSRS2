--------------------------------------------------------
-- EDI05 - Controle des Factures de Programme de Vente
--------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select pv.t_ofbp as TiersAcheteur, 
tiera.t_nama as NomTiersAcheteur, 
pv.t_stbp as TiersDestinataire, 
tierd.t_nama as NomTiersDestinataire, 
pv.t_corn as CommandeClient, 
pv.t_schn as Programme, 
pv.t_sctp as CodeTypeProgramme, 
dbo.convertenum('td','B61C','a9','bull','sls.reltype',pv.t_sctp,'4') as TypeProgramme, 
pv.t_citm as ArticleClient, 
left(pv.t_item, 9) as ProjetArticle, 
substring(pv.t_item, 10, len(pv.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
pv.t_cono as Contrat, 
'' as Client, 
pv.t_pono as Position, 
livpv.t_qidl as QuantiteLivree, 
art.t_cuni as Unite, 
livpv.t_dldt as DateLivraison, 
livpv.t_dlno as CodeExpedition, 
livpv.t_shpo as PositionExpedition, 
livpv.t_refs as ReferenceExpedition, 
info.t_fd05 as Kanban, 
info.t_fd06 as RAN, 
info.t_fd10 as TransportID, 
livpv.t_stat as CodeStatut, 
dbo.convertenum('td','B61C','a9','bull','sls.stat',livpv.t_stat,'4') as Statut, 
livpv.t_qnvc as QuantiteFacturee, 
livpv.t_namt as MontantFacture, 
pv.t_ccur as Devise, 
livpv.t_scmp as SocieteFacture, 
livpv.t_ttyp as TypeFacture, 
livpv.t_invn as NumeroFacture, 
livpv.t_invd as DateFacture 
from ttdsls340500 livpv --Lignes de Livraison de Programme de Vente Réelles
left outer join ttdsls311500 pv on pv.t_schn = livpv.t_schn and pv.t_sctp = livpv.t_sctp and pv.t_revn = (select top 1 prog1.t_revn from ttdsls311500 prog1 where prog1.t_schn = pv.t_schn and prog1.t_sctp = pv.t_sctp order by prog1.t_revn desc) --Programmes de Vente
left outer join ttccom100500 tiera on tiera.t_bpid = pv.t_ofbp --Tiers Acheteur
left outer join ttccom100500 tierd on tierd.t_bpid = pv.t_stbp --Tiers Destinataire
left outer join ttcibd001500 art on art.t_item = pv.t_item --Articles
left outer join ttdsls300500 cont on cont.t_cono = pv.t_cono --Contrats de Vente
left outer join ttcstl210500 info on info.t_adin = pv.t_adin --Informations Supplémentaires
where left(pv.t_schn, 2) between @ue_f and @ue_t --Bornage sur l'Unité d'Entreprise définie par le Programme de Vente
and livpv.t_dldt between @dateliv_f and @dateliv_t --Bornage sur la Date de Livraison
and pv.t_ofbp between @tiersa_f and @tiersa_t --Bornage sur le Tiers Acheteur
and pv.t_item in (@art) --Bornage sur l'Article
and livpv.t_stat between 9 and 10 --On ne ramène que les lignes de livraison facturées