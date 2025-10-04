-- ===============================================
-- Tourism & Travel CRM Database Schema
-- ===============================================
-- Comprehensive database structure for travel industry CRM
-- Supports multilingual content, booking management, and analytics
-- Optimized for MySQL 8.0+ with utf8mb4 encoding
-- ===============================================

-- Drop database if exists (development only)
-- DROP DATABASE IF EXISTS tourism_crm;

-- Create database with proper character set
CREATE DATABASE IF NOT EXISTS tourism_crm 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE tourism_crm;

-- ===============================================
-- Core System Tables
-- ===============================================

-- Users table (system users - agents, managers, admins)
CREATE TABLE users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    avatar VARCHAR(255),
    role ENUM('admin', 'manager', 'agent', 'customer') DEFAULT 'agent',
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    language ENUM('en', 'ar') DEFAULT 'en',
    timezone VARCHAR(50) DEFAULT 'UTC',
    last_login_at TIMESTAMP NULL,
    remember_token VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_users_email (email),
    INDEX idx_users_role (role),
    INDEX idx_users_status (status)
);

-- Permissions and roles
CREATE TABLE permissions (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL,
    module VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE roles (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    guard_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE role_has_permissions (
    permission_id BIGINT UNSIGNED NOT NULL,
    role_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (permission_id, role_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

CREATE TABLE model_has_permissions (
    permission_id BIGINT UNSIGNED NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (permission_id, model_id, model_type),
    FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE,
    INDEX idx_model_has_permissions_model_id_type (model_id, model_type)
);

CREATE TABLE model_has_roles (
    role_id BIGINT UNSIGNED NOT NULL,
    model_type VARCHAR(255) NOT NULL,
    model_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (role_id, model_id, model_type),
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    INDEX idx_model_has_roles_model_id_type (model_id, model_type)
);

-- ===============================================
-- Customer Management
-- ===============================================

-- Customers (travelers/clients)
CREATE TABLE customers (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_code VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    whatsapp VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('male', 'female') NULL,
    nationality VARCHAR(100),
    passport_number VARCHAR(50),
    passport_expiry DATE,
    preferred_language ENUM('en', 'ar') DEFAULT 'en',
    customer_type ENUM('individual', 'corporate', 'group') DEFAULT 'individual',
    company_name VARCHAR(255) NULL,
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(20),
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    dietary_restrictions TEXT,
    accessibility_needs TEXT,
    travel_preferences JSON,
    loyalty_points INT DEFAULT 0,
    lifetime_value DECIMAL(12, 2) DEFAULT 0.00,
    notes TEXT,
    status ENUM('active', 'inactive', 'blacklisted') DEFAULT 'active',
    assigned_agent_id BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (assigned_agent_id) REFERENCES users(id) ON SET NULL,
    INDEX idx_customers_email (email),
    INDEX idx_customers_code (customer_code),
    INDEX idx_customers_type (customer_type),
    INDEX idx_customers_agent (assigned_agent_id),
    INDEX idx_customers_status (status),
    FULLTEXT idx_customers_search (first_name, last_name, email, company_name)
);

-- Customer journey stages and tracking
CREATE TABLE customer_journey_stages (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    stage ENUM('inquiry', 'quote_sent', 'negotiation', 'booking', 'payment', 'pre_travel', 'traveling', 'post_travel', 'follow_up') NOT NULL,
    status ENUM('active', 'completed', 'skipped') DEFAULT 'active',
    entered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    notes TEXT,
    created_by BIGINT UNSIGNED,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON SET NULL,
    INDEX idx_journey_customer (customer_id),
    INDEX idx_journey_stage (stage),
    INDEX idx_journey_status (status)
);

-- ===============================================
-- Destination Management
-- ===============================================

-- Countries
CREATE TABLE countries (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    code VARCHAR(3) NOT NULL UNIQUE,
    currency VARCHAR(10),
    timezone VARCHAR(50),
    language VARCHAR(10) DEFAULT 'en',
    visa_required BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_countries_code (code)
);

-- Cities
CREATE TABLE cities (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    country_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    timezone VARCHAR(50),
    is_popular BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE CASCADE,
    INDEX idx_cities_country (country_id),
    INDEX idx_cities_popular (is_popular)
);

-- Destinations (tourist attractions, landmarks)
CREATE TABLE destinations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    city_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255),
    description TEXT,
    description_ar TEXT,
    category ENUM('historical', 'cultural', 'natural', 'adventure', 'religious', 'entertainment', 'shopping', 'beach', 'mountain') NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    address TEXT,
    address_ar TEXT,
    opening_hours JSON,
    entry_fee DECIMAL(8, 2) DEFAULT 0.00,
    duration_hours DECIMAL(4, 2) DEFAULT 2.00,
    difficulty_level ENUM('easy', 'moderate', 'challenging') DEFAULT 'easy',
    best_season ENUM('spring', 'summer', 'autumn', 'winter', 'all_year') DEFAULT 'all_year',
    min_age INT DEFAULT 0,
    accessibility_features TEXT,
    images JSON,
    rating DECIMAL(3, 2) DEFAULT 0.00,
    review_count INT DEFAULT 0,
    is_popular BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (city_id) REFERENCES cities(id) ON DELETE CASCADE,
    INDEX idx_destinations_city (city_id),
    INDEX idx_destinations_category (category),
    INDEX idx_destinations_rating (rating),
    INDEX idx_destinations_popular (is_popular),
    FULLTEXT idx_destinations_search (name, name_ar, description, description_ar)
);

-- ===============================================
-- Travel Package Management
-- ===============================================

-- Travel package categories
CREATE TABLE package_categories (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    description TEXT,
    description_ar TEXT,
    icon VARCHAR(100),
    color VARCHAR(20),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Main travel packages
CREATE TABLE travel_packages (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_code VARCHAR(20) UNIQUE NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    name_ar VARCHAR(255),
    short_description TEXT,
    short_description_ar TEXT,
    description TEXT,
    description_ar TEXT,
    duration_days INT NOT NULL,
    duration_nights INT NOT NULL,
    min_participants INT DEFAULT 1,
    max_participants INT DEFAULT 50,
    difficulty_level ENUM('easy', 'moderate', 'challenging') DEFAULT 'easy',
    age_restriction_min INT DEFAULT 0,
    age_restriction_max INT DEFAULT 100,
    base_price DECIMAL(10, 2) NOT NULL,
    child_price DECIMAL(10, 2),
    single_supplement DECIMAL(10, 2) DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'USD',
    includes JSON,
    excludes JSON,
    what_to_bring JSON,
    cancellation_policy TEXT,
    cancellation_policy_ar TEXT,
    terms_conditions TEXT,
    terms_conditions_ar TEXT,
    images JSON,
    featured_image VARCHAR(255),
    video_url VARCHAR(255),
    brochure_url VARCHAR(255),
    rating DECIMAL(3, 2) DEFAULT 0.00,
    review_count INT DEFAULT 0,
    booking_count INT DEFAULT 0,
    is_featured BOOLEAN DEFAULT FALSE,
    is_popular BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_by BIGINT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES package_categories(id) ON DELETE RESTRICT,
    FOREIGN KEY (created_by) REFERENCES users(id) ON SET NULL,
    INDEX idx_packages_code (package_code),
    INDEX idx_packages_category (category_id),
    INDEX idx_packages_price (base_price),
    INDEX idx_packages_duration (duration_days),
    INDEX idx_packages_featured (is_featured),
    INDEX idx_packages_active (is_active),
    FULLTEXT idx_packages_search (name, name_ar, short_description, short_description_ar)
);

-- Package itineraries (day-by-day breakdown)
CREATE TABLE package_itineraries (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_id BIGINT UNSIGNED NOT NULL,
    day_number INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    title_ar VARCHAR(255),
    description TEXT,
    description_ar TEXT,
    activities JSON,
    meals_included ENUM('none', 'breakfast', 'half_board', 'full_board') DEFAULT 'none',
    accommodation_type VARCHAR(100),
    transportation JSON,
    free_time_minutes INT DEFAULT 0,
    notes TEXT,
    notes_ar TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (package_id) REFERENCES travel_packages(id) ON DELETE CASCADE,
    INDEX idx_itinerary_package (package_id),
    INDEX idx_itinerary_day (day_number)
);

-- Package destinations (linking packages to destinations)
CREATE TABLE package_destinations (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_id BIGINT UNSIGNED NOT NULL,
    destination_id BIGINT UNSIGNED NOT NULL,
    visit_order INT DEFAULT 0,
    duration_hours DECIMAL(4, 2) DEFAULT 2.00,
    is_optional BOOLEAN DEFAULT FALSE,
    additional_cost DECIMAL(8, 2) DEFAULT 0.00,
    notes TEXT,
    
    FOREIGN KEY (package_id) REFERENCES travel_packages(id) ON DELETE CASCADE,
    FOREIGN KEY (destination_id) REFERENCES destinations(id) ON DELETE CASCADE,
    INDEX idx_package_dest_package (package_id),
    INDEX idx_package_dest_destination (destination_id)
);

-- Package pricing (seasonal pricing, group discounts)
CREATE TABLE package_pricing (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_id BIGINT UNSIGNED NOT NULL,
    season_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    adult_price DECIMAL(10, 2) NOT NULL,
    child_price DECIMAL(10, 2),
    infant_price DECIMAL(10, 2) DEFAULT 0.00,
    single_supplement DECIMAL(10, 2) DEFAULT 0.00,
    group_discount_percentage DECIMAL(5, 2) DEFAULT 0.00,
    min_group_size INT DEFAULT 1,
    currency VARCHAR(10) DEFAULT 'USD',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (package_id) REFERENCES travel_packages(id) ON DELETE CASCADE,
    INDEX idx_pricing_package (package_id),
    INDEX idx_pricing_dates (start_date, end_date),
    INDEX idx_pricing_active (is_active)
);

-- Package availability calendar
CREATE TABLE package_availability (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_id BIGINT UNSIGNED NOT NULL,
    departure_date DATE NOT NULL,
    return_date DATE NOT NULL,
    available_slots INT NOT NULL,
    booked_slots INT DEFAULT 0,
    price_adult DECIMAL(10, 2) NOT NULL,
    price_child DECIMAL(10, 2),
    guide_name VARCHAR(100),
    guide_language ENUM('en', 'ar', 'both') DEFAULT 'en',
    special_notes TEXT,
    status ENUM('available', 'limited', 'full', 'cancelled') DEFAULT 'available',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (package_id) REFERENCES travel_packages(id) ON DELETE CASCADE,
    UNIQUE KEY unique_package_departure (package_id, departure_date),
    INDEX idx_availability_dates (departure_date, return_date),
    INDEX idx_availability_status (status)
);

-- ===============================================
-- Booking Management
-- ===============================================

-- Main bookings table
CREATE TABLE bookings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_reference VARCHAR(20) UNIQUE NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    package_id BIGINT UNSIGNED NOT NULL,
    availability_id BIGINT UNSIGNED,
    departure_date DATE NOT NULL,
    return_date DATE NOT NULL,
    adults_count INT DEFAULT 1,
    children_count INT DEFAULT 0,
    infants_count INT DEFAULT 0,
    total_participants INT AS (adults_count + children_count + infants_count) STORED,
    base_amount DECIMAL(12, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL,
    paid_amount DECIMAL(12, 2) DEFAULT 0.00,
    currency VARCHAR(10) DEFAULT 'USD',
    payment_status ENUM('pending', 'partial', 'paid', 'refunded', 'cancelled') DEFAULT 'pending',
    booking_status ENUM('inquiry', 'quote', 'confirmed', 'cancelled', 'completed', 'no_show') DEFAULT 'inquiry',
    payment_method ENUM('cash', 'card', 'bank_transfer', 'online', 'installment') DEFAULT 'cash',
    special_requests TEXT,
    internal_notes TEXT,
    customer_notes TEXT,
    confirmation_sent_at TIMESTAMP NULL,
    reminder_sent_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    cancellation_reason TEXT,
    refund_amount DECIMAL(12, 2) DEFAULT 0.00,
    agent_id BIGINT UNSIGNED NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT,
    FOREIGN KEY (package_id) REFERENCES travel_packages(id) ON DELETE RESTRICT,
    FOREIGN KEY (availability_id) REFERENCES package_availability(id) ON SET NULL,
    FOREIGN KEY (agent_id) REFERENCES users(id) ON DELETE RESTRICT,
    INDEX idx_bookings_reference (booking_reference),
    INDEX idx_bookings_customer (customer_id),
    INDEX idx_bookings_package (package_id),
    INDEX idx_bookings_dates (departure_date, return_date),
    INDEX idx_bookings_status (booking_status),
    INDEX idx_bookings_payment (payment_status),
    INDEX idx_bookings_agent (agent_id)
);

-- Booking participants (detailed traveler information)
CREATE TABLE booking_participants (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT UNSIGNED NOT NULL,
    participant_type ENUM('adult', 'child', 'infant') NOT NULL,
    title ENUM('mr', 'mrs', 'ms', 'dr', 'prof') NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    date_of_birth DATE,
    nationality VARCHAR(100),
    passport_number VARCHAR(50),
    passport_expiry DATE,
    passport_country VARCHAR(100),
    gender ENUM('male', 'female'),
    dietary_restrictions TEXT,
    accessibility_needs TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    room_preference ENUM('single', 'double', 'twin', 'triple', 'any') DEFAULT 'any',
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    INDEX idx_participants_booking (booking_id),
    INDEX idx_participants_type (participant_type)
);

-- Booking status history
CREATE TABLE booking_status_history (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT UNSIGNED NOT NULL,
    old_status ENUM('inquiry', 'quote', 'confirmed', 'cancelled', 'completed', 'no_show'),
    new_status ENUM('inquiry', 'quote', 'confirmed', 'cancelled', 'completed', 'no_show') NOT NULL,
    notes TEXT,
    changed_by BIGINT UNSIGNED,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id) ON SET NULL,
    INDEX idx_status_history_booking (booking_id)
);

-- ===============================================
-- Payment Management
-- ===============================================

-- Payment transactions
CREATE TABLE payments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(50) UNIQUE NOT NULL,
    booking_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    payment_method ENUM('cash', 'credit_card', 'debit_card', 'bank_transfer', 'paypal', 'stripe', 'online_banking') NOT NULL,
    payment_type ENUM('deposit', 'partial', 'full', 'refund', 'penalty') DEFAULT 'full',
    gateway VARCHAR(50),
    gateway_transaction_id VARCHAR(100),
    gateway_response JSON,
    status ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded') DEFAULT 'pending',
    notes TEXT,
    receipt_url VARCHAR(255),
    processed_by BIGINT UNSIGNED,
    processed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE RESTRICT,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE RESTRICT,
    FOREIGN KEY (processed_by) REFERENCES users(id) ON SET NULL,
    INDEX idx_payments_transaction (transaction_id),
    INDEX idx_payments_booking (booking_id),
    INDEX idx_payments_customer (customer_id),
    INDEX idx_payments_status (status),
    INDEX idx_payments_method (payment_method)
);

-- Payment installments (for payment plans)
CREATE TABLE payment_installments (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT UNSIGNED NOT NULL,
    installment_number INT NOT NULL,
    due_date DATE NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    paid_amount DECIMAL(12, 2) DEFAULT 0.00,
    status ENUM('pending', 'paid', 'overdue', 'cancelled') DEFAULT 'pending',
    payment_id BIGINT UNSIGNED NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON DELETE CASCADE,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON SET NULL,
    INDEX idx_installments_booking (booking_id),
    INDEX idx_installments_due_date (due_date),
    INDEX idx_installments_status (status)
);

-- ===============================================
-- Communication & Marketing
-- ===============================================

-- Email templates
CREATE TABLE email_templates (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('booking_confirmation', 'payment_reminder', 'travel_reminder', 'follow_up', 'marketing', 'custom') NOT NULL,
    subject VARCHAR(255) NOT NULL,
    subject_ar VARCHAR(255),
    body TEXT NOT NULL,
    body_ar TEXT,
    variables JSON,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email_templates_type (type)
);

-- Email logs
CREATE TABLE email_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED,
    booking_id BIGINT UNSIGNED,
    template_id BIGINT UNSIGNED,
    to_email VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT,
    status ENUM('sent', 'failed', 'bounced') DEFAULT 'sent',
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    opened_at TIMESTAMP NULL,
    clicked_at TIMESTAMP NULL,
    error_message TEXT,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON SET NULL,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON SET NULL,
    FOREIGN KEY (template_id) REFERENCES email_templates(id) ON SET NULL,
    INDEX idx_email_logs_customer (customer_id),
    INDEX idx_email_logs_booking (booking_id),
    INDEX idx_email_logs_status (status)
);

