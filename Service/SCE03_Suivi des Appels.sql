-----------------------------
-- SCE03 - Suivi des Appels
-----------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

select apl.t_ccll as NumeroAppel, 
apl.t_cllo as CodeOrigine, 
dbo.convertenum('ts','B61C','a9','bull','clm.cllo',apl.t_cllo,'4') as Origine, 
apl.t_stat as CodeStatut, 
dbo.convertenum('ts','B61C','a9','bull','clm.stat',apl.t_stat,'4') as Statut, 
apl.t_rpct as SignaleA, 
apl.t_cvtm as DureeCouverture, 
gar.t_optm as DateInstallation, 
gar.t_gwte as GarantieGenerique, 
gargen.t_nrpe as Periode, 
gargen.t_peru as UnitePeriode, 
(case 
when gargen.t_peru = 25 --Année
	then dateadd(day, (gargen.t_nrpe * 365), gar.t_optm) --On multiplie par 365
when gargen.t_peru = 20 --Trimestre
	then dateadd(day, (gargen.t_nrpe * 90), gar.t_optm) --On multiplie par 90
when gargen.t_peru = 15 --Mois
	then dateadd(day, (gargen.t_nrpe * 30), gar.t_optm) --On multiplie par 30
when gargen.t_peru = 10 --Semaine
	then dateadd(day, (gargen.t_nrpe * 7), gar.t_optm) --On multiplie par 7
when gargen.t_peru = 5 --Mois
	then dateadd(day, (gargen.t_nrpe * 1), gar.t_optm) --On multiplie par 1
end) as ExpirationConditionLe, 
'' as VehiculeSousGarantie, --Calcul fait sur SSRS pour comparer le champ ExpirationConditionLe (date) à la date du jour. Non si inférieur, oui sinon
apl.t_clna as NomCorrespondant, 
apl.t_telp as Telephone, 
apl.t_ofbp as TiersAcheteur, 
tiers.t_nama as NomTiersAcheteur, 
apl.t_emer as CodeUrgence, 
dbo.convertenum('tc','B61C','a9','bull','yesno',apl.t_emer,'4')	as Urgence, 
apl.t_encl as Kilometrage, 
left(apl.t_item, 9) as Projet, 
substring(apl.t_item, 10, len(apl.t_item)) as Article, 
art.t_dsca as DescriptionArticle, --Rajout
apl.t_sern as NumeroSerie, 
--Modification faite par rbesnier le 16/05/2019 pour ne plus aller dans la table Série Magasin qui ramenait parfois des lignes en double
--ser.t_ornv as CommandeClient, 
gar.t_srno as CommandeClient, 
apl.t_crtc as DelaiReponse, 
del.t_desc as DescriptionDelai, 
apl.t_rtct as HeureReaction, 
apl.t_svct as HeureFinResolutionAuPlusTard, 
apl.t_shpd as Description, 
dbo.textnumtotext(apl.t_txta,'4') as Commentaire, 
apl.t_rprl as ProblemeSignale, 
pb.t_desc as DescriptionProbleme, 
tiersach.t_cadr as CodeAdresseTiersAcheteur, 
adrta.t_nama as Adresse1, 
adrta.t_namb as Adresse2, 
concat(adrta.t_hono, adrta.t_namc) as Adresse3, 
adrta.t_namd as Adresse4, 
concat(adrta.t_pstc, adrta.t_ccit) as Ville, 
adrta.t_ccty as CodePays, 
paysta.t_dsca as Pays, 
apl.t_emno as IngenieurSupport, 
empi.t_nama as NomIngenieurSupport, 
apl.t_cxsc as DepartementServiceReparation, 
dpt.t_dsca as TypeDepartement, 
apl.t_oemn as Technicien, 
empt.t_nama as NomTechnicien, 
apl.t_rsvo as OrdreServiceAssocie, 
apl.t_ofad as CodeAdresseEmplacement, 
adremp.t_nama as Adresse1Emplacement, 
adremp.t_namb as Adresse2Emplacement, 
concat(adremp.t_hono, adremp.t_namc) as Adresse3Emplacement, 
adremp.t_namd as Adresse4Emplacement, 
concat(adremp.t_pstc, adremp.t_ccit) as VilleEmplacement, 
adremp.t_ccty as CodePaysEmplacement, 
paysemp.t_dsca as PaysEmplacement, 
apl.t_cctp as TypeCouverture, 
couv.t_desc as DescriptionCouverture, 
apl.t_fcll as AppelAssocie, 
txt.t_user as CommentairePar, 
txt.t_ludt as DateCommentaire, 
dbo.textnumtotext(apl.t_txtk,'4') as DernierCommentaire, 
dbo.textnumtotext(apl.t_txte,'4') as TexteResolution, 
apl.t_actt as PrestationRealisee, 
presta.t_desc as DescriptionPrestation, 
apl.t_ustm as DureeUtilisation, 
apl.t_adtm as TempsArret, 
apl.t_wait as EnAttente, 
apl.t_user as Agent, --Rajout
empa.t_nama as NomAgent, --Rajout
apl.t_slct as DateCloture, --Rajout le 09/02/2018 suite à la demande de Cédric Fazilleau. Correspond à l'Heure de résolution de l'appel
--rajout par rbesnier le 10/04/2018 suite à la demande de Matthieu Dagorne et Christophe Jan
apl.t_expr as CodeProblemeAttendu, 
pbatt.t_desc as ProblemeAttendu, 
apl.t_exsl as CodeSolutionPrevue, 
solprev.t_desc as SolutionPrevue, 
apl.t_espr as CodeProblemeReel, 
pbreel.t_desc as ProblemeReel, 
apl.t_sltn as CodeSolutionReelle, 
solreel.t_desc as SolutionReelle, 
--rajout par rbesnier le 23/01/2019
apl.t_shdp as DetailsResolutionDescription 
from ttsclm100500 apl --Appels
left outer join ttccom100500 tiers on tiers.t_bpid = apl.t_ofbp --Tiers
left outer join ttccom110500 tiersach on tiersach.t_ofbp = apl.t_ofbp --Tiers Acheteur
--Modification faite par rbesnier le 16/05/2019 pour ne plus aller dans la table Série Magasin qui ramenait parfois des lignes en double
--left outer join twhltc500500 ser on ser.t_item = apl.t_item and ser.t_serl = apl.t_sern --Numero de Serie par Magasin
left outer join ttccom001500 empi on empi.t_emno = apl.t_emno --Employés - Ingenieur Support
left outer join ttccom001500 empt on empt.t_emno = apl.t_oemn --Employés - Technicien
left outer join ttccom001500 empa on empa.t_emno = apl.t_user --Employés - Technicien
left outer join ttscfg200500 gar on gar.t_item = apl.t_item and gar.t_sern = apl.t_sern --Articles Sérialisés
left outer join ttcmcs065500 dpt on dpt.t_cwoc = apl.t_cxsc --Départements
left outer join ttsctm500500 gargen on gargen.t_gwte = gar.t_gwte --Garanties Génériques
left outer join ttsclm330500 pb on pb.t_cprl = apl.t_rprl --Problèmes
left outer join ttccom130500 adrta on adrta.t_cadr = tiersach.t_cadr --Adresses Tiers Acheteur
left outer join ttcmcs010500 paysta on paysta.t_ccty = adrta.t_ccty --Pays Tiers Acheteur
left outer join ttccom130500 adremp on adremp.t_cadr = apl.t_ofad --Adresses
left outer join ttcmcs010500 paysemp on paysemp.t_ccty = adremp.t_ccty --Pays
left outer join ttsacm101500 presta on presta.t_cact = apl.t_actt --Prestations de Référence
left outer join ttsclm020500 del on del.t_crtc = apl.t_crtc --Délais de Réponses
left outer join ttsmdm035500 couv on couv.t_cctp = apl.t_cctp --Type de Couverture
left outer join ttttxt002500 txt on txt.t_ctxt = apl.t_txtk --Textes du Dernier Commentaires
left outer join ttcibd001500 art on art.t_item = apl.t_item --Article
--rajout par rbesnier le 10/04/2018 suite à la demande de Matthieu Dagorne et Christophe Jan
left outer join ttsclm330500 pbatt on pbatt.t_cprl = apl.t_expr --Problème Attendu
left outer join ttsclm335500 solprev on solprev.t_cstn = apl.t_exsl --Solution Prévue
left outer join ttsclm330500 pbreel on pbreel.t_cprl = apl.t_espr --Problème Réel
left outer join ttsclm335500 solreel on solreel.t_cstn = apl.t_sltn --Solution Réelle
where apl.t_rpct between @date_f and @date_t --Bornage sur la Date d'Appel
and apl.t_ccll between @appel_f and @appel_t --Bornage sur le Numéro d'Appel
and apl.t_stat between @stat_f and @stat_t --Bornage sur le Statut
and apl.t_cvtm between @couv_f and @couv_t --Bornage sur la Durée de Couverture
and left(apl.t_ccll, 2) between @ue_f and @ue_t --Bornage sur l'UE défini par le Numéro d'Appel