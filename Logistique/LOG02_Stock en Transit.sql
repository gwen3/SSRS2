-----------------------------
-- LOG02 - Stock en Transit
-----------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select dbo.convertenum('wh','B61C','a9','bull','inh.oorg',tra.t_oorg,'4') as TypeOrdre
,tra.t_orno as Ordre
,tra.t_pono as Ligne
,tra.t_seqn as Sequence
,tra.t_cwar as MagasinDestination
,sortie.t_cwar as MagasinExpedition
,tra.t_prdt as DatePlanifiee
,left(tra.t_item, 9) as Projet
,substring(tra.t_item, 10, len(tra.t_item)) as Article
,art.t_dsca as DescriptionArticle
,sortie.t_qshp as QuantiteExpediee
,tra.t_qrec as QuantiteReceptionnee
,(sortie.t_qshp - tra.t_qrec) as QuantiteEnTransit
,expe.t_iadt as DateExpedition
,expe.t_shpm as NumeroBL
-- Modification brevol le 02/06 : Prendre le pmp du code article de la sortie (les articles en entrée et sortie peuvent être différents)
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = sortie.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(sortie.t_cwar, 2)) and pmp.t_trdt <= expe.t_iadt order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PUMPActuel
,((select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = sortie.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(sortie.t_cwar, 2)) and pmp.t_trdt <= expe.t_iadt order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) * (sortie.t_qshp - tra.t_qrec)) as ValorisationPMP
from twhinh210500 tra --Lignes d'ordres d'entrée en stock
left outer join ttcibd001500 art on art.t_item = tra.t_item --Articles
left outer join twhinh431500 expe on expe.t_worg = tra.t_oorg and expe.t_worn = tra.t_orno and expe.t_wpon = tra.t_pono and expe.t_wseq = tra.t_seqn --Lignes d'expédition
left outer join twhinh220500 sortie on sortie.t_orno = tra.t_orno and sortie.t_pono = tra.t_pono and sortie.t_seqn = tra.t_seqn and sortie.t_oorg = tra.t_oorg --Lignes de sorties de stock
where tra.t_blck = 2 --Bloqué à Non
and tra.t_lsta = 5 --Statut Ouvert
and tra.t_oorg in ('71','72','90') --Origine Transfert, Transfert (manuel) ou Distribution EP
and left(tra.t_orno, 2) between @ue_f and @ue_t --On récupère l'UE sur l'ordre
and sortie.t_qshp != tra.t_qrec --On prend la quantité en sortie différente de la quantité en entrée (pour gérer les cas des reliquats en cours de prélèvement)