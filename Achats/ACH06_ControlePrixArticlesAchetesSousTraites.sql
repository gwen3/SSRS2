----------------------------------------------------------------
-- ACH06 - Controle des Prix des Articles Achetés Sous Traités
----------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select left(art.t_item, 9) as Projet, 
substring(art.t_item, 10, len(art.t_item)) as Article, 
art.t_dsca as DesignationArticle, 
art.t_cood as CoordinateurTechnique, 
emp.t_nama as NomCoordinateurTechnique, 
art.t_cuni as UniteStockArticle, 
achart.t_otbp as Fournisseur, 
four.t_nama as NomFournisseur, 
achart.t_scpr as PrixAchatSousTraitance, 
achart.t_cupp as UnitePrixAchatSousTraitance, 
achart.t_ccur as DevisePrixAchatSousTraitance, 
dbo.convertenum('tc','B61C','a9','bull','sopr',achart.t_sopr,'4') as SourcePrix, 
prsim.t_sipp as PrixAchatSimule, 
prsim.t_cupp as UnitePrixAchatSimule, 
prsim.t_ccur as DevisePrixAchatSimule, 
ctstd.t_ecpr_1 as CoutStandard, 
pa.t_avpr as PrixAchatMoyen, 
pa.t_ltpp as DateTransactionPrixAchat 
from ttcibd001500 art --Articles
left outer join ttdipu001500 achart on achart.t_item = art.t_item --Données Articles Achats
left outer join tticpr170500 prsim on prsim.t_item = art.t_item and prsim.t_cpcc = '001' --Prix Achats Simulés
left outer join tticpr007500 ctstd on ctstd.t_item = art.t_item --Couts Standards
left outer join ttccom001500 emp on emp.t_emno = art.t_cood --Employés - Coordinateur Technique
left outer join ttccom100500 four on four.t_bpid = achart.t_otbp --Tiers - Fournisseur
left outer join ttdipu100500 pa on pa.t_item = art.t_item --Prix d'achat réel de l'article
where art.t_kitm = 1 --Articles Achetés
and art.t_subc = 1 --Articles Sous Traités
and art.t_cood between @coor_f and @coor_t --Bornage sur le CoordinateurTechnique
