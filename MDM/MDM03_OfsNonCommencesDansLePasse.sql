--------------------------------------------
-- MDM03 - OFs Non Commencés dans le Passé
--------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select 
(case left(ofab.t_pdno, 2) 
when 'AC' 
	then 'Sanicar'
when 'AD' 
	then 'Ducarme'
when 'AL' 
	then 'Gifa'
when 'AM' 
	then 'Gifa'
when 'AP' 
	then 'Petit Picot'
when 'EC' 
	then 'Electron'
when 'LB' 
	then 'Labbe'
when 'LV' 
	then 'Laval'
when 'LY' 
	then 'Lyon'
when 'PN' 
	then 'Paris Nord'
when 'PS' 
	then 'Paris Sud'
when 'SM' 
	then 'Lorraine'
end) as SiteGruau, 
ofab.t_pdno as OrdreFabrication, 
dbo.convertenum('tc','B61C','a9','bull','osta',ofab.t_osta,'4') as StatutOF, 
ofab.t_cprj as Projet, 
ofab.t_mitm as Article, 
art.t_dsca as DescriptionArticle, 
art.t_citg as GroupeArticle, 
grpart.t_dsca as DescriptionGroupeArticle, 
ofab.t_qrdr as QuantiteOrdre, 
(select sum(opt.t_prtm) from ttisfc010500 opt where opt.t_pdno = ofab.t_pdno) as HeuresMainOeuvreAllouees, 
(select sum(opt.t_sptm) from ttisfc010500 opt where opt.t_pdno = ofab.t_pdno) as HeuresMainOeuvrePassee, 
ofab.t_prdt as DateDebutFabrication, 
ofab.t_apdt as DateDebutReelle, 
ofab.t_cmdt as DateAchevement, 
ofab.t_adld as DateLivraisonReelle, 
ofab.t_cldt as DateCloture, 
(select sum(
(case 
when cout.t_ques >= cout.t_qucs
	then (cout.t_ques - cout.t_qucs) * cout.t_cpes_1
else 0
end)) from tticst001500 cout where cout.t_pdno = ofab.t_pdno) as CoutsASortir, 
--(select sum((cout.t_ques - cout.t_qucs) * cout.t_cpes_1) from tticst001500 cout where cout.t_pdno = ofab.t_pdno) as CoutsASortir, 
(select sum(cout.t_aamt_1) from tticst001500 cout where cout.t_pdno = ofab.t_pdno) as MontantReel 
from ttisfc001500 ofab --Ordres de Fabrication
inner join ttcibd001500 art on art.t_item = ofab.t_mitm --Articles
left outer join ttcmcs023500 grpart on grpart.t_citg = art.t_citg --Groupe Articles
where ofab.t_prdt < getdate() and ofab.t_prdt > '01/01/1980' 
--ofab.t_prdt < dateadd(m, -1, getdate()) and ofab.t_prdt > '01/01/1980' 
and ofab.t_cmdt < '01/01/1980' 
order by SiteGruau