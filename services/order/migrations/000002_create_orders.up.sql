CREATE TYPE order_status AS ENUM ('draft', 'reserved', 'paid', 'cancelled', 'expired');

CREATE TABLE orders (
    order_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payment_id BIGINT NOT NULL,
    product_id BIGINT NOT NULL,
    amount INT NOT NULL
        CHECK (amount > 0),
    status order_status DEFAULT 'draft' NOT NULL,
    error_code INT,
    error_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW() ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW() 
        CHECK (updated_at >= created_at),
    expired_at TIMESTAMPTZ NOT NULL
        CHECK (expired_at > created_at),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);