-- Customer communications log
CREATE TABLE communications (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT UNSIGNED NOT NULL,
    booking_id BIGINT UNSIGNED,
    type ENUM('email', 'phone', 'whatsapp', 'meeting', 'note') NOT NULL,
    direction ENUM('inbound', 'outbound') NOT NULL,
    subject VARCHAR(255),
    content TEXT NOT NULL,
    attachments JSON,
    user_id BIGINT UNSIGNED,
    scheduled_at TIMESTAMP NULL,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON SET NULL,
    INDEX idx_communications_customer (customer_id),
    INDEX idx_communications_booking (booking_id),
    INDEX idx_communications_type (type),
    FULLTEXT idx_communications_content (subject, content)
);

-- ===============================================
-- Reviews & Feedback
-- ===============================================

-- Package reviews
CREATE TABLE package_reviews (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_id BIGINT UNSIGNED NOT NULL,
    customer_id BIGINT UNSIGNED NOT NULL,
    booking_id BIGINT UNSIGNED,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    review TEXT NOT NULL,
    review_ar TEXT,
    photos JSON,
    travel_date DATE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT TRUE,
    helpful_count INT DEFAULT 0,
    response TEXT,
    responded_by BIGINT UNSIGNED,
    responded_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (package_id) REFERENCES travel_packages(id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE CASCADE,
    FOREIGN KEY (booking_id) REFERENCES bookings(id) ON SET NULL,
    FOREIGN KEY (responded_by) REFERENCES users(id) ON SET NULL,
    INDEX idx_reviews_package (package_id),
    INDEX idx_reviews_customer (customer_id),
    INDEX idx_reviews_rating (rating),
    INDEX idx_reviews_published (is_published)
);

-- ===============================================
-- System Settings & Configuration
-- ===============================================

-- System settings
CREATE TABLE settings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    key_name VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    type ENUM('string', 'number', 'boolean', 'json') DEFAULT 'string',
    category VARCHAR(50) DEFAULT 'general',
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_settings_category (category)
);

