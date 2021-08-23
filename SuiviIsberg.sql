-------------------------
-- COM05 - Suivi Isberg
-------------------------

select lignecde.t_orno as Ordre, 
left(lignecde.t_item, 9) as Projet, 
substring(lignecde.t_item, 10, len(lignecde.t_item)) as Article, 
art.t_dsca as Designation, 
lignecde.t_qoor as QteComReliquat, 
lignecde.t_cuqs as Unite, 
lignecde.t_ddta as DateProdGruau, 
lignecde.t_oamt as MontantTotalRemise, 
cde.t_odat as DateOrdre, 
artligcde.t_cpcl as ClasseProduit, 
classeproduit.t_dsca as DescriptionClasseProduit, 
cde.t_sotp as TypeOrdre, 
cde.t_ofbp as TiersAcheteur, 
tiers.t_nama as NomTiers, 
cde.t_corn as ReferenceA, 
artligcde.t_citg as GroupeArticle, 
lignecde.t_serl as VIN, 
lignecde.t_dapc as DateArriveePrevueChassis, 
lignecde.t_dtaf as DateAffectationChassis, 


(select top 1 nserie.t_isdt 
from twhltc500500 nserie --Numero série par Magasin
where nserie.t_serl = lignecde.t_serl 
and nserie.t_item = lignecde.t_item 
) as DateLivraisonChassis, 


expe.t_pdat as DateBL, 
lignecde.t_dlsc as DateLivraisonSouhaitee, 
lignecde.t_prdt as DateMADC, 
cde.t_refb as ContactCde 
from ttdsls401500 lignecde 
full join ttdsls400500 cde on lignecde.t_orno = cde.t_orno 
full join ttcibd001500 art on lignecde.t_item = art.t_item 
full join ttdsls411500 artligcde on lignecde.t_orno = artligcde.t_orno and lignecde.t_pono = artligcde.t_pono and lignecde.t_sqnb = artligcde.t_sqnb 
full join ttccom100500 tiers on lignecde.t_ofbp = tiers.t_bpid 
full join ttcmcs062500 classeproduit on artligcde.t_cpcl = classeproduit.t_cpcl 
full join ttdsls406500 liglivrcdecli on lignecde.t_orno = liglivrcdecli.t_orno and lignecde.t_pono = liglivrcdecli.t_pono and lignecde.t_sqnb = liglivrcdecli.t_sqnb 
full join twhinh430500 expe on liglivrcdecli.t_shpm = expe.t_shpm 
where lignecde.t_sqnb = 0 
and lignecde.t_cwar != '' 
and lignecde.t_odat between @datef and @datet 
and lignecde.t_orno between @ordref and @ordret;