insert into currency values (100, 'EUR', 0.85, '2022-01-01 13:29');
insert into currency values (100, 'EUR', 0.79, '2022-01-08 13:29');

SELECT 
    COALESCE(u.name, 'not defined') AS name,
    COALESCE(u.lastname, 'not defined') AS lastname,
    c.name AS currency_name,
    b.money * COALESCE(
        (
            SELECT rate_to_usd 
            FROM Currency 
            WHERE ID = b.currency_id AND updated <= b.updated 
            ORDER BY updated DESC 
            LIMIT 1
        ),
        (
            SELECT rate_to_usd 
            FROM Currency 
            WHERE ID = b.currency_id AND updated > b.updated 
            ORDER BY updated 
            LIMIT 1
        ),
        1
    ) AS currency_in_usd
FROM 
    public.user u
RIGHT JOIN 
    Balance b ON u.ID = b.user_id
LEFT JOIN 
    Currency c ON b.currency_id = c.ID
	WHERE c.name IS NOT NULL
GROUP BY 
    u.name, u.lastname, c.name, b.money, b.updated, b.currency_id
ORDER BY 
    name DESC, lastname, currency_name;
