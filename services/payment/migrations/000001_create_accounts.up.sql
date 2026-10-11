CREATE TYPE account_type AS ENUM ('card', 'blockchain');

CREATE TABLE accounts (
    account_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    type account_type NOT NULL,
    balance BIGINT NOT NULL DEFAULT 0
        CHECK (balance >= 0),
    currency VARCHAR(10) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE UNIQUE INDEX accounts_wallet ON accounts (user_id, type);
