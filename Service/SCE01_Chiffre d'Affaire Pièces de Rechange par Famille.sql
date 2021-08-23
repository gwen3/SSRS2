-------------------------------------------------------------
-- SCE01 - Chiffre d'Affaire Pieces de Rechange par Famille
-------------------------------------------------------------

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT LigneFacture.t_sfcp AS 'SocFinance',
-- Suivant le cas d'origine, Matière, Main d'oeuvre ou autre
-- La famille est égal qu deux premiers caractères de la prestation de référence
(CASE LigneFacture.t_invt
WHEN 10 THEN (SELECT substring(Presta.t_crac,1,2)
			FROM 	ttssoc220500 Mat
			INNER JOIN ttssoc210500 Presta ON Presta.t_orno = Mat.t_orno AND Presta.t_acln = Mat.t_acln
			WHERE 	Mat.t_orno = LigneFacture.t_orno
			AND 	Mat.t_lino = LigneFacture.t_pono)
WHEN 11 THEN (SELECT substring(Presta.t_crac,1,2)
			FROM 	ttssoc230500 Moe
			INNER JOIN ttssoc210500 Presta ON Presta.t_orno = Moe.t_orno AND Presta.t_acln = Moe.t_acln
			WHERE 	Moe.t_orno = LigneFacture.t_orno
			AND 	Moe.t_lino = LigneFacture.t_pono)
WHEN 24 THEN (SELECT Substring(Presta.t_crac,1,2)
			FROM 	ttssoc240500 Autre
			INNER JOIN ttssoc210500 Presta ON Presta.t_orno = Autre.t_orno AND Presta.t_acln = Autre.t_acln
			WHERE 	Autre.t_orno = LigneFacture.t_orno
			AND 	Autre.t_lino = LigneFacture.t_pono)
WHEN 50 THEN (SELECT Substring(Presta.t_crac,1,2)
			FROM ttssoc210500 Presta
			WHERE Presta.t_orno = LigneFacture.t_orno
			AND Presta.t_acln = CAST(Substring(LigneFacture.t_borf,1,Charindex('/',LigneFacture.t_borf)-1) AS INT))
END
) AS 'ReferencePresta',
(CASE LigneFacture.t_invt
WHEN 10 THEN (SELECT PrestaRef.t_desc
			FROM 	ttssoc220500 Mat
			INNER JOIN ttssoc210500 Presta ON Presta.t_orno = Mat.t_orno AND Presta.t_acln = Mat.t_acln
			INNER JOIN ttsacm101500 PrestaRef ON PrestaRef.t_cact = Presta.t_crac
			WHERE 	Mat.t_orno = LigneFacture.t_orno
			AND 	Mat.t_lino = LigneFacture.t_pono)
WHEN 11 THEN (SELECT PrestaRef.t_desc
			FROM 	ttssoc230500 Moe
			INNER JOIN ttssoc210500 Presta ON Presta.t_orno = Moe.t_orno AND Presta.t_acln = Moe.t_acln
			INNER JOIN ttsacm101500 PrestaRef ON PrestaRef.t_cact = Presta.t_crac
			WHERE 	Moe.t_orno = LigneFacture.t_orno
			AND 	Moe.t_lino = LigneFacture.t_pono)
WHEN 24 THEN (SELECT PrestaRef.t_desc
			FROM 	ttssoc240500 Autre
			INNER JOIN ttssoc210500 Presta ON Presta.t_orno = Autre.t_orno AND Presta.t_acln = Autre.t_acln
			INNER JOIN ttsacm101500 PrestaRef ON PrestaRef.t_cact = Presta.t_crac
			WHERE 	Autre.t_orno = LigneFacture.t_orno
			AND 	Autre.t_lino = LigneFacture.t_pono)
WHEN 50 THEN (SELECT PrestaRef.t_desc
			FROM ttssoc210500 Presta
			INNER JOIN ttsacm101500 PrestaRef ON PrestaRef.t_cact = Presta.t_crac
			WHERE Presta.t_orno = LigneFacture.t_orno
			AND Presta.t_acln = CAST(Substring(LigneFacture.t_borf,1,Charindex('/',LigneFacture.t_borf)-1) AS INT))
END
) AS 'PrestaDesc', 
LigneFacture.t_amth_1 AS 'MontantEur',
EnteteFacture.t_doct AS 'TypeDocument',
dbo.convertenum('ci','B61C','a9','bull','sli.doct',EnteteFacture.t_doct,'4') AS 'DescTypeDoct',
EnteteFacture.t_idat AS 'DateFacture',
EntiteCle.t_grid AS 'UniteEntreprise'
FROM tcisli310500 LigneFacture
INNER JOIN tcisli305500 EnteteFacture ON EnteteFacture.t_sfcp = LigneFacture.t_sfcp 
AND EnteteFacture.t_tran = LigneFacture.t_tran
AND EnteteFacture.t_idoc = LigneFacture.t_idoc
INNER JOIN ttssoc200500 OrdreService ON OrdreService.t_orno = LigneFacture.t_orno
INNER JOIN ttcemm110500 EntiteCle ON EntiteCle.t_enty = 3 AND EntiteCle.t_loco = 500 AND EntiteCle.t_enid = OrdreService.t_cwoc
WHERE LigneFacture.t_srtp = 60
AND EXISTS(SELECT PrestaRef.t_desc
	FROM ttssoc210500 Presta
	INNER JOIN ttsacm101500 PrestaRef ON PrestaRef.t_cact = Presta.t_crac
	WHERE Presta.t_orno = LigneFacture.t_orno)
-- #DM 20161124: il nous faut tous les types de services (PR,QUA,SAV,REV) dans les prestations de reference
-- #DM 20161124: AND PrestaRef.t_cctp = 'PR')
and LigneFacture.t_sfcp between @sfcp_f and @sfcp_t
and LigneFacture.t_orno between @orno_f and @orno_t
and EnteteFacture.t_idat between @date_f and @date_t
and EntiteCle.t_grid between @grid_f and @grid_t
and left(LigneFacture.t_orno, 2) between @ue_f and @ue_t