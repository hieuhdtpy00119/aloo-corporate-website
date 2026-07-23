-- Bring databases created from the legacy baseline up to the complete schema
-- before Hibernate validates it. Existing reviews and tables are preserved.

IF OBJECT_ID(N'dbo.product_reviews', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.product_reviews (
        id BIGINT IDENTITY(1,1) NOT NULL,
        product_id BIGINT NOT NULL,
        user_id BIGINT NOT NULL,
        customer_name NVARCHAR(100) NOT NULL,
        avatar_url NVARCHAR(500) NULL,
        rating INT NOT NULL,
        content NVARCHAR(MAX) NOT NULL,
        status NVARCHAR(20) NOT NULL CONSTRAINT df_product_reviews_status DEFAULT N'PENDING',
        created_at DATETIME2(0) NOT NULL CONSTRAINT df_product_reviews_created_at DEFAULT GETDATE(),
        updated_at DATETIME2(0) NOT NULL CONSTRAINT df_product_reviews_updated_at DEFAULT GETDATE(),
        CONSTRAINT pk_product_reviews PRIMARY KEY (id),
        CONSTRAINT fk_product_reviews_product FOREIGN KEY (product_id) REFERENCES dbo.products(id),
        CONSTRAINT fk_product_reviews_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
        CONSTRAINT ck_product_reviews_rating CHECK (rating BETWEEN 1 AND 5),
        CONSTRAINT ck_product_reviews_status CHECK (status IN (N'PENDING', N'APPROVED', N'REJECTED')),
        CONSTRAINT uq_product_reviews_product_user UNIQUE (product_id, user_id)
    );
END;

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_product_reviews_product_status'
      AND object_id = OBJECT_ID(N'dbo.product_reviews')
)
    CREATE INDEX ix_product_reviews_product_status
        ON dbo.product_reviews(product_id, status, created_at DESC);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = N'ix_product_reviews_status_created'
      AND object_id = OBJECT_ID(N'dbo.product_reviews')
)
    CREATE INDEX ix_product_reviews_status_created
        ON dbo.product_reviews(status, created_at DESC);
