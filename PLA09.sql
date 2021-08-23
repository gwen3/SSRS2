SELECT a.*
,substring(a.t_item,10,37) AS [item]
,substring(a.t_item,1,9) AS [cprj]
,ttdsls400500.t_sotp AS [ttdsls400500 t_sotp]
,ttdsls400500.t_cofc AS [ttdsls400500 t_cofc]
,ttdsls400500.t_odat AS [ttdsls400500 t_odat]
,ttdsls400500.t_ofbp AS [ttdsls400500 t_ofbp]
,ttdsls400500.t_crep AS [ttdsls400500 t_crep]
,ttdsls400500.t_refa AS [ttdsls400500 t_refa]
,ttdsls400500.t_corn AS [ttdsls400500 t_corn]
,ttcibd001500.t_kitm AS [ttcibd001500 t_kitm]
,ttcibd001500.t_dsca AS [ttcibd001500 t_dsca]
,ttcibd001500.t_dfit AS [ttcibd001500 t_dfit]
,ttcemm112500.t_dicl AS [ttcemm112500 t_dicl]
,ttdsls411500.t_citg AS [ttdsls411500 t_citg]
,ttipcs030500.t_psta AS [ttipcs030500 t_psta]
,ttccom100500.t_nama AS [ttccom100500 t_nama]
,ttccom001500.t_nama AS [ttccom001500 t_nama]
,ttcmcs023500.t_dsca AS [ttcmcs023500 t_dsca]
, dbo.textnumtotext(a.t_txta,'4') AS 'Txta LOV'
,(CASE
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) 
			THEN (SELECT TOP 1 b.t_pdno FROM ttimfc010500 b WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND NOT EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) 
			THEN (SELECT TOP 1 c.t_pdno FROM ttisfc001500 c WHERE a.t_item = c.t_mitm)
WHEN (a.t_serl = ''  AND a.t_item <>@item_chassis) THEN (SELECT TOP 1 c.t_pdno FROM ttisfc001500 c WHERE a.t_item = c.t_mitm)
END) AS ORDRE_FABRICATION

,CASE 
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_prdt
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttimfc010500 b WHERE b.t_mitm = a.t_item and b.t_mser = a.t_serl))
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND NOT EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_prdt
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item))
WHEN (a.t_serl = '' AND a.t_item <> @item_chassis) THEN 
	(SELECT  c.t_prdt
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item)
		)
END AS OF_PRDT
,CASE 
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_pldt
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttimfc010500 b WHERE b.t_mitm = a.t_item and b.t_mser = a.t_serl))
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND NOT EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_pldt
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item))
WHEN (a.t_serl = '' AND a.t_item <> @item_chassis) THEN 
	(SELECT  c.t_pldt
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item)
		)
END AS OF_PLDT       
,CASE 
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_cmdt
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttimfc010500 b WHERE b.t_mitm = a.t_item and b.t_mser = a.t_serl))
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND NOT EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_cmdt
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item))	
WHEN (a.t_serl = '' AND a.t_item <> @item_chassis) THEN 
	(SELECT  c.t_cmdt
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item)
		)
END AS OF_CMDT 

,(CASE
WHEN (a.t_serl <> '' AND a.t_item =  @item_chassis) 
	THEN (SELECT dbo.convertlistcdf('wh','B61C','a9','grup','mar',e.t_cdf_marq,'4') FROM twhltc500500 e
		WHERE (a.t_item = e.t_item AND a.t_serl = e.t_serl AND a.t_cwar = e.t_cwar)) 
        ELSE (SELECT dbo.convertlistcdf('wh','B61C','a9','grup','mar',e.t_cdf_marq,'4') FROM twhltc500500 e
		WHERE (a.t_item = e.t_item AND a.t_serl = e.t_serl AND a.t_cwar = e.t_cwar))
END) AS MARQUE

,(CASE
WHEN (a.t_serl <> '' AND a.t_item =  @item_chassis) 
	THEN (SELECT e.t_rdat FROM twhltc500500 e
		WHERE (a.t_item = e.t_item AND a.t_serl = e.t_serl AND a.t_cwar = e.t_cwar)) 
END) AS ARRIVEE_CHASSIS

,(CASE
-- Gamme Standard
WHEN j.t_stor = 1 THEN 
	(SELECT sum ((h.t_sutm*h.t_most)/60 + (h.t_rutm*h.t_mopr)/60) FROM ttirou102500 h
		WHERE (h.t_mitm = '' AND h.t_opro = j.t_strc))
 -- Game Non Standard
WHEN j.t_stor = 2 THEN
	(SELECT sum ((h.t_sutm*h.t_most)/60 + (h.t_rutm*h.t_mopr)/60) FROM ttirou102500 h
		WHERE (a.t_item = h.t_mitm AND a.t_item <>@item_chassis AND ltrim(rtrim(h.t_opro)) = '0'))
-- Par défaut
ELSE
	0.0
END) AS TA_GLOBAL

