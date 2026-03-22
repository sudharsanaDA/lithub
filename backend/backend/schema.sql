-- ═══════════════════════════════════════════════════════════════
-- LITHUB DATABASE SCHEMA — PostgreSQL
-- ═══════════════════════════════════════════════════════════════

-- Create database (run separately as superuser)
-- CREATE DATABASE lithub;
-- \c lithub

-- ─── EXTENSIONS ─────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


-- ─── ENUM TYPES ──────────────────────────────────────────────────
CREATE TYPE user_role          AS ENUM ('USER', 'ADMIN');
CREATE TYPE book_condition     AS ENUM ('NEW', 'USED');
CREATE TYPE order_status       AS ENUM ('PENDING', 'CONFIRMED', 'SHIPPED', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED');
CREATE TYPE reading_status     AS ENUM ('WANT_TO_READ', 'CURRENTLY_READING', 'COMPLETED', 'ABANDONED');


-- ═══════════════════════════════════════════════════════════════
-- TABLE: users
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE users (
    id               BIGSERIAL PRIMARY KEY,
    username         VARCHAR(50)  UNIQUE NOT NULL,
    email            VARCHAR(255) UNIQUE NOT NULL,
    password         VARCHAR(255) NOT NULL,
    nickname         VARCHAR(50),
    gender           VARCHAR(20),
    age              SMALLINT CHECK (age >= 13 AND age <= 120),
    bio              TEXT,
    is_verified      BOOLEAN      NOT NULL DEFAULT FALSE,
    otp_code         CHAR(6),
    otp_expires_at   TIMESTAMP,
    role             user_role    NOT NULL DEFAULT 'USER',
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email    ON users(email);


-- ═══════════════════════════════════════════════════════════════
-- TABLE: books
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE books (
    id              BIGSERIAL PRIMARY KEY,
    title           VARCHAR(500)    NOT NULL,
    author          VARCHAR(255)    NOT NULL,
    description     TEXT,
    price           NUMERIC(10, 2)  NOT NULL CHECK (price >= 0),
    genre           VARCHAR(100),
    language        VARCHAR(50)     DEFAULT 'English',
    pages           INTEGER         CHECK (pages > 0),
    year            SMALLINT        CHECK (year >= 1000 AND year <= 9999),
    rating          NUMERIC(3, 2)   CHECK (rating >= 0 AND rating <= 5),
    cover_url       TEXT,
    isbn            VARCHAR(13)     UNIQUE,
    stock_count     INTEGER         NOT NULL DEFAULT 0 CHECK (stock_count >= 0),
    is_ebook        BOOLEAN         NOT NULL DEFAULT FALSE,
    is_bestseller   BOOLEAN         NOT NULL DEFAULT FALSE,
    is_new_arrival  BOOLEAN         NOT NULL DEFAULT FALSE,
    condition       book_condition  NOT NULL DEFAULT 'NEW',
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_books_genre        ON books(genre);
CREATE INDEX idx_books_author       ON books USING gin(to_tsvector('english', author));
CREATE INDEX idx_books_title_search ON books USING gin(to_tsvector('english', title));
CREATE INDEX idx_books_price        ON books(price);
CREATE INDEX idx_books_rating       ON books(rating DESC);
CREATE INDEX idx_books_is_ebook     ON books(is_ebook);
CREATE INDEX idx_books_bestseller   ON books(is_bestseller) WHERE is_bestseller = TRUE;
CREATE INDEX idx_books_new_arrival  ON books(is_new_arrival) WHERE is_new_arrival = TRUE;


-- ═══════════════════════════════════════════════════════════════
-- TABLE: cart_items
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE cart_items (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT          NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    book_id     BIGINT          NOT NULL REFERENCES books(id)  ON DELETE CASCADE,
    quantity    INTEGER         NOT NULL DEFAULT 1 CHECK (quantity > 0),
    added_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, book_id)
);

CREATE INDEX idx_cart_user ON cart_items(user_id);


-- ═══════════════════════════════════════════════════════════════
-- TABLE: wishlist
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE wishlist (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT    NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    book_id     BIGINT    NOT NULL REFERENCES books(id)  ON DELETE CASCADE,
    added_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, book_id)
);

CREATE INDEX idx_wishlist_user ON wishlist(user_id);


-- ═══════════════════════════════════════════════════════════════
-- TABLE: orders
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE orders (
    id               BIGSERIAL PRIMARY KEY,
    user_id          BIGINT          NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    order_number     VARCHAR(50)     UNIQUE NOT NULL,
    total_amount     NUMERIC(10, 2)  NOT NULL CHECK (total_amount >= 0),
    status           order_status    NOT NULL DEFAULT 'PENDING',
    shipping_address TEXT,
    created_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_user       ON orders(user_id);
CREATE INDEX idx_orders_status     ON orders(status);
CREATE INDEX idx_orders_number     ON orders(order_number);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);


-- ═══════════════════════════════════════════════════════════════
-- TABLE: order_items
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE order_items (
    id          BIGSERIAL PRIMARY KEY,
    order_id    BIGINT          NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    book_id     BIGINT          NOT NULL REFERENCES books(id)  ON DELETE RESTRICT,
    quantity    INTEGER         NOT NULL DEFAULT 1 CHECK (quantity > 0),
    unit_price  NUMERIC(10, 2)  NOT NULL CHECK (unit_price >= 0)
);

CREATE INDEX idx_order_items_order ON order_items(order_id);


-- ═══════════════════════════════════════════════════════════════
-- TABLE: communities
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE communities (
    id             BIGSERIAL PRIMARY KEY,
    name           VARCHAR(100)   UNIQUE NOT NULL,
    description    TEXT,
    genre          VARCHAR(100),
    language       VARCHAR(50),
    is_paid        BOOLEAN        NOT NULL DEFAULT FALSE,
    monthly_price  NUMERIC(8, 2)  CHECK (monthly_price >= 0),
    created_by     BIGINT         REFERENCES users(id) ON DELETE SET NULL,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_communities_genre ON communities(genre);


-- ═══════════════════════════════════════════════════════════════
-- TABLE: community_members  (many-to-many join)
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE community_members (
    community_id BIGINT    NOT NULL REFERENCES communities(id) ON DELETE CASCADE,
    user_id      BIGINT    NOT NULL REFERENCES users(id)       ON DELETE CASCADE,
    joined_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (community_id, user_id)
);

CREATE INDEX idx_community_members_user ON community_members(user_id);


-- ═══════════════════════════════════════════════════════════════
-- TABLE: reading_progress
-- ═══════════════════════════════════════════════════════════════
CREATE TABLE reading_progress (
    id                  BIGSERIAL PRIMARY KEY,
    user_id             BIGINT          NOT NULL REFERENCES users(id)  ON DELETE CASCADE,
    book_id             BIGINT          NOT NULL REFERENCES books(id)  ON DELETE CASCADE,
    current_page        INTEGER         NOT NULL DEFAULT 0 CHECK (current_page >= 0),
    progress_percent    SMALLINT        NOT NULL DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
    total_minutes_read  INTEGER         NOT NULL DEFAULT 0 CHECK (total_minutes_read >= 0),
    status              reading_status  NOT NULL DEFAULT 'WANT_TO_READ',
    started_at          TIMESTAMP,
    completed_at        TIMESTAMP,
    last_read_at        TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, book_id)
);

CREATE INDEX idx_reading_progress_user   ON reading_progress(user_id);
CREATE INDEX idx_reading_progress_status ON reading_progress(user_id, status);


-- ═══════════════════════════════════════════════════════════════
-- AUTO-UPDATE updated_at TRIGGER
-- ═══════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_books_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ═══════════════════════════════════════════════════════════════
-- SEED DATA — Books
-- ═══════════════════════════════════════════════════════════════
INSERT INTO books (title, author, description, price, genre, language, pages, year, rating, cover_url, isbn, stock_count, is_ebook, is_bestseller, is_new_arrival, condition)
VALUES
('The Midnight Library',  'Matt Haig',          'A dazzling novel about all the choices that go into a life well lived.', 14.99, 'Fiction',   'English', 304, 2020, 4.7, 'https://covers.openlibrary.org/b/id/10909258-L.jpg', '9780525559474', 12, TRUE,  TRUE,  FALSE, 'NEW'),
('Atomic Habits',         'James Clear',         'Tiny changes, remarkable results. A proven system for building good habits.',  12.99, 'Self-Help', 'English', 320, 2018, 4.9, 'https://covers.openlibrary.org/b/id/10521270-L.jpg', '9780735211292',  5, TRUE,  TRUE,  FALSE, 'NEW'),
('Dune',                  'Frank Herbert',       'A masterwork of science fiction, the epic story of Paul Atreides.',          9.99,  'Sci-Fi',    'English', 688, 1965, 4.8, 'https://covers.openlibrary.org/b/id/8231856-L.jpg',  '9780441013593', 20, FALSE, FALSE, TRUE,  'NEW'),
('The Alchemist',         'Paulo Coelho',        'A magical story of self-discovery and following your dreams.',               11.99, 'Fiction',   'English', 208, 1988, 4.6, 'https://covers.openlibrary.org/b/id/8116302-L.jpg',  '9780062315007',  8, TRUE,  TRUE,  FALSE, 'USED'),
('Sapiens',               'Yuval Noah Harari',   'A brief history of humankind, from the Stone Age to the 21st century.',     13.99, 'History',   'English', 443, 2011, 4.5, 'https://covers.openlibrary.org/b/id/8739161-L.jpg',  '9780062316097', 15, FALSE, FALSE, TRUE,  'NEW'),
('Normal People',         'Sally Rooney',        'An intricate portrait of mutual fascination, friendship and love.',          10.99, 'Romance',   'English', 266, 2018, 4.3, 'https://covers.openlibrary.org/b/id/10222599-L.jpg', '9781984822185',  0, TRUE,  FALSE, FALSE, 'NEW');


-- ═══════════════════════════════════════════════════════════════
-- SEED DATA — Communities
-- ═══════════════════════════════════════════════════════════════
INSERT INTO communities (name, description, genre, language, is_paid, monthly_price)
VALUES
('Midnight Readers',  'Late night literary discussions',          'Fiction',   'English', FALSE, NULL),
('Sci-Fi Universe',   'Deep dives into speculative fiction',      'Sci-Fi',    'English', TRUE,  4.99),
('Self-Help Circle',  'Transform your life through books',        'Self-Help', 'English', FALSE, NULL),
('Classic Lit Club',  'Timeless works, timeless conversations',   'Classics',  'English', TRUE,  2.99);
