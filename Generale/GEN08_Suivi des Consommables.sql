-----------------------------------
-- GEN08 - Suivi des Consommables
-----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select conso.t_trdt as DateTransaction
,conso.t_orno as NumeroOrdre
,conso.t_pono as LigneOrdre
,conso.t_srnb as SequenceOrdre
,conso.t_cwar as Magasin
,left(conso.t_item, 9) as ProjetArticle
,substring(conso.t_item, 10, len(conso.t_item)) as Article
,art.t_dsca as DescriptionArticle
,art.t_citg as GroupeArticle
,grpart.t_dsca as DescriptionGroupeArticle
,conso.t_qstk as QuantiteConsommee
,art.t_cuni as UniteStock
,conso.t_ctdt as DateConsommation
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = conso.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(conso.t_cwar, 2)) and pmp.t_trdt <= conso.t_ctdt order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PMP
,((select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = conso.t_item and substring(pmp.t_wvgr, 4, len(pmp.t_wvgr)) = concat('V', left(conso.t_cwar, 2)) and pmp.t_trdt <= conso.t_ctdt order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) * conso.t_qstk) as Montant
,dbo.convertenum('tc','B61C','a9','bull','typs',omag.t_stty,4) as TypeDestinataire
,omag.t_stco as CodeDestinataire
,(case omag.t_stty
when 1 then ''
when 2 then (select tiers.t_nama from ttccom100500 tiers where tiers.t_bpid = omag.t_stco)
when 3 then (select prj.t_dsca from ttppdm600500 prj where prj.t_cprj = omag.t_stco)
when 4 then (select cc.t_dsca from ttcmcs065500 cc where cc.t_cwoc = omag.t_stco)
when 10 then ''
end) as NomDestinataire
,cc.t_emno as ResponsableCentreCharge
,emp.t_nama as NomResponsableCentreCharge
,left(conso.t_cwar, 2) as UniteEntreprise
from twhina114500 conso --Consommation des réceptions
left outer join ttcibd001500 art on art.t_item = conso.t_item --Article
left outer join twhinh220500 lomag on lomag.t_oorg = 51 and lomag.t_orno = conso.t_orno and lomag.t_pono = conso.t_pono and lomag.t_seqn = conso.t_srnb --Lignes d'ordre de sortie de stock ; Le code n'est pas le même dans les 2 tables
left outer join twhinh200500 omag on omag.t_oorg = lomag.t_oorg and omag.t_orno = lomag.t_orno and omag.t_oset = lomag.t_oset --Ordres Magasins
left outer join ttcmcs065500 cc on cc.t_cwoc = omag.t_stco --Centre de Charge
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Article
left outer join ttccom001500 emp on emp.t_emno = cc.t_emno --Employé - Responsable du Centre de Charge
where left(conso.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE
and conso.t_ctdt between @dateconso_f and @dateconso_t --Bornage sur la Date de Consommation
and conso.t_koor = 32 --On ne prend que le type d'ordre Production SFC (manuelle) qui représente les consommables
--and omag.t_stco in (@cc) --Bornage sur le Centre de Charge
order by omag.t_orno, omag.t_oset