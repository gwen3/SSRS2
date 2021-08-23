--------------------------------------
-- MET01 - Nomenclature Multi Niveau 
--------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- dboivin 24/05/2018 ajout des déclarations de variables pour développement SQL server
-- dboivin 24/05/2018 modification de la recherche du prix d'achat selon le type de tranche et la série économique pour PrixAchatParQuantiteBaremeGroupe2 et PrixAchatContrat1
/*
declare @dateapplic date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @datepmp date = DATEADD(DD, 0, CAST(CURRENT_TIMESTAMP AS DATE));
declare @prj_f nvarchar(9) = '         '; -- vide '         '
declare @prj_t nvarchar(9) = '         ';
declare @art_f nvarchar(21) = 'E00070';
declare @art_t nvarchar(21) = 'E00070';
declare @ue_f nvarchar(2) = '  ';
declare @ue_t nvarchar(2) = 'ZZ';
declare @serie nvarchar(2) = '10';
declare @uechoisie nvarchar(2) = 'LV';
declare @tauxhoraire integer = '56';*/

--Rajout le 31/08/2017 de la vérification de la date d'application et de la date d'expiration à chaque utilisation de la table tirou102 par rbesnier
with nomenclature (Niveau, Position, ArticlePere, DescriptionArticlePere, ArticleFils, DescriptionArticleFils, Fantome, SignalArticle, GroupeArticle, DateApplication, DateExpiration, TypeArticleFils, SousTraite, Quantite, UniteStock, Magasin, chemin, tri, tripere) as (
-- article tete
select 0 as Niveau
,right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)
,nome.t_mitm
,pere.t_dsca
,nome.t_sitm
,fils.t_dsca
,dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_cpha,'4')
,fils.t_csig
,fils.t_citg
,nome.t_indt
,nome.t_exdt
,dbo.convertenum('tc','B61C','a9','bull','kitm',fils.t_kitm,'4')
,dbo.convertenum('tc','B61C','a9','bull','yesno',fils.t_subc,'4')
,nome.t_qana
,fils.t_cuni
,nome.t_cwar
,cast(cast(nome.t_mitm as nvarchar(30)) + '/' + cast(nome.t_sitm as nvarchar(30)) as nvarchar(1000))
,cast(concat(nome.t_mitm, '_', 0, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))
,cast(concat(nome.t_mitm, '_', 0, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))
from ttibom010500 nome --Nomenclatures
inner join ttcibd001500 fils on nome.t_sitm = fils.t_item
inner join ttcibd001500 pere on nome.t_mitm = pere.t_item
where nome.t_indt <= @dateapplic --Date d'application de la nomenclature inférieure ou égale à la date du jour
and nome.t_exdt > @dateapplic --Date d'expiration de la nomenclature n'est pas encore arrivée à la date du jour
and left(nome.t_mitm, 9) between @prj_f and @prj_t --Bornage sur le Projet de l'Article Fabriqué
and substring(nome.t_mitm, 10, len(nome.t_mitm)) between @art_f and @art_t --Bornage sur le Projet de l'Article Fabriqué
and ((left(nome.t_mitm, 2) between @ue_f and @ue_t) or left(nome.t_mitm, 2) = '') --Bornage sur l'UE à partir du projet de l'Article, on prend également lorsqu'il n'y en a pas
union all 
-- récursivité
select Niveau + 1
,right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)
,nome.t_mitm
,pere.t_dsca
,nome.t_sitm
,fils.t_dsca
,dbo.convertenum('tc','B61C','a9','bull','yesno',nome.t_cpha,'4')
,fils.t_csig
,fils.t_citg
,nome.t_indt
,nome.t_exdt
,dbo.convertenum('tc','B61C','a9','bull','kitm',fils.t_kitm,'4')
,dbo.convertenum('tc','B61C','a9','bull','yesno',fils.t_subc,'4')
,nome.t_qana
,fils.t_cuni
,nome.t_cwar
,cast((chemin + '/' + cast(nome.t_sitm as nvarchar(30))) as nvarchar(1000))
,cast(concat(tri, '/', Niveau + 1, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))
,cast(concat(tri, '/', Niveau + 1, '-', right(replicate('0',4) + cast(nome.t_pono as varchar(5)), 4)) as nvarchar(1000))  
from ttibom010500 nome --Nomenclatures
inner join nomenclature on nome.t_mitm = nomenclature.ArticleFils --On fait appel à la table nomenclature définie en tout début
inner join ttcibd001500 pere on nome.t_mitm = pere.t_item --On va chercher l'article père
inner join ttcibd001500 fils on nome.t_sitm = fils.t_item --On va chercher l'article fils
where nome.t_indt <= @dateapplic --Date d'application de la nomenclature inférieure ou égale à la date du jour
and nome.t_exdt > @dateapplic --Date d'expiration de la nomenclature n'est pas encore arrivée à la date du jour
)
select nomenclature.Niveau
,nomenclature.Position
,nomenclature.ArticlePere
,nomenclature.DescriptionArticlePere
,nomenclature.ArticleFils
,nomenclature.DescriptionArticleFils
,pr2.t_ecpr_1 as ComposePrixRevientEstime
,pr2.t_emtc_1 as ComposeCoutMatiereEstime
,pr2.t_eopc_1 as ComposeCoutTotalOperatoireEstime
,(case gampere.t_stor 
when 1 --Gamme Standard
	then (select sum(opgampere.t_sutm) from ttirou102500 opgampere where opgampere.t_mitm = ' ' and opgampere.t_opro = gampere.t_strc and opgampere.t_indt <= @dateapplic and opgampere.t_exdt > @dateapplic) 
when 2 --Gamme non Standard
	then (select sum(opgampere.t_sutm) from ttirou102500 opgampere where opgampere.t_mitm = nomenclature.ArticlePere and opgampere.t_opro = '     0' and opgampere.t_indt <= @dateapplic and opgampere.t_exdt > @dateapplic) 
end) as ComposeTempsPrepa, 
(case gampere.t_stor 
when 1 --Gamme Standard
	then (select sum(opgampere.t_rutm) from ttirou102500 opgampere where opgampere.t_mitm = ' ' and opgampere.t_opro = gampere.t_strc and opgampere.t_indt <= @dateapplic and opgampere.t_exdt > @dateapplic) 
when 2 --Gamme non Standard
	then (select sum(opgampere.t_rutm) from ttirou102500 opgampere where opgampere.t_mitm = nomenclature.ArticlePere and opgampere.t_opro = '     0' and opgampere.t_indt <= @dateapplic and opgampere.t_exdt > @dateapplic) 
end) as ComposeTempsExecution
,nomenclature.Fantome
,nomenclature.SignalArticle
,nomenclature.GroupeArticle
,nomenclature.DateApplication
,nomenclature.DateExpiration
,pr.t_ltcp as DateCalculPrixRevient
,nomenclature.TypeArticleFils
,nomenclature.SousTraite
,pr.t_ecpr_1 as PrixRevientEstime6
,pr.t_emtc_1 as CoutMatiereEstime
,(case gam.t_stor 
when 1 --Gamme Standard
	then (select sum(opgam.t_sutm) from ttirou102500 opgam where opgam.t_mitm = ' ' and opgam.t_opro = gam.t_strc and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic) 
when 2 --Gamme non Standard
	then (select sum(opgam.t_sutm) from ttirou102500 opgam where opgam.t_mitm = nomenclature.ArticleFils and opgam.t_opro = '     0' and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic) 
end) as ComposantTempsPrepa --Sommes des temps de Préparation dans les Opérations de Gammes en MINUTES
,(case gam.t_stor 
when 1 --Gamme Standard
	then (select sum(opgam.t_rutm) from ttirou102500 opgam where opgam.t_mitm = ' ' and opgam.t_opro = gam.t_strc and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic) 
when 2 --Gamme non Standard
	then (select sum(opgam.t_rutm) from ttirou102500 opgam where opgam.t_mitm = nomenclature.ArticleFils and opgam.t_opro = '     0' and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic) 
end) as ComposantTempsExecution --Sommes des temps d'Exécution dans les Opérations de Gammes en MINUTES
,(case gam.t_stor 
when 1 --Gamme Standard
	then ((((select sum(opgam.t_sutm) from ttirou102500 opgam where opgam.t_mitm = ' ' and opgam.t_opro = gam.t_strc and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic) / 
(case nomenclature.TypeArticleFils
when 'Acheté'
	then artacht.t_qiec 
when 'Fabriqué' 
	then artcom.t_ecoq 
end)
) + (select sum(opgam.t_rutm) from ttirou102500 opgam where opgam.t_mitm = ' ' and opgam.t_opro = gam.t_strc and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic)) * @tauxhoraire / 60)
when 2 --Gamme non Standard
	then ((((select sum(opgam.t_sutm) from ttirou102500 opgam where opgam.t_mitm = nomenclature.ArticleFils and opgam.t_opro = '     0' and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic) / 
(case nomenclature.TypeArticleFils
when 'Acheté'
	then artacht.t_qiec 
when 'Fabriqué' 
	then artcom.t_ecoq 
end)
) + (select sum(opgam.t_rutm) from ttirou102500 opgam where opgam.t_mitm = nomenclature.ArticleFils and opgam.t_opro = '     0' and opgam.t_indt <= @dateapplic and opgam.t_exdt > @dateapplic)) * @tauxhoraire / 60)
end) as CoutOperatoireComposant
,nomenclature.Quantite
,nomenclature.UniteStock
,nomenclature.Magasin
,stk.t_qhnd as StockPhysique
,stk.t_qall as StockReserve
,stk.t_qord as StockEnCommande
,stk.t_qcis as SortiesCumulees
,magart.t_sfst as StockSecurite
,magart.t_mioq as MinimumCommande
,magart.t_oqmf as IncrementCommande
,dbo.convertenum('td','B61C','a9','bull','ipu.pref',artacht.t_pref,'4') as Recommande
,artacht.t_otbp as TiersVendeur
,tiers.t_nama as NomTiersVendeur
,artacht.t_qimi as QuantiteCommandeMinimum
,(case nomenclature.TypeArticleFils
when 'Acheté'
	then artacht.t_qiec 
when 'Fabriqué' 
	then artcom.t_ecoq 
end) as SerieEconomique
,artacht.t_suti as DelaiAppro
,priach.t_sipp as PrixSimule4
,priach.t_cupp as Unite
,priach.t_ccur as Devise
,(case 
when nomenclature.UniteStock = priach.t_cupp or priach.t_cupp is null
	then 1
else
	isnull(faconv.t_conv, isnull((select faconvgen.t_conv from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_basu = nomenclature.UniteStock and faconvgen.t_unit = priach.t_cupp), (select (1 / faconvgen.t_conv) from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_basu = priach.t_cupp and faconvgen.t_unit = nomenclature.UniteStock))) 
end) as FacteurConversion
,(case (select top 1 lb.t_brty from ttdpcg031500 lb where lb.t_item = nomenclature.ArticleFils and lb.t_otbp = artacht.t_otbp and lb.t_prbk = 'LVM000001' and lb.t_efdt <= @dateapplic and (lb.t_exdt > @dateapplic or lb.t_exdt < '01/01/1980')) 
when 1 -- type de tranche Minimum, on choisit parmi les tranches inférieures à la série éco, la plus proche de la série éco en les classant par ordre décroissant
	then (select top 1 lb.t_bapr from ttdpcg031500 lb where lb.t_item = nomenclature.ArticleFils and lb.t_otbp = artacht.t_otbp and lb.t_prbk = 'LVM000001' and lb.t_efdt <= @dateapplic and (lb.t_exdt > @dateapplic or lb.t_exdt < '01/01/1980') and ((@serieachete = 'Oui' and lb.t_miqt <= @serie) or (@serieachete = 'Non' and lb.t_miqt <= artacht.t_qiec)) order by lb.t_miqt desc)
when 2 -- type de tranche Jusqu'à, on choisit parmi les tranches supérieures à la série éco, la plus proche de la série éco en les classant par ordre croissant
	then (select top 1 lb.t_bapr from ttdpcg031500 lb where lb.t_item = nomenclature.ArticleFils and lb.t_otbp = artacht.t_otbp and lb.t_prbk = 'LVM000001' and lb.t_efdt <= @dateapplic and (lb.t_exdt > @dateapplic or lb.t_exdt < '01/01/1980') and ((@serieachete = 'Oui' and lb.t_miqt >= @serie) or (@serieachete = 'Non' and lb.t_miqt >= artacht.t_qiec)) order by lb.t_miqt asc)
end) as PrixAchatParQuantiteBaremeGroupe2
,prreel.t_ltpr as DernierPrixAchat3
,achart.t_ccur as DeviseAchat
,achart.t_cupp as UniteAchat
,(case 
when nomenclature.UniteStock = achart.t_cupp or achart.t_cupp is null
	then 1
else
	isnull(faconv2.t_conv, isnull((select faconvgen.t_conv from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_basu = nomenclature.UniteStock and faconvgen.t_unit = achart.t_cupp), (select (1 / faconvgen.t_conv) from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_unit = nomenclature.UniteStock and faconvgen.t_basu = achart.t_cupp))) 
end) as FacteurConversion2
,prreel.t_ltpp as DateDerniereTransactionPrixAchat
,prreel.t_avpr as PrixAchatMoyen5
,prreel.t_purc as ReceptionAchatsCumules
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = nomenclature.ArticleFils and right(pmp.t_wvgr, 2) = @uechoisie and pmp.t_trdt <= getdate() order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PUMPActuel
,(select top 1 (select sum(pmpdet.t_mauc_1) from twhina137500 pmpdet where pmpdet.t_item = pmp.t_item and pmpdet.t_wvgr = pmp.t_wvgr and pmpdet.t_trdt = pmp.t_trdt and pmpdet.t_seqn = pmp.t_seqn) as PMP from twhina136500 pmp where pmp.t_item = nomenclature.ArticleFils and right(pmp.t_wvgr, 2) = @uechoisie and pmp.t_trdt <= @datepmp order by pmp.t_item,pmp.t_trdt desc, pmp.t_seqn desc) as PUMPADate
,cont.t_cono as ContratAchat
,cont.t_pono as PositionContratAchat
,prcont.t_prbk as BaremePrixContratAchat
,(case (select top 1 lb.t_brty from ttdpcg031500 lb where lb.t_item = nomenclature.ArticleFils and lb.t_prbk = prcont.t_prbk and lb.t_efdt <= @dateapplic and (lb.t_exdt > @dateapplic or lb.t_exdt < '01/01/1980')) 
when 1 -- type de tranche Minimum, on choisit parmi les tranches inférieures à la série éco, la plus proche de la série éco en les classant par ordre décroissant
	then (select top 1 lb.t_bapr from ttdpcg031500 lb where lb.t_item = nomenclature.ArticleFils and lb.t_prbk = prcont.t_prbk and lb.t_efdt <= @dateapplic and (lb.t_exdt > @dateapplic or lb.t_exdt < '01/01/1980') and ((@serieachete = 'Oui' and lb.t_miqt <= @serie) or (@serieachete = 'Non' and lb.t_miqt <= artacht.t_qiec)) order by lb.t_miqt desc)
when 2 -- type de tranche Jusqu'à, on choisit parmi les tranches supérieures à la série éco, la plus proche de la série éco en les classant par ordre croissant
	then (select top 1 lb.t_bapr from ttdpcg031500 lb where lb.t_item = nomenclature.ArticleFils and lb.t_prbk = prcont.t_prbk and lb.t_efdt <= @dateapplic and (lb.t_exdt > @dateapplic or lb.t_exdt < '01/01/1980') and ((@serieachete = 'Oui' and lb.t_miqt >= @serie) or (@serieachete = 'Non' and lb.t_miqt >= artacht.t_qiec)) order by lb.t_miqt asc)
end) as PrixAchatContrat1
,isnull((case 
when nomenclature.UniteStock = 
		(case (select top 1 lb3.t_brty from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = prcont.t_prbk and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980')) 
		when 1 -- type de tranche Minimum, on choisit parmi les tranches inférieures à la série éco, la plus proche de la série éco en les classant par ordre décroissant
			then (select top 1 lb3.t_prun from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = prcont.t_prbk and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980') and ((@serie != '' and lb3.t_miqt <= @serie) or (lb3.t_miqt <= artacht.t_qiec)) order by lb3.t_miqt desc)
		when 2 -- type de tranche Jusqu'à, on choisit parmi les tranches supérieures à la série éco, la plus proche de la série éco en les classant par ordre croissant
			then (select top 1 lb3.t_prun from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = prcont.t_prbk and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980') and ((@serie != '' and lb3.t_miqt >= @serie) or (lb3.t_miqt >= artacht.t_qiec)) order by lb3.t_miqt asc)
		end) 
		/*or (case (select top 1 lb3.t_brty from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = prcont.t_prbk and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980')) 
		when 1 -- type de tranche Minimum, on choisit parmi les tranches inférieures à la série éco, la plus proche de la série éco en les classant par ordre décroissant
			then (select top 1 lb3.t_prun from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = prcont.t_prbk and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980') and ((@serie != '' and lb3.t_miqt <= @serie) or (lb3.t_miqt <= artacht.t_qiec)) order by lb3.t_miqt desc)
		when 2 -- type de tranche Jusqu'à, on choisit parmi les tranches supérieures à la série éco, la plus proche de la série éco en les classant par ordre croissant
			then (select top 1 lb3.t_prun from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = prcont.t_prbk and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980') and ((@serie != '' and lb3.t_miqt >= @serie) or (lb3.t_miqt >= artacht.t_qiec)) order by lb3.t_miqt asc)
		end) is null -- Je ne sais plus pourquoi j'avais rajouté cette ligne, voir pour la remettre en cas d'erreurs signalées*/
	then 1
else
	isnull(faconvbar.t_conv, (select faconvgen.t_conv from ttcibd003500 faconvgen where faconvgen.t_item = '' and faconvgen.t_basu = nomenclature.UniteStock and faconvgen.t_unit = (case (select top 1 lb3.t_brty from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = 'LVM000001' and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980')) 
		when 1 -- type de tranche Minimum, on choisit parmi les tranches inférieures à la série éco, la plus proche de la série éco en les classant par ordre décroissant
			then (select top 1 lb3.t_prun from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = 'LVM000001' and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980') and ((@serie != '' and lb3.t_miqt <= @serie) or (lb3.t_miqt <= artacht.t_qiec)) order by lb3.t_miqt desc)
		when 2 -- type de tranche Jusqu'à, on choisit parmi les tranches supérieures à la série éco, la plus proche de la série éco en les classant par ordre croissant
			then (select top 1 lb3.t_prun from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = 'LVM000001' and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980') and ((@serie != '' and lb3.t_miqt >= @serie) or (lb3.t_miqt >= artacht.t_qiec)) order by lb3.t_miqt asc)
	end))) 
end), 1) as FacteurConversionBareme
,(select top 1 lb3.t_curn from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = 'LVM000001' and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980')) as DeviseBareme
,nomenclature.chemin
,nomenclature.tri
,nomenclature.tripere
,'=SI(BK2<>C2;"";SOMME.SI.ENS($BN$2:$BN$5000;$CM$2:$CM$5000;$CM2)+SI(BK2=C2;(J2/BY2+K2)*BX2/60;0))' as PrixNomenclature
,'=SI(ET($R2="Fabriqué";BN$1=$A2);SOMME.SI.ENS(BO$2:BO$5000;$BK$2:$BK$5000;$BJ2)*$Y2+$Y2*SIERREUR(($V2/$AM2+$W2)*$BX2/60;0);SI(ET($R2="Acheté";$S2="Oui";BN$1=$A2);(SOMME.SI.ENS(BO$2:BO$5000;$BK$2:$BK$5000;$BJ2)+$BL2)*$Y2;SI(ET($R2="Acheté";$A2=BN$1);$Y2*$BL2;"")))' as Niveau0
--On répète les formules sur Excel, ce n'est pas nécessaire de la réécrire dans chaque colonne
,'' as Niveau1
,'' as Niveau2
,'' as Niveau3
,'' as Niveau4
,'' as Niveau5
,'' as Niveau6
,'' as Niveau7
,'' as Niveau8
,'' as Niveau9
,artcompere.t_ecoq as QuantiteEcoPere
,'=SI(BK2<>C2;"";SOMME.SI.ENS($CA$2:$CA$5000;$C$2:$C$5000;CM$2)+SI(BK2=C2;(J2/BY2+K2)*BX2/60;0))' as CoutTotalMO
,'=SI(ET($R2="Fabriqué";DROITE(CA$1;1)=$A2);SOMME.SI.ENS(CB$2:CB$5000;$BK$2:$BK$5000;$BJ2)*$Y2+$Y2*SIERREUR(($V2/$AM2+$W2)*$BX2/60;0);SI(ET($R2="Acheté";$S2="Oui";DROITE(CA$1;1)=$A2);(SOMME.SI.ENS(CB$3:CB$5001;$BK$2:$BK$5000;$BJ2)*$Y2);""))' as Nivx0
,'' as Nivx1
,'' as Nivx2
,'' as Nivx3
,'' as Nivx4
,'' as Nivx5
,'' as Nivx6
,'' as Nivx7
,'' as Nivx8
,'' as Nivx9
,isnull(facach.t_rate, '1') as TauxChangeDeviseAchat
,isnull(facsim.t_rate, '1') as TauxChangeDeviseSimulee
,isnull(facbareme.t_rate, '1') as TauxChangeDeviseBareme
,left(nomenclature.tripere, charindex('_', nomenclature.tripere) - 1) as ArticlePerePere 
from nomenclature 
--Correction apportée par rbesnier le 09/10/2018 pour ne prendre que le source unique en 1er ou le préféré sinon
left outer join ttdipu010500 artacht on artacht.t_item = nomenclature.ArticleFils and ((artacht.t_pref = 2 and artacht.t_efdt < @dateapplic and artacht.t_exdt > @dateapplic) or (artacht.t_pref = 1 and artacht.t_otbp = (select top 1 a.t_otbp from ttdipu010500 a where a.t_item = nomenclature.ArticleFils and a.t_efdt < @dateapplic and a.t_exdt > @dateapplic and artacht.t_item not in (select artacht2.t_item from ttdipu010500 artacht2 where artacht2.t_item = artacht.t_item and artacht2.t_pref = 2) order by a.t_prio asc))) --Articles Achats Tiers
left outer join ttccom100500 tiers on tiers.t_bpid = artacht.t_otbp --Tiers
left outer join tticpr170500 priach on priach.t_item = nomenclature.ArticleFils and priach.t_cpcc = '001' --Prix d'Achats Simulés
left outer join tticpr007500 pr on pr.t_item = nomenclature.ArticleFils --Données Etablissements des Prix de Revients
left outer join tticpr007500 pr2 on pr2.t_item = nomenclature.ArticlePere --Données Etablissements des Prix de Revients Article Père
left outer join ttdipu100500 prreel on prreel.t_item = nomenclature.ArticleFils --Prix d'Achats Réels de l'Article
left outer join ttdipu001500 achart on achart.t_item = nomenclature.ArticleFils --Données d'Achat Article
left outer join twhwmd210500 magart on magart.t_item = nomenclature.ArticleFils and magart.t_cwar = nomenclature.Magasin --Magasin Données Articles
left outer join twhwmd215500 stk on stk.t_item = nomenclature.ArticleFils and stk.t_cwar = nomenclature.Magasin and left(stk.t_cwar, 2) = @uechoisie --Stock des Articles par Magasin
left outer join ttdpur301500 cont on cont.t_item = nomenclature.ArticleFils and cont.t_otbp = artacht.t_otbp and left(cont.t_cono, 2) = @uechoisie and (cont.t_sdat < @dateapplic or cont.t_sdat < '01/01/1980') and cont.t_edat > @dateapplic
--Rajout le 01/09/2017 par rbesnier car certaines lignes reviennent en double du fait que certains contrats n'aient pas de dates d'expiration
and cont.t_sdat = (select top 1 con.t_sdat from ttdpur301500 con where con.t_item = cont.t_item and con.t_otbp = cont.t_otbp and left(con.t_cono, 2) = @uechoisie and (con.t_sdat < @dateapplic or con.t_sdat < '01/01/1980') and con.t_edat > @dateapplic order by con.t_sdat desc) --Lignes de Contrats d'Achats
left outer join ttdpur303500 prcont on prcont.t_cono = cont.t_cono and prcont.t_pono = cont.t_pono and left(prcont.t_cono, 2) = @uechoisie --Prix de Contrats d'Achats
left outer join ttcibd003500 faconv on faconv.t_item = nomenclature.ArticleFils and faconv.t_basu = nomenclature.UniteStock and faconv.t_unit = priach.t_cupp --Facteur de Conversion 
left outer join ttcibd003500 faconv2 on faconv2.t_item = nomenclature.ArticleFils and faconv2.t_basu = nomenclature.UniteStock and faconv2.t_unit = achart.t_cupp --Facteur de Conversion 
left outer join ttcibd003500 faconvbar on faconvbar.t_item = nomenclature.ArticleFils and faconvbar.t_basu = nomenclature.UniteStock and faconvbar.t_unit = (case (select top 1 lb3.t_brty from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = 'LVM000001' and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980')) 
	when 1 -- type de tranche Minimum, on choisit parmi les tranches inférieures à la série éco, la plus proche de la série éco en les classant par ordre décroissant
		then (select top 1 lb3.t_prun from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = 'LVM000001' and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980') and ((@serie != '' and lb3.t_miqt <= @serie) or (lb3.t_miqt <= artacht.t_qiec)) order by lb3.t_miqt desc)
	when 2 -- type de tranche Jusqu'à, on choisit parmi les tranches supérieures à la série éco, la plus proche de la série éco en les classant par ordre croissant
		then (select top 1 lb3.t_prun from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = 'LVM000001' and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980') and ((@serie != '' and lb3.t_miqt >= @serie) or (lb3.t_miqt >= artacht.t_qiec)) order by lb3.t_miqt asc)
	end)  --Facteur de Conversion Bareme
left outer join ttcibd200500 artcom on artcom.t_item = nomenclature.ArticleFils --Articles Commandes
left outer join ttcibd200500 artcompere on artcompere.t_item = nomenclature.ArticlePere --Articles Commandes
left outer join ttirou101500 gampere on gampere.t_mitm = nomenclature.ArticlePere and gampere.t_opro = '     0' --Gammes par Article Père
left outer join ttirou101500 gam on gam.t_mitm = nomenclature.ArticleFils and gam.t_opro = '     0' --Gammes par Article Fils
left outer join ttcmcs008500 facach on facach.t_bcur = 'EUR' and facach.t_ccur = achart.t_ccur and facach.t_rtyp = 'INT' and facach.t_stdt = (select top 1 fa.t_stdt from ttcmcs008500 fa where fa.t_bcur = 'EUR' and fa.t_ccur = achart.t_ccur and fa.t_rtyp = 'INT' order by fa.t_stdt desc)
left outer join ttcmcs008500 facsim on facsim.t_bcur = 'EUR' and facsim.t_ccur = priach.t_ccur and facsim.t_rtyp = 'INT' and facsim.t_stdt = (select top 1 fs.t_stdt from ttcmcs008500 fs where fs.t_bcur = 'EUR' and fs.t_ccur = priach.t_ccur and fs.t_rtyp = 'INT' order by fs.t_stdt desc)
left outer join ttcmcs008500 facbareme on facbareme.t_bcur = 'EUR' and facbareme.t_ccur = (select top 1 lb3.t_curn from ttdpcg031500 lb3 where lb3.t_item = nomenclature.ArticleFils and lb3.t_prbk = 'LVM000001' and lb3.t_efdt <= @dateapplic and (lb3.t_exdt > @dateapplic or lb3.t_exdt < '01/01/1980')) and facbareme.t_rtyp = 'INT' and facbareme.t_stdt = (select top 1 fs.t_stdt from ttcmcs008500 fs where fs.t_bcur = 'EUR' and fs.t_ccur = priach.t_ccur and fs.t_rtyp = 'INT' order by fs.t_stdt desc)
order by nomenclature.tri asc