-- Activity logs (audit trail)
CREATE TABLE activity_logs (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    log_name VARCHAR(255),
    description TEXT NOT NULL,
    subject_type VARCHAR(255),
    subject_id BIGINT UNSIGNED,
    causer_type VARCHAR(255),
    causer_id BIGINT UNSIGNED,
    properties JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_activity_logs_subject (subject_type, subject_id),
    INDEX idx_activity_logs_causer (causer_type, causer_id),
    INDEX idx_activity_logs_log_name (log_name)
);

-- File uploads and media
CREATE TABLE media (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    model_type VARCHAR(255) NOT NULL,
    model_id BIGINT UNSIGNED NOT NULL,
    collection_name VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(255),
    disk VARCHAR(255) NOT NULL,
    size BIGINT UNSIGNED NOT NULL,
    manipulations JSON,
    custom_properties JSON,
    responsive_images JSON,
    order_column INT UNSIGNED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_media_model (model_type, model_id),
    INDEX idx_media_collection (collection_name)
);

-- ===============================================
-- Analytics & Reporting Tables
-- ===============================================

-- Daily analytics summary
CREATE TABLE daily_analytics (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    date DATE UNIQUE NOT NULL,
    new_customers INT DEFAULT 0,
    new_bookings INT DEFAULT 0,
    confirmed_bookings INT DEFAULT 0,
    cancelled_bookings INT DEFAULT 0,
    total_revenue DECIMAL(12, 2) DEFAULT 0.00,
    payments_received DECIMAL(12, 2) DEFAULT 0.00,
    refunds_issued DECIMAL(12, 2) DEFAULT 0.00,
    active_packages INT DEFAULT 0,
    popular_destination_id BIGINT UNSIGNED,
    conversion_rate DECIMAL(5, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (popular_destination_id) REFERENCES destinations(id) ON SET NULL,
    INDEX idx_daily_analytics_date (date)
);

-- Package performance metrics
CREATE TABLE package_metrics (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    package_id BIGINT UNSIGNED NOT NULL,
    month_year DATE NOT NULL,
    views INT DEFAULT 0,
    inquiries INT DEFAULT 0,
    bookings INT DEFAULT 0,
    revenue DECIMAL(12, 2) DEFAULT 0.00,
    average_rating DECIMAL(3, 2) DEFAULT 0.00,
    conversion_rate DECIMAL(5, 2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (package_id) REFERENCES travel_packages(id) ON DELETE CASCADE,
    UNIQUE KEY unique_package_month (package_id, month_year),
    INDEX idx_package_metrics_month (month_year)
);

-- ===============================================
-- Sample Data Inserts
-- ===============================================

-- Insert default countries
INSERT INTO countries (name, name_ar, code, currency, timezone) VALUES
('Egypt', 'مصر', 'EGY', 'EGP', 'Africa/Cairo'),
('United Arab Emirates', 'الإمارات العربية المتحدة', 'ARE', 'AED', 'Asia/Dubai'),
('Jordan', 'الأردن', 'JOR', 'JOD', 'Asia/Amman'),
('Turkey', 'تركيا', 'TUR', 'TRY', 'Europe/Istanbul'),
('Morocco', 'المغرب', 'MAR', 'MAD', 'Africa/Casablanca'),
('Saudi Arabia', 'المملكة العربية السعودية', 'SAU', 'SAR', 'Asia/Riyadh');

-- Insert default package categories
INSERT INTO package_categories (name, name_ar, description, icon, color) VALUES
('Cultural Tours', 'الجولات الثقافية', 'Explore rich history and culture', 'fas fa-landmark', '#8B4513'),
('Adventure Tours', 'جولات المغامرة', 'Thrilling outdoor experiences', 'fas fa-mountain', '#FF6347'),
('Beach & Relaxation', 'الشاطئ والاسترخاء', 'Peaceful beach destinations', 'fas fa-umbrella-beach', '#4169E1'),
('City Breaks', 'عطل المدن', 'Urban exploration and city tours', 'fas fa-city', '#32CD32'),
('Family Tours', 'الجولات العائلية', 'Perfect for family vacations', 'fas fa-family', '#FFB6C1'),
('Luxury Tours', 'الجولات الفاخرة', 'Premium travel experiences', 'fas fa-crown', '#FFD700');

-- Insert default user roles
INSERT INTO roles (name, guard_name, description) VALUES
('admin', 'web', 'System Administrator'),
('manager', 'web', 'Travel Manager'),
('agent', 'web', 'Travel Agent'),
('customer', 'web', 'Customer');

-- Insert basic permissions
INSERT INTO permissions (name, guard_name, module) VALUES
('view_dashboard', 'web', 'dashboard'),
('manage_customers', 'web', 'customers'),
('manage_bookings', 'web', 'bookings'),
('manage_packages', 'web', 'packages'),
('manage_payments', 'web', 'payments'),
('view_reports', 'web', 'reports'),
('manage_users', 'web', 'users'),
('system_settings', 'web', 'settings');

-- Insert basic settings
INSERT INTO settings (key_name, value, type, category, description) VALUES
('company_name', 'Tourism & Travel CRM', 'string', 'company', 'Company name'),
('company_email', 'info@tourism-crm.com', 'string', 'company', 'Company email'),
('company_phone', '+1-234-567-8900', 'string', 'company', 'Company phone'),
('default_currency', 'USD', 'string', 'general', 'Default currency'),
('default_language', 'en', 'string', 'general', 'Default language'),
('booking_confirmation_auto', 'true', 'boolean', 'booking', 'Auto send booking confirmations'),
('payment_reminder_days', '7', 'number', 'payment', 'Days before payment due to send reminder'),
('cancellation_fee_percentage', '10', 'number', 'booking', 'Cancellation fee percentage');

-- ===============================================
-- Views for Common Queries
-- ===============================================

-- Active bookings with customer and package details
CREATE VIEW active_bookings_view AS
SELECT 
    b.id,
    b.booking_reference,
    b.departure_date,
    b.return_date,
    b.booking_status,
    b.payment_status,
    b.total_amount,
    b.paid_amount,
    CONCAT(c.first_name, ' ', c.last_name) as customer_name,
    c.email as customer_email,
    c.phone as customer_phone,
    p.name as package_name,
    p.duration_days,
    CONCAT(u.name) as agent_name
FROM bookings b
JOIN customers c ON b.customer_id = c.id
JOIN travel_packages p ON b.package_id = p.id
JOIN users u ON b.agent_id = u.id
WHERE b.booking_status IN ('confirmed', 'quote');

-- Package performance summary
CREATE VIEW package_performance_view AS
SELECT 
    p.id,
    p.package_code,
    p.name,
    p.base_price,
    p.rating,
    p.review_count,
    COUNT(b.id) as total_bookings,
    SUM(CASE WHEN b.booking_status = 'confirmed' THEN 1 ELSE 0 END) as confirmed_bookings,
    SUM(CASE WHEN b.booking_status = 'confirmed' THEN b.total_amount ELSE 0 END) as total_revenue,
    AVG(CASE WHEN b.booking_status = 'confirmed' THEN b.total_amount ELSE NULL END) as average_booking_value
FROM travel_packages p
LEFT JOIN bookings b ON p.id = b.package_id
WHERE p.is_active = TRUE
GROUP BY p.id;

-- Customer lifetime value
CREATE VIEW customer_value_view AS
SELECT 
    c.id,
    c.customer_code,
    CONCAT(c.first_name, ' ', c.last_name) as full_name,
    c.email,
    COUNT(b.id) as total_bookings,
    SUM(CASE WHEN b.payment_status = 'paid' THEN b.total_amount ELSE 0 END) as lifetime_value,
    AVG(b.total_amount) as average_booking_value,
    MIN(b.created_at) as first_booking_date,
    MAX(b.created_at) as last_booking_date
FROM customers c
LEFT JOIN bookings b ON c.id = b.customer_id
GROUP BY c.id;

-- ===============================================
-- Indexes for Performance Optimization
-- ===============================================

-- Composite indexes for common queries
CREATE INDEX idx_bookings_customer_status ON bookings(customer_id, booking_status);
CREATE INDEX idx_bookings_package_dates ON bookings(package_id, departure_date, return_date);
CREATE INDEX idx_bookings_agent_status ON bookings(agent_id, booking_status);
CREATE INDEX idx_payments_booking_status ON payments(booking_id, status);
CREATE INDEX idx_availability_package_date ON package_availability(package_id, departure_date);

-- Full-text search indexes
ALTER TABLE travel_packages ADD FULLTEXT(name, name_ar, short_description, short_description_ar);
ALTER TABLE customers ADD FULLTEXT(first_name, last_name, email, company_name);
ALTER TABLE destinations ADD FULLTEXT(name, name_ar, description, description_ar);

-- ===============================================
-- End of Schema
-- ===============================================