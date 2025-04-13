SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[BRAND_Update]
    @p_BRAND_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @p_ADMIN_ID NVARCHAR(20),
				@p_BRAND_ID INT,
                @p_BRAND_NAME NVARCHAR(50),
                @p_BRAND_IMAGE NVARCHAR(MAX),
                @p_BRAND_STATUS NVARCHAR(10);

        SELECT  @p_ADMIN_ID = ADMIN_ID,
				@p_BRAND_ID = BrandId,
                @p_BRAND_NAME = BrandName,
                @p_BRAND_IMAGE = BrandImage,
                @p_BRAND_STATUS = BrandStatus
        FROM OPENJSON(@p_BRAND_DATA_JSON)
        WITH (
			ADMIN_ID nvarchar(20) '$.ADMIN_ID',
            BrandId INT '$.BRAND_ID',
            BrandName NVARCHAR(50) '$.BRAND_NAME',
            BrandImage NVARCHAR(MAX) '$.BRAND_IMAGE',
            BrandStatus NVARCHAR(10) '$.BRAND_STATUS'
        );

        IF @p_BRAND_ID IS NULL
        BEGIN
            ROLLBACK TRANSACTION
			select N'Dữ liệu trống' as RESULT,
					422 as CODE
			RETURN
        END

        IF NOT EXISTS (SELECT 1 FROM [dbo].BRANDS WHERE BRAND_ID = @p_BRAND_ID)
        BEGIN
            ROLLBACK TRANSACTION
			select N'Thương hiệu không tồn tại' as RESULT, 
					404 as CODE
			RETURN;
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

        UPDATE [dbo].BRANDS
        SET BRAND_NAME = ISNULL(@p_BRAND_NAME, BRAND_NAME),
            BRAND_IMAGE = ISNULL(@p_BRAND_IMAGE, BRAND_IMAGE),
            BRAND_STATUS = ISNULL(@p_BRAND_STATUS, BRAND_STATUS),
            UPDATE_AT = GETDATE()
        WHERE BRAND_ID = @p_BRAND_ID;

        IF @@ROWCOUNT = 1
        BEGIN            
			COMMIT TRANSACTION
            SELECT BRAND_ID, BRAND_NAME, BRAND_IMAGE, BRAND_STATUS, UPDATE_AT, N'Câp nhật thương hiệu thành công' as RESULT, 200 as CODE
            FROM [dbo].BRANDS
            WHERE BRAND_ID = @p_BRAND_ID;
        END
    END TRY
    BEGIN CATCH
        rollback transaction
		select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
    END CATCH
END
GO