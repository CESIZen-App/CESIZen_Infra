-- Suppression des tables si elles existent (pour pouvoir relancer le script proprement)
DROP TABLE IF EXISTS configs_respiration;
DROP TABLE IF EXISTS exercices;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS informations;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

-- 1. Table des rôles
CREATE TABLE roles (
id SERIAL PRIMARY KEY,
libelle VARCHAR(50) NOT NULL
);

-- 2. Table des utilisateurs
CREATE TABLE users (
id SERIAL PRIMARY KEY,
nom VARCHAR(100),
email VARCHAR(150) UNIQUE NOT NULL,
password VARCHAR(500) NOT NULL,
role_id INT NOT NULL,
CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- 3. Table des exercices
CREATE TABLE exercices (
id SERIAL PRIMARY KEY,
titre VARCHAR(100) NOT NULL,
description TEXT,
is_public BOOLEAN DEFAULT FALSE,
createur_id INT NOT NULL,
CONSTRAINT fk_createur FOREIGN KEY (createur_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. Table des configurations
CREATE TABLE configs_respiration (
id SERIAL PRIMARY KEY,
exercice_id INT NOT NULL,
temps_inspire INT NOT NULL,
temps_expire INT NOT NULL,
temps_pause INT DEFAULT 0,
nombre_cycles INT NOT NULL,
CONSTRAINT fk_exercice FOREIGN KEY (exercice_id) REFERENCES exercices(id) ON DELETE CASCADE
);

-- 5. Table des pages d'information
CREATE TABLE informations (
id SERIAL PRIMARY KEY,
titre VARCHAR(200) NOT NULL,
contenu TEXT,
is_published BOOLEAN DEFAULT FALSE,
created_at TIMESTAMP NOT NULL DEFAULT NOW(),
updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE password_reset_tokens (
id SERIAL PRIMARY KEY,
user_id INT NOT NULL,
token VARCHAR(255) UNIQUE NOT NULL,
expires_at TIMESTAMP NOT NULL,
used BOOLEAN DEFAULT FALSE,
CONSTRAINT fk_user_reset FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

INSERT INTO roles (libelle) VALUES ('ADMIN'), ('USER');

-- Administrateur principal (hcaudron1@gmail.com / HHHuuuGGG@@@300605)
INSERT INTO users (nom, email, password, role_id)
VALUES (
    'Hugo Caudron',
    'hcaudron1@gmail.com',
    '35FF834C325CD96CD2D09E6AB83B912B1269BD3C136D0784C85D715152CF6467D5853D0626892B7369833E32C6804E979BDB057DBC26BDBC1B5C3DB90B993598:36D7E8693E678860023BABFBF9A50859553B506A3702BC77441F1E54DA590F1398FAED710EE70D5E26EEF6B2436CB699FD499037E3F89505774773D604CED01D',
    1
);

INSERT INTO exercices (titre, description, is_public, createur_id)
VALUES ('Respiration Carrée', 'Idéal pour le stress', true, 1);

INSERT INTO configs_respiration (exercice_id, temps_inspire, temps_expire, temps_pause, nombre_cycles)
VALUES (1, 4, 4, 4, 10);