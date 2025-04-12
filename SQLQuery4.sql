-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE BRAND_Delete
	@p_BRAND_DATA_JSON NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE  @p_ADMIN_ROLE NVARCHAR(255),
				 @p_BRAND_ID INT

		SELECT  @p_ADMIN_ROLE = AdminRole,
				@p_BRAND_ID = BrandId
		FROM OPENJSON(@p_BRAND_DATA_JSON)
		WITH(
			AdminId NVARCHAR(255) '$.ADMIN_ROLE',
			BrandId INT '$.BRAND_ID'
		)

		IF @p_ADMIN_ROLE NOT IN('CEO', 'CTO', 'CFO')
		BEGIN 
			ROLLBACK TRANSACTION
			RETURN
		END

		IF @p_BRAND_ID EXISTS (SELECT BRAND_ID FROM PRODUCTS WHERE BRAND_ID = @p_BRAND_ID)
		BEGIN
			ROLLBACK TRANSACTION
			RETURN
		END

		DELETE FROM BRAND WHERE BRAND_ID = @p_BRAND_ID

		IF @@ROWCOUNT = 1
		BEGIN
			SELECT 1 AS RESULT
			COMMIT TRANSACTION
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		PRINT ERROR_MESSAGE()
	END CATCH
END
GO
