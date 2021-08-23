-----------------------------------
-- LOG15 - Sortie Magasin Traitée
-----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

if (@datelivreelleuniquement = 1)
(select dbo.convertenum('wh','B61C','a9','bull','inh.oorg',omag.t_oorg,4) as Origine, 
omag.t_oset as Groupe, 
omag.t_orno as Ordre, 
concat(omag.t_orno, '-', omag.t_oset) as OrdreGroupe, 
dbo.convertenum('wh','B61C','a9','bull','inh.ittp',omag.t_ittp,4) as TypeTransaction, 
omag.t_odat as DateOrdre, 
omag.t_odat as HeureDateOrdre, 
omag.t_pddt as DateLivPlan, 
omag.t_pddt as HeureDateLivPlan, 
omag.t_sfco as CodeExped, 
(case omag.t_sfty 
when 1 then '' 
when 2 then (select tiers.t_nama from ttccom100500 tiers where tiers.t_bpid = omag.t_sfco) 
when 3 then (select prj.t_dsca from ttppdm600500 prj where prj.t_cprj = omag.t_sfco) 
when 4 then (select cc.t_dsca from ttcmcs065500 cc where cc.t_cwoc = omag.t_sfco) 
when 10 then '' 
end) as NomExpediteur, 
dbo.convertenum('tc','B61C','a9','bull','typs',omag.t_stty,4) as TypeDest, 
omag.t_stco as CodeDest, 
(case omag.t_stty 
when 1 then '' 
when 2 then (select tiers.t_nama from ttccom100500 tiers where tiers.t_bpid = omag.t_stco) 
when 3 then (select prj.t_dsca from ttppdm600500 prj where prj.t_cprj = omag.t_stco) 
when 4 then (select cc.t_dsca from ttcmcs065500 cc where cc.t_cwoc = omag.t_stco) 
when 10 then '' 
end) as NomDestinataire, 
dbo.convertenum('wh','B61C','a9','bull','inh.hsta',omag.t_hsta,4) as Statut, 
line.t_pono as Ligne, 
line.t_seqn as Sequence, 
line.t_item as Article, 
art.t_dsca as Description, 
line.t_qoro as QteCmdeUnitOrdre, 
line.t_orun as UniteOrdre, 
art.t_cuni as UniteStock, 
dbo.convertenum('wh','B61C','a9','bull','inh.lstb',line.t_lsta,4) as StatutLigne, 
line.t_qord as QteCmde, 
line.t_qadv as QteProposee, 
line.t_qrel as QteLancee, 
line.t_qpic as QtePrelevee, 
line.t_qapr as QteAppro, 
line.t_qnsh as QteNonExpediee, 
line.t_qshp as QteExpediee, 
line.t_qcnl as QteAnnulee, 
line.t_addt as DteLivReelle, 
line.t_addt as HeureDteLivReelle, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_bflh,4) as PostConso, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_shrt,4) as Rupture, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_blck,4) as Bloquee, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_cncl,4) as Annulee, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_bcko,4) as Reliquat, 
sortiestk.t_time as DateGeneration, 
sortiestk.t_time as HeureDateGeneration, 
sortiestk.t_runn as Traitement, 
sortiestk.t_picm as Tournee
from twhinh200500 omag --Ordre Magasin
left join twhinh220500 line on line.t_oorg = omag.t_oorg and line.t_orno = omag.t_orno and line.t_oset=omag.t_oset --Lignes d'ordre de sortie de stock
left join ttcibd001500 art on art.t_item=line.t_item --Article
left join twhinh225500 sortiestk on sortiestk.t_oorg = line.t_oorg and sortiestk.t_orno = line.t_orno and sortiestk.t_pono = line.t_pono and sortiestk.t_seqn = line.t_seqn --Proposition de sortie de stock
where left(line.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le Magasin
and line.t_addt between @addt_f and @addt_t --Bornage sur la date de livraison réelle
and line.t_cwar between @cwar_f and @cwar_t --Bornage sur le Filtre Magasin
and line.t_lsta = 30 --Bornage sur le Statut Ligne à Expédié
and omag.t_oorg between @orig_f and @orig_t --Bornage sur l'Origine d'Ordre
)
else 
(select dbo.convertenum('wh','B61C','a9','bull','inh.oorg',omag.t_oorg,4) as Origine, 
omag.t_oset as Groupe, 
omag.t_orno as Ordre, 
concat(omag.t_orno, '-', omag.t_oset) as OrdreGroupe, 
dbo.convertenum('wh','B61C','a9','bull','inh.ittp',omag.t_ittp,4) as TypeTransaction, 
omag.t_odat as DateOrdre, 
omag.t_odat as HeureDateOrdre, 
omag.t_pddt as DateLivPlan, 
omag.t_pddt as HeureDateLivPlan, 
omag.t_sfco as CodeExped, 
(case omag.t_sfty 
when 1 then '' 
when 2 then (select tiers.t_nama from ttccom100500 tiers where tiers.t_bpid = omag.t_sfco) 
when 3 then (select prj.t_dsca from ttppdm600500 prj where prj.t_cprj = omag.t_sfco) 
when 4 then (select cc.t_dsca from ttcmcs065500 cc where cc.t_cwoc = omag.t_sfco) 
when 10 then '' 
end) as NomExpediteur, 
dbo.convertenum('tc','B61C','a9','bull','typs',omag.t_stty,4) as TypeDest, 
omag.t_stco as CodeDest, 
(case omag.t_stty 
when 1 then '' 
when 2 then (select tiers.t_nama from ttccom100500 tiers where tiers.t_bpid = omag.t_stco) 
when 3 then (select prj.t_dsca from ttppdm600500 prj where prj.t_cprj = omag.t_stco) 
when 4 then (select cc.t_dsca from ttcmcs065500 cc where cc.t_cwoc = omag.t_stco) 
when 10 then '' 
end) as NomDestinataire, 
dbo.convertenum('wh','B61C','a9','bull','inh.hsta',omag.t_hsta,4) as Statut, 
line.t_pono as Ligne, 
line.t_seqn as Sequence, 
line.t_item as Article, 
art.t_dsca as Description, 
line.t_qoro as QteCmdeUnitOrdre, 
line.t_orun as UniteOrdre, 
art.t_cuni as UniteStock, 
dbo.convertenum('wh','B61C','a9','bull','inh.lstb',line.t_lsta,4) as StatutLigne, 
line.t_qord as QteCmde, 
line.t_qadv as QteProposee, 
line.t_qrel as QteLancee, 
line.t_qpic as QtePrelevee, 
line.t_qapr as QteAppro, 
line.t_qnsh as QteNonExpediee, 
line.t_qshp as QteExpediee, 
line.t_qcnl as QteAnnulee, 
line.t_addt as DteLivReelle, 
line.t_addt as HeureDteLivReelle, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_bflh,4) as PostConso, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_shrt,4) as Rupture, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_blck,4) as Bloquee, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_cncl,4) as Annulee, 
dbo.convertenum('tc','B61C','a9','bull','yesno',line.t_bcko,4) as Reliquat, 
sortiestk.t_time as DateGeneration, 
sortiestk.t_time as HeureDateGeneration, 
sortiestk.t_runn as Traitement, 
sortiestk.t_picm as Tournee
from twhinh200500 omag --Ordre Magasin
left join twhinh220500 line on line.t_oorg = omag.t_oorg and line.t_orno = omag.t_orno and line.t_oset=omag.t_oset --Lignes d'ordre de sortie de stock
left join ttcibd001500 art on art.t_item=line.t_item --Article
left join twhinh225500 sortiestk on sortiestk.t_oorg = line.t_oorg and sortiestk.t_orno = line.t_orno and sortiestk.t_pono = line.t_pono and sortiestk.t_seqn = line.t_seqn --Proposition de sortie de stock
where left(line.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE définit par le Magasin
and omag.t_pddt between @pddt_f and @pddt_t --Bornage sur la Date de Livraison Planifiee
and sortiestk.t_time between @dategen_f and @dategen_t --Bornage sur la Date de Génération
and line.t_addt between @addt_f and @addt_t --Bornage sur la date de livraison réelle
and line.t_cwar between @cwar_f and @cwar_t --Bornage sur le Filtre Magasin
and line.t_lsta = 30 --Bornage sur le Statut Ligne à Expédié
and omag.t_oorg between @orig_f and @orig_t --Bornage sur l'Origine d'Ordre
) 
order by omag.t_orno, omag.t_oset;