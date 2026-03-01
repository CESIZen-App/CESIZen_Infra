-- Suppression des tables si elles existent (pour pouvoir relancer le script proprement)
DROP TABLE IF EXISTS configs_respiration;
DROP TABLE IF EXISTS exercices;
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
password VARCHAR(255) NOT NULL,
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

INSERT INTO roles (libelle) VALUES ('ADMIN'), ('USER');

-- Mdp exemple: 'password123' (à hasher plus tard dans ton API)
INSERT INTO users (nom, email, password, role_id)
VALUES ('Admin Zen', 'admin@cesizen.fr', 'hash_admin', 1);

INSERT INTO exercices (titre, description, is_public, createur_id)
VALUES ('Respiration Carrée', 'Idéal pour le stress', true, 1);

INSERT INTO configs_respiration (exercice_id, temps_inspire, temps_expire, temps_pause, nombre_cycles)
VALUES (1, 4, 4, 4, 10);