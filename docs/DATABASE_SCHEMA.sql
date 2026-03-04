-- Database Schema for POS Desktop System (PostgreSQL)

-- Roles & Users
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    permissions JSONB DEFAULT '{}'
);

INSERT INTO roles (name, permissions) VALUES 
('Admin', '{"*": true}'),
('Manager', '{"inventory": true, "sales": true, "reports": true}'),
('Cashier', '{"sales": true, "pos": true}'),
('Waiter', '{"orders": true, "tables": true}'),
('Receptionist', '{"rooms": true, "bookings": true}'),
('Accountant', '{"accounting": true, "reports": true}');

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role_id INTEGER REFERENCES roles(id),
    email VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories & Products
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id INTEGER REFERENCES categories(id)
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    sku VARCHAR(50) UNIQUE,
    barcode VARCHAR(100) UNIQUE,
    description TEXT,
    category_id INTEGER REFERENCES categories(id),
    cost_price DECIMAL(15, 2) NOT NULL,
    sale_price DECIMAL(15, 2) NOT NULL,
    tax_rate DECIMAL(5, 2) DEFAULT 0.00,
    is_stock_managed BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_barcode ON products(barcode);
CREATE INDEX idx_product_sku ON products(sku);

-- Inventory
CREATE TABLE inventory (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    current_stock INTEGER DEFAULT 0,
    low_stock_threshold INTEGER DEFAULT 5,
    batch_number VARCHAR(50),
    expiry_date DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_inventory_product_id ON inventory(product_id);

-- Sales
CREATE TABLE sales (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER, -- Optional, could link to a customers table
    cashier_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(15, 2) NOT NULL,
    discount_amount DECIMAL(15, 2) DEFAULT 0.00,
    tax_amount DECIMAL(15, 2) DEFAULT 0.00,
    payment_method VARCHAR(50), -- Cash, Card, Mobile, Split
    payment_status VARCHAR(20) DEFAULT 'paid',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_sales_created_at ON sales(created_at);

CREATE TABLE sale_items (
    id SERIAL PRIMARY KEY,
    sale_id INTEGER REFERENCES sales(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(15, 2) NOT NULL,
    subtotal DECIMAL(15, 2) NOT NULL
);

-- Restaurant/Bar Features
CREATE TABLE tables (
    id SERIAL PRIMARY KEY,
    table_number VARCHAR(10) NOT NULL,
    capacity INTEGER DEFAULT 4,
    status VARCHAR(20) DEFAULT 'available' -- available, occupied, reserved, dirty
);

CREATE TABLE kitchen_orders (
    id SERIAL PRIMARY KEY,
    sale_id INTEGER REFERENCES sales(id),
    table_id INTEGER REFERENCES tables(id),
    status VARCHAR(20) DEFAULT 'pending', -- pending, preparing, ready, served
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hotel/Motel Features
CREATE TABLE room_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price_per_night DECIMAL(15, 2) NOT NULL
);

CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    room_number VARCHAR(10) UNIQUE NOT NULL,
    type_id INTEGER REFERENCES room_types(id),
    status VARCHAR(20) DEFAULT 'available' -- available, occupied, maintenance
);

CREATE TABLE guests (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    id_number VARCHAR(50)
);

CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    guest_id INTEGER REFERENCES guests(id),
    room_id INTEGER REFERENCES rooms(id),
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'confirmed', -- confirmed, checked_in, checked_out, cancelled
    total_amount DECIMAL(15, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Optimized Queries Samples

-- 1. Get Monthly Sales Report
-- EXPLAIN ANALYZE
SELECT 
    DATE_TRUNC('day', created_at) as sale_day,
    COUNT(*) as total_sales,
    SUM(total_amount) as revenue
FROM sales
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY 1
ORDER BY 1 DESC;

-- 2. Find Low Stock Products
SELECT 
    p.name, 
    p.sku, 
    i.current_stock, 
    i.low_stock_threshold
FROM products p
JOIN inventory i ON p.id = i.product_id
WHERE i.current_stock <= i.low_stock_threshold;

-- 3. Check Room Availability
-- Checks for overlapping dates
SELECT * FROM rooms
WHERE id NOT IN (
    SELECT room_id FROM bookings
    WHERE status NOT IN ('cancelled', 'checked_out')
    AND (check_in_date, check_out_date) OVERLAPS ('2026-03-04', '2026-03-10')
);