, (SELECT TOP 1 ttdsls406500.t_dldt
	FROM ttdsls406500
	WHERE (a.t_orno = ttdsls406500.t_orno 
    			AND a.t_pono = ttdsls406500.t_pono 
    			AND a.t_sqnb = ttdsls406500.t_sqnb)
  ) AS  DATE_LIV

, (SELECT TOP 1 ttdsls406500.t_shpm
	FROM ttdsls406500
	WHERE (a.t_orno = ttdsls406500.t_orno 
    			AND a.t_pono = ttdsls406500.t_pono 
    			AND a.t_sqnb = ttdsls406500.t_sqnb)
  ) AS  SHPM

, (SELECT twhinh430500.t_pdat
	from twhinh430500
	where twhinh430500.t_shpm = (SELECT TOP 1 ttdsls406500.t_shpm
	FROM ttdsls406500
	WHERE (a.t_orno = ttdsls406500.t_orno 
    			AND a.t_pono = ttdsls406500.t_pono 
    			AND a.t_sqnb = ttdsls406500.t_sqnb)
  ) 
  )
  AS  BL_PDAT

,CASE 
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_sfpl
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttimfc010500 b WHERE b.t_mitm = a.t_item and b.t_mser = a.t_serl))
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND NOT EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_sfpl
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item))	
WHEN (a.t_serl = '' AND a.t_item <> @item_chassis) THEN 
	(SELECT  c.t_sfpl
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item)
		)
END AS PiloteAtelier  

,CASE 
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_osta
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttimfc010500 b WHERE b.t_mitm = a.t_item and b.t_mser = a.t_serl))
WHEN (a.t_serl <> '' AND a.t_item <> @item_chassis AND NOT EXISTS (SELECT b.t_pdno FROM ttimfc010500 b 
		WHERE (a.t_item = b.t_mitm AND a.t_serl = b.t_mser))) THEN 
   (SELECT  c.t_osta
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item))	
WHEN (a.t_serl = '' AND a.t_item <> @item_chassis) THEN 
	(SELECT  c.t_osta
	FROM ttisfc001500 c
	WHERE c.t_pdno = 
	(SELECT TOP 1 b.t_pdno FROM ttisfc001500 b WHERE b.t_mitm = a.t_item)
		)
END AS StatutOF  
	
FROM ttdsls401500 a 
INNER JOIN ttdsls400500         ON a.t_orno = ttdsls400500.t_orno
INNER JOIN ttcibd001500         ON ttcibd001500.t_item = a.t_item
LEFT OUTER JOIN ttcemm112500    ON (ttcemm112500.t_loco = 500 AND ttcemm112500.t_waid = a.t_cwar)  
INNER JOIN ttdsls411500         ON (a.t_orno = ttdsls411500.t_orno AND a.t_pono = ttdsls411500.t_pono AND a.t_sqnb = ttdsls411500.t_sqnb)
LEFT OUTER JOIN ttipcs030500    ON ttipcs030500.t_cprj = substring(a.t_item,1,9)
LEFT OUTER JOIN ttccom100500    ON  ttdsls400500.t_ofbp = ttccom100500.t_bpid
LEFT OUTER JOIN ttccom001500    ON ttdsls400500.t_crep = ttccom001500.t_emno
LEFT OUTER JOIN ttcmcs023500    ON ttcmcs023500.t_citg = ttdsls411500.t_citg
LEFT OUTER JOIN ttirou101500 j  ON j.t_mitm = a.t_item AND ltrim(rtrim(j.t_opro)) = '0' AND a.t_item <>@item_chassis
WHERE a.t_orno between @orno_f and @orno_t
AND a.t_clyn <> 1
AND	ttdsls400500.t_sotp between @sotp_f and @sotp_t
AND	ttdsls400500.t_cofc between @cofc_f and @cofc_t
AND	ttdsls400500.t_odat between @odat_f and @odat_t
AND	ttdsls411500.t_citg between @citg_f and @citg_t
AND (@facture=1 or (NOT EXISTS 
 (SELECT ttdsls406500.t_orno
	FROM ttdsls406500
	WHERE (a.t_orno = ttdsls406500.t_orno 
    			AND a.t_pono = ttdsls406500.t_pono 
    			AND a.t_sqnb = ttdsls406500.t_sqnb)
  )
  OR
  EXISTS 
 (SELECT ttdsls406500.t_orno
	FROM ttdsls406500
	WHERE (a.t_orno = ttdsls406500.t_orno 
    			AND a.t_pono = ttdsls406500.t_pono 
    			AND a.t_sqnb = ttdsls406500.t_sqnb)
  AND ttdsls406500.t_invn = 0
  )
  ))
AND (ttcibd001500.t_kitm = 1 OR ttcibd001500.t_kitm = 2 OR ttcibd001500.t_kitm = 3)