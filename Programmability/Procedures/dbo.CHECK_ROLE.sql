SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHECK_ROLE](
	@p_ADMIN_ID nvarchar(10),
	@p_RESULT nvarchar(10) output 

)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF EXISTS (
		SELECT 1 
		FROM [ADMIN]
		WHERE [ADMIN_ID] = @p_ADMIN_ID 
		  AND [ROLE] IN ('CEO', 'CTO', 'CFO')
	)
	BEGIN
		SET @p_RESULT = 'OK';
	END
	ELSE
	BEGIN
		SET @p_RESULT = 'NO';
	END
END
GO