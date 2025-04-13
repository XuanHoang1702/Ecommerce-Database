SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CATEGORY_Delete] 
	@p_CATEGORY_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE	 @p_ADMIN_ID NVARCHAR(20),
				 @p_CATEGORY_ID INT

		SELECT	 @p_ADMIN_ID = ADMIN_ID,
				 @p_CATEGORY_ID = CategoryId
		FROM OPENJSON(@p_CATEGORY_DATA_JSON)
		WITH(
			ADMIN_ID NVARCHAR(20) '$.ADMIN_ID',
			CategoryId INT '$.CATEGORY_ID'
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

		IF EXISTS (SELECT 1 FROM PRODUCTS WHERE CATEGORY_ID = @p_CATEGORY_ID)
		BEGIN
			ROLLBACK TRANSACTION
			select N'Tồn tại sản phẩm thuộc thương hiệu' as RESULT,
					409 as CODE
			RETURN
		END

		DELETE FROM CATEGORIES WHERE CATEGORY_ID = @p_CATEGORY_ID

		IF @@ROWCOUNT <> 0
		BEGIN
			COMMIT TRANSACTION
			select N'Xóa thương hiệu thành công' as RESULT,
					200 as CODE
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION 
		select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
	END CATCH
END
GO