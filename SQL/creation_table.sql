-- ============================================================
-- Script de création de la base de données CESIZen (PostgreSQL)
-- Ordre de suppression inverse des dépendances FK pour éviter
-- les erreurs de contrainte lors d'une réexécution.
-- ============================================================

-- Suppression des tables si elles existent (pour pouvoir relancer le script proprement)
DROP TABLE IF EXISTS configs_respiration;
DROP TABLE IF EXISTS exercices;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS informations;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

-- ============================================================
-- STRUCTURE DES TABLES
-- ============================================================

-- 1. Table des rôles
-- Contient les deux rôles applicatifs : ADMIN (id=1) et USER (id=2)
CREATE TABLE roles
(
    id      SERIAL PRIMARY KEY,
    libelle VARCHAR(50) NOT NULL
);

-- 2. Table des utilisateurs
-- Le mot de passe est stocké au format "hash_hex:sel_hex" (PBKDF2-SHA512, 350 000 itérations)
-- L'email est unique pour éviter les doublons de comptes
CREATE TABLE users
(
    id       SERIAL PRIMARY KEY,
    nom      VARCHAR(100),
    email    VARCHAR(150) UNIQUE NOT NULL,
    password VARCHAR(500)        NOT NULL,   -- format : hash_hex:sel_hex
    role_id  INT                 NOT NULL,
    CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES roles (id)
);

-- 3. Table des exercices de respiration
-- ON DELETE CASCADE : si un utilisateur est supprimé, ses exercices le sont aussi
CREATE TABLE exercices
(
    id          SERIAL PRIMARY KEY,
    titre       VARCHAR(100) NOT NULL,
    description TEXT,
    is_public   BOOLEAN DEFAULT FALSE,  -- false = exercice privé (visible uniquement par le créateur)
    createur_id INT          NOT NULL,
    CONSTRAINT fk_createur FOREIGN KEY (createur_id) REFERENCES users (id) ON DELETE CASCADE
);

-- 4. Table des configurations de respiration
-- Chaque configuration appartient à un exercice et définit les durées en secondes
-- ON DELETE CASCADE : si l'exercice est supprimé, ses configurations le sont aussi
CREATE TABLE configs_respiration
(
    id            SERIAL PRIMARY KEY,
    exercice_id   INT NOT NULL,
    temps_inspire INT NOT NULL,          -- durée d'inspiration en secondes
    temps_expire  INT NOT NULL,          -- durée d'expiration en secondes
    temps_pause   INT DEFAULT 0,         -- durée de pause (apnée) en secondes, 0 = pas de pause
    nombre_cycles INT NOT NULL,
    CONSTRAINT fk_exercice FOREIGN KEY (exercice_id) REFERENCES exercices (id) ON DELETE CASCADE
);

-- 5. Table des pages d'information (contenu éditorial)
-- TIMESTAMP WITHOUT TIME ZONE : compatible avec Npgsql 6+ (pas de Kind=UTC)
-- is_published = false → brouillon visible uniquement par les administrateurs
CREATE TABLE informations
(
    id           SERIAL PRIMARY KEY,
    titre        VARCHAR(200) NOT NULL,
    contenu      TEXT,
    is_published BOOLEAN               DEFAULT FALSE,
    created_at   TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- 6. Table des tokens de réinitialisation de mot de passe
-- Le token est un hex de 32 octets (64 caractères), unique et à usage unique (used = true après consommation)
-- expires_at : expiration après 1 heure (défini dans UserService.ForgotPasswordAsync)
-- ON DELETE CASCADE : si l'utilisateur est supprimé, ses tokens le sont aussi
CREATE TABLE password_reset_tokens
(
    id         SERIAL PRIMARY KEY,
    user_id    INT                 NOT NULL,
    token      VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP           NOT NULL,
    used       BOOLEAN DEFAULT FALSE,        -- true après utilisation pour éviter la réutilisation
    CONSTRAINT fk_user_reset FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

-- ============================================================
-- DONNÉES DE BASE
-- ============================================================

-- Insertion des deux rôles applicatifs (id=1 → ADMIN, id=2 → USER)
INSERT INTO roles (libelle)
VALUES ('ADMIN'),
       ('USER');

-- Administrateur principal
-- Mot de passe haché avec PBKDF2-SHA512 (format hash_hex:sel_hex)
-- Mot de passe en clair du compte de démonstration : voir README.md à la racine du workspace
INSERT INTO users (nom, email, password, role_id)
VALUES ('Hugo Caudron',
        'hcaudron1@gmail.com',
        '4A878B447151F887C79254D229432141C77B14C9AAC1EAF903EE28D77F8F52B74FD43808276071357C5E4E0455C01C82F90B0498D69DDC9D0E7005B61D34BAA5:2F03E40D491DC58F4CE1C0DD1FD657757A9D79C8BE896A02548A4D5C5081C7512E0F8F884936366DB26A60706C0AFF13792C170418CF5AAA825F314738F6513A',
        1);

-- ============================================================
-- EXERCICES DE RESPIRATION (4 au total)
-- ============================================================

-- Exercice 1 : Respiration Carrée (4-4-4-4)
-- Technique utilisée par les forces spéciales américaines (Navy SEALs)
INSERT INTO exercices (titre, description, is_public, createur_id)
VALUES ('Respiration Carrée',
        'Idéal pour réduire le stress et retrouver un état de calme. Technique utilisée par les forces spéciales américaines pour gérer la pression.',
        true, 1);

INSERT INTO configs_respiration (exercice_id, temps_inspire, temps_expire, temps_pause, nombre_cycles)
VALUES (1, 4, 4, 4, 10);

-- Exercice 2 : Cohérence Cardiaque (5-5)
-- 6 cycles/min × 3 séances/jour = protocole standard de cohérence cardiaque
INSERT INTO exercices (titre, description, is_public, createur_id)
VALUES ('Cohérence Cardiaque',
        'Technique de référence pour réguler le système nerveux autonome. Pratiquer 3 fois par jour pendant 5 minutes pour des effets durables sur le stress et l''anxiété.',
        true, 1);

INSERT INTO configs_respiration (exercice_id, temps_inspire, temps_expire, temps_pause, nombre_cycles)
VALUES (2, 5, 5, 0, 18);

-- Exercice 3 : Respiration 4-7-8
-- Technique du Dr Andrew Weil — favorise l'endormissement
INSERT INTO exercices (titre, description, is_public, createur_id)
VALUES ('Respiration 4-7-8',
        'Technique du Dr Andrew Weil favorisant l''endormissement et la réduction de l''anxiété. La rétention prolongée permet une oxygénation profonde et un relâchement du système nerveux.',
        true, 1);

INSERT INTO configs_respiration (exercice_id, temps_inspire, temps_expire, temps_pause, nombre_cycles)
VALUES (3, 4, 8, 7, 8);

-- Exercice 4 : Respiration Abdominale Profonde (6-2-6)
-- Exercice de base, recommandé aux débutants
INSERT INTO exercices (titre, description, is_public, createur_id)
VALUES ('Respiration Abdominale Profonde',
        'Exercice fondamental pour apprendre à respirer correctement. Idéal pour les débutants souhaitant améliorer leur capacité pulmonaire et réduire les tensions musculaires.',
        true, 1);

INSERT INTO configs_respiration (exercice_id, temps_inspire, temps_expire, temps_pause, nombre_cycles)
VALUES (4, 6, 6, 2, 12);

-- ============================================================
-- PAGES D'INFORMATION (10 articles)
-- ============================================================

INSERT INTO informations (titre, contenu, is_published)
VALUES ('Bienvenue sur l''application de respiration',
        'Bienvenue ! Cette application vous accompagne dans la pratique d''exercices de respiration guidée. Que vous souhaitiez réduire votre stress, améliorer votre sommeil ou simplement prendre soin de vous, vous trouverez ici des techniques adaptées à tous les niveaux. Commencez par explorer les exercices disponibles et pratiquez régulièrement pour en ressentir tous les bienfaits.',
        true),
       ('Les bienfaits de la respiration consciente',
        'La respiration consciente est l''un des outils les plus puissants pour agir sur notre état mental et physique. En modulant volontairement notre rythme respiratoire, nous influençons directement notre système nerveux autonome, réduisons la production de cortisol (hormone du stress) et favorisons la libération d''endorphines. Des études scientifiques démontrent qu''une pratique régulière améliore la concentration, diminue l''anxiété et renforce le système immunitaire.',
        true),
       ('Comment fonctionne la cohérence cardiaque ?',
        'La cohérence cardiaque repose sur la synchronisation entre le rythme respiratoire et la variabilité de la fréquence cardiaque (VFC). Lorsque vous respirez à environ 6 cycles par minute (5 secondes d''inspiration, 5 secondes d''expiration), votre cœur entre dans un état de cohérence optimale. Cet état améliore la communication entre le cerveau et le cœur, réduit le stress perçu et stabilise les émotions. La règle des 3-6-5 recommande 3 séances par jour, de 6 respirations par minute, pendant 5 minutes.',
        true),
       ('Respiration et gestion du stress : ce que dit la science',
        'De nombreuses études ont démontré l''efficacité des techniques de respiration sur la gestion du stress. Les recherches du Dr Herbert Benson (Harvard) ont mis en évidence la "réponse de relaxation" déclenchée par une respiration lente et contrôlée. Une méta-analyse publiée dans Frontiers in Human Neuroscience (2018) conclut que les exercices de respiration réduisent significativement l''anxiété, la dépression et le stress perçu. Ces effets sont observables dès la première séance et s''amplifient avec une pratique régulière.',
        true),
       ('Débuter avec la respiration : conseils pour les débutants',
        'Si vous débutez dans la pratique de la respiration consciente, voici quelques conseils essentiels. Commencez par des sessions courtes de 3 à 5 minutes. Choisissez un endroit calme et une posture confortable, assis ou allongé. Ne forcez jamais votre souffle : la respiration doit rester douce et naturelle. Il est normal de se sentir légèrement étourdi au début, surtout avec les techniques de rétention. En cas d''inconfort, revenez simplement à une respiration normale. La régularité prime sur la durée : mieux vaut 5 minutes chaque jour qu''une longue session hebdomadaire.',
        true),
       ('La technique 4-7-8 expliquée',
        'La technique 4-7-8, popularisée par le Dr Andrew Weil, est particulièrement efficace pour lutter contre l''insomnie et les crises d''anxiété. Le principe : inspirez par le nez pendant 4 secondes, retenez votre souffle pendant 7 secondes, puis expirez lentement par la bouche pendant 8 secondes. La rétention prolongée permet une meilleure oxygénation du sang et active le système nerveux parasympathique. Pratiquez 4 cycles maximum lors de vos premières semaines, puis augmentez progressivement.',
        true),
       ('Respiration et sommeil : retrouver un endormissement serein',
        'Les troubles du sommeil touchent près d''un tiers de la population. Les techniques de respiration constituent une alternative naturelle et efficace aux somnifères. En pratiquant 5 à 10 minutes de respiration lente avant de dormir, vous abaissez votre rythme cardiaque, détendez les muscles et préparez votre cerveau au sommeil. Les exercices recommandés en soirée sont la respiration 4-7-8 et la respiration abdominale profonde. Évitez la respiration de type hyperventilation (Wim Hof) le soir, qui peut être stimulante.',
        true),
       ('Respiration et sport : optimiser ses performances',
        'Les sportifs de haut niveau intègrent de plus en plus les techniques de respiration dans leur préparation. Une respiration maîtrisée améliore l''endurance en optimisant les échanges gazeux, accélère la récupération après l''effort en activant le système parasympathique, et renforce la concentration avant une compétition. La respiration nasale, souvent négligée, filtre l''air, humidifie les voies respiratoires et favorise une meilleure oxygénation grâce à la production d''oxyde nitrique dans les sinus.',
        true),
       ('Foire aux questions (FAQ)',
        'Q : À quelle fréquence pratiquer les exercices ? R : Idéalement, 2 à 3 fois par jour, notamment le matin au réveil, à la pause déjeuner et le soir. Q : Puis-je pratiquer si j''ai une maladie respiratoire ? R : Consultez votre médecin avant de commencer, surtout en cas d''asthme ou de BPCO. Q : Les exercices sont-ils adaptés aux enfants ? R : Oui, à partir de 6-7 ans sous supervision d''un adulte, avec des sessions courtes et des rythmes adaptés. Q : Combien de temps avant de voir des résultats ? R : Les effets immédiats (calme, concentration) se ressentent dès la première session. Les bénéfices durables apparaissent après 3 à 4 semaines de pratique régulière.',
        true),
       ('Mentions légales et politique de confidentialité',
        'Cette application est éditée à titre personnel. Les données personnelles collectées (email, nom) sont utilisées uniquement pour la gestion de votre compte et ne sont en aucun cas transmises à des tiers. Conformément au RGPD, vous disposez d''un droit d''accès, de rectification et de suppression de vos données. Pour exercer ces droits ou pour toute question, contactez l''administrateur via la page de contact. Les exercices proposés sont fournis à titre informatif et ne constituent pas un avis médical.',
        true);
