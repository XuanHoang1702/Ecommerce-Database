SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRODUCT_Fillter] 
    @p_PRODUCT_DATA_JSON NVARCHAR(MAX),
    @p_TOTAL_RECORD INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @p_BRAND_ID INT, 
            @p_CATEGORY_ID INT,
            @p_PRODUCT_PRICE_MAX DECIMAL(10, 2),
            @p_PRODUCT_PRICE_MIN DECIMAL(10, 2),
            @p_PAGE_NUMBER INT,
            @p_PAGE_SIZE INT

    BEGIN TRY
        SELECT  @p_BRAND_ID = BrandId,
                @p_CATEGORY_ID = CategoryId,
                @p_PRODUCT_PRICE_MAX = ProductPriceMax,
                @p_PRODUCT_PRICE_MIN = ProductPriceMin,
                @p_PAGE_NUMBER = PageNumber,
                @p_PAGE_SIZE = PageSize
        FROM OPENJSON(@p_PRODUCT_DATA_JSON)
        WITH(
            BrandId INT '$.BRAND_ID',
            CategoryId INT '$.CATEGORY_ID',
            ProductPriceMin DECIMAL(10, 2) '$.PRICE_MIN',
            ProductPriceMax DECIMAL(10, 2) '$.PRICE_MAX',
            PageNumber INT '$.PAGE_NUMBER',
            PageSize INT '$.PAGE_SIZE'
        )

        SET @p_BRAND_ID = NULLIF(@p_BRAND_ID, 0)
        SET @p_CATEGORY_ID = NULLIF(@p_CATEGORY_ID, 0)
        SET @p_PRODUCT_PRICE_MIN = ISNULL(@p_PRODUCT_PRICE_MIN, 0)
        SET @p_PRODUCT_PRICE_MAX = ISNULL(@p_PRODUCT_PRICE_MAX, 99999999.99)
        SET @p_PAGE_NUMBER = ISNULL(@p_PAGE_NUMBER, 1)
        SET @p_PAGE_SIZE = ISNULL(@p_PAGE_SIZE, 10)

        IF @p_PAGE_NUMBER < 1 SET @p_PAGE_NUMBER = 1
        IF @p_PAGE_SIZE < 1 SET @p_PAGE_SIZE = 10

        IF @p_BRAND_ID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM BRANDS WHERE BRAND_ID = @p_BRAND_ID)
        BEGIN
            RAISERROR('Brand ID does not exist', 16, 1)
            RETURN
        END

        IF @p_CATEGORY_ID IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CATEGORIES WHERE CATEGORY_ID = @p_CATEGORY_ID)
        BEGIN
            RAISERROR('Category ID does not exist', 16, 1)
            RETURN
        END


        SELECT @p_TOTAL_RECORD = COUNT(*) 
        FROM PRODUCTS P
        WHERE 
            (@p_BRAND_ID IS NULL OR P.BRAND_ID = @p_BRAND_ID)
            AND (@p_CATEGORY_ID IS NULL OR P.CATEGORY_ID = @p_CATEGORY_ID)
            AND (P.PRODUCT_PRICE BETWEEN @p_PRODUCT_PRICE_MIN AND @p_PRODUCT_PRICE_MAX)

        SELECT 
            P.PRODUCT_ID,
            P.PRODUCT_NAME,
			P_I.IMAGE_NAME,
            P.PRODUCT_PRICE,
            P.PRODUCT_STATUS,
            B.BRAND_NAME,
            C.CATEGORY_NAME
        FROM PRODUCTS P
        LEFT JOIN BRANDS B ON P.BRAND_ID = B.BRAND_ID
        LEFT JOIN CATEGORIES C ON P.CATEGORY_ID = C.CATEGORY_ID
		RIGHT JOIN PRODUCT_IMAGE P_I ON P_I.PRODUCT_ID = P.PRODUCT_ID
        WHERE 
            (@p_BRAND_ID IS NULL OR P.BRAND_ID = @p_BRAND_ID)
            AND (@p_CATEGORY_ID IS NULL OR P.CATEGORY_ID = @p_CATEGORY_ID)
            AND (P.PRODUCT_PRICE BETWEEN @p_PRODUCT_PRICE_MIN AND @p_PRODUCT_PRICE_MAX)
			AND P_I.PRODUCT_ID = P.PRODUCT_ID
        ORDER BY P.PRODUCT_ID
        OFFSET (@p_PAGE_NUMBER - 1) * @p_PAGE_SIZE ROWS
        FETCH NEXT @p_PAGE_SIZE ROWS ONLY
    END TRY
    BEGIN CATCH
        -- Handle errors
        SET @p_TOTAL_RECORD = 0
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE()
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY()
        DECLARE @ErrorState INT = ERROR_STATE()

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState)
        RETURN
    END CATCH
END
GO