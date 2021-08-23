--------------------------------------------------------
-- FIN07 PMP Négatifs 
--------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
pmp.t_wvgr as GroupeValoMag,
substring(pmp.t_item, 1, 9) as ArticleProjet,
substring(pmp.t_item, 10, len(pmp.t_item)) as Article,
artgen.t_dsca as DescriptionArticle,
pmp.t_trdt as DateTransaction,
pmp.t_seqn as SeqTransaction,
pmp.t_cpcp as EltPrixRevient,
epr.t_dsca as DescriptionEPR,
pmp.t_mauc_1 as PrixEpr,
(select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PrixMoyenPond
--(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) from twhina136500 recpmp where recpmp.t_item = pmp.t_item and recpmp.t_wvgr = pmp.t_wvgr and recpmp.t_trdt = pmp.t_trdt order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PMP,
--(select top 1 trnpmp.t_trdt from twhina136500 trnpmp where trnpmp.t_item = pmp.t_item and trnpmp.t_wvgr = pmp.t_wvgr order by trnpmp.t_trdt desc, trnpmp.t_seqn desc) as DerniereDate
from 
twhina137500 pmp
inner join ttcibd001500 artgen on pmp.t_item = artgen.t_item --Articles
inner join ttcmcs048500 epr on epr.t_cpcp = pmp.t_cpcp --Eléments prix de revient
where
substring(pmp.t_wvgr,1,3) in (@wvgr)
and pmp.t_trdt between @prdt_f and @prdt_t
and pmp.t_mauc_1 < -0.10
and pmp.t_trdt = (select top 1 pmptrdt.t_trdt from twhina137500 pmptrdt 
					where pmptrdt.t_item = pmp.t_item and pmptrdt.t_wvgr = pmp.t_wvgr and pmptrdt.t_trdt between @prdt_f and @prdt_t
					order by pmptrdt.t_trdt desc, pmptrdt.t_seqn desc)
and pmp.t_seqn = (select top 1 pmptrdt2.t_seqn from twhina137500 pmptrdt2 
					where pmptrdt2.t_item = pmp.t_item and pmptrdt2.t_wvgr = pmp.t_wvgr and pmptrdt2.t_trdt between @prdt_f and @prdt_t
					order by pmptrdt2.t_trdt desc, pmptrdt2.t_seqn desc)
order by 1, 3