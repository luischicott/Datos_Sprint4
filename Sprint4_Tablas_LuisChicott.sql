   -- Sprint 4, Nivel 1
   /* Descarga los archivos CSV, estudiales y diseña una base de datos con un esquema de estrella que contenga,
   al menos 4 tablas de las que puedas realizar las siguientes consultas */ 
    
    -- Creación de base de datos 'business'
    CREATE DATABASE IF NOT EXISTS business;
    USE business;
    
    -- Creación de la tabla 'companies' 
    CREATE TABLE IF NOT EXISTS companies (
        company_id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );
    
    -- Cargar los datos de la tabla 'companies'
    
LOAD DATA INFILE '/Users/luischicott/Documents/Especialización Datos/Bases de datos/DB Sprint 4/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

    
    -- Creación de la tabla 'users'
    CREATE TABLE IF NOT EXISTS users (
		id INT PRIMARY KEY,
		name VARCHAR(100),
		surname VARCHAR(100),
		phone VARCHAR(150),
		email VARCHAR(150),
		birth_date VARCHAR(100),
		country VARCHAR(150),
		city VARCHAR(150),
		postal_code VARCHAR(100),
		address VARCHAR(255)    
);
    
	-- Cargar los datos de la tabla 'users'. Cargaré 2 archivos csv uno con usuarios europeos y otro con usuarios americanos. 
    
    -- Datos de los usuarios europeos
LOAD DATA LOCAL INFILE '/Users/luischicott/Documents/Especialización Datos/Bases de datos/DB Sprint 4/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Datos de los usuarios americanos

LOAD DATA LOCAL INFILE '/Users/luischicott/Documents/Especialización Datos/Bases de datos/DB Sprint 4/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
    
-- Creación de la tabla 'credit_cards'
CREATE TABLE IF NOT EXISTS credit_cards (
    id VARCHAR(20),
    user_id INT,
    iban VARCHAR(50),
    pan VARCHAR(50),
    pin VARCHAR(4),
    cvv INT,
    track1 VARCHAR(100),
    track2 VARCHAR(100),
    expiring_date VARCHAR(25),
    PRIMARY KEY(id)
);

-- Cargar datos de la tabla 'creditcards'
LOAD DATA LOCAL INFILE '/Users/luischicott/Documents/Especialización Datos/Bases de datos/DB Sprint 4/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Creación de la tabla transactions
    CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(255) PRIMARY KEY,
    card_id VARCHAR(20) REFERENCES credit_cards(id),
    business_id VARCHAR(20) REFERENCES companies(company_id),
    timestamp TIMESTAMP,
    amount DECIMAL(10, 2),
    declined BOOLEAN,
    product_ids VARCHAR(100),
    user_id INT REFERENCES users(id),
    lat FLOAT,
    longitude FLOAT
);

-- Cargar datos de la tabla 'transactions'. Datos separados por ';'
LOAD DATA LOCAL INFILE '/Users/luischicott/Documents/Especialización Datos/Bases de datos/DB Sprint 4/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- Sprint 4, Nivel 2
/* Crea una nueva tabla que refleje el estado de las tarjetas de crédito basado en si las últimas tres transacciones 
fueron declinadas */


-- Creación de la tabla 'cards_status' y en ingresar los datos que resulten de esta consulta 

CREATE TABLE IF NOT EXISTS cards_status AS (
WITH UltimasTransacciones AS (
    SELECT
        timestamp,
        card_id,
        declined,
        ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS rank_transacciones
    FROM
        transactions
), EstadoTarjetas AS (
    SELECT
        card_id,
        SUM(CASE WHEN declined = TRUE THEN 1 ELSE 0 END) AS transacciones_declinadas,
        COUNT(*) AS total_ultimas_transacciones
    FROM
        UltimasTransacciones
    WHERE
        rank_transacciones <= 3
    GROUP BY
        card_id
)
SELECT
    e.card_id AS card_id,
    CASE
        WHEN e.transacciones_declinadas = 3 AND e.total_ultimas_transacciones = 3 THEN FALSE
        ELSE TRUE
    END AS active_card
FROM
    EstadoTarjetas e
);



-- Sprint 4, Nivel 3
/* Crea una tabla con la que podamos unir los datos del nuevo archivo products.csv con la base de datos creada, 
teniendo en cuenta que desde transaction tienes product_ids. Genera la siguiente consulta:*/ 


-- Creación de la tabla 'products'
    CREATE TABLE IF NOT EXISTS products (
        id INT PRIMARY KEY,
        product_name VARCHAR(255),
		price VARCHAR(20),
        colour VARCHAR(100),
        weight VARCHAR(100),
        warehouse_id VARCHAR(15)
    );
    
	-- Cargar los datos de la tabla 'products'
    
LOAD DATA LOCAL INFILE '/Users/luischicott/Documents/Especialización Datos/Bases de datos/DB Sprint 4/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; 

-- Creación de la tabla 'transactions_products'. 

CREATE TABLE IF NOT EXISTS transactions_products AS(
SELECT  transactions.id AS transaction_id, products.id AS product_id
	FROM transactions
	JOIN products
	ON   FIND_IN_SET((products.id),
	REPLACE(transactions.product_ids, ' ', '')) > 0
    );



    