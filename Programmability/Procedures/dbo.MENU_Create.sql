﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MENU_Create] 
	@p_MENU_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE	 @p_ADMIN_ID nvarchar(20),
				 @p_MENU_NAME NVARCHAR(50),
				 @p_MENU_LINK NVARCHAR(50),
				 @p_PARENT_ID INT,
				 @p_MENU_STATUS NVARCHAR(20)

		SELECT  @p_ADMIN_ID = [AdminId],
				@p_MENU_NAME = MenuName,
				@p_MENU_LINK = MenuLink,
				@p_PARENT_ID = ParentId,
				@p_MENU_STATUS = MenuStatus
		FROM OPENJSON(@p_MENU_DATA_JSON)
		WITH(
			[AdminId] nvarchar(20) '$.ADMIN_ID',
			MenuName NVARCHAR(20) '$.MENU_NAME',
			MenuLink NVARCHAR(20) '$.MENU_LINK',
			ParentId INT '$.PARENT_ID',
			MenuStatus NVARCHAR(10) '$.MENU_STATUS'
		)

		declare @p_ROLE_RESULT nvarchar(10)
		exec [dbo].[CHECK_ROLE] @p_ADMIN_ID = @p_ADMIN_ID, @p_RESULT = @p_ROLE_RESULT output

		if @p_ROLE_RESULT != 'OK'
		begin
			rollback transaction
			select N'Không đủ quyền' as RESULT,
					403 as CODE
			return
		end

		IF EXISTS (SELECT 1 FROM MENU WHERE MENU_NAME = @p_MENU_NAME OR MENU_LINK = @p_MENU_LINK)
		BEGIN
			ROLLBACK TRANSACTION
			select N'Menu đã tồn tại' as RESULT,
					409 as CODE
			RETURN 
		END

	INSERT INTO MENU (MENU_NAME, MENU_LINK, PARENT_ID, MENU_STATUS, CREATED_AT, UPDATED_AT)
	VALUES (@p_MENU_NAME, @p_MENU_LINK, @p_PARENT_ID, @p_MENU_STATUS, GETDATE(), GETDATE())

	IF @@ROWCOUNT = 1
	BEGIN
		COMMIT TRANSACTION
		SELECT  @p_MENU_NAME AS MENU_NAME,
				@p_MENU_LINK AS MENU_LINK,
				@p_PARENT_ID AS PARENT_ID,
				@p_MENU_STATUS AS MENU_STATUS,
				'Tạo menu thành công' as RESULT,
				201 as CODE
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