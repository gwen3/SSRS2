---------------------------------
-- LOG03 - Ordres de Correction
---------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select inh.t_orno as Ordre, 
dbo.convertenum('wh','B61C','a9','bull','inh.adst',inh.t_adst,'4') as Statut, 
inh.t_cwar as Magasin, 
inh.t_odat as DateCommande, 
emp.t_nama as NomEmploye, 
linh.t_pono as NumeroLigne, 
left(linh.t_item, 9) as Projet, 
substring(linh.t_item, 10, len(linh.t_item)) as Article, 
art.t_dsca as DescriptionArticle, 
linh.t_qvrr as Quantite, 
linh.t_stun as Unite, 
linh.t_adrn as Motif, 
adrn.t_dsca as LibelleMotif, 
linh.t_amnt as MontantValorisation, 
'EUR' as Monnaie, 
histlinh.t_logn as CodeAcces, 
linh.t_adat as DateCorrection 
from twhinh520500 inh --Ordres de Correction
left outer join twhinh521500 linh on linh.t_orno = inh.t_orno --Lignes d'ordre de correction
left outer join ttcmcs005500 adrn on adrn.t_cdis = linh.t_adrn --Motifs
left outer join ttccom001500 emp on emp.t_emno = inh.t_emno --Employés
left outer join ttcibd001500 art on art.t_item = linh.t_item --Articles
left outer join twhinh571500 histlinh on histlinh.t_orno = inh.t_orno and histlinh.t_pono = linh.t_pono and histlinh.t_hist = 4 --Historique des lignes d'ordre de correction, on prend les lignes au statut créées
where inh.t_odat between @date_f and @date_t --Bornage sur la Date de Commande
and inh.t_orno between @ordre_f and @ordre_t --Bornage sur l'Ordre
and inh.t_cwar between @mag_f and @mag_t --Bornage sur le Magasin
and linh.t_adrn between @motif_f and @motif_t --Bornage sur le Motif
and left(inh.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE par le magasin