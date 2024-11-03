WITH cur AS 
(
	SELECT id, MAX(updated) AS last_update
	FROM currency
	GROUP BY id
),
user_balance AS
(
	SELECT COALESCE(usr.name, 'not defined') AS name, COALESCE(usr.lastname, 'not defined') AS lastname, 
		balance.type,
		SUM(balance.money) AS volume,
		balance.currency_id
	FROM "user" usr
	FULL JOIN balance ON balance.user_id = usr.id
	GROUP BY usr.name, usr.lastname, balance.type, balance.currency_id
)

SELECT ub.name, ub.lastname, ub.type, ub.volume, 
	COALESCE(currency.name, 'not defined') AS currency_name, 
	COALESCE(currency.rate_to_usd, 1) AS last_rate_to_usd,
	COALESCE(ub.volume * currency.rate_to_usd, ub.volume) AS total_volume_in_usd
FROM user_balance AS ub
LEFT JOIN cur ON cur.id = ub.currency_id
LEFT JOIN currency ON currency.id = cur.id 
	AND currency.updated = cur.last_update
ORDER BY ub.name DESC, ub.lastname ASC, ub.type ASC;