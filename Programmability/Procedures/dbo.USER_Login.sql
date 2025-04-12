SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USER_Login]
    @p_USER_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE  @p_USER_ID NVARCHAR(255),
                 @p_USER_FIRST_NAME NVARCHAR(255),
				 @p_USER_LAST_NAME NVARCHAR(255),
				 @p_USER_GENDER NVARCHAR(255),
                 @p_USER_EMAIL NVARCHAR(255),
                 @p_USER_PHONE NVARCHAR(18),
                 @p_USER_PASSWORD NVARCHAR(255),
                 @p_USER_HASHED_PASSWORD NVARCHAR(255)

        -- Parse JSON input
        SELECT  @p_USER_EMAIL = USER_EMAIL,
                @p_USER_PHONE = USER_PHONE,
                @p_USER_PASSWORD = USER_PASSWORD
        FROM OPENJSON(@p_USER_DATA_JSON)
        WITH (
            USER_EMAIL NVARCHAR(255) '$.USER_EMAIL',
            USER_PHONE NVARCHAR(255) '$.USER_PHONE',
            USER_PASSWORD NVARCHAR(255) '$.USER_PASSWORD'
        )

        -- Validate and get user data
        IF @p_USER_EMAIL IS NOT NULL
        BEGIN
            SELECT  @p_USER_ID = [USER_ID],
                    @p_USER_FIRST_NAME = [USER_FIRST_NAME],
					@p_USER_LAST_NAME = USER_LAST_NAME,
					@p_USER_GENDER = USER_GENDER,
                    @p_USER_PHONE = [USER_PHONE],
                    @p_USER_HASHED_PASSWORD = [USER_PASSWORD]
            FROM [dbo].[USERS]
            WHERE [USER_EMAIL] = @p_USER_EMAIL
        END
        ELSE IF @p_USER_PHONE IS NOT NULL
        BEGIN 
            SELECT  @p_USER_ID = [USER_ID],
			        @p_USER_FIRST_NAME = [USER_FIRST_NAME],
					@p_USER_LAST_NAME = USER_LAST_NAME,
					@p_USER_GENDER = USER_GENDER,
                    @p_USER_EMAIL = [USER_EMAIL],
					@p_USER_GENDER = USER_GENDER,
                    @p_USER_HASHED_PASSWORD = [USER_PASSWORD]
            FROM [dbo].[USERS]
            WHERE [USER_PHONE] = @p_USER_PHONE
        END

        -- Kiểm tra user có tồn tại không
        IF @p_USER_ID IS NULL
        BEGIN
            RAISERROR('Tài khoản không tồn tại', 16, 1);
            RETURN;
        END

        -- Kiểm tra mật khẩu (Cần hash mật khẩu trước khi so sánh nếu đang lưu dạng hash)
        IF @p_USER_HASHED_PASSWORD <> @p_USER_PASSWORD
        BEGIN
            RAISERROR('Mật khẩu không chính xác', 16, 2);
            RETURN;
        END

        -- Trả về dữ liệu người dùng
        SELECT  @p_USER_ID AS [USER_ID],
                @p_USER_FIRST_NAME AS [USER_FIRST_NAME],
				@p_USER_LAST_NAME AS [USER_LAST_NAME],
				@p_USER_GENDER  AS USER_GENDER,
                @p_USER_EMAIL AS [USER_EMAIL],
                @p_USER_PHONE AS [USER_PHONE];

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
         ROLLBACK TRANSACTION
		 PRINT ERROR_MESSAGE()
    END CATCH
END
GO