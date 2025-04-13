SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRODUCT_Delete]
    @p_PRODUCT_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION
    BEGIN TRY
        DECLARE @p_ADMIN_ID NVARCHAR(20),
                @p_PRODUCT_ID INT

        SELECT  @p_ADMIN_ID = ADMIN_ID,
                @p_PRODUCT_ID = ProductId
        FROM OPENJSON(@p_PRODUCT_DATA_JSON)
        WITH(
            ADMIN_ID NVARCHAR(20) '$.ADMIN_ID',
            ProductId INT '$.PRODUCT_ID'
        )

        IF @p_PRODUCT_ID IS NULL
        BEGIN
			ROLLBACK TRANSACTION
            select N'Mã sản phẩm bị trống' as RESULT,
					404 as CODE
            RETURN
        END

        declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		IF @p_ROLE_RESULT <> 1
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

        IF EXISTS (
            SELECT 1 
            FROM PRODUCTS P
            INNER JOIN ORDER_DETAILS O_D ON P.PRODUCT_ID = O_D.PRODUCT_ID 
            INNER JOIN ORDERS O ON O.ID = O_D.ORDER_ID
            WHERE P.PRODUCT_ID = @p_PRODUCT_ID 
            AND O.ORDER_STATUS = 'PENDING'
        )
        BEGIN
			ROLLBACK TRANSACTION
            select N'Sản phẩm hiện đang có trong một đơn hàng' as RESULT,
					409 as CODE
            
            RETURN
        END

        DELETE FROM PRODUCTS 
        WHERE PRODUCT_ID = @p_PRODUCT_ID

        IF @@ROWCOUNT <> 0
        BEGIN 
			ROLLBACK TRANSACTION
            select N'Xóa sản phẩm thành công'as RESULT,
					200 as CODE
            RETURN
        END

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
		rollback transaction
		select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
    END CATCH
END
GO