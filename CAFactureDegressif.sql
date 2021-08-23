--CA Facturé Dégressif

select a.t_otbp AS 'Tiersvendeur', 
	(SELECT sum(t_amth_1)
	from
	(select sum(d.t_amth_1) AS t_amth_1
	from ttfacp200500 d
	where d.t_docd >= @docd_f and d.t_docd <= @docd_t
	and d.t_otbp = a.t_otbp
	and d.t_tpay in (1,4)
	UNION
	select sum(d.t_amth_1) AS t_amth_1
	from ttfacp200400 d
	where d.t_docd >= @docd_f and d.t_docd <= @docd_t
	and d.t_otbp = a.t_otbp
	and d.t_tpay in (1,4)) AS TEMP) AS 'Montant',
	(SELECT sum(t_vath_1)
	from
	(select sum(d.t_vath_1) AS t_vath_1
	from ttfacp200500 d
	where d.t_docd >= @docd_f and d.t_docd <= @docd_t
	and d.t_otbp = a.t_otbp
	and d.t_tpay in (1,4)
	UNION
	select sum(d.t_vath_1) AS t_vath_1
	from ttfacp200400 d
	where d.t_docd >= @docd_f and d.t_docd <= @docd_t
	and d.t_otbp = a.t_otbp
	and d.t_tpay in (1,4)) AS TEMP) AS 'TotalTVA',
	b.t_nama as 'NomTiersVendeur',
	c.t_namc as 'AdresseTiersVendeur',
	c.t_pstc as 'CPTiersVendeur',
	c.t_ccty as 'PaysTiersVendeur',
	a.t_ccon as 'AcheteurTiersVendeur',
	a.t_cdec as 'LivTiesVendeur',
	d.t_dats as 'FAMACHA',
	e.t_dats as 'SFAMACH',
	f.t_dats as 'SEGMENP',
	b.t_seak as 'Recherche',
	b.t_prst as 'Statut'
	--dbo.convertenum('tc','B61C','a9','bull','tccom.prst',b.t_prst,'4') as 'Statut'
from ttccom120500 a 
INNER JOIN ttccom100500 b on b.t_bpid = a.t_otbp
LEFT  JOIN ttccom130500 c on c.t_cadr = a.t_cadr
LEFT  JOIN ttdsmi101500 d on d.t_bpid = a.t_otbp and d.t_role = 7 and d.t_sern = 1
LEFT  JOIN ttdsmi101500 e on e.t_bpid = a.t_otbp and e.t_role = 7 and e.t_sern = 2
LEFT  JOIN ttdsmi101500 f on f.t_bpid = a.t_otbp and f.t_role = 7 and f.t_sern = 3
--where a.t_otbp >= @otbp_f and a.t_otbp <= @otbp_t
and exists( 	select d.t_otbp 
		from ttfacp200500 d
		where d.t_docd >= @docd_f and d.t_docd <= @docd_t
		and d.t_otbp = a.t_otbp
		and d.t_tpay in (1,4)
		union all
		select d.t_otbp 
		from ttfacp200400 d
		where d.t_docd >= @docd_f and d.t_docd <= @docd_t
		and d.t_otbp = a.t_otbp
		and d.t_tpay in (1,4))
order by a.t_otbp