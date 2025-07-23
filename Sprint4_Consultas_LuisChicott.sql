use business; 


-- Sprint 4, Nivel 1

/* Ejercicio 1
Realiza una subconsulta que muestre a todos los usuarios con más de 80 transacciones utilizando al menos 2 tablas. */ 

SELECT id, name, surname 
FROM users
WHERE id IN (SELECT user_id FROM transactions GROUP BY user_id HAVING COUNT(*) > 80); 

/* Ejercicio 2
Muestra la media de amount por IBAN de las tarjetas de crédito en la compañía Donec Ltd., utiliza por lo menos 2 tablas. */ 

SELECT c.iban, ROUND(AVG(amount), 2) as media 
FROM transactions t 
JOIN credit_cards c
ON t.card_id = c.id
WHERE business_id IN (SELECT company_id FROM companies WHERE company_name = 'Donec Ltd')
AND declined = 0
GROUP BY c.iban
ORDER BY media DESC;

-- Sprint 4, Nivel 2 
-- Ejercicio 1: ¿Cuántas tarjetas están activas?

SELECT COUNT(*) as cant_tarjetas_activas
FROM cards_status
WHERE active_card = 1; 


-- Sprint 4, Nivel 3 

-- Ejercicio 1: Necesitamos conocer el número de veces que se ha vendido cada producto.
        
SELECT product_id, COUNT(transaction_id) AS cantidad
FROM transactions_products
GROUP BY product_id
ORDER BY cantidad DESC;

















