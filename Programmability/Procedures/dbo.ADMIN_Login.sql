﻿SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ADMIN_Login] 
	@p_ADMIN_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE  @p_ADMIN_ID NVARCHAR(10),
				 @p_ADMIN_NAME NVARCHAR(50),
				 @p_ADMIN_EMAIL NVARCHAR(50),
				 @p_ADMIN_PHONE NVARCHAR(20),
				 @p_ADMIN_PASSWORD NVARCHAR(255),
				 @p_ADMIN_HASH_PASSWORD NVARCHAR(255),
				 @p_ROLE NVARCHAR(10)

		SELECT  @p_ADMIN_EMAIL = AdminEmail,
				@p_ADMIN_PASSWORD = AdminPassword
		FROM OPENJSON(@p_ADMIN_DATA_JSON)
		WITH(
			AdminEmail NVARCHAR(50) '$.ADMIN_EMAIL',
			AdminPassword NVARCHAR(255) '$.ADMIN_PASSWORD'
		)

		IF EXISTS (SELECT 1 FROM [dbo].[ADMIN] WHERE ADMIN_EMAIL = @p_ADMIN_EMAIL)
		BEGIN
			SELECT  
				@p_ADMIN_ID = ADMIN_ID,
				@p_ADMIN_NAME = ADMIN_NAME,
				@p_ADMIN_PHONE = ADMIN_PHONE,
				@p_ADMIN_HASH_PASSWORD = ADMIN_PASSWORD,
				@p_ROLE = [ROLE]
		FROM [ADMIN]
		WHERE ADMIN_EMAIL = @p_ADMIN_EMAIL

		IF @p_ADMIN_HASH_PASSWORD <> @p_ADMIN_PASSWORD
		BEGIN
			rollback transaction
			select N'Mật khẩu không chính xác' as RESULT,
					401 as CODE
			RETURN;
		END

		SELECT  @p_ADMIN_ID AS ADMIN_ID,
				@p_ADMIN_NAME AS ADMIN_NAME,
				@p_ADMIN_EMAIL AS ADMIN_EMAIL,
				@p_ADMIN_PHONE AS ADMIN_PHONE,
				@p_ROLE AS [ROLE]
		END
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;
		select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
	END CATCH
END
GO