SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRODUCT_Update]
    @p_PRODUCT_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON để tránh trả về số dòng bị ảnh hưởng
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION
    BEGIN TRY
        DECLARE @p_ADMIN_ID NVARCHAR(20),
                @p_PRODUCT_ID INT,
                @p_PRODUCT_NAME NVARCHAR(100),
                @p_PRODUCT_PRICE DECIMAL(10, 2),
                @p_PRODUCT_DETAIL NVARCHAR(MAX),
                @p_PRODUCT_DESCRIPTION NVARCHAR(MAX),
                @p_BRAND_ID INT,
                @p_CATEGORY_ID INT,
                @p_PRODUCT_STATUS NVARCHAR(10)

        SELECT  @p_ADMIN_ID = AdminId,
                @p_PRODUCT_ID = ProductId,
                @p_PRODUCT_NAME = ProductName,
                @p_PRODUCT_PRICE = ProductPrice,
                @p_PRODUCT_DETAIL = ProductDetail,
                @p_PRODUCT_DESCRIPTION = ProductDescription,
                @p_BRAND_ID = BrandId,
                @p_CATEGORY_ID = CategoryId,
                @p_PRODUCT_STATUS = ProductStatus
        FROM OPENJSON(@p_PRODUCT_DATA_JSON)
        WITH(
            AdminId NVARCHAR(20) '$.ADMIN_ID',
            ProductId INT '$.PRODUCT_ID',
            ProductName NVARCHAR(100) '$.PRODUCT_NAME',
            ProductPrice DECIMAL(10, 2) '$.PRODUCT_PRICE',
            ProductDetail NVARCHAR(MAX) '$.PRODUCT_DETAIL',
            ProductDescription NVARCHAR(MAX) '$.PRODUCT_DESCRIPTION',
            BrandId INT '$.BRAND_ID',
            CategoryId INT '$.CATEGORY_ID',
            ProductStatus NVARCHAR(10) '$.PRODUCT_STATUS'
        )

        IF NOT EXISTS (SELECT 1 FROM PRODUCTS WHERE PRODUCT_ID = @p_PRODUCT_ID)
        BEGIN
            ROLLBACK TRANSACTION
            select 'Không tìm thấy sản phẩm' as RESULT,
					404 as CODE
            RETURN
        END

		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		if @p_ROLE_RESULT != 'OK'
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

        UPDATE PRODUCTS
        SET PRODUCT_NAME = ISNULL(@p_PRODUCT_NAME, PRODUCT_NAME),
            PRODUCT_PRICE = ISNULL(@p_PRODUCT_PRICE, PRODUCT_PRICE),
            PRODUCT_DETAIL = ISNULL(@p_PRODUCT_DETAIL, PRODUCT_DETAIL),
            PRODUCT_DESCRIPTION = ISNULL(@p_PRODUCT_DESCRIPTION, PRODUCT_DESCRIPTION),
            BRAND_ID = ISNULL(@p_BRAND_ID, BRAND_ID),
            CATEGORY_ID = ISNULL(@p_CATEGORY_ID, CATEGORY_ID),
            PRODUCT_STATUS = ISNULL(@p_PRODUCT_STATUS, PRODUCT_STATUS),
            UPDATED_AT = GETDATE()
        WHERE PRODUCT_ID = @p_PRODUCT_ID

        IF @@ROWCOUNT <> 0
		BEGIN 
			COMMIT TRANSACTION
			SELECT *, 'Cập nhật sản phẩm thành công' as RESULT, 200 as CODE
			FROM PRODUCTS
			WHERE PRODUCT_ID = @p_PRODUCT_ID
		END
    END TRY
    BEGIN CATCH
        rollback transaction
		select	 ERROR_MESSAGE() as RESULT,
				 ERROR_NUMBER() as CODE
    END CATCH
END
GO