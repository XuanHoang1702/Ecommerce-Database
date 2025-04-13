SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DISCOUNT_Create]
    @p_DISCOUNT_DATA_JSON nvarchar(max)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY
        DECLARE @p_ADMIN_ID nvarchar(20),
                @p_PRODUCT_ID int,
                @p_DISCOUNT_PERCENT decimal(10, 2),
                @p_START_DT datetime,
                @p_END_DT datetime,
                @p_DISCOUNT_STATUS nvarchar(10);

        SELECT @p_ADMIN_ID = ADMIN_ID,
               @p_PRODUCT_ID = ProductId,
               @p_DISCOUNT_PERCENT = DiscountPercent,
               @p_START_DT = StartDate,
               @p_END_DT = EndDate
        FROM OPENJSON(@p_DISCOUNT_DATA_JSON)
        WITH (
            ADMIN_ID nvarchar(20) '$.ADMIN_ID',
            ProductId int '$.PRODUCT_ID',
            DiscountPercent decimal(10, 2) '$.DISCOUNT_PERCENT',
            StartDate datetime '$.START_DT',
            EndDate datetime '$.END_DT'
        );

        DECLARE @p_ROLE_RESULT int;
        EXEC [dbo].[CHECK_ROLE] @p_ADMIN = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT OUTPUT;

        IF @p_ROLE_RESULT <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT N'Không đủ quyền' AS RESULT, 403 AS CODE;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM PRODUCTS WHERE PRODUCT_ID = @p_PRODUCT_ID)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT N'Sản phẩm không tồn tại' AS RESULT, 404 AS CODE;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM DISCOUNT WHERE PRODUCT_ID = @p_PRODUCT_ID AND END_DT > @p_START_DT)
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT N'Sản phẩm đang được giảm giá' AS RESULT, 409 AS CODE;
            RETURN;
        END

        SET @p_DISCOUNT_STATUS = 'ACTIVE'; -- Gán giá trị mặc định
        INSERT INTO DISCOUNT (PRODUCT_ID, DISCOUNT_PERCENT, START_DT, END_DT, DISCOUNT_STATUS)
        VALUES (@p_PRODUCT_ID, @p_DISCOUNT_PERCENT, @p_START_DT, @p_END_DT, @p_DISCOUNT_STATUS);

        IF @@ROWCOUNT = 1
        BEGIN
            COMMIT TRANSACTION;
            SELECT @p_PRODUCT_ID AS PRODUCT_ID,
                   @p_DISCOUNT_PERCENT AS DISCOUNT_PERCENT,
                   @p_START_DT AS START_DT,
                   @p_END_DT AS END_DT,
                   @p_DISCOUNT_STATUS AS DISCOUNT_STATUS,
                   N'Tạo giảm giá thành công' AS RESULT,
                   201 AS CODE;
        END
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_MESSAGE() AS RESULT, ERROR_NUMBER() AS CODE;
        RETURN;
    END CATCH
END
GO