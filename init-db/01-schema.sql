-- Create enum for availability status
CREATE TYPE availability_status AS ENUM ('In Stock', 'Out of Stock');

-- Create categories table first
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    slug VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    parent_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create products table with correct foreign keys from the start
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    model VARCHAR(50) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    availability availability_status NOT NULL DEFAULT 'In Stock',
    image_src VARCHAR(255) NOT NULL, -- Path to thumbnail image
    img_full VARCHAR(255) NOT NULL, -- Path to full-size image
    image_alt VARCHAR(255) NOT NULL,
    is_new BOOLEAN DEFAULT false,
    clients VARCHAR(50),
    features TEXT[] DEFAULT '{}',
    tech_spec_pdf VARCHAR(255), -- Path to PDF file
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    category_id INTEGER REFERENCES categories(id),
    subcategory_id INTEGER REFERENCES categories(id)
);

-- Create a trigger to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add triggers for both tables
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for common queries
CREATE INDEX idx_products_model ON products(model);
CREATE INDEX idx_products_availability ON products(availability);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_subcategory_id ON products(subcategory_id);

-- Insert main categories
INSERT INTO categories (name, slug, description) VALUES
    ('Networking', 'networking', 'Network infrastructure and security solutions'),
    ('Cameras', 'cameras', 'Security and surveillance cameras'),
    ('Access', 'access', 'Access control systems');

-- Insert sub-categories
INSERT INTO categories (name, slug, description, parent_id) VALUES
    ('Security Gateways', 'security-gateways', 'Network security and gateway devices', 
        (SELECT id FROM categories WHERE slug = 'networking')),
    ('Switches', 'switches', 'Network switches and routing equipment', 
        (SELECT id FROM categories WHERE slug = 'networking')),
    ('Wireless', 'wireless', 'Wireless networking solutions', 
        (SELECT id FROM categories WHERE slug = 'networking'));

-- Insert sample product with paths to files in volumes
INSERT INTO products (
    title,
    model,
    description,
    price,
    availability,
    image_src,
    img_full,
    image_alt,
    is_new,
    clients,
    features,
    tech_spec_pdf,
    category_id,
    subcategory_id
) VALUES (
    'Dream Machine Pro',
    'UDM-Pro',
    'Enterprise-grade, rack-mount UniFi Cloud Gateway with full UniFi application support, 10 Gbps performance, and an integrated switch.',
    379.00,
    'In Stock',
    '/images/products/download.png',
    '/images/products/full/949fdb99-c8cb-4dae-8097-943f59eced8d.png',
    'Dream Machine Pro',
    true,
    '5,000',
    ARRAY['NeXT AI Cybersecurity'],
    '/docs/products/udm-pro-specs.pdf',
    (SELECT id FROM categories WHERE slug = 'networking'),
    (SELECT id FROM categories WHERE slug = 'security-gateways')
);
