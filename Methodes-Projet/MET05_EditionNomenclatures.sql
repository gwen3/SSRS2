----------------------------------
-- MET05 - Edition Nomenclatures
----------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(nome.t_mitm, 9) as ProjetArticlePere
,substring(nome.t_mitm, 10, len(nome.t_mitm)) as ArticlePere
,artpere.t_dsca as DescriptionArticlePere
,artpere.t_csig as SignalArticlePere
,artpere.t_citg as GroupeArticlePere
,grpartpere.t_dsca as DescriptionGroupeArticlePere
,nome.t_pono as Position
,nome.t_seqn as Sequence
,left(nome.t_sitm, 9) as ProjetArticleFils
,substring(nome.t_sitm, 10, len(nome.t_sitm)) as ArticleFils
,artfils.t_dsca as DescriptionArticleFils
,artfils.t_csig as SignalArticleFils
,artfils.t_citg as GroupeArticleFils
,grpartfils.t_dsca as DescriptionGroupeArticleFils
,nome.t_qana as QuantiteNette
,artfils.t_cuni as UniteStockArticleFils
,nome.t_cwar as Magasin
,nome.t_opno as Operation
,nome.t_indt as DateApplication
,nome.t_exdt as DateExpiration
,dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_cpha,'4') as Fantome
,stk.t_qhnd as StockPhysique
,stk.t_qall as StockReserve
,stk.t_qord as StockEnCommande
from ttibom010500 nome --Nomenclatures
left outer join ttcibd001500 artpere on artpere.t_item = nome.t_mitm --Article - Père
left outer join ttcmcs023500 grpartpere on grpartpere.t_citg = artpere.t_citg --Groupe Article
left outer join ttcibd001500 artfils on artfils.t_item = nome.t_sitm --Article - Fils
left outer join ttcmcs023500 grpartfils on grpartfils.t_citg = artfils.t_citg --Groupe Article
left outer join twhwmd215500 stk on stk.t_item = nome.t_sitm and stk.t_cwar = nome.t_cwar --Stock des Articles par Magasin
where left(nome.t_cwar, 2) between @ue_f and @ue_t --Bornage sur l'UE
and substring(nome.t_mitm, 10, len(nome.t_mitm)) between @artpere_f and @artpere_t --Bornage sur l'Article Père
and artpere.t_citg between @grpartpere_f and @grpartpere_t --Bornage sur le Groupe Article Père
and artpere.t_csig in (@csig) --Bornage sur le Code signal
and (@prj = 1 and left(nome.t_mitm, 9) = ' ') --Si on souhaite ne pas avoir de projet (@prj à Oui)