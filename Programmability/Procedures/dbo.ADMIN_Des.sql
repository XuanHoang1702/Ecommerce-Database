SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ADMIN_Des]
    @p_ADMIN_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION
    BEGIN TRY
        DECLARE @p_ADMIN_ID NVARCHAR(10),
                @p_ROLE NVARCHAR(10),
                @p_ROLE_ACTION NVARCHAR(10)

        --
        SELECT  @p_ADMIN_ID = AdminId,
                @p_ROLE_ACTION = RoleAction
        FROM OPENJSON(@p_ADMIN_DATA_JSON)
        WITH(
            AdminId NVARCHAR(10) '$.ADMIN_ID',
            RoleAction NVARCHAR(10) '$.ROLE_ACTION'
        )

        SELECT @p_ROLE = [ROLE]
        FROM [ADMIN]
        WHERE ADMIN_ID = @p_ADMIN_ID

        --
        IF @p_ROLE IN ('CEO', 'CTO', 'CFO')
        BEGIN
			ROLLBACK TRANSACTION;
            select N'Không thể xóa tài khoản này' as RESULT,
					400 as CODE
            
            RETURN;
        END

        DELETE FROM [ADMIN] WHERE [ADMIN_ID] = @p_ADMIN_ID

		if @@ROWCOUNT <> 0
		begin 
			COMMIT TRANSACTION;
			SELECT N'Xóa tài khoản thành công' AS RESULT, 200 AS CODE;
		end
        
        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        select ERROR_MESSAGE() as RESULT,
				ERROR_NUMBER() as CODE
    END CATCH
END
GO