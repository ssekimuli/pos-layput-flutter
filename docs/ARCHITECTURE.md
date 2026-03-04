# POS Desktop System Architecture

## 1. Introduction
The POS Desktop System is a high-performance, scalable solution designed for retail, wholesale, and hospitality industries. It features a modern desktop UI built with Flutter and follows a clean architecture approach.

## 2. System Components

### 2.1 Frontend (Flutter Desktop)
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod
- **Architecture:** Clean Architecture with Feature-based modularization.
- **Styling:** Modern, responsive design with dark/light theme support.

### 2.2 Backend (Mock API for Development)
- **RESTful API:** Node.js/Express (proposed for production).
- **Mock Data:** Realistic dummy data in JSON format.
- **Authentication:** JWT-based auth with Role-Based Access Control (RBAC).

### 2.3 Database (Proposed)
- **Engine:** PostgreSQL (for high performance and ACID compliance).
- **Indexing:** Optimized indexing for fast lookups (product barcode, order IDs, date-based reports).

## 3. Database Schema

### 3.1 Core Modules
- `users`: id, username, password_hash, role_id, email, status.
- `roles`: id, name (Admin, Manager, Cashier, etc.), permissions (JSON).
- `products`: id, name, sku, barcode, description, category_id, brand_id, cost_price, sale_price, tax_rate, unit_id, is_stock_managed.
- `categories`: id, name, parent_id.
- `suppliers`: id, name, contact_person, email, phone, address.

### 3.2 Sales & Inventory
- `sales`: id, customer_id, cashier_id, total_amount, discount_amount, tax_amount, payment_method, payment_status, created_at.
- `sale_items`: id, sale_id, product_id, quantity, unit_price, subtotal.
- `inventory`: id, product_id, current_stock, low_stock_threshold, expiry_date, batch_number.
- `purchase_orders`: id, supplier_id, total_amount, status, created_at.

### 3.3 Restaurant & Bar
- `tables`: id, table_number, capacity, status (Available, Occupied, Reserved).
- `kitchen_orders`: id, sale_id, table_id, status (Pending, In Progress, Ready, Delivered), notes.

### 3.4 Hotel & Motel
- `rooms`: id, room_number, type_id, status (Available, Occupied, Maintenance, Dirty), price_per_night.
- `room_types`: id, name, description, capacity.
- `bookings`: id, guest_id, room_id, check_in_date, check_out_date, status, total_amount.
- `guests`: id, first_name, last_name, email, phone, id_number.

### 3.5 Accounting
- `expenses`: id, category_id, amount, description, date.
- `transactions`: id, reference_id (sale_id or expense_id), type (Income, Expense), amount, date.

## 4. REST API Endpoints

### Auth
- `POST /api/auth/login`
- `POST /api/auth/logout`
- `GET /api/auth/me`

### Products & Inventory
- `GET /api/products`
- `POST /api/products`
- `GET /api/inventory`
- `PUT /api/inventory/stock-adjust`

### Sales
- `POST /api/sales`
- `GET /api/sales`
- `GET /api/sales/{id}`

### Hospitality (Restaurant/Hotel)
- `GET /api/tables`
- `GET /api/rooms`
- `POST /api/bookings`

## 5. Deployment Instructions
- **Frontend:** Build for Windows/MacOS/Linux using `flutter build <platform>`.
- **Backend:** Deploy Node.js API to a cloud provider (AWS/DigitalOcean/Azure) with Docker.
- **Database:** Managed PostgreSQL instance.
