CREATE TYPE payment_status AS ENUM ('hold', 'accepted', 'rejected');

CREATE TABLE payments (
    payment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    account_id BIGINT NOT NULL,
    amount BIGINT NOT NULL
        CHECK (amount > 0),
    status payment_status NOT NULL DEFAULT 'hold',
    err_code INT,
    err_message TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);
