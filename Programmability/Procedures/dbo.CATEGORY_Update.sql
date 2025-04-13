﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CATEGORY_Update] 
	@p_CATEGORY_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE	 @p_ADMIN_ID NVARCHAR(20),
				 @p_CATEGORY_ID INT,
				 @p_CATEGORY_NAME NVARCHAR(50),
				 @p_CATEGORY_IMAGE NVARCHAR(MAX),
				 @p_CATEGORY_STATUS NVARCHAR(10)

		SELECT	 @p_ADMIN_ID = ADMIN_ID,
				 @p_CATEGORY_ID = CategoryId,
				 @p_CATEGORY_NAME = CategoryName,
				 @p_CATEGORY_IMAGE = CategoryImage,
				 @p_CATEGORY_STATUS = CategoryStatus
		FROM OPENJSON(@p_CATEGORY_DATA_JSON)
		WITH(
			ADMIN_ID nvarchar(20) '$.ADMIN_ID',
			CategoryId INT '$.CATEGORY_ID',
			CategoryName NVARCHAR(50) '$.CATEGORY_NAME',
			CategoryImage NVARCHAR(MAX) '$.CATEGORY_IMAGE',
			CategoryStatus NVARCHAR(10) '$.CATEGORY_STATUS'
		)

		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		IF @p_ROLE_RESULT <> 1
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

		IF @p_CATEGORY_ID IS NULL
		BEGIN
            ROLLBACK TRANSACTION
			select N'Dữ liệu trống' as RESULT,
					422 as CODE
			RETURN
		END

		IF NOT EXISTS (SELECT 1 FROM CATEGORIES WHERE CATEGORY_ID = @p_CATEGORY_ID)
		BEGIN
			ROLLBACK TRANSACTION
			select N'Danh mục không tồn tại' as RESULT, 
					409 as CODE
			RETURN
		END

		UPDATE [dbo].CATEGORIES
        SET CATEGORY_NAME = ISNULL(@p_CATEGORY_NAME, CATEGORY_NAME),
            CATEGORY_IMAGE = ISNULL(@p_CATEGORY_IMAGE, CATEGORY_IMAGE),
            CATEGORY_STATUS = ISNULL(@p_CATEGORY_STATUS, CATEGORY_STATUS),
            UPDATE_AT = GETDATE()
        WHERE CATEGORY_ID = @p_CATEGORY_ID;

		IF @@ROWCOUNT <> 0
		BEGIN 
		commit transaction
			SELECT CATEGORY_ID, CATEGORY_IMAGE, CATEGORY_IMAGE, CATEGORY_STATUS, N'Câp nhật danh mục thành công' as RESULT, 200 as CODE
			FROM CATEGORIES
			WHERE CATEGORY_ID = @p_CATEGORY_ID
			
		END

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
		RETURN
	END CATCH
END
